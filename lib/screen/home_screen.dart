import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/search_table_tennis_court_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var searchKeywordController = TextEditingController();

  FocusNode searchKeywordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container( // 전체 화면
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Center(child: Text("홈 화면")),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchKeywordController,
                                focusNode: searchKeywordFocus,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  hintText: "체육관을 검색해보세요.",
                                  hintStyle: TextStyle(fontSize: 15),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(121, 55, 64, 0)
                                    )
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color:Color.fromRGBO(122, 11, 11, 0)
                                    )
                                  )
                                ),
                                onChanged:(value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            if (searchKeywordController.text.isNotEmpty)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  searchKeywordController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  size: 20,
                                )
                              )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: IconButton(
                        onPressed: () {
                          print("keyword: ${searchKeywordController.text}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchTableTennisCourtScreen(
                                keyword: searchKeywordController.text
                              )
                            )
                          );
                        },
                        icon: Icon(
                          Icons.search,
                          color: Colors.black,
                        )
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}