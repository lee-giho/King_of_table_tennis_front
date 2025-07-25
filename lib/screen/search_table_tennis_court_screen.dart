import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/table_tennis_court_dto.dart';
import 'package:king_of_table_tennis/screen/table_tennis_court_detail_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/widget/tableTennisCourtTile.dart';

class SearchTableTennisCourtScreen extends StatefulWidget {
  final String keyword;
  const SearchTableTennisCourtScreen({
    super.key,
    required this.keyword
  });

  @override
  State<SearchTableTennisCourtScreen> createState() => _SearchTableTennisCourtScreenState();
}

class _SearchTableTennisCourtScreenState extends State<SearchTableTennisCourtScreen> {

  List<TableTennisCourtDTO> tableTennisCourts = [];

  @override
  void initState() {
    super.initState();

    handleSearchTableTennisCourtByKeyword();
  }

  void handleSearchTableTennisCourtByKeyword() async {
    final response = await apiRequest(() => searchTableTennisCourtByName(widget.keyword), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final courtsJsonList = data["tableTennisCourts"] as List;

      setState(() {
        tableTennisCourts = courtsJsonList
          .map((json) => TableTennisCourtDTO.fromJson(json))
          .toList();
      });

      print(tableTennisCourts[0].name);
    } else {
      log("탁구장 검색 결과 가져오기 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "검색 결과"
        ),
      ),
      body: SafeArea(
        child: Container( // 전체화면
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: tableTennisCourts.isEmpty
            ? const Center(
                child: Text(
                  "검색 결과가 없습니다."
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final tableTennisCourt = tableTennisCourts[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TableTennisCourtDetailScreen(
                                            tableTennisCourtDTO: tableTennisCourt
                                          )
                                        )
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: TableTennisCourtTile(
                                      tableTennisCourtDTO: tableTennisCourt
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: tableTennisCourts.length
                          ),
                        )
                      ],
                    )
                  )
                ],
              ),
        )
      ),
    );
  }
}