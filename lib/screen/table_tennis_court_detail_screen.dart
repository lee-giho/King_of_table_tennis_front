import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/table_tennis_court_dto.dart';
import 'package:king_of_table_tennis/screen/game_registration_screen.dart';
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
          
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.tableBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameRegistrationScreen(
                tableTennisCourtId: widget.tableTennisCourtDTO.id
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