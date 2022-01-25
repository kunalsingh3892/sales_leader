
import 'dart:ui';

import 'package:flutter/material.dart';

const String BASE_URL = "dev.techstreet.in";
const String API_PATH = "/salesleader/public/api";
const String URL1 = "https://lms.glenindia.com/api/";
const String URL = "https://dev.techstreet.in/salesleader/public/api/";
const Color primaryColor = Color(0xff9b56ff);
const Color primaryColorLight = Color(0xff9b56ff);
const Color drawerColoPrimary = Color(0xff9b56ff);
const String ALERT_DIALOG_TITLE = "Alert";

final String path = 'assets/images/';

final List<Draw> drawerItems = [
 /* Draw(title: 'Orders', icon: path + 'orders.png'),
  Draw(title: 'Sales Targets', icon:  path + 'sales.png'),
  Draw(title: 'Expensive Reimbursements', icon: path + 'expenses.png'),*/
  Draw(title: 'Company Promotion', icon:  path + 'promotion.png'),
  Draw(title: 'Competition Promotion', icon: path + 'competition.png'),
];


final List categories = [
  {'image': path + 'leads.png', 'title': 'Leads'},
  {'image': path + 'visits.png', 'title': 'Visits'},
  {'image': path + 'tours.png', 'title': 'Tours'},
  {'image': path + 'attendance.png', 'title': 'Attendance'},
  {'image': path + 'dealer.png', 'title': 'Add Contact'},
  {'image': path + 'orders.png', 'title': 'Orders'},
  {'image': path + 'expenses.png', 'title': 'Expense Reimbursements'},
  {'image': path + 'promotion.png', 'title': 'Company Promotion'},
  {'image': path + 'competition.png', 'title': 'Competition Promotion'},
  {'image': path + 'sales.png', 'title': 'Sales Target'},
  {'image': path + 'achievement.png', 'title': 'Target Achievement'},
  {'image': path + 'worker.png', 'title': 'My Dealer/Dist.'},

];
final List categories1 = [
  {'image': path + 'leads.png', 'title': 'Leads'},

];


class Draw {
  final String title;
  final String icon;
  Draw({this.title, this.icon});
}
