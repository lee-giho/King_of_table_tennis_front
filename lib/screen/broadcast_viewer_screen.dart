import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:king_of_table_tennis/model/broadcastRoomInfo.dart';
import 'package:king_of_table_tennis/model/update_score.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';
import 'package:king_of_table_tennis/widget/scoreBoard.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class BroadcastViewerScreen extends StatefulWidget {
  final BroadcastRoomInfo broadcastRoomInfo;
  const BroadcastViewerScreen({
    super.key,
    required this.broadcastRoomInfo
  });

  @override
  State<BroadcastViewerScreen> createState() => _BroadcastViewerScreenState();
}

class _BroadcastViewerScreenState extends State<BroadcastViewerScreen> {

  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  final List<RTCIceCandidate> _candidateQueue = [];
  late StompClient stompClient;
  String? viewerId;
  final String socketUrlSockJS = dotenv.get("WS_ADDRESS");

  @override
  void initState() {
    super.initState();

    // 가로모드 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    _initViewer();
  }

  Future<void> _initViewer() async {
    viewerId = await SecureStorage.getId();
    await _remoteRenderer.initialize();
    _connectSocket();
  }

  void _connectSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: "$socketUrlSockJS/signaling",
        onConnect: (frame) => _onConnect(stompClient),
        onWebSocketError: (dynamic err) => print("WebSocket error: $err")
      )
    );
    stompClient.activate();
  }

  void _onConnect(StompClient client) async {
    final roomId = widget.broadcastRoomInfo.gameInfoId;
    _peerConnection = await _createPeerConnection(roomId);

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    client.send(
      destination: "/app/broadcast/peer/offer/$roomId",
      body: jsonEncode({
        'sdp': offer.sdp,
        'viewerId': viewerId
      })
    );

    client.subscribe(
      destination: "/topic/broadcast/peer/answer/$roomId/$viewerId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        final sdp = data['sdp'];

        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(sdp, 'answer')
        );

        for (var c in _candidateQueue) {
          await _peerConnection!.addCandidate(c);
        }
        _candidateQueue.clear();
      }
    );

    client.subscribe(
      destination: "/topic/broadcast/peer/candidate/viewer/$roomId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex']
        );

        if (_peerConnection?.getRemoteDescription() != null) {
          await _peerConnection!.addCandidate(candidate);
        } else {
          _candidateQueue.add(candidate);
        }
      }
    );

    client.subscribe(
      destination: "/topic/broadcast/end/$roomId",
      callback: (_) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    );

    client.subscribe(
      destination: "/topic/broadcast/score/$roomId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        
        UpdateScore updateScore = UpdateScore.fromJson(data);

        setState(() {
          if (updateScore.side == "defender") {
            widget.broadcastRoomInfo.defender.score = updateScore.newScore;
          } else {
            widget.broadcastRoomInfo.challenger.score = updateScore.newScore;
          }
        });
      }
    );

    client.subscribe(
      destination: "/topic/broadcast/leftIsDefender/$roomId",
      callback: (frame) {
        final data = jsonDecode(frame.body!);
        bool leftIsDefender = data["leftIsDefender"];
        setState(() {
          widget.broadcastRoomInfo.leftIsDefender = leftIsDefender;
        });
        print("leftIsDefender: ${widget.broadcastRoomInfo.leftIsDefender}");
      }
    );
  }

  Future<RTCPeerConnection> _createPeerConnection(String roomId) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };
    final pc = await createPeerConnection(config);
    pc.onTrack = (event) {
      if (event.track.kind == 'video') {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    pc.onIceCandidate = (candidate) {
      stompClient.send(
        destination: "/app/broadcast/peer/candidate/$roomId",
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

  @override
  void dispose() {
    _remoteRenderer.srcObject = null;
    _remoteRenderer.dispose();
    _peerConnection?.close();
    stompClient.deactivate();

    // 세로모드 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RTCVideoView(
            _remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            top: 15,
            left: 15,
            child: IconButton(
              onPressed: () {
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
              onChangeSeats: null,
            )
          ),
        ],
      ),
    );
  }
}