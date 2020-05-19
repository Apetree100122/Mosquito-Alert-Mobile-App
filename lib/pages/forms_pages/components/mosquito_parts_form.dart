import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/image_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MosquitoPartsForm extends StatefulWidget {
  final Map displayQuestion;

  MosquitoPartsForm(this.displayQuestion);
  @override
  _MosquitoPartsFormState createState() => _MosquitoPartsFormState();
}

class _MosquitoPartsFormState extends State<MosquitoPartsForm> {
  List<Question> questions = List();

  List<String> torax;

  @override
  void initState() {
    super.initState();

    if (Utils.report != null) {
      for (Question q in Utils.report.responses) {
        if (q.question_id == 7) {
          questions.add(q);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var sizeWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Style.title('¿Como era el mosquito?'),
              SizedBox(
                height: 20,
              ),
              // GridView.builder(
              //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //         crossAxisCount: 4,
              //         crossAxisSpacing: 10,
              //         mainAxisSpacing: 10),
              //     shrinkWrap: true,
              //     physics: NeverScrollableScrollPhysics(),
              //     itemCount: widget.displayQuestion['answers'].length,
              //     itemBuilder: (ctx, index) {
              //       String text =
              //           widget.displayQuestion['answers'][index]['text']['es'];
              //       int id = widget.displayQuestion['answers'][index]['id'];
              //       return Container(
              //         child: GestureDetector(
              //           onTap: () {
              //             onSelect(text, id, 710);
              //           },
              //           child: Container(
              //             // width: sizeWidth * 0.22,
              //             // height: 20,
              //             // margin: EdgeInsets.only(right: 2.5),
              //             // color: Colors.green,
              //             // child: Image.asset(
              //             //     widget.displayQuestion['answers'][index]['img']),
              //             child: ImageQuestionOption(
              //               questions.any((q) => q.answer_id == id),
              //               '',
              //               '',
              //               "",
              //               // widget.displayQuestion['answers'][index]['img'],
              //               disabled: questions.length != null
              //                   ? isDisabled(710, id)
              //                   : false,
              //             ),
              //           ),
              //         ),
              //       );
              //     }),
              // Container(
              //   height: 200,
              //   child: ListView.builder(
              //       itemCount: torax.length,
              //       shrinkWrap: true,
              //       physics: NeverScrollableScrollPhysics(),
              //       scrollDirection: Axis.horizontal,
              //       itemBuilder: (context, index) {
              //         int i = index + 711;
              //         return GestureDetector(
              //           onTap: () {
              //             onSelect('Torax${index + 1}', i, 710);
              //           },
              //           child: Container(
              //             width: sizeWidth * 0.22,
              //             margin: EdgeInsets.only(right: 5),
              //             child: ImageQuestionOption(
              //               questions.any((q) => q.answer_id == i),
              //               '',
              //               '',
              //               'assets/img/abdomen_711.png',
              //               disabled: questions.length != null
              //                   ? isDisabled(710, index + 711)
              //                   : false,
              //             ),
              //           ),
              //         );
              //       }),
              // ),
              // Container(
              //   height: 200,
              //   child: ListView.builder(
              //       itemCount: 4,
              //       shrinkWrap: true,
              //       physics: NeverScrollableScrollPhysics(),
              //       scrollDirection: Axis.horizontal,
              //       itemBuilder: (context, index) {
              //         return GestureDetector(
              //           onTap: () {
              //             onSelect('Abdomen${index + 1}', (index + 721), 720);
              //           },
              //           child: Container(
              //             width: sizeWidth * 0.22,
              //             margin: EdgeInsets.only(right: 5),
              //             // color: Colors.green,
              //             child: ImageQuestionOption(
              //               questions.any((q) => q.answer_id == (index + 721)),
              //               '',
              //               '',
              //               'assets/img/abdomen_721.png',
              //               disabled: questions.length != null
              //                   ? isDisabled(720, (index + 721))
              //                   : false,
              //             ),
              //           ),
              //         );
              //       }),
              // ),
              Container(
                height: 200,
                child: ListView.builder(
                    itemCount: 4,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      String text = widget.displayQuestion['answers'][index]
                          ['text']['es'];
                      int id = widget.displayQuestion['answers'][index]['id'];
                      print(text);
                      return GestureDetector(
                        onTap: () {
                          onSelect('Leg ${index + 1}', (index + 731), 730);
                        },
                        child: Container(
                          width: sizeWidth * 0.22,
                          // height: 20,
                          margin: EdgeInsets.only(right: 5),
                          // color: Colors.green,
                          // child: Image.asset(
                          //     widget.displayQuestion['answers'][index]['img']),
                          child: ImageQuestionOption(
                            questions.any((q) => q.answer_id == id),
                            '',
                            '',
                            // "",
                            widget.displayQuestion['answers'][index]['img'],
                            disabled: questions.length != null
                                ? isDisabled(710, id)
                                : false,
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 15,
              ),
              Center(child: Style.noBgButton("No lo tengo claro", () {}))
            ],
          ),
        ),
      ),
    );
  }

  onSelect(answer, answerId, int i) {
    Utils.addAdultPartsResponse(answer, answerId, i);

    setState(() {
      questions = Utils.report.responses;
    });
  }

  bool isDisabled(int index, int aswerId) {
    var group = questions
        .where((q) => q.answer_id >= index && q.answer_id < index + 10)
        .toList();

    return group.any((q) => q.answer_id != aswerId);
  }
}
