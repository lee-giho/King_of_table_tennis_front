import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';

Future<String?> showCustomStringPicker({
  required BuildContext context,
  required List<String> options,
  required String initialValue
}) async {

  String selectedValue = initialValue;
  int initialIndex = options.indexOf(selectedValue);
  final scrollController = FixedExtentScrollController(initialItem: initialIndex);

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
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: scrollController,
                    onSelectedItemChanged: (index) {
                      setModalState(() {
                        selectedValue = options[index];
                      });
                    },
                    children: options
                      .map((value) => Center(
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 20
                          ),
                        ),
                      )).toList()
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
                        Navigator.pop(
                          context,
                          selectedValue
                        );
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