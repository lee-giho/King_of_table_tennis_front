import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/main.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';

Future<DateTime?> showCustomDateTimePicker({
  required BuildContext context,
  required DateTime selectDate,
  required List<DateTime> blackList
}) async {

  final now = DateTime.now();
  final roundedNow = DateTime(now.year, now.month, now.day, now.hour+1);

  DateTime tempSelectedDate = DateTime(now.year, now.month, now.day, now.hour+1);

  return await showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: DateTime(selectDate.year, selectDate.month, selectDate.day, selectDate.hour+1),
                    minimumDate: roundedNow,
                    maximumDate: roundedNow.add(const Duration(days: 30)),
                    use24hFormat: true,
                    minuteInterval: 60,
                    onDateTimeChanged: (DateTime newDateTime) {
                      setModalState(() {
                        tempSelectedDate = newDateTime;
                      });
                    }
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.racketRed,
                        foregroundColor: Colors.white
                      ),
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final isBlocked = blackList.any((blocked) =>
                          blocked.year == tempSelectedDate.year &&
                          blocked.month == tempSelectedDate.month &&
                          blocked.day == tempSelectedDate.day &&
                          blocked.hour == tempSelectedDate.hour
                        );

                        print("isBlocked: $isBlocked");
                        print("blackList: $blackList");

                        if (isBlocked) {
                          ToastMessage.show("이미 예약된 시간입니다. 다시 선택해주세요.");
                        } else {
                          Navigator.pop(
                            context,
                            tempSelectedDate
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tableBlue,
                        foregroundColor: Colors.white
                      ),
                      child: const Text(
                        "확인",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                  ],
                )
              ],
            ),
          );
        }
      );
    }
  );
}