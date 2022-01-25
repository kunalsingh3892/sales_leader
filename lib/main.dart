
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glen_lms/screens/dasboard.dart';
import 'package:glen_lms/screens/dashboard_screens/add_competitorpromotions.dart';
import 'package:glen_lms/screens/dashboard_screens/add_dealer.dart';
import 'package:glen_lms/screens/dashboard_screens/add_expense.dart';
import 'package:glen_lms/screens/dashboard_screens/add_glenpromotions.dart';
import 'package:glen_lms/screens/dashboard_screens/add_order.dart';
import 'package:glen_lms/screens/dashboard_screens/add_salestarget.dart';
import 'package:glen_lms/screens/dashboard_screens/add_tour.dart';
import 'package:glen_lms/screens/dashboard_screens/add_visits.dart';
import 'package:glen_lms/screens/dashboard_screens/approved_tours.dart';
import 'package:glen_lms/screens/dashboard_screens/assign_ocp.dart';
import 'package:glen_lms/screens/dashboard_screens/attendance.dart';
import 'package:glen_lms/screens/dashboard_screens/comp_details.dart';
import 'package:glen_lms/screens/dashboard_screens/competitor_promotionlist.dart';
import 'package:glen_lms/screens/dashboard_screens/completed_tours.dart';
import 'package:glen_lms/screens/dashboard_screens/contacts.dart';
import 'package:glen_lms/screens/dashboard_screens/da_list.dart';
import 'package:glen_lms/screens/dashboard_screens/dealer_detail.dart';
import 'package:glen_lms/screens/dashboard_screens/dealer_list.dart';

import 'package:glen_lms/screens/dashboard_screens/dummy.dart';
import 'package:glen_lms/screens/dashboard_screens/edit_expense.dart';
import 'package:glen_lms/screens/dashboard_screens/expense.dart';
import 'package:glen_lms/screens/dashboard_screens/expense_approved.dart';
import 'package:glen_lms/screens/dashboard_screens/expense_details.dart';
import 'package:glen_lms/screens/dashboard_screens/expense_pending.dart';
import 'package:glen_lms/screens/dashboard_screens/expense_tour_details.dart';
import 'package:glen_lms/screens/dashboard_screens/extend_tour.dart';
import 'package:glen_lms/screens/dashboard_screens/glen_details.dart';
import 'package:glen_lms/screens/dashboard_screens/glen_promotionlist.dart';
import 'package:glen_lms/screens/dashboard_screens/influencer_details.dart';
import 'package:glen_lms/screens/dashboard_screens/lead_details.dart';
import 'package:glen_lms/screens/dashboard_screens/lead_history.dart';
import 'package:glen_lms/screens/dashboard_screens/my_attendance.dart';
import 'package:glen_lms/screens/dashboard_screens/my_dealers.dart';
import 'package:glen_lms/screens/dashboard_screens/my_leads.dart';
import 'package:glen_lms/screens/dashboard_screens/my_tours.dart';
import 'package:glen_lms/screens/dashboard_screens/my_visits.dart';
import 'package:glen_lms/screens/dashboard_screens/notification_list.dart';
import 'package:glen_lms/screens/dashboard_screens/order_details.dart';
import 'package:glen_lms/screens/dashboard_screens/order_list.dart';
import 'package:glen_lms/screens/dashboard_screens/pending_for_approval_tour.dart';
import 'package:glen_lms/screens/dashboard_screens/pending_tour_expense.dart';
import 'package:glen_lms/screens/dashboard_screens/pending_tours.dart';
import 'package:glen_lms/screens/dashboard_screens/product_list.dart';
import 'package:glen_lms/screens/dashboard_screens/profile_screen.dart';
import 'package:glen_lms/screens/dashboard_screens/sales_executive_view_expense.dart';
import 'package:glen_lms/screens/dashboard_screens/splash.dart';
import 'package:glen_lms/screens/dashboard_screens/sub_dashboard.dart';
import 'package:glen_lms/screens/dashboard_screens/target_achievement.dart';
import 'package:glen_lms/screens/dashboard_screens/target_details.dart';
import 'package:glen_lms/screens/dashboard_screens/team_pendingexpense.dart';
import 'package:glen_lms/screens/dashboard_screens/team_pendingtours.dart';
import 'package:glen_lms/screens/dashboard_screens/teamlead_details.dart';
import 'package:glen_lms/screens/dashboard_screens/tour_details.dart';
import 'package:glen_lms/screens/dashboard_screens/tour_detailsextended.dart';
import 'package:glen_lms/screens/dashboard_screens/tours.dart';
import 'package:glen_lms/screens/dashboard_screens/tree_page.dart';
import 'package:glen_lms/screens/dashboard_screens/update_lead.dart';
import 'package:glen_lms/screens/dashboard_screens/view_salestarget.dart';
import 'package:glen_lms/screens/dashboard_screens/visit_details.dart';
import 'package:glen_lms/screens/home_screen.dart';
import 'package:glen_lms/screens/login.dart';
import 'package:glen_lms/screens/otp_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modal/product_modal.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  void initState() {
    super.initState();

    // _checkLoggedIn();
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Leader',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color(0xff9b56ff)),
      ),
      debugShowCheckedModeBanner: false,

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return PageTransition(
              child: LoginPage(),
              type: null,
              settings: settings,
            );
            break;

          case '/otp-screen':
            var obj = settings.arguments;
            return PageTransition(
              child: OtpScreen(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/dashboard':
            return PageTransition(
              child: Dashboard(),
              type: null,
              settings: settings,
            );
            break;
        /* case '/my-attendance':
            return PageTransition(
              child: SearchableDropdownApp(),
              type: null,
              settings: settings,
            );
            break;*/
          case '/my-leads':
            var obj = settings.arguments;
            return PageTransition(
              child: MyLeads(argument: obj),
              type: null,
              settings: settings,
            );
            break;


          case '/tours':
            var obj = settings.arguments;
            return PageTransition(
              child: AllTours(argument: obj),
              type: null,
              settings: settings,
            );
            break;


          case '/my-visits':
            var obj = settings.arguments;
            return PageTransition(
              child: MyVisits(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/my-dealers':
            var obj = settings.arguments;
            return PageTransition(
              child: MyDealers(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/schedule-visits':
            return PageTransition(
              child: MyVisits(),
              type: null,
              settings: settings,
            );
            break;
          case '/home-screen':
            return PageTransition(
              child: HomePage(),
              type: null,
              settings: settings,
            );
            break;
          case '/lead-details':
            var obj = settings.arguments;
            return PageTransition(
              child: LeadDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/teamlead-details':
            var obj = settings.arguments;
            return PageTransition(
              child: TeamLeadDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/visit-details':
            var obj = settings.arguments;
            return PageTransition(
              child: VisitDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/tour-details':
            var obj = settings.arguments;
            return PageTransition(
              child: TourDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/add-tour':
            return PageTransition(
              child: AddTour(),
              type: null,
              settings: settings,
            );
            break;
          case '/extend-tour':
            var obj = settings.arguments;
            return PageTransition(
              child: ExtendTour(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/add-dealer':
            return PageTransition(
              child: AddDealer(),
              type: null,
              settings: settings,
            );
            break;
          case '/dealer-detail':
            var obj = settings.arguments;
            return PageTransition(
              child: DealerDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/influencer-details':
            var obj = settings.arguments;
            return PageTransition(
              child: InfluencerDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/add-glenpromotionslist':
            return PageTransition(
              child: AddGlenPromotion(),
              type: null,
              settings: settings,
            );
            break;
          case '/add-competitorpromotions':
            return PageTransition(
              child: AddCompetitorPromotion(),
              type: null,
              settings: settings,
            );
            break;
          case '/glen-promotionlist':
            return PageTransition(
              child: GlenPromotionList(),
              type: null,
              settings: settings,
            );
            break;
          case '/competitor-promotionlist':
            return PageTransition(
              child: CompetitorPromotionList(),
              type: null,
              settings: settings,
            );
            break;
          case '/dealer-list':
            return PageTransition(
              child: AllDealers(),
              type: null,
              settings: settings,
            );
            break;
          case '/profile-screen':
            return PageTransition(
              child: ProfilePage(),
              type: null,
              settings: settings,
            );
            break;
          case '/add-order':
            var obj = settings.arguments;
            return PageTransition(
              child: AddOrder(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/order-list':
            var obj = settings.arguments;
            return PageTransition(
              child: MyOrders(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/order-details':
            var obj = settings.arguments;
            return PageTransition(
              child: OrderDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/product-list':
            var obj = settings.arguments;
            return PageTransition(
              child: ProductList(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/view-salestarget':
            var obj = settings.arguments;
            return PageTransition(
              child: SalesList(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/target-achievement':
            var obj = settings.arguments;
            return PageTransition(
              child: SalesAchievementList(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/add-salestarget':
            var obj = settings.arguments;
            return PageTransition(
              child: AddSalesTarget(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/add-visits':
            var obj = settings.arguments;
            return PageTransition(
              child: AddVisits(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/target-details':
            var obj = settings.arguments;
            return PageTransition(
              child: SalesTargetDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/expense':
            var obj = settings.arguments;
            return PageTransition(
              child: AllExpense(argument: obj),
              type: null,
              settings: settings,
            );
            break;


          case '/dummy':
            var obj = settings.arguments;
            return PageTransition(
              child: Dummy(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/add-expense':
            var obj = settings.arguments;
            return PageTransition(
              child: AddExpense(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/expense-details':
            var obj = settings.arguments;
            return PageTransition(
              child: ExpenseDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/edit-expense':
            var obj = settings.arguments;
            return PageTransition(
              child: EditExpense(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/glen-details':
            var obj = settings.arguments;
            return PageTransition(
              child: GlenDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/comp-details':
            var obj = settings.arguments;
            return PageTransition(
              child: CompetitionDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/update-lead':
            var obj = settings.arguments;
            return PageTransition(
              child: UpdateLead(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/assign-ocp':
            var obj = settings.arguments;
            return PageTransition(
              child: AssignOCP(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/lead-history':
            var obj = settings.arguments;
            return PageTransition(
              child: History(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/sub-dashboard':
            var obj = settings.arguments;
            return PageTransition(
              child: SubHomePage(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/tree-page':
            var obj = settings.arguments;
            return PageTransition(
              child: MyTeams(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/pending-tour-expense':
            var obj = settings.arguments;
            return PageTransition(
              child: PendingTours1(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/pending-for-approval-tour':
            var obj = settings.arguments;
            return PageTransition(
              child: PendingForApprovalTours(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/tour-detailsextended':
            var obj = settings.arguments;
            return PageTransition(
              child: ExtendedTourDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/attendance':
            var obj = settings.arguments;
            return PageTransition(
              child: TodayVisit(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/expense-tour-details':
            var obj = settings.arguments;
            return PageTransition(
              child: TeamExpensePendingDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/da-list':

            return PageTransition(
              child: DAList(),
              type: null,
              settings: settings,
            );
            break;

          case '/notification-list':
            return PageTransition(
              child: NotificationList(),
              type: null,
              settings: settings,
            );
            break;
          case '/sales-executive-view-expense':
            var obj = settings.arguments;
            return PageTransition(
              child: SalesExecutivePendingDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/splash':

            return PageTransition(
              child: SplashScreen(),
              type: null,
              settings: settings,
            );
            break;

          default:
            return null;
        }
      },
      home: Scaffold(
        body:   homeOrLog(),


      ),
    );

  }
  Widget homeOrLog(){
    return SplashScreen();

  }
}
