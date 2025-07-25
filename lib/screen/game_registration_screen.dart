import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/widget/customDateTimePicker.dart';

class GameRegistrationScreen extends StatefulWidget {
  final String tableTennisCourtId;
  const GameRegistrationScreen({
    super.key,
    required this.tableTennisCourtId
  });

  @override
  State<GameRegistrationScreen> createState() => _GameRegistrationScreenState();
}

class _GameRegistrationScreenState extends State<GameRegistrationScreen> {

  DateTime now = DateTime.now();
  late DateTime selectDate;

  @override
  void initState() {
    super.initState();

    setState(() {
      selectDate = DateTime(now.year, now.month, now.day, now.hour+1);  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "탁구 경기 생성"
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "선택한 시간: $selectDate"
            ),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showCustomDateTimePicker(
                  context: context,
                  selectDate: selectDate,
                  blackList: []
                );

                if (picked != null) {
                  setState(() {
                    selectDate = picked;
                  });
                  ScaffoldMessenger.of(context) .showSnackBar(
                    SnackBar(content: Text("선택된 시간: $picked"))
                  );
                }
              },
              child: const Text("날짜 및 시간 선택")
            )
          ],
        )
      ),
    );
  }
}