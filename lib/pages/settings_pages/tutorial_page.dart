import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class TutorialPage extends StatefulWidget {
  bool goBack;
  TutorialPage(this.goBack);
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  List<Slide> slides = new List();

  Function goToTab;

  @override
  void initState() {
    super.initState();
  }

  List<Slide> initSlides() {
    slides.add(new Slide(
      title: "",
      description: MyLocalizations.of(context, "tutorial_info_01"),
      pathImage: "assets/img/tutorial/Fig1.png",
    ));
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "tutorial_info_02"),
        pathImage: "assets/img/tutorial/Fig2.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "tutorial_info_03"),
        pathImage: "assets/img/tutorial/Fig3.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "tutorial_info_04"),
        pathImage: "assets/img/tutorial/Fig4.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_05"),
        description: MyLocalizations.of(context, "tutorial_info_05"),
        pathImage: "assets/img/tutorial/Fig5.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_06"),
        description: MyLocalizations.of(context, "tutorial_info_06"),
        pathImage: "assets/img/tutorial/Fig6.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_07"),
        description: MyLocalizations.of(context, "tutorial_info_07"),
        pathImage: "assets/img/tutorial/Fig7.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_08"),
        description: MyLocalizations.of(context, "tutorial_info_08"),
        pathImage: "assets/img/tutorial/Fig8.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_09"),
        description: MyLocalizations.of(context, "tutorial_info_09"),
        pathImage: "assets/img/tutorial/Fig9.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_10"),
        description: MyLocalizations.of(context, "tutorial_info_10"),
        pathImage: "assets/img/tutorial/Fig10.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_11"),
        description: MyLocalizations.of(context, "tutorial_info_11"),
        pathImage: "assets/img/tutorial/Fig11.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_12"),
        description: MyLocalizations.of(context, "tutorial_info_12"),
        pathImage: "assets/img/tutorial/Fig12.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_13"),
        description: MyLocalizations.of(context, "tutorial_info_13"),
        pathImage: "assets/img/tutorial/Fig13.png",
      ),
    );
    slides.add(
      new Slide(
        title: MyLocalizations.of(context, "tutorial_title_14"),
        description: MyLocalizations.of(context, "tutorial_info_14"),
        pathImage: "assets/img/tutorial/Fig14.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "tutorial_info_15"),
        pathImage: "assets/img/tutorial/Fig1.png",
      ),
    );
    return slides;
  }

  void onDonePress() {
    // Back to the first tab
    // this.goToTab(0);
    Navigator.pop(context);
  }

  void onTabChangeCompleted(index) {
    // Index of current tab is focused
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Style.colorPrimary,
      size: 25.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Style.colorPrimary,
    );
  }

  List<Widget> renderListCustomTabs() {
    List<Widget> tabs = new List();
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                  child: Image.asset(
                currentSlide.pathImage,
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.55,
                fit: BoxFit.contain,
              )),
              Container(
                child: Style.titleMedium(
                  currentSlide.title,
                  // style: currentSlide.styleTitle,
                  textAlign: TextAlign.center,
                  fontSize: 14,
                ),
                // margin: EdgeInsets.only(top: 20.0),
              ),
              Container(
                child: Style.body(
                  currentSlide.description,
                  // style: currentSlide.styleDescription,
                  textAlign: TextAlign.center,
                  maxLines: 15,
                  // overflow: TextOverflow.ellipsis,
                ),
                margin: EdgeInsets.all(20.0),
              ),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Style.title(MyLocalizations.of(context, 'tutorial_txt'),
            fontSize: 16),
        leading: widget.goBack
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : Container(),
      ),
      body: new IntroSlider(
        // List slides
        slides: initSlides(),

        //skip button
        isShowSkipBtn: false,

        // Next button
        renderNextBtn: this.renderNextBtn(),

        // Done button
        renderDoneBtn: this.renderDoneBtn(),
        onDonePress: this.onDonePress,
        colorDoneBtn: Style.colorPrimary.withOpacity(0.2),
        highlightColorDoneBtn: Style.colorPrimary,

        // Dot indicator
        colorDot: Style.colorPrimary.withOpacity(0.4),
        sizeDot: 5.0,
        colorActiveDot: Style.colorPrimary,
        // typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,

        // Tabs
        listCustomTabs: this.renderListCustomTabs(),
        backgroundColorAllSlides: Colors.white,
        refFuncGoToTab: (refFunc) {
          this.goToTab = refFunc;
        },

        // Show or hide status bar
        shouldHideStatusBar: false,

        // On tab change completed
        onTabChangeCompleted: this.onTabChangeCompleted,
      ),
    );
  }
}
