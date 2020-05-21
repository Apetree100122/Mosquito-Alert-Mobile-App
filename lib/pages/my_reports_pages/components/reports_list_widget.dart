import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:intl/intl.dart';

class ReportsList extends StatelessWidget {
  final Function onTap;
  final List<Report> reports;

  ReportsList(this.reports, this.onTap);

  @override
  Widget build(BuildContext context) {
    if (UserManager.profileUUIDs == null) {
      return Center(
        child: Style.body(MyLocalizations.of(context, "no_reports_yet_txt")),
      );
    } else {
      return ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          if (UserManager.profileUUIDs != null &&
              UserManager.profileUUIDs.any((id) => id == reports[index].user)) {
            return GestureDetector(
              onTap: () {
                onTap(context, reports[index]);
              },
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      SvgPicture.asset(
                        reports[index].type == 'adult'
                            ? 'assets/img/ic_adults_yours.svg'
                            : reports[index].type == 'site'
                                ? 'assets/img/ic_breeding_yours.svg'
                                : 'assets/img/ic_bites_yours.svg',
                        width: 40,
                      ),
                      Container(height: 60, child: VerticalDivider()),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Style.titleMedium(
                                MyLocalizations.of(
                                        context, "report_of_the_day_txt") +
                                    DateFormat('dd-MM-yyyy')
                                        .format(DateTime.parse(
                                            reports[index].creation_time))
                                        .toString(),
                                fontSize: 14),
                            Style.body(
                                MyLocalizations.of(context, "location_txt") +
                                    "**Mi casa"),
                            Style.body(
                                MyLocalizations.of(context, "at_time_txt") +
                                    DateFormat.Hm()
                                        .format(DateTime.parse(
                                            reports[index].creation_time))
                                        .toString(),
                                color: Colors.grey),
                          ],
                        ),
                      ),
                      reports[index].photos.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                'http://humboldt.ceab.csic.es/media/' +
                                    reports[index].photos[0].photo,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ))
                          : Container(
                              // child: Style.title(
                              //     reports[index].version_number.toString()),
                              ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      );
    }
  }
}
