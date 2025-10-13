import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/table_tennis_court_dto.dart';
import 'package:king_of_table_tennis/screen/table_tennis_court_detail_ended_game_screen.dart';
import 'package:king_of_table_tennis/screen/table_tennis_court_detail_registered_game_screen.dart';
import 'package:king_of_table_tennis/util/appColors.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Align(
            alignment: Alignment.topLeft,
            child: Text(
              widget.tableTennisCourtDTO.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.tableBlue,
            overlayColor: MaterialStateProperty.all(const Color.fromARGB(39, 30, 77, 135)),
            tabs: [
              Tab(
                child: Text(
                  "등록된 경기",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "종료된 경기",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ]
          ),
        ),
        body: TabBarView(
          children: [
            TableTennisCourtDetailRegisteredGameScreen(
              tableTennisCourtId: widget.tableTennisCourtDTO.id,
              tableTennisCourtName: widget.tableTennisCourtDTO.name
            ),
            TableTennisCourtDetailEndedGameScreen(
              tableTennisCourtId: widget.tableTennisCourtDTO.id
            )
          ]
        )
      ),
    );
  }
}