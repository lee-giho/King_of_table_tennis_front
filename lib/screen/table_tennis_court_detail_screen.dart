import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/recruiting_game_dto.dart';
import 'package:king_of_table_tennis/model/table_tennis_court_dto.dart';
import 'package:king_of_table_tennis/screen/game_registration_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/widget/recruitingGameTile.dart';

class TableTennisCourtDetailScreen extends StatefulWidget {
  final TableTennisCourtDTO tableTennisCourtDTO;
  const TableTennisCourtDetailScreen({
    super.key,
    required this.tableTennisCourtDTO
  });

  @override
  State<TableTennisCourtDetailScreen> createState() => _TableTennisCourtDetailScreenState();
}

class _TableTennisCourtDetailScreenState extends State<TableTennisCourtDetailScreen> {

  List<RecruitingGameDTO> recruitingGames = [];

  @override
  void initState() {
    super.initState();

    handleGetRecruitingGameList(widget.tableTennisCourtDTO.id);
  }

  void handleGetRecruitingGameList(String tableTennisCourtId) async {
    final response = await apiRequest(() => getRecruitingGameList(tableTennisCourtId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final recruitingGameList = data["recruitingGames"] as List;

      setState(() {
        recruitingGames = recruitingGameList
          .map((json) => RecruitingGameDTO.fromJson(json))
          .toList();
      });

    } else {
      log("탁구장 경기 리스트 가져오기 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.tableTennisCourtDTO.name
          ),
        ),
      ),
      body: SafeArea(
        child: Container( // 전체화면
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: recruitingGames.isEmpty
            ? const Center(
                child: Text(
                  "등록된 경기가 없습니다."
                )
              )
            : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final recruitingGame = recruitingGames[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                child: InkWell(
                                  onTap: () {

                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: RecruitingGameTile(
                                    recruitingGameDTO: recruitingGame,
                                    onApplyComplete: () {
                                      handleGetRecruitingGameList(widget.tableTennisCourtDTO.id);
                                    }
                                  )
                                ),
                              ),
                            );
                          },
                          childCount: recruitingGames.length
                        )
                      )
                    ],
                  )
                )
              ],
            )
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.tableBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameRegistrationScreen(
                tableTennisCourtId: widget.tableTennisCourtDTO.id,
                tableTennisCourtName: widget.tableTennisCourtDTO.name
              )
            )
          );
        },
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}