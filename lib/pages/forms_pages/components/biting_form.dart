import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import '../../../utils/Utils.dart';

class BitingForm extends StatefulWidget {
  final List<Map> displayQuestions;
  final Function setValid;

  BitingForm(this.displayQuestions, this.setValid);
  @override
  _BitingFormState createState() => _BitingFormState();
}

class _BitingFormState extends State<BitingForm> {
  List<Question> questions;
  List<Map> displayQuestions = [];
  Map bodyQuestion = {};
  String language;
  int bites = 0;

  bool showDaytime = false;

  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    questions = [];

    if (Utils.report != null) {
      for (Question q in Utils.report.responses) {
        if (q.question_id == 1) {
          bites = int.parse(q.answer_value);
        }
        if (q.question_id <= 4 || q.question_id == 13) {
          questions.add(q);
        }
        if (q.answer_id == 132) {
          showDaytime = true;
        }
      }
    }
    bool isValid = canContinue();
    widget.setValid(isValid);
    _textController.text = bites.toString();
    language = Utils.getLanguage();
    displayQuestions =
        widget.displayQuestions.where((q) => q['question']['id'] > 2).toList();
    bodyQuestion = widget.displayQuestions
        .where((q) => q['question']['id'] == 2)
        .toList()[0];
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
                height: 24,
              ),
              Style.titleMedium(
                  MyLocalizations.of(context, 'bytes_and_place_report_txt'),
                  fontSize: 16),
              SizedBox(
                height: 12,
              ),
              Row(
                children: <Widget>[
                  Style.button(
                    '-',
                    () {
                      bites = max(bites - 1, 0);
                      _textController.text = bites.toString();
                      var question = widget.displayQuestions
                          .where((q) => q['question']['id'] == 1)
                          .toList();
                      addToList(question[0]['question']['text'][language], "",
                          question_id: 1,
                          answer_id: 11,
                          answer_value: _textController.text);
                      bool isValid = canContinue();
                      widget.setValid(isValid);
                    },
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      flex: 1,
                      child: Style.textField(
                        "a",
                        _textController,
                        context,
                        enabled: false,
                      )),
                  SizedBox(
                    width: 12,
                  ),
                  Style.button(
                    '+',
                    () {
                      bites = min(bites = bites + 1, 20);
                      _textController.text = bites.toString();
                      var question = widget.displayQuestions
                          .where((q) => q['question']['id'] == 1)
                          .toList();
                      addToList(question[0]['question']['text'][language], "",
                          question_id: 1,
                          answer_id: 11,
                          answer_value: _textController.text);
                      bool isValid = canContinue();
                      widget.setValid(isValid);
                    },
                  ),
                ],
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Stack(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Image.asset(
                          'assets/img/ic_full_body_off.png',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions.any((question) => question.answer_id == 25)
                              ? 'assets/img/ic_left_leg_on.png'
                              : "assets/img/ic_left_leg_off.png",
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions.any((question) => question.answer_id == 26)
                              ? 'assets/img/ic_right_leg_on.png'
                              : 'assets/img/ic_right_leg_off.png',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions.any((question) => question.answer_id == 22)
                              ? 'assets/img/ic_left_hand_on.png'
                              : 'assets/img/ic_left_hand_off.png',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions.any((question) => question.answer_id == 23)
                              ? 'assets/img/ic_right_hand_on.png'
                              : 'assets/img/ic_right_hand_off.png',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions.any((question) => question.answer_id == 21)
                              ? 'assets/img/ic_head_on.png'
                              : 'assets/img/ic_head_off.png',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions.any((question) => question.answer_id == 24)
                              ? 'assets/img/ic_chest_on.png'
                              : 'assets/img/ic_chest_off.png',
                          width: mediaQuery.width,
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.05,
                          left: mediaQuery.width * 0.37,
                          child: questions
                                  .any((question) => question.answer_id == 21)
                              ? Style.body(getIndexBody(21))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.18,
                          left: mediaQuery.width * 0.21,
                          child: questions
                                  .any((question) => question.answer_id == 23)
                              ? Style.body(getIndexBody(23))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.18,
                          left: mediaQuery.width * 0.70,
                          child: questions
                                  .any((question) => question.answer_id == 22)
                              ? Style.body(getIndexBody(22))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.23,
                          left: mediaQuery.width * 0.56,
                          child: questions
                                  .any((question) => question.answer_id == 24)
                              ? Style.body(getIndexBody(24))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.37,
                          left: mediaQuery.width * 0.28,
                          child: questions
                                  .any((question) => question.answer_id == 26)
                              ? Style.body(getIndexBody(26))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.37,
                          left: mediaQuery.width * 0.63,
                          child: questions
                                  .any((question) => question.answer_id == 25)
                              ? Style.body(getIndexBody(25))
                              : Container(),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        //HEAD
                        GestureDetector(
                          onTap: _validateAddBite()
                              ? () {
                                  addToList(
                                      bodyQuestion['question']['text']
                                          [language],
                                      bodyQuestion['answers'][0]['text']
                                          [language],
                                      question_id: 2,
                                      answer_id: 21);
                                }
                              : null,
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
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text']
                                              [language],
                                          bodyQuestion['answers'][2]['text']
                                              [language],
                                          question_id: 2,
                                          answer_id: 23);
                                    }
                                  : null,
                              child: Container(
                                color: Colors.blue.withOpacity(0.0),
                                height: mediaQuery.height * 0.1,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                            //CHEST
                            GestureDetector(
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text']
                                              [language],
                                          bodyQuestion['answers'][3]['text']
                                              [language],
                                          question_id: 2,
                                          answer_id: 24);
                                    }
                                  : null,
                              child: Container(
                                // margin: EdgeInsets.only(top: 5),
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.13,
                                width: mediaQuery.width * 0.15,
                              ),
                            ),
                            //ARM
                            GestureDetector(
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text']
                                              [language],
                                          bodyQuestion['answers'][1]['text']
                                              [language],
                                          question_id: 2,
                                          answer_id: 22);
                                    }
                                  : null,
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
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text']
                                              [language],
                                          bodyQuestion['answers'][5]['text']
                                              [language],
                                          question_id: 2,
                                          answer_id: 26);
                                    }
                                  : null,
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.15,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                            //LEG
                            GestureDetector(
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text']
                                              [language],
                                          bodyQuestion['answers'][4]['text']
                                              [language],
                                          question_id: 2,
                                          answer_id: 25);
                                    }
                                  : null,
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
              SizedBox(
                height: 12,
              ),
              Center(
                child: Style.button(MyLocalizations.of(context, 'reset'), () {
                  Utils.resetBitingQuestion();
                  setState(() {
                    questions = Utils.report.responses;
                  });
                }),
              ),
              SizedBox(
                height: 24,
              ),

              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: showDaytime
                    ? displayQuestions.length
                    : displayQuestions.length - 1,
                itemBuilder: (context, i) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Style.titleMedium(
                          displayQuestions[i]['question']['text'][language],
                          fontSize: 16),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        // height: 450,
                        child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: displayQuestions[i]['answers'].length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 5 / 2,
                              // crossAxisSpacing: 10,
                            ),
                            itemBuilder: (context, index) {
                              String answerTxt = displayQuestions[i]['answers']
                                  [index]['text'][language];
                              String questionTxt = displayQuestions[i]
                                  ['question']['text'][language];
                              int questionId =
                                  displayQuestions[i]['question']['id'];
                              int answerId =
                                  displayQuestions[i]['answers'][index]['id'];
                              return Container(
                                padding: EdgeInsets.all(5),
                                child: InkWell(
                                  onTap: () {
                                    if (answerId == 132) {
                                      setState(() {
                                        showDaytime = true;
                                      });
                                    } else if (answerId == 131) {
                                      setState(() {
                                        showDaytime = false;
                                      });
                                    }
                                    addToList(questionTxt, answerTxt,
                                        question_id: questionId,
                                        answer_id: answerId);
                                  },
                                  child: SmallQuestionOption(
                                    answerTxt,
                                    selected: questions
                                        .any((q) => q.answer_id == answerId),
                                    // index: getIndexAnswer(answerId),
                                    // disabled:
                                    //     _getDisabled(answerId, questionId),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: 15,
              ),
              // canContinue()
              // true
              // ? GestureDetector(
              //     onTap: () {
              //       widget.nextPage();
              //     },
              //     child: Container(
              //       padding: EdgeInsets.symmetric(vertical: 20),
              //       width: double.infinity,
              //       decoration: BoxDecoration(
              //         color: Style.colorPrimary,
              //         borderRadius: BorderRadius.circular(15),
              //       ),
              //       child: Style.body(
              //           MyLocalizations.of(context, "continue_txt"),
              //           textAlign: TextAlign.center,
              //           color: Colors.white),
              //     ),
              //   )
              // : Container(
              //     padding: EdgeInsets.symmetric(vertical: 20),
              //     width: double.infinity,
              //     decoration: BoxDecoration(
              //       color: Colors.grey,
              //       borderRadius: BorderRadius.circular(15),
              //     ),
              //     child: Style.body(
              //         MyLocalizations.of(context, "complete_all_txt"),
              //         textAlign: TextAlign.center,
              //         color: Colors.white),
              //   ),
              SizedBox(
                height: 15,
              ),
              Style.bottomOffset,
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

  addToList(String question, String answer,
      {question_id, answer_id, answer_value}) {
    if ((question_id != 1 && int.parse(_textController.text) > 0) ||
        question_id == 1) {
      Utils.addBiteResponse(
        question,
        answer,
        question_id: question_id,
        answer_id: answer_id,
        answer_value: answer_value,
      );

      setState(() {
        questions = Utils.report.responses;
      });
      bool isValid = canContinue();
      widget.setValid(isValid);
    }
  }

  bool _validateAddBite() {
    int totalParts = 0;
    questions.forEach((q) {
      if (q.question_id == 2) {
        totalParts = totalParts + int.parse(q.answer_value);
      }
    });
    return totalParts < bites;
  }

  bool canContinue() {
    if (questions.length > 1 && questions.isNotEmpty) {
      bool totalBites = _validateAddBite();
      int totalQ3 = 0;
      int totalQ4 = 0;
      int totalQ5 = 0;

      questions.forEach((q) {
        if (q.question_id == 4) totalQ3++;
        if (q.question_id == 13) totalQ4++;
        if (q.question_id == 3) totalQ5++;
      });

      if (questions.any((q) => q.answer_id == 132)) {
        if (bites > 0 &&
            !totalBites &&
            totalQ3 == 1 &&
            totalQ4 == 1 &&
            totalQ5 == 1) {
          return true;
        }
      } else {
        if (bites > 0 && !totalBites && totalQ3 == 1 && totalQ4 == 1) {
          return true;
        }
      }
      return false;
    }
    return false;
  }
}
