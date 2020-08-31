import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Slide> slides = new List();

  Function goToTab;

  @override
  void initState() {
    super.initState();
  }

  List<Slide> initSlides() {
    slides.add(new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_01"),
        pathImage: "assets/img/gallery/guia_1.png",
        backgroundImage: "assets/img/gallery/guia_1.png"));
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_02"),
        pathImage: "assets/img/gallery/guia_2.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_03"),
        pathImage: "assets/img/gallery/guia_3.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_04"),
        pathImage: "assets/img/gallery/guia_4.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_05"),
        pathImage: "assets/img/gallery/guia_5.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_06"),
        pathImage: "assets/img/gallery/guia_6.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_07"),
        pathImage: "assets/img/gallery/guia_7.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_08"),
        pathImage: "assets/img/gallery/guia_8.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_09"),
        pathImage: "assets/img/gallery/guia_9.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_10"),
        pathImage: "assets/img/gallery/guia_10.png",
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description: MyLocalizations.of(context, "gallery_info_11"),
        pathImage: "assets/img/gallery/guia_11.png",
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
    List<Widget> tabs = new List();
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 40),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                  child: Image.asset(
                currentSlide.pathImage,
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
                fit: BoxFit.contain,
              )),
              // Container(
              //   child: Text(
              //     currentSlide.title,
              //     style: currentSlide.styleTitle,
              //     textAlign: TextAlign.center,
              //   ),
              //   margin: EdgeInsets.only(top: 20.0),
              // ),
              Container(
                child: Text(
                  currentSlide.description,
                  // style: currentSlide.styleDescription,
                  textAlign: TextAlign.center,
                  maxLines: 10,
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
        title: Style.title(MyLocalizations.of(context, 'mosquitos_gallery_txt'),
            fontSize: 16),
      ),
      body: new IntroSlider(
        // List slides
        slides: initSlides(),

        // Skip button

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
        sizeDot: 6.0,
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
