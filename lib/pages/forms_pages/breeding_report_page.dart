import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/biting_logation_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/public_breeding_site_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BreedingReportPage extends StatefulWidget {
  @override
  _BreedingReportPageState createState() => _BreedingReportPageState();
}

class _BreedingReportPageState extends State<BreedingReportPage> {
  final _pagesController = PageController();
  List _formsRepot;

  bool skipReport = false;

  setSkipReport() {
    setState(() {
      skipReport = !skipReport;
    });
  }

  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      PublicBreedingForm(setSkipReport),
      // TakePicturePage(),
      QuestionsBreedingForm(),
      BitingLocationForm(),
      // viste mosquitos ?
      AddOtherReportPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            double currentPage = _pagesController.page;
            if (currentPage == 0.0) {
              Navigator.pop(context);
            } else {
              _pagesController.previousPage(
                  duration: Duration(microseconds: 300), curve: Curves.ease);
            }
          },
        ),
        title: Style.title(MyLocalizations.of(context, "biting_report_txt"),
            fontSize: 16),
        actions: <Widget>[
          Style.noBgButton(
              false //TODO: show finish in last page
                  ? MyLocalizations.of(context, "finish")
                  : MyLocalizations.of(context, "next"),
              true
                  ? () {
                      double currentPage = _pagesController.page;
                      if (skipReport) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainVC()),
                        );
                      } else {
                        if (currentPage == _formsRepot.length - 1) {
                          // Utils.createReport();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MainVC()),
                          );
                        } else {
                          _pagesController.nextPage(
                              duration: Duration(microseconds: 300),
                              curve: Curves.ease);
                        }
                      }
                    }
                  : null)
        ],
      ),
      body: PageView.builder(
          controller: _pagesController,
          itemCount: _formsRepot.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _formsRepot[index];
          }),
    );
  }
}