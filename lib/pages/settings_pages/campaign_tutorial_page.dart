import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class CampaignTutorialPage extends StatefulWidget {
  @override
  _CampaignTutorialPageState createState() => _CampaignTutorialPageState();
}

class _CampaignTutorialPageState extends State<CampaignTutorialPage> {
  List<Slide> slides = [];

  Function goToTab;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Style.title(MyLocalizations.of(context, "campaign_tutorial_txt",), fontSize: 16),
      ),
      body: IntroSlider(
        slides: initSlides(),
        isShowSkipBtn: false,
        renderNextBtn: renderNextBtn(),
        renderDoneBtn: renderDoneBtn(),
        onDonePress: onDonePress,
        colorDoneBtn: Style.colorPrimary.withOpacity(0.2),
        highlightColorDoneBtn: Style.colorPrimary,
        colorDot: Style.colorPrimary.withOpacity(0.4),
        sizeDot: 6.0,
        colorActiveDot: Style.colorPrimary,
        listCustomTabs: renderListCustomTabs(),
        backgroundColorAllSlides: Colors.white,
        refFuncGoToTab: (refFunc) {
          goToTab = refFunc;
        },
        shouldHideStatusBar: false,
        onTabChangeCompleted: onTabChangeCompleted,
      ),
    );
  }

  // Slide Management
  List<Slide> initSlides() {
    slides.clear();
    for (int idx = 0; idx < 9; idx ++) {
      slides.add(Slide(
          title: '',
          description: MyLocalizations.of(context, 'tutorial_send_module_00${idx+1}'),
          pathImage: 'assets/img/sendmodule/fg_module_00${idx+1}.png',
          backgroundImage: 'assets/img/sendmodule/fg_module_00${idx+1}.png'));
    }
    return slides;
  }
  void onDonePress() {
    Navigator.pop(context);
  }
  void onTabChangeCompleted(int page) {
  }
  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Style.colorPrimary,
      size: 35.0,
    );
  }
  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Style.colorPrimary,
    );
  }
  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Style.colorPrimary,
    );
  }
  List<Widget> renderListCustomTabs() {
    var tabs = <Widget>[];

    for (var i = 0; i < slides.length; i++) {
      var currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 0),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                  child: Image.asset(
                    currentSlide.pathImage,
                    width: MediaQuery.of(context).size.width ,
                    fit: BoxFit.cover,
                  )),
              Container(
                child: Text(
                  currentSlide.description,
                  textAlign: TextAlign.center,
                  maxLines: 20,
                ),
                margin: EdgeInsets.all(12.0),
              ),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

}
