import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/game_detail_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';

class TableTennisGameInfoDetailScreen extends StatefulWidget {
  final String gameInfoId;
  const TableTennisGameInfoDetailScreen({
    super.key,
    required this.gameInfoId
  });

  @override
  State<TableTennisGameInfoDetailScreen> createState() => _TableTennisGameInfoDetailScreenState();
}

class _TableTennisGameInfoDetailScreenState extends State<TableTennisGameInfoDetailScreen> {

  late GameDetailInfoDTO gameDetailInfo;

  @override
  void initState() {
    super.initState();

    handleGetGameDetailInfo(widget.gameInfoId);
  }

  void handleGetGameDetailInfo(String gameInfoId) async {
    final response = await apiRequest(() => getGameDetailInfo(gameInfoId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        gameDetailInfo = GameDetailInfoDTO.fromJson(data);
      });
    } else {
      log("탁구장 경기 리스트 가져오기 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.gameInfoId);
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "경기 정보"
          ),
        ),
      ),
    );
  }
}