import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingForm extends StatefulWidget {
  final List<Map> displayQuestions;
  final Function nextPage;

  BitingForm(this.displayQuestions, this.nextPage);
  @override
  _BitingFormState createState() => _BitingFormState();
}

class _BitingFormState extends State<BitingForm> {
  List<Question> questions;

  @override
  void initState() {
    questions = [];
    if (Utils.report != null) {
      for (Question q in Utils.report.responses) {
        if (q.question_id <= 4) {
          questions.add(q);
        }
      }
    } else {
      Utils.createNewReport('bite');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 35,
              ),
              Style.title(
                  MyLocalizations.of(context, "need_more_information_txt")),
              Style.bodySmall(MyLocalizations.of(context, "lets_go_txt")),
              SizedBox(
                height: 25,
              ),
              Style.titleMedium('¿Cuántas picaduras quieres reportar y dónde?',
                  fontSize: 16),
              Container(
                alignment: Alignment.topLeft,
                child: Stack(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Image.asset('assets/img/ic_full_body_off.png'),
                        questions.any((question) => question.answer_id == 6)
                            ? Image.asset('assets/img/ic_left_leg_on.png')
                            : Image.asset("assets/img/ic_left_leg_off.png"),
                        questions.any((question) => question.answer_id == 5)
                            ? Image.asset('assets/img/ic_right_leg_on.png')
                            : Image.asset('assets/img/ic_right_leg_off.png'),
                        questions.any((question) => question.answer_id == 4)
                            ? Image.asset('assets/img/ic_left_hand_on.png')
                            : Image.asset('assets/img/ic_left_hand_off.png'),
                        questions.any((question) => question.answer_id == 3)
                            ? Image.asset('assets/img/ic_right_hand_on.png')
                            : Image.asset('assets/img/ic_right_hand_off.png'),
                        questions.any((question) => question.answer_id == 1)
                            ? Image.asset('assets/img/ic_head_on.png')
                            : Image.asset('assets/img/ic_head_off.png'),
                        questions.any((question) => question.answer_id == 2)
                            ? Image.asset('assets/img/ic_chest_on.png')
                            : Image.asset('assets/img/ic_chest_off.png'),
                        Positioned(
                          top: mediaQuery.height * 0.05,
                          left: mediaQuery.width * 0.37,
                          child: questions
                                  .any((question) => question.answer_id == 1)
                              ? Style.body(getIndexBody(1))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.18,
                          left: mediaQuery.width * 0.21,
                          child: questions
                                  .any((question) => question.answer_id == 3)
                              ? Style.body(getIndexBody(3))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.18,
                          left: mediaQuery.width * 0.70,
                          child: questions
                                  .any((question) => question.answer_id == 4)
                              ? Style.body(getIndexBody(4))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.23,
                          left: mediaQuery.width * 0.56,
                          child: questions
                                  .any((question) => question.answer_id == 2)
                              ? Style.body(getIndexBody(2))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.37,
                          left: mediaQuery.width * 0.28,
                          child: questions
                                  .any((question) => question.answer_id == 5)
                              ? Style.body(getIndexBody(5))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.37,
                          left: mediaQuery.width * 0.63,
                          child: questions
                                  .any((question) => question.answer_id == 6)
                              ? Style.body(getIndexBody(6))
                              : Container(),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        //HEAD
                        GestureDetector(
                          onTap: () {
                            addToList('donde pico', "head",
                                question_id: 2, answer_id: 1);
                          },
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 40),
                              color: Colors.transparent,
                              height: mediaQuery.height * 0.08,
                              width: mediaQuery.width * 0.15,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //ARM
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "right arm",
                                    question_id: 2, answer_id: 3);
                              },
                              child: Container(
                                color: Colors.blue.withOpacity(0.0),
                                height: mediaQuery.height * 0.1,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                            //CHEST
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "chest",
                                    question_id: 2, answer_id: 2);
                              },
                              child: Container(
                                // margin: EdgeInsets.only(top: 5),
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.13,
                                width: mediaQuery.width * 0.15,
                              ),
                            ),
                            //ARM
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "left arm",
                                    question_id: 2, answer_id: 4);
                              },
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.1,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //LEG
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "right leg",
                                    question_id: 2, answer_id: 5);
                              },
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.15,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                            //LEG
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "left leg",
                                    question_id: 2, answer_id: 6);
                              },
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.15,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: Style.body(
                  MyLocalizations.of(context, 'tap_image_biting_txt'),
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.displayQuestions.length,
                itemBuilder: (context, i) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Style.titleMedium(
                          widget.displayQuestions[i]['question']['text']['es'],
                          fontSize: 16),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        // height: 450,
                        child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                widget.displayQuestions[i]['answers'].length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 5 / 2,
                              // crossAxisSpacing: 10,
                            ),
                            itemBuilder: (context, index) {
                              String answerTxt = widget.displayQuestions[i]
                                  ['answers'][index]['text']['es'];
                              String questionTxt = widget.displayQuestions[i]
                                  ['question']['text']['es'];
                              int questionId =
                                  widget.displayQuestions[i]['question']['id'];
                              int answerId = widget.displayQuestions[i]
                                  ['answers'][index]['id'];
                              return Container(
                                padding: EdgeInsets.all(5),
                                child: InkWell(
                                  onTap: _getDisabled(answerId, questionId)
                                      ? null
                                      : () {
                                          addToList(questionTxt, answerTxt,
                                              question_id: questionId,
                                              answer_id: answerId);
                                        },
                                  child: SmallQuestionOption(
                                    answerTxt,
                                    selected: questions
                                        .any((q) => q.answer_id == answerId),
                                    index: getIndexAnswer(answerId),
                                    disabled:
                                        _getDisabled(answerId, questionId),
                                  ),
                                ),
                              );
                            }),
                      ),
                      //TOODO: Question "nolose"
                    ],
                  );
                },
              ),
              SizedBox(
                height: 15,
              ),
              canContinue()
                  // true
                  ? GestureDetector(
                      onTap: () {
                        widget.nextPage();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Style.colorPrimary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Style.body(
                            MyLocalizations.of(context, "continue_txt"),
                            textAlign: TextAlign.center,
                            color: Colors.white),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Style.body(
                          MyLocalizations.of(context, "complete_all_txt"),
                          textAlign: TextAlign.center,
                          color: Colors.white),
                    ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _getDisabled(int answerId, int questionId) {
    if (questions.isEmpty) {
      return false;
    }

    int index = questions.indexWhere((q) => q.question_id == 1);
    int totalAnswers =
        index != -1 ? int.parse(questions[index].answer_value) : 0;

    int currentValues = 0;

    questions.forEach((q) {
      if (q.question_id == questionId) {
        currentValues = currentValues + 1;
      }
    });

    return currentValues >= totalAnswers;
  }

  String getIndexBody(int answer_id) {
    int index = Utils.report.responses
        .indexWhere((question) => question.answer_id == answer_id);

    if (index != -1) {
      return Utils.report.responses[index].answer_value;
    }
  }

  String getIndexAnswer(int answer_id) {
    int index = 0;

    questions.map((q) {
      if (q.answer_id == answer_id) {
        index = index + 1;
      }
    }).toList();

    if (index > 0) {
      return index.toString();
    }
  }

  addToList(String question, String answer, {question_id, answer_id}) {
    Utils.addBiteResponse(question, answer,
        question_id: question_id, answer_id: answer_id);

    setState(() {
      questions = Utils.report.responses;
    });
  }

  bool canContinue() {
    if (questions.length > 1 && questions.isNotEmpty) {
      int totalIndex = questions.indexWhere((q) => q.question_id == 1);
      int totalValues = int.parse(questions[totalIndex].answer_value);
      bool canContinue = false;
      int totalParts = 0;
      int totalQ3 = 0;
      int totalQ4 = 0;

      questions.forEach((q) {
        if (q.question_id == 2) {
          totalParts = totalParts + int.parse(q.answer_value);
        }
        if (q.question_id == 3) totalQ3++;
        if (q.question_id == 4) totalQ3++;
      });
      return totalQ3 >= totalParts;

      //   for (int j = 2; j <= 3; j++) {
      //     int questionValue = 0;
      //     int total3 = 0;
      //     for (int i = 0; i < questions.length; i++) {
      //       // 2 = first questions on screen; 3 = only 3 questions in this screen (2 shown + 1 auto)
      //       if (questions[i].question_id == 2) {
      //         questionValue =
      //             questionValue + int.parse(questions[i].answer_value);
      //       } else if (questions[i].question_id == 3) {
      //         total3++;
      //       }
      //     }
      //     if (questionValue == totalValues || total3 == totalValues) {
      //       canContinue = true;
      //     } else {
      //       canContinue = false;
      //     }
      //   }
      //   return canContinue;
    }
    return false;
    // }
  }
}
