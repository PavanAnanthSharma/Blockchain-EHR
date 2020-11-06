import 'package:doctor/landingpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'add_record.dart';
import 'providers/record_provider.dart';
import 'providers/userauth_provider.dart';
import 'providers/node_provider.dart';
import 'records_detail.dart';
import 'screen.dart';
import 'add_visit.dart';
import 'view_open_transactions.dart';
import 'visit_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primarycolor = Color(0xff3FD5AE);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xff3FD5AE),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => RecordsProvider()),
        ChangeNotifierProvider(create: (ctx) => NodeProvider()),
        ChangeNotifierProvider(create: (ctx) => UserAuthProvider())
      ],
      child: Consumer<UserAuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EhrDoctor',
          theme: ThemeData(
            primaryColor: primarycolor,
            accentColor: Colors.redAccent,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            buttonTheme: ButtonThemeData(
              buttonColor: primarycolor,
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            appBarTheme: AppBarTheme(
              color: Colors.white,
              centerTitle: true,
              elevation: 0,
            ),
            textTheme: GoogleFonts.montserratTextTheme(),
            primaryTextTheme: GoogleFonts.montserratTextTheme(),
          ),
          home: auth.isLoggedIn() ? Screen() : LandingPage(),
          //home: Screen(),
          routes: {
            'records_detail': (ctx) => RecordsDetail(),
            'visit_detail': (ctx) => VisitDetails(),
            'add_record': (ctx) => AddRecord(),
            'view_open_transaction': (ctx) => ViewOpenTransactions(),
            'add_visit': (ctx) => AddVisit(),

            //to implement onboarding screen
            // 'landing_page': (ctx) => LandingPage()
          },
        ),
      ),
    );
  }
}
