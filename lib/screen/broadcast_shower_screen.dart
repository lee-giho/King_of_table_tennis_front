import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:king_of_table_tennis/api/broadcast_api.dart';
import 'package:king_of_table_tennis/model/broadcastRoomInfo.dart';
import 'package:king_of_table_tennis/model/update_score.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/widget/scoreBoard.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class BroadcastShowerScreen extends StatefulWidget {
  final BroadcastRoomInfo broadcastRoomInfo;
  const BroadcastShowerScreen({
    super.key,
    required this.broadcastRoomInfo
  });

  @override
  State<BroadcastShowerScreen> createState() => _BroadcastShowerScreenState();
}

class _BroadcastShowerScreenState extends State<BroadcastShowerScreen> {
  final _localRenderer =RTCVideoRenderer();
  MediaStream? _localStream;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, List<RTCIceCandidate>> _candidateQueue = {};
  late StompClient stompClient;

  bool frontCamera = false;
  bool micEnabled = true;
  bool rendererInitialized = false;

    @override
  void initState() {
    super.initState();

    // 가로모드 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    _permission();
    _initRenderer();
  }

  @override
  void dispose() {
    // 세로모드 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    _localRenderer.srcObject = null;
    _localRenderer.dispose();
    _localStream?.dispose();
    for (var pc in _peerConnections.values) {
      pc.close();
    }
    stompClient.deactivate();

    super.dispose();
  }

  Future<void> _permission() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _initRenderer() async {
    await _localRenderer.initialize();
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': frontCamera ? 'user' : 'environment'}
    });
    _localRenderer.srcObject = _localStream;
    if (mounted) {
      setState(() {
        rendererInitialized = true;
      });
    }
    _connectSocket();
  }

  void _connectSocket() {
    final wsAddress = dotenv.get("WS_ADDRESS");

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/signaling",
        onConnect: (frame) => _onConnect(stompClient),
        onWebSocketError: (dynamic err) => print("WebSocket error: $err")
      )
    );
    stompClient.activate();
  }

  void _onConnect(StompClient client) {
    final roomId = widget.broadcastRoomInfo.gameInfoId;

    client.subscribe(
      destination: "/topic/broadcast/peer/offer/$roomId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        final offerSdp = data['sdp'];
        final viewerId = data['viewerId'];

        final pc = await _createPeerConnection(viewerId, roomId);
        _peerConnections[viewerId] = pc;

        await pc.setRemoteDescription(RTCSessionDescription(offerSdp, 'offer'));
        _localStream?.getTracks().forEach((track) => pc.addTrack(track, _localStream!));

        final answer = await pc.createAnswer();
        await pc.setLocalDescription(answer);

        client.send(
          destination: "/app/broadcast/peer/answer/$roomId/$viewerId",
          body: jsonEncode({'sdp': answer.sdp})
        );

        if (_candidateQueue.containsKey(viewerId)) {
          for (var candidate in _candidateQueue[viewerId]!) {
            pc.addCandidate(candidate);
          }
          _candidateQueue.remove(viewerId);
        }
      }
    );

    client.subscribe(
      destination: "/topic/broadcast/peer/candidate/$roomId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        final viewerId = data['viewerId'];

        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex']
        );

        final pc = _peerConnections[viewerId];
        if (pc != null && pc.getRemoteDescription != null) {
          await pc.addCandidate(candidate);
        } else {
          _candidateQueue.putIfAbsent(viewerId, () => []).add(candidate);
        }
      }
    );

    client.subscribe(
      destination: "/topic/broadcast/score/$roomId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        
        UpdateScore updateScore = UpdateScore.fromJson(data);
      }
    );
  }

  Future<RTCPeerConnection> _createPeerConnection(String viewerId, String roomId) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };
    final pc = await createPeerConnection(config);

    pc.onIceCandidate = (candidate) {
      stompClient.send(
        destination: "/app/broadcast/peer/candidate/viewer/$roomId",
        body: jsonEncode({
          'viewerId': viewerId,
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex
        })
      );
    };

    return pc;
  }

  Future<void> _switchCamera() async {
    final videoTrack = _localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
      setState(() {
        frontCamera = !frontCamera;
      });
    }
  }

  void _toggleMic() {
    final audioTrack = _localStream?.getAudioTracks().first;
    if (audioTrack != null) {
      final enabled = audioTrack.enabled;
      audioTrack.enabled = !enabled;
      setState(() {
        micEnabled = !enabled;
      });
    }
  }

  void _endBroadcast() {
    for (final viewer in _peerConnections.keys) {
      stompClient.send(
        destination: "/app/broadcast/end/${widget.broadcastRoomInfo.gameInfoId}",
        headers: {},
        body: 'end'
      );
    }
    Navigator.pop(context);
  }

  Future<void> _deleteBroadcastRoom() async {
    final response = await apiRequest(() => deleteBroadcastRoom(widget.broadcastRoomInfo.gameInfoId), context);
    
    if (response.statusCode == 200) {
        log("delete broadcast room: ${response.body}");

        _endBroadcast();
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("방송 삭제를 실패했습니다."))
        );
      }
  }

  void updateScore(UpdateScore updateScore) {
    stompClient.send(
      destination: "/app//broadcast/score/${widget.broadcastRoomInfo.gameInfoId}",
      body: json.encode(updateScore.toJson())
    );
  }

  void changeSeats() {
    widget.broadcastRoomInfo.leftIsDefender = !widget.broadcastRoomInfo.leftIsDefender;
    print("leftIsDefender: $widget.broadcastRoomInfo.leftIsDefender");
    stompClient.send(
      destination: "/app/broadcast/leftIsDefender/${widget.broadcastRoomInfo.gameInfoId}",
      body: jsonEncode({
        'leftIsDefender': widget.broadcastRoomInfo.leftIsDefender
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          rendererInitialized
            ? RTCVideoView(
              _localRenderer,
              mirror: frontCamera,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
            : const Center(
                child: CircularProgressIndicator()
              ),
          Positioned(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        print("왼쪽 +1!!");
                        setState(() {
                          if (widget.broadcastRoomInfo.leftIsDefender) {
                            widget.broadcastRoomInfo.defender.incrementScore();
                            updateScore(UpdateScore(side: "defender", newScore: widget.broadcastRoomInfo.defender.score));
                          } else {
                            widget.broadcastRoomInfo.challenger.incrementScore();
                            updateScore(UpdateScore(side: "challenger", newScore: widget.broadcastRoomInfo.challenger.score));
                          }
                        });
                        print(widget.broadcastRoomInfo.defender.score);
                        print(widget.broadcastRoomInfo.challenger.score);
                      },
                      onLongPress: () {
                        print("왼쪽 -1!!");
                        setState(() {
                          if (widget.broadcastRoomInfo.leftIsDefender) {
                            widget.broadcastRoomInfo.defender.decrementScore();
                            updateScore(UpdateScore(side: "defender", newScore: widget.broadcastRoomInfo.defender.score));
                          } else {
                            widget.broadcastRoomInfo.challenger.decrementScore();
                            updateScore(UpdateScore(side: "challenger", newScore: widget.broadcastRoomInfo.challenger.score));
                          }
                        });
                        print(widget.broadcastRoomInfo.defender.score);
                        print(widget.broadcastRoomInfo.challenger.score);
                      },
                      child: Container(

                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        print("오른쪽 +1!!");
                        setState(() {
                          if (widget.broadcastRoomInfo.leftIsDefender) {
                            widget.broadcastRoomInfo.challenger.incrementScore();
                            updateScore(UpdateScore(side: "challenger", newScore: widget.broadcastRoomInfo.challenger.score));
                          } else {
                            widget.broadcastRoomInfo.defender.incrementScore();
                            updateScore(UpdateScore(side: "defender", newScore: widget.broadcastRoomInfo.defender.score));
                          }
                        });
                        print(widget.broadcastRoomInfo.defender.score);
                        print(widget.broadcastRoomInfo.challenger.score);
                      },
                      onLongPress: () {
                        print("오른쪽 -1!!");
                        setState(() {
                          if (widget.broadcastRoomInfo.leftIsDefender) {
                            widget.broadcastRoomInfo.challenger.decrementScore();
                            updateScore(UpdateScore(side: "challenger", newScore: widget.broadcastRoomInfo.challenger.score));
                          } else {
                            widget.broadcastRoomInfo.defender.decrementScore();
                            updateScore(UpdateScore(side: "defender", newScore: widget.broadcastRoomInfo.defender.score));
                          }
                        });
                        print(widget.broadcastRoomInfo.defender.score);
                        print(widget.broadcastRoomInfo.challenger.score);
                      },
                      child: Container(

                      ),
                    ),
                  ),
                ],
              ),
            )
          ),
          Positioned(
            top: 15,
            left: 15,
            child: IconButton(
              onPressed: () {
                _deleteBroadcastRoom();
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                size: 30,
              )
            )
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScoreBoard(
              defender: widget.broadcastRoomInfo.defender,
              challenger: widget.broadcastRoomInfo.challenger,
              leftIsDefender: widget.broadcastRoomInfo.leftIsDefender,
              onChangeSeats: changeSeats,
            )
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    micEnabled 
                      ? Icons.mic
                      : Icons.mic_off,
                    size: 40,
                  ),
                  onPressed: _toggleMic,
                ),
                IconButton(
                  icon: Icon(
                    Icons.cameraswitch,
                    size: 40,
                  ),
                  onPressed: _switchCamera,
                )
              ]
            ),
          )
        ]
      )
    );
  }
}