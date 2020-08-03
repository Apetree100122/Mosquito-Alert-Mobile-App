import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/session.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:package_info/package_info.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../models/question.dart';
import 'MyLocalizations.dart';

class Utils {
  static String language;

  //images
  static List<Map> imagePath;
  static double maskCoordsValue = 0.025;

  static void saveImgPath(File img) {
    if (imagePath == null) {
      imagePath = [];
    }
    imagePath.add({'image': img.path, 'id': report.version_UUID});
  }

  static void deleteImage(String image) {
    imagePath.removeWhere((element) => element['image'] == image);
  }

  //REPORTS
  static Report report;
  static Session session;
  static List<Report> reportsList;

  static closeSession() {
    session.session_end_time = DateTime.now().toIso8601String();
    ApiSingleton().closeSession(session);
  }

  static Future<bool> createNewReport(String type,
      {lat, lon, locationType}) async {
    if (session == null) {
      reportsList = [];

      String userUUID = await UserManager.getUUID();

      int sessionId = await ApiSingleton().getLastSession(userUUID);
      sessionId = sessionId + 1;

      session = new Session(
          session_ID: sessionId,
          user: userUUID,
          session_start_time: DateTime.now().toIso8601String());

      session.id = await ApiSingleton().createSession(session);
    }

    if (session.id != null) {
      var userUUID = await UserManager.getUUID();
      report = new Report(
          type: type,
          report_id: randomAlphaNumeric(4).toString(),
          version_number: 0,
          version_UUID: new Uuid().v4(),
          user: userUUID,
          session: session.id,
          responses: []);

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      report.package_name = packageInfo.packageName;
      report.package_version = 32;

      if (Platform.isAndroid) {
        var buildData = await DeviceInfoPlugin().androidInfo;
        report.device_manufacturer = buildData.manufacturer;
        report.device_model = buildData.model;
        report.os = 'Android';
        report.os_language = getLanguage();
        report.os_version = buildData.version.sdkInt.toString();
        report.app_language = getLanguage();
      } else if (Platform.isIOS) {
        var buildData = await DeviceInfoPlugin().iosInfo;
        report.device_manufacturer = 'Apple';
        report.device_model = buildData.model;
        report.os = buildData.systemName;
        report.os_language = getLanguage();
        report.os_version = buildData.systemVersion;
        report.app_language = getLanguage();
      }

      if (lat != null && lon != null) {
        if (locationType == 'selected') {
          report.location_choice = 'selected';
          report.selected_location_lat = lat;
          report.selected_location_lon = lon;
        } else {
          report.location_choice = 'current';
          report.current_location_lat = lat;
          report.current_location_lon = lon;
        }
      }
      return true;
    }
    return false;
  }

  static resetReport() {
    report = null;
    session = null;
    reportsList = null;
  }

  static setEditReport(Report editReport) {
    report = editReport;
    report.version_number = report.version_number + 1;
    report.version_UUID = new Uuid().v4();

    if (editReport.photos != null || editReport.photos.isNotEmpty) {
      imagePath = [];
      editReport.photos.forEach((element) {
        imagePath.add({
          'image': 'http://humboldt.ceab.csic.es/media/${element.photo}',
          'id': editReport.version_UUID
        });
      });
    }
  }

  static addOtherReport(String type) {
    report.version_time = DateTime.now().toIso8601String();
    report.creation_time = DateTime.now().toIso8601String();
    report.phone_upload_time = DateTime.now().toIso8601String();

    reportsList.add(report);
    report = null;
    if (reportsList.last.location_choice == 'selected') {
      createNewReport(type,
          lat: reportsList.last.selected_location_lat,
          lon: reportsList.last.selected_location_lon,
          locationType: 'selected');
    } else {
      createNewReport(type,
          lat: reportsList.last.current_location_lat,
          lon: reportsList.last.current_location_lon,
          locationType: 'current');
    }
  }

  static deleteLastReport() {
    report = reportsList.last;
    reportsList.removeLast();
    print(reportsList);
  }

  static setCurrentLocation(double latitude, double longitude) {
    report.location_choice = 'current';
    // report.selected_location_lat = null;
    // report.selected_location_lon = null;
    report.current_location_lat = latitude;
    report.current_location_lon = longitude;
  }

  static setSelectedLocation(double lat, lon) {
    report.location_choice = "selected";
    // report.current_location_lat = null;
    // report.current_location_lon = null;
    report.selected_location_lat = lat;
    report.selected_location_lon = lon;
  }

  static void addLocationResponse(double lat, lon) {
    var newQuestion = new Question(
        question: "¿Donde estabas cuando te picaron?",
        answer: " ",
        question_id: 5,
        answer_id: 51,
        answer_value: "POINT( $lat, $lon)");

    report.responses.add(newQuestion);
  }

  static void addBiteResponse(String question, String answer,
      {question_id, answer_id, answer_value}) {
    if (report == null) {
      return;
    }

    List<Question> _questions = report.responses;

    // add total bites

    if (question_id == 1) {
      int currentIndex = _questions.indexWhere((question) =>
          // question.question_id == question_id &&
          question.question_id == question_id);
      if (currentIndex == -1) {
        _questions.add(Question(
          question: question.toString(),
          answer: ' ',
          answer_id: answer_id,
          question_id: question_id,
          answer_value: '1',
        ));
      } else {
        _questions[currentIndex].answer_value = answer_value.toString();
      }
    }

    //increase answer_value question 2
    if (question_id == 2) {
      int currentIndex = _questions.indexWhere((question) =>
          // question.question_id == question_id &&
          question.answer_id == answer_id);
      if (currentIndex == -1) {
        _questions.add(Question(
          question: question.toString(),
          answer: answer.toString(),
          answer_id: answer_id,
          question_id: question_id,
          answer_value: '1',
        ));
      } else {
        int value = int.parse(_questions[currentIndex].answer_value);
        value = value + 1;
        _questions[currentIndex].answer_value = value.toString();
      }
    }

    //add other questions without answer_value
    if (question_id != 2 && question_id != 1) {
      if (_questions.any((q) => q.answer_id == answer_id)) {
        // delete question from list
        _questions.removeWhere((q) => q.answer_id == answer_id);
      } else {
        if (_questions.any(
            (q) => q.question_id == question_id && q.answer_id != answer_id)) {
          //modify question
          int index =
              _questions.indexWhere((q) => q.question_id == question_id);
          _questions[index].answer_id = answer_id;
          _questions[index].answer = answer;
        } else {
          _questions.add(Question(
            question: question.toString(),
            answer: answer.toString(),
            answer_id: answer_id,
            question_id: question_id,
          ));
        }
      }
    }

    if (answer_id == 131) {
      _questions.removeWhere((q) => q.question_id == 3);
    }
    report.responses = _questions;
  }

  static void resetBitingQuestion() {
    List<Question> _questions = report.responses;

    _questions.removeWhere((q) => q.question_id == 2);

    report.responses = _questions;
  }

  static void addAdultPartsResponse(answer, answerId, i) {
    var _questions = report.responses;
    int index =
        _questions.indexWhere((q) => q.answer_id > i && q.answer_id < i + 10);
    if (index != -1) {
      if (_questions[index].answer_id == answerId) {
        _questions.removeAt(index);
      } else {
        _questions[index].answer_id = answerId;
        _questions[index].answer = answer;
      }
    } else {
      Question newQuestion = new Question(
        question: '¿Como era el mosquito?',
        answer: answer,
        question_id: 7,
        answer_id: answerId,
      );
      _questions.add(newQuestion);
    }
    report.responses = _questions;
  }

  static void addResponse(Question question) {
    int index = report.responses
        .indexWhere((q) => q.question_id == question.question_id);
    var _responses = report.responses;
    if (_responses == null) {
      _responses = [];
    }
    if (index != -1) {
      _responses[index] = question;
    } else {
      _responses.add(question);
      report.responses = _responses;
    }
  }

  static Future<bool> saveReports() async {
    bool res;
    if (reportsList != null && reportsList.isNotEmpty) {
      for (int i = 0; i < reportsList.length; i++) {
        res = await ApiSingleton().createReport(reportsList[i]);
      }
    }
    return true;
    // return res;
  }

  static Future<bool> createReport() async {
    if (report.version_number > 0) {
      report.version_time = DateTime.now().toIso8601String();
      bool res = await ApiSingleton().createReport(report);
      return res;
    } else {
      report.version_time = DateTime.now().toIso8601String();
      report.creation_time = DateTime.now().toIso8601String();
      report.phone_upload_time = DateTime.now().toIso8601String();
      reportsList.add(report);
      bool isCreated;
      for (int i = 0; i < reportsList.length; i++) {
        isCreated = await ApiSingleton().createReport(reportsList[i]);
      }

      closeSession();
      resetReport();
      imagePath = [];
      return isCreated;
    }
  }

  static Future<bool> deleteReport(r) async {
    Report deleteReport = r;
    deleteReport.version_time = DateTime.now().toIso8601String();
    deleteReport.version_number = -1;
    deleteReport.version_UUID = Uuid().v4();

    bool res = await ApiSingleton().createReport(deleteReport);
    return res;
  }

  static getLocation() async {
    location = await Geolocator().getLastKnownPosition();
  }

  static final RegExp mailRegExp = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  //Alerts
  static Future showAlert(String title, String text, BuildContext context,
      {onPressed, barrierDismissible}) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible != null
            ? barrierDismissible
            : true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(text),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(MyLocalizations.of(context, 'ok')),
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: context, //
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: new Text(
              title,
              style: TextStyle(letterSpacing: -0.3),
            ),
            content: Column(
              children: <Widget>[
                SizedBox(
                  height: 4,
                ),
                Text(
                  text,
                  style: TextStyle(height: 1.2),
                )
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(MyLocalizations.of(context, 'ok')),
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  static Future showAlertYesNo(
    String title,
    String text,
    onYesPressed,
    BuildContext context,
  ) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(text),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(MyLocalizations.of(context, 'yes')),
                onPressed: () {
                  Navigator.of(context).pop();
                  onYesPressed();
                },
              ),
              FlatButton(
                child: Text(MyLocalizations.of(context, 'no')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: context, //
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Column(
              children: <Widget>[
                SizedBox(
                  height: 4,
                ),
                Text(
                  text,
                )
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(MyLocalizations.of(context, 'yes')),
                onPressed: () {
                  onYesPressed();
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context, 'no')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  static Future modalDetailTrackingforPlatform(List<Widget> list,
      TargetPlatform platform, BuildContext context, Function close,
      {title, cancelButton}) {
    if (platform == TargetPlatform.iOS) {
      return showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
                title: title != null ? Text(title) : null,
                cancelButton: cancelButton != null
                    ? cancelButton
                    : CupertinoActionSheetAction(
                        onPressed: close,
                        child: Text(
                          MyLocalizations.of(context, 'cancel'),
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                actions: list);
          });
    } else if (platform == TargetPlatform.android) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return BottomSheet(
              builder: (BuildContext context) {
                return SafeArea(
                    child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      title != null
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                  top: 20, left: 20, right: 20, bottom: 0),
                              child: Text(title,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400)),
                            )
                          : Container(),
                      Wrap(children: list),
                    ],
                  ),
                ));
              },
              onClosing: close,
            );
          });
    }
  }

  static Widget authBottomInfo(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 15, left: 15, right: 15),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            Text('${MyLocalizations.of(context, 'terms_and_conditions_txt1')} ',
                style: TextStyle(color: Style.textColor, fontSize: 12)),
            InkWell(
              onTap: () async {
                final url = MyLocalizations.of(context, 'url_politics');
                if (await canLaunch(url))
                  await launch(url);
                else
                  throw 'Could not launch $url';
              },
              child: Text(
                  MyLocalizations.of(context, 'terms_and_conditions_txt2'),
                  style: TextStyle(
                      color: Style.textColor,
                      fontSize: 12,
                      decoration: TextDecoration.underline)),
            ),
            Text(
                ' ${MyLocalizations.of(context, 'terms_and_conditions_txt3')} ',
                style: TextStyle(color: Style.textColor, fontSize: 12)),
            InkWell(
              onTap: () async {
                final url = MyLocalizations.of(context, 'url_legal');
                if (await canLaunch(url))
                  await launch(url);
                else
                  throw 'Could not launch $url';
              },
              child: Text(
                  MyLocalizations.of(context, 'terms_and_conditions_txt4'),
                  style: TextStyle(
                      color: Style.textColor,
                      fontSize: 12,
                      decoration: TextDecoration.underline)),
            ),
            Text('.', style: TextStyle(color: Style.textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  static Widget loading(_isLoading, [Color indicatorColor]) {
    return _isLoading == true
        ? new Container(
            color: Colors.transparent,
            child: Center(
              child: new CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    indicatorColor == null
                        ? Style.colorPrimary
                        : indicatorColor),
              ),
            ),
          )
        : new Container();
  }

  static infoAdultCamera(context, getImage) async {
    bool showInfo = await UserManager.getShowInfoAdult();
    if (showInfo == null || !showInfo) {
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              content: Container(
                padding: EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: AssetImage(
                        'assets/img/bg_alert_camera_adult.png',
                      ),
                      fit: BoxFit.cover),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      height: 45,
                    ),
                    Style.body(
                      MyLocalizations.of(context, 'camera_info_adult_txt_01'),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Style.body(
                      MyLocalizations.of(context, 'camera_info_adult_txt_02'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Style.noBgButton(
                            MyLocalizations.of(context, "ok_next_txt"),
                            () {
                              Navigator.of(context).pop();
                              getImage(ImageSource.camera);
                            },
                            textColor: Style.colorPrimary,
                          ),
                        ),
                        Expanded(
                          child: Style.noBgButton(
                            MyLocalizations.of(context, "no_show_again"),
                            () {
                              getImage(ImageSource.camera);
                              UserManager.setSowInfoAdult(true);
                              Navigator.of(context).pop();
                            },
                            // textColor: Style.colorPrimary,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
    } else {
      getImage(ImageSource.camera);
    }
  }

  static infoBreedingCamera(context, getImage) async {
    bool showInfo = await UserManager.getShowInfoBreeding();

    if (showInfo == null || !showInfo) {
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              content: Container(
                height: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Style.body(
                      MyLocalizations.of(
                          context, 'camera_info_breeding_txt_01'),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Style.body(
                      MyLocalizations.of(
                          context, 'camera_info_breeding_txt_02'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Style.noBgButton(
                            MyLocalizations.of(context, "ok_next_txt"),
                            () {
                              Navigator.of(context).pop();
                              getImage(ImageSource.camera);
                            },
                            textColor: Style.colorPrimary,
                          ),
                        ),
                        Expanded(
                          child: Style.noBgButton(
                            MyLocalizations.of(context, "no_show_again"),
                            () {
                              UserManager.setSowInfoBreeding(true);
                              Navigator.of(context).pop();
                              getImage(ImageSource.camera);
                            },
                            // textColor: Style.colorPrimary,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
    } else {
      getImage(ImageSource.camera);
    }
  }

  static getSavedLanguage() async {
    language = await UserManager.getLanguage();
  }

  static String getLanguage() {
    getSavedLanguage();
    if (language == null) {
      String lan = ui.window.locale.languageCode;
      if (lan == 'es') {
        language = 'es';
      } else if (lan == 'ca') {
        language = 'ca';
      } else {
        language = 'es';
      }
    }

    return language;
  }

  static launchUrl(url) async {
    if (await canLaunch(url))
      await launch(url, forceSafariVC: false);
    else
      throw 'Could not launch';
  }

  //Manage Data
  static Position location;
  static LatLng defaultLocation = LatLng(41.3874, 2.1688);
}
