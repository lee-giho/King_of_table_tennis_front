import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/post_api.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/RegisterPostRequest.dart';
import 'package:king_of_table_tennis/model/post.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';

class PostUpdateScreen extends StatefulWidget {
  final Post post;
  const PostUpdateScreen({
    super.key,
    required this.post
  });

  @override
  State<PostUpdateScreen> createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends State<PostUpdateScreen> {

  PostType selectedCategory = PostType.GENERAL;
  var titleController = TextEditingController();
  var contentController = TextEditingController();

  bool canSubmit = false;

  bool isTitleChanged = false;
  bool isContentChanged = false;
  bool isCategoryChanged = false;

  @override
  void initState() {
    super.initState();

    titleController.addListener(updateCanSubmit);
    contentController.addListener(updateCanSubmit);

    selectedCategory = widget.post.category;
    titleController.text = widget.post.title;
    contentController.text = widget.post.content;

    updateCanSubmit();
  }

  @override
  void dispose() {
    titleController.removeListener(updateCanSubmit);
    contentController.removeListener(updateCanSubmit);
    titleController.dispose();
    contentController.dispose();

    super.dispose();
  }

  void updateCanSubmit() {
    final hasTitle = titleController.text.trim().isNotEmpty;
    final hasContent = contentController.text.trim().isNotEmpty;

    // 원래 게시글의 값
    final originalTitle = widget.post.title;
    final originalContent = widget.post.content;
    final originalCategory = widget.post.category;

    // 변경 여부
    isTitleChanged = titleController.text.trim() != originalTitle;
    isContentChanged = contentController.text.trim() != originalContent;
    isCategoryChanged = selectedCategory != originalCategory;

    final next = hasTitle && hasContent && (isTitleChanged || isContentChanged || isCategoryChanged);

    if (next != canSubmit) {
      setState(() {
        canSubmit = next;
      });
    }
  }

  void handlePatchPost(String postId, RegisterPostRequest registerPostRequest) async {
    final response = await apiRequest(() => patchMyPost(postId, registerPostRequest), context);

    if (response.statusCode == 204) {
      ToastMessage.show("게시물이 수정되었습니다.");
      Navigator.pop(context, true);
    } else {
      ToastMessage.show("게시물이 수정되지 않았습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "게시글 수정",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit
              ? () {
                  handlePatchPost(
                    widget.post.id,
                    RegisterPostRequest(
                      title: isTitleChanged ? titleController.text : null,
                      category: isCategoryChanged ? selectedCategory.value : null,
                      content: isContentChanged ? contentController.text : null
                    )
                  );
                }
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.racketRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              )
            ),
            child: Text(
              "수정하기",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            )
          ),
        )
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container( // 전체화면
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: Column(
                    children: [
                      Column( // 제목
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "제목",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: "제목을 입력해주세요",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: AppColors.tableBlue
                                ),
                                borderRadius: BorderRadius.circular(15),
                              )
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Column( // 카테고리
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "카테고리",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Row(
                            children: PostType.values.map((type) {
                              final isSelected = selectedCategory == type;
                  
                              return Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = type;
                                    });
                                    updateCanSubmit();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (_) {
                                          setState(() {
                                            selectedCategory = type;
                                          });
                                          updateCanSubmit();
                                        },
                                        activeColor: AppColors.tableBlue,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        type.label,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              );
                            }).toList()
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "내용",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: contentController,
                                expands: true,
                                maxLines: null,
                                minLines: null,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: "내용을 입력해주세요",
                                  alignLabelWithHint: true,
                                  contentPadding: EdgeInsets.all(12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      width: 1
                                    )
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: AppColors.tableBlue
                                    ),
                                    borderRadius: BorderRadius.circular(15)
                                  )
                                )
                              ),
                            ),
                          ],
                        )
                      ),
                      SizedBox(height: 10)
                    ],
                  ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}