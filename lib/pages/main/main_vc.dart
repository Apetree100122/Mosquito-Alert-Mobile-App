import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/pages/info_pages/points_info_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_wodget.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MainVC extends StatefulWidget {
  @override
  _MainVCState createState() => _MainVCState();
}

class _MainVCState extends State<MainVC> {
  String userName;
  int userScore = 1;

  @override
  void initState() {
    super.initState();
    UserManager.startFirstTime(context);
    _getData();
  }

  _getData() async {
    var user = await UserManager.fetchUser();
    int points = await UserManager.getUserScores();
    if (user != null && user.displayName != null && points != null) {
      setState(() {
        userName = user.displayName;
        userScore = points;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.settings,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          title: Image.asset(
            'assets/img/ic_logo.png',
            height: 40,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            )
          ],
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 24,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Style.title(
                                              userName != null
                                                  ? " ${MyLocalizations.of(context, "welcome_text")}, $userName."
                                                  : " ${MyLocalizations.of(context, "welcome_text")}",
                                              fontSize: 20),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Style.body(
                                              MyLocalizations.of(
                                                  context, "what_to_do_txt"),
                                              fontSize: 14),
                                        ]),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PointsInfo()),
                                      );
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/img/points_box.png"),
                                        ),
                                      ),
                                      child: Center(
                                          child: AutoSizeText(
                                        userScore != null
                                            ? userScore.toString()
                                            : '',
                                        maxLines: 1,
                                        maxFontSize: 26,
                                        minFontSize: 16,
                                        style: TextStyle(
                                            color: Color(0xFF4B3D04),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 24),
                                      )),
                                    ),
                                  ),
                                ]),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Divider(),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BitingReportPage()),
                                      );
                                    },
                                    child: CustomCard(
                                      img: 'assets/img/ic_bite_report.png',
                                      title: MyLocalizations.of(
                                          context, 'report_biting_txt'),
                                      subtitle: MyLocalizations.of(context,
                                          'bitten_by_mosquito_question_txt'),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AdultReportPage()),
                                      );
                                    },
                                    child: CustomCard(
                                      img: 'assets/img/ic_mosquito_report.png',
                                      title: MyLocalizations.of(
                                          context, 'report_adults_txt'),
                                      subtitle: MyLocalizations.of(context,
                                          'report_us_adult_mosquitos_txt'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BreedingReportPage()),
                                    );
                                  },
                                  child: CustomCard(
                                    img: 'assets/img/ic_breeding_report.png',
                                    title: MyLocalizations.of(
                                        context, 'report_nest_txt'),
                                    subtitle: MyLocalizations.of(context,
                                        'found_breeding_place_question_txt'),
                                  ),
                                )),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MyReportsPage()),
                                    );
                                  },
                                  child: CustomCard(
                                    img: 'assets/img/ic_my_reports.png',
                                    title: MyLocalizations.of(
                                        context, 'your_reports_txt'),
                                    subtitle: MyLocalizations.of(
                                        context, 'explore_your_reports_txt'),
                                  ),
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // Card(
                            //   elevation: 2,
                            //   shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(20)),
                            //   child: Container(
                            //     padding: EdgeInsets.only(left: 20, right: 10, top: 15, bottom: 15),
                            //     child: Row(
                            //       children: <Widget>[
                            //         Image.asset(
                            //           'assets/img/ic_validate_photos.png',
                            //           width: 55,
                            //           fit: BoxFit.fitWidth,
                            //         ),
                            //         SizedBox(width: 15,),
                            //         Expanded(
                            //           flex: 2,
                            //           child: Column(
                            //             children: <Widget>[
                            //               Style.titleMedium(
                            //                   MyLocalizations.of(context,
                            //                       'help_validating_other_photos_txt'),
                            //                   fontSize: 16),
                            //               SizedBox(
                            //                 height: 5,
                            //               ),
                            //               Style.bodySmall(MyLocalizations.of(
                            //                   context, 'we_need_help_txt')),
                            //               SizedBox(
                            //                 height: 5,
                            //               ),
                            //             ],
                            //           ),
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(top: 25),
                          child: SvgPicture.asset(
                            'assets/img/ic_bottom_waves.svg',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
