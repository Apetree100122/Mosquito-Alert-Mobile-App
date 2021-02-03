import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/session.dart';
import 'package:mosquito_alert_app/pages/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:package_info/package_info.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import 'MyLocalizations.dart';

class Utils {
  static Locale language = Locale('en', 'US');
  static List<Map> imagePath;
  static double maskCoordsValue = 0.025;

  //Manage Data
  static Position location;
  static LatLng defaultLocation = LatLng(41.3874, 2.1688);
  static StreamController<int> userScoresController = StreamController<int>.broadcast();

  //REPORTS
  static Report report;
  static Session session;
  static List<Report> reportsList;
  static Report savedAdultReport;

  static void saveImgPath(File img) {
    if (imagePath == null) {
      imagePath = [];
    }
    imagePath.add({'image': img.path, 'id': report.version_UUID, 'imageFile': img});
  }

  static void deleteImage(String image) {
    imagePath.removeWhere((element) => element['image'] == image);
  }

  static void closeSession() {
    session.session_end_time = DateTime.now().toIso8601String();
    ApiSingleton().closeSession(session);
  }

  static Future<bool> createNewReport(String type, {lat, lon, locationType}) async {
    if (session == null) {
      reportsList = [];

      String userUUID = await UserManager.getUUID();

      int sessionId = await ApiSingleton().getLastSession(userUUID);
      sessionId = sessionId + 1;

      session = new Session(session_ID: sessionId, user: userUUID, session_start_time: DateTime.now().toIso8601String());

      print(language);

      session.id = await ApiSingleton().createSession(session);
    }

    if (session.id != null && language != null) {
      var lang = await UserManager.getLanguage();
      var userUUID = await UserManager.getUUID();
      report = new Report(type: type, report_id: randomAlphaNumeric(4).toString(), version_number: 0, version_UUID: new Uuid().v4(), user: userUUID, session: session.id, responses: []);

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      report.package_name = packageInfo.packageName;
      report.package_version = 32;

      if (Platform.isAndroid) {
        var buildData = await DeviceInfoPlugin().androidInfo;
        report.device_manufacturer = buildData.manufacturer;
        report.device_model = buildData.model;
        report.os = 'Android';
        report.os_language = language.languageCode;
        report.os_version = buildData.version.sdkInt.toString();
        report.app_language = lang != null ? lang : language.languageCode;
      } else if (Platform.isIOS) {
        var buildData = await DeviceInfoPlugin().iosInfo;
        report.device_manufacturer = 'Apple';
        report.device_model = buildData.model;
        report.os = buildData.systemName;
        report.os_language = language.languageCode;
        report.os_version = buildData.systemVersion;
        report.app_language = lang != null ? lang : language.languageCode;
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
    resetReport();
    report = editReport;
    report.version_number = report.version_number + 1;
    report.version_UUID = new Uuid().v4();

    if (editReport.photos != null || editReport.photos.isNotEmpty) {
      imagePath = [];
      editReport.photos.forEach((element) {
        imagePath.add({
          'image': '${ApiSingleton.baseUrl}/media/${element.photo}',
          // 'image': 'http://webserver.mosquitoalert.com/media/${element.photo}',
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
      createNewReport(type, lat: reportsList.last.selected_location_lat, lon: reportsList.last.selected_location_lon, locationType: 'selected');
    } else {
      createNewReport(type, lat: reportsList.last.current_location_lat, lon: reportsList.last.current_location_lon, locationType: 'current');
    }
  }

  static deleteLastReport() {
    report = null;
    report = new Report.fromJson(reportsList.last.toJson());
    reportsList.removeLast();
    print(reportsList);
  }

  static setCurrentLocation(double latitude, double longitude) {
    report.location_choice = 'current';
    report.selected_location_lat = null;
    report.selected_location_lon = null;
    report.current_location_lat = latitude;
    report.current_location_lon = longitude;
  }

  static setSelectedLocation(double lat, lon) {
    report.location_choice = "selected";
    report.current_location_lat = null;
    report.current_location_lon = null;
    report.selected_location_lat = lat;
    report.selected_location_lon = lon;
  }

  static void addBiteResponse(String question, String answer, {question_id, answer_id, answer_value}) {
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
          answer: 'N/A',
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
        if (_questions.any((q) => q.question_id == question_id && q.answer_id != answer_id)) {
          //modify question
          int index = _questions.indexWhere((q) => q.question_id == question_id);
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
    int index = _questions.indexWhere((q) => q.answer_id > i && q.answer_id < i + 10);
    if (index != -1) {
      if (_questions[index].answer_id == answerId) {
        _questions.removeAt(index);
      } else {
        _questions[index].answer_id = answerId;
        _questions[index].answer = answer;
      }
    } else {
      Question newQuestion = new Question(
        question: 'question_7',
        answer: answer,
        question_id: 7,
        answer_id: answerId,
      );
      _questions.add(newQuestion);
    }
    report.responses = _questions;
  }

  static void addResponse(Question question) {
    int index = report.responses.indexWhere((q) => q.question_id == question.question_id);
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

  static Future<bool> createReport() async {
    if (report.version_number > 0) {
      report.version_time = DateTime.now().toIso8601String();
      var res = await ApiSingleton().createReport(report);
      if (res.type == 'adult') {
        savedAdultReport = res;
      }
      return res != null ? true : false;
    } else {
      report.version_time = DateTime.now().toIso8601String();
      report.creation_time = DateTime.now().toIso8601String();
      report.phone_upload_time = DateTime.now().toIso8601String();
      reportsList.add(report);
      bool isCreated;
      for (int i = 0; i < reportsList.length; i++) {
        var res = await ApiSingleton().createReport(reportsList[i]);
        if (res.type == 'adult') {
          savedAdultReport = res;
        }
        isCreated = res != null ? true : false;
        if (!isCreated) {
          await saveLocalReport(reportsList[i]);
        }
      }

      closeSession();
      // resetReport();
      // imagePath = [];
      return isCreated;
    }
  }

  static Future<void> saveLocalReport(Report report) async {
    List<String> savedReports = await UserManager.getReportList();
    if (savedReports == null || savedReports.isEmpty) {
      savedReports = [];
    }
    String reportString = json.encode(report.toJson());
    savedReports.add(reportString);
    await UserManager.setReportList(savedReports);
  }

  static Future<void> saveLocalImage(String image, String version_UUID) async {
    List<String> savedImages = await UserManager.getImageList();
    if (savedImages == null || savedImages.isEmpty) {
      savedImages = [];
    }

    String imageString = json.encode({'image': image, 'verison_UUID': version_UUID});
    savedImages.add(imageString);
    await UserManager.setImageList(savedImages);
  }

  static void syncReports() async {
    List savedReports = await UserManager.getReportList();
    List savedImages = await UserManager.getImageList();

    await UserManager.setReportList(<String>[]);
    await UserManager.setImageList(<String>[]);

    if (savedReports != null && savedReports.isNotEmpty) {
      bool isCreated;
      for (int i = 0; i < savedReports.length; i++) {
        Report savedReport = Report.fromJson(json.decode(savedReports[i]));
        isCreated = await ApiSingleton().createReport(savedReport) != null ? true : false;

        if (!isCreated) {
          saveLocalReport(savedReport);
        }
      }
    }

    if (savedImages != null && savedImages.isNotEmpty) {
      bool isCreated;
      for (int i = 0; i < savedImages.length; i++) {
        Map image = json.decode(savedImages[i]);
        isCreated = await ApiSingleton().saveImage(image['image'], image['verison_UUID']);
        if (!isCreated) {
          saveLocalImage(image['image'], image['verison_UUID']);
        } else {
          await File(image['image']).delete();
        }
      }
    }
  }

  static Future<bool> deleteReport(r) async {
    Report deleteReport = r;
    deleteReport.version_time = DateTime.now().toIso8601String();
    deleteReport.version_number = -1;
    deleteReport.version_UUID = Uuid().v4();

    bool res = await ApiSingleton().createReport(deleteReport) != null ? true : false;
    return res;
  }

  static getLocation() async {
    location = await getLastKnownPosition();
  }

  static final RegExp mailRegExp = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  //Alerts
  static Future showAlert(String title, String text, BuildContext context, {onPressed, barrierDismissible}) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible != null ? barrierDismissible : true, // user must tap button!
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

  static Future showCustomAlert(String title, Widget body, BuildContext context, {onPressed, barrierDismissible}) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible != null ? barrierDismissible : true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  body,
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
                body,
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

  static Future modalDetailTrackingforPlatform(List<Widget> list, TargetPlatform platform, BuildContext context, Function close, {title, cancelButton}) {
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
                              padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
                              child: Text(title, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400)),
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
            Text('${MyLocalizations.of(context, 'terms_and_conditions_txt1')} ', style: TextStyle(color: Style.textColor, fontSize: 12)),
            InkWell(
              onTap: () async {
                final url = MyLocalizations.of(context, 'url_politics');
                if (await canLaunch(url))
                  await launch(url);
                else
                  throw 'Could not launch $url';
              },
              child: Text(MyLocalizations.of(context, 'terms_and_conditions_txt2'), style: TextStyle(color: Style.textColor, fontSize: 12, decoration: TextDecoration.underline)),
            ),
            Text(' ${MyLocalizations.of(context, 'terms_and_conditions_txt3')} ', style: TextStyle(color: Style.textColor, fontSize: 12)),
            InkWell(
              onTap: () async {
                final url = MyLocalizations.of(context, 'url_legal');
                if (await canLaunch(url))
                  await launch(url);
                else
                  throw 'Could not launch $url';
              },
              child: Text(MyLocalizations.of(context, 'terms_and_conditions_txt4'), style: TextStyle(color: Style.textColor, fontSize: 12, decoration: TextDecoration.underline)),
            ),
            Text('.', style: TextStyle(color: Style.textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  static Widget loading(_isLoading, [Color indicatorColor]) {
    return _isLoading == true
        ? IgnorePointer(
            child: Container(
            color: Colors.transparent,
            child: Center(
              child: new CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(indicatorColor == null ? Style.colorPrimary : indicatorColor),
              ),
            ),
          ))
        : new Container();
  }

  static infoAdultCamera(context, getImage, {bool gallery = false}) async {
    var showInfo = await UserManager.getShowInfoAdult();
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
                  maxHeight: MediaQuery.of(context).size.height * 0.50,
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
                            MyLocalizations.of(context, 'ok_next_txt'),
                            () {
                              Navigator.of(context).pop();
                              !gallery ? getImage(ImageSource.camera) : getImage();
                            },
                            textColor: Style.colorPrimary,
                          ),
                        ),
                        Expanded(
                          child: Style.noBgButton(
                            MyLocalizations.of(context, "no_show_again"),
                            () {
                              !gallery ? getImage(ImageSource.camera) : getImage();
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
      !gallery ? getImage(ImageSource.camera) : getImage();
    }
  }

  static infoBreedingCamera(context, getImage, {bool gallery = false}) async {
    var showInfo = await UserManager.getShowInfoBreeding();

    if (showInfo == null || !showInfo) {
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              content: Container(
                // height: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: Column(
                  children: <Widget>[
                    Style.body(
                      MyLocalizations.of(context, 'camera_info_breeding_txt_01'),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Style.body(
                      MyLocalizations.of(context, 'camera_info_breeding_txt_02'),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Style.noBgButton(
                            MyLocalizations.of(context, 'ok_next_txt'),
                            () {
                              Navigator.of(context).pop();
                              !gallery ? getImage(ImageSource.camera) : getImage();
                            },
                            textColor: Style.colorPrimary,
                          ),
                        ),
                        Expanded(
                          child: Style.noBgButton(
                            MyLocalizations.of(context, 'no_show_again'),
                            () {
                              UserManager.setSowInfoBreeding(true);
                              Navigator.of(context).pop();
                              !gallery ? getImage(ImageSource.camera) : getImage();
                            },
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
      !gallery ? getImage(ImageSource.camera) : getImage();
    }
  }

  static showAlertCampaign(ctx, activeCampaign, onPressed) {
    if (Platform.isAndroid) {
      return showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              MyLocalizations.of(context, 'app_name'),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Style.body(MyLocalizations.of(context, 'save_report_ok_txt')), Style.body(MyLocalizations.of(context, 'alert_campaign_found_create_body'))],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/img/sendmodule/ic_adn.svg",
                        color: Style.colorPrimary,
                        height: 20,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(MyLocalizations.of(context, 'show_info'))
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CampaignTutorialPage()),
                    );
                    onPressed(context);
                  }),
              FlatButton(
                child: Text(MyLocalizations.of(context, 'no_show_info')),
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  Utils.resetReport();
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              MyLocalizations.of(context, 'app_name'),
              style: TextStyle(letterSpacing: -0.3),
            ),
            content: Column(
              children: <Widget>[
                SizedBox(
                  height: 4,
                ),
                Style.body(MyLocalizations.of(context, 'save_report_ok_txt'), textAlign: TextAlign.center),
                SizedBox(
                  height: 8,
                ),
                Style.body(MyLocalizations.of(context, 'alert_campaign_found_create_body'), textAlign: TextAlign.center)
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/img/sendmodule/ic_adn.svg",
                        color: Colors.blueAccent,
                        height: 20,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(MyLocalizations.of(context, 'show_info'))
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CampaignTutorialPage()),
                    );
                    onPressed(context);
                  }),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(MyLocalizations.of(context, 'no_show_info')),
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  Utils.resetReport();
                },
              ),
            ],
          );
        },
      );
    }
  }

  static getLanguage() {
    if (ui.window != null && ui.window.locale != null) {
      String stringLanguange = ui.window.locale.languageCode;
      String stringCountry = ui.window.locale.countryCode;

      if (stringLanguange == "es" && stringCountry == 'ES' ||
          stringLanguange == "ca" && stringCountry == 'ES' ||
          stringLanguange == "en" && stringCountry == 'US' ||
          stringLanguange == "sq" ||
          stringLanguange == "bg" ||
          stringLanguange == "nl" ||
          stringLanguange == "de" ||
          stringLanguange == "it" ||
          stringLanguange == "pt" ||
          stringLanguange == "ro") {
        language = ui.window.locale;
      }
    } else {
      language = Locale('en', 'US');
    }

    return language;
  }

  static launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      throw 'Could not launch';
    }
  }
}
