import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nsut_daily_app/attendance_components/attendance_constants.dart';
import 'package:nsut_daily_app/previous_year_papers/branchsemscreen.dart';
import 'package:nsut_daily_app/screens/regCourse_screen.dart';
import 'package:nsut_daily_app/constants.dart';
import 'package:nsut_daily_app/nav_bar_file.dart';
import 'package:nsut_daily_app/profilepage2.dart';
import 'package:nsut_daily_app/screens/attendance_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nsut_daily_app/screens/result.dart';
import 'package:nsut_daily_app/attendance_components/attendanceDetails.dart';
import 'package:nsut_daily_app/screens/timetable_screen.dart';
import 'package:nsut_daily_app/screens/todo_screen.dart';
import 'package:nsut_daily_app/profile_page/services.dart';
import 'package:nsut_daily_app/syllabus_screen/branch_sem_screen.dart';
import 'package:nsut_daily_app/timetable_helper.dart';
import 'package:nsut_daily_app/welcome_screen/captchaScreen.dart';
import 'package:nsut_daily_app/welcome_screen/login_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';
import 'package:nsut_daily_app/session_check.dart';
import '../main.dart';
import '../notifications.dart';
import '../screens/attendance_screen.dart';
import 'dart:ui';
import 'package:overlay_tooltip/overlay_tooltip.dart';
import 'custom_tooltip2.dart';
import 'package:shared_preferences/shared_preferences.dart';
//xx
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

SharedPreferences _preffs;
bool newFeature = false;
bool home = false;

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final TooltipController _controller = TooltipController();
  bool done = false;
  Services s;
  GlobalKey<RefreshIndicatorState> refreshKey;

  AttendanceState attendanceState;
  var imageURL;
  var cookie;
  var time;
  String nextDay;
  int j;
  int time2;
  int i = 0;
  var y = ['0', '0', '0'];
  var w = ['0', '0'];

  @override
  String getDate() {
    var now = new DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  String getTeacherString(String daySelectedParameter, int i) {
    List list = timeTable[daySelectedParameter][i]["teacher"];
    String str = "";
    for (int i = 0; i < list.length; i++) {
      str += list[i];
      str += ", ";
    }
    str = str.substring(0, str.length - 2);
    return str;
  }

  Color getColor(double x) {
    if (x == 0) {
      return Colors.grey.shade300;
    } else if (x < 0.75) {
      return kRed;
    } else {
      return isdark ? Color(0xFF0BA484) : Color(0xFF6FCF97);
    }
  }

  Color getSecondColor(String name) {
    // to hide widgets with no data
    if (name == "") {
      return isdark ? dark : Colors.white;
    }
    return isdark ? Colors.white : Colors.black;
  }

  String getStartingTime() {
    return timeTable[getDayToday().substring(0, 3)][0]["time"].toString();
  }

  int nextDateCounter = 0;
  String getDayTomorrow() {
    var weekdays = [
      "No-day",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    int x = DateTime.now().weekday;

    String day = weekdays[x];
    int temp = x;
    nextDateCounter = 1; //for x+1
    while (true) {
      if (timeTable[weekdays[x % 7 + 1].substring(0, 3)] != null &&
          timeTable[weekdays[x % 7 + 1].substring(0, 3)].length != 0) {
        day = weekdays[x % 7 + 1];
        break;
      } else {
        x = x % 7 + 1;
        nextDateCounter++;
        if (x == temp) {
          break;
        }
      }
    }
    mydate();
    setState(() {});

    return day;
  }

  String mydate() {
    var month = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sept",
      "Oct",
      "Nov",
      "Dec"
    ];
    DateTime currentDate = DateTime.now().add(Duration(days: nextDateCounter));
    w[0] = currentDate.day.toString();
    w[1] = month[currentDate.month - 1];

    y[0] = DateTime.now().day.toString();
    y[1] = month[DateTime.now().month - 1];
    y[2] = DateTime.now().year.toString();

    String z = y[0] + "-" + y[1] + "-" + y[2];
    return z;
  }

  bool getPresentClass() {
    j = 0;
    int m = timeTable[getDayToday().substring(0, 3)].length;
    for (; j < m; j++) {
      if (now.hour == timeTable[getDayToday().substring(0, 3)][j]["time"]) {
        time2 = timeTable[getDayToday().substring(0, 3)][j]["time"];
        break;
      }
    }
    if (j != m) {
      time2 = timeTable[getDayToday().substring(0, 3)][j]["time"];
    }
    return now.weekday == 6 || now.weekday == 7 || j == m ? false : true;
  }

  String getDayToday() {
    var weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    String day = weekdays[DateTime.now().weekday - 1];
    if (day == "Saturday" || day == "Sunday") {
      day = "Monday";
    }
    return day;
  }

  String getDayTodaytop() {
    var weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    String day = weekdays[DateTime.now().weekday - 1];
    return day;
  }

  String getCode(int i) {
    if (i >= allCourses.length) {
      return "";
    }
    return allCourses[i].courseCode;
  }

  String getName(int i) {
    if (i >= allCourses.length) {
      return "";
    }
    return allCourses[i].courseName;
  }

  double getPercent(int i) {
    if (i >= allCourses.length) {
      return 0;
    }
    double temp = allCourses[i].attendancePercent / 100;
    return temp;
  }

  var now = DateTime.now();

  bool getNextClass() {
    i = 0;
    int x = timeTable[getDayToday().substring(0, 3)].length;
    for (; i < x; i++) {
      if (now.hour < timeTable[getDayToday().substring(0, 3)][i]["time"]) {
        time = timeTable[getDayToday().substring(0, 3)][i]["time"];
        break;
      }
    }
    if (i != x) {
      time = timeTable[getDayToday().substring(0, 3)][i]["time"];
    }
    return now.weekday == 6 || now.weekday == 7 || i == x ? false : true;
  }

  getPhoto() async {
    if (document == null || forceSet == true) {
      document = await s.get();
    }
    preffs = await SharedPreferences.getInstance();
    cookie = preffs.getString("cookie");
    imageURL = await document.querySelectorAll("img")[0].attributes["src"];
    return imageURL;
  }

  waitForTimeTable() async {
    if (timeTable == null || forceSet == true) {
      timeTable = await getTimeTable();
    }

    return timeTable;
  }

  getAttendanceData() async {
    if (allCourses == null || forceSet == true) {
      allCourses = await attendanceState.fetchData();
    }
    return allCourses;
  }

  Future selectNotification(String payload) async {
    // if (payload != null) {
    //   debugPrint('notification payload: $payload');
    // }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => CaptchaScreen()),
    // );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  void sessionCheck() async {
    SessionCheck sessionClass = new SessionCheck();
    String s = await sessionClass.sessionCheck();
    if (s.contains('sessionexpired.php')) {
      Route route = MaterialPageRoute(builder: (context) => CaptchaScreen());
      Navigator.of(context).pushReplacement(route);
    }
  }

  Future get() async {
    _preffs = await SharedPreferences.getInstance();
    var temp = _preffs.getBool('newFeature');
    if (temp == null || temp == true) {
      newFeature = true;
      _preffs.setBool('newFeature', true);
    }
    var temp2 = _preffs.getBool('home');
    if(temp2 == null || temp2 == true){
      home = true;
      _preffs.setBool('home',true);
    }
    else
      home=false;
  }

  void initState() {
    _controller.onDone(() {
      setState(() {
        done = true;
      });
    });
    super.initState();
    isdark = themeChangeProvider.darkTheme;

    get();

    attendanceState = AttendanceState();
    s = Services();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('icontest');
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    getImpDataFuture();
    getAttendenceFuture();
    getTimeTableFuture();
  }

  bool timetableLoaded = false;
  void getTimeTableFuture() async {
    if (timeTable == null) {
      await waitForTimeTable();
      ClassReminder();
    }
    timetableLoaded = true;
    setState(() {});
  }

  void getImpDataFuture() async {
    if (allimpdata.semester == null) {
      await attendanceState.fetchImpData();
    }
    setState(() {});
  }

  bool attendenceDataFetched = false;
  void getAttendenceFuture() async {
    if (allCourses == null) {
      await attendanceState.fetchData();
    }
    attendenceDataFetched = true;

    // Error Handling where no courses are registered and the attendence table is empty
    setState(() {});
  }

  String test() {
    print("INSIDE BUILD OF HOMEPAGE");
    return "";
  }
  //final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return OverlayTooltipScaffold(
        overlayColor: Colors.grey.withOpacity(0.9),
        controller: _controller,
        startWhen: (initializedWidgetLength) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if(home==true)
        {
          //controller: _scrollController;
          //_scrollController.animateTo(_scrollController.position.maxScrollExtent,duration:Duration(milliseconds: 100),curve: Curves.easeInOut);
          _preffs.setBool('home', false);
          return initializedWidgetLength == 2 && !done;
        }
        return false;
        },
    child:SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: isdark ? darkBG : Colors.white,
        body: SingleChildScrollView(
          child: Column(
          //return Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  OverlayTooltipItem(
                    displayIndex: 0,
                    tooltipVerticalPosition:TooltipVerticalPosition.BOTTOM,
                    tooltip: (controller) =>
                        Padding(
                          padding: const EdgeInsets.only(left:15),
                          child: MTooltip(
                            controller,
                            'Welcome to NsutX',
                          ),
                        ),
                    controller: _controller,
                    child:Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 0.25, right: 0.25),
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25)),
                      child: Image(
                        image: AssetImage(
                          'images/nsit.png',
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),),
                  Positioned(
                    top: 5,
                    left: -15,
                    child: FlatButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Icon(
                        Icons.reorder,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 15,
                    child: Container(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return BackdropFilter(
                                  filter:
                                  ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    content: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0.0,
                                            top: 0.0,
                                            right: 0.0,
                                            bottom: 0.0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.7,
                                          // height: MediaQuery.of(context).size.height*0.7,
                                          child: Column(
                                            children: [
                                              Center(
                                                child: AutoSizeText(
                                                  "Your data is safe",
                                                  style: GoogleFonts.montserrat(
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      color: kPink),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Center(
                                                  child: AutoSizeText(
                                                    "NSUTx is using IMS APIs to display a student's information. All your data is completely secured.",
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 14,
                                                    ),
                                                    //  style: codesExplainedStyle,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Icon(
                            Icons.info_outline,
                            color: Color(0xFF121428),
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -75.0,
                    child: isCaptchaSkipped
                        ? Container(
                      height: 150.0,
                      child: InkResponse(
                        child: CircleAvatar(
                          radius: 55.0,
                          backgroundColor: kPink,
                          child: CircleAvatar(
                            radius: 55.0,
                            child: ClipOval(
                                child: Image(
                                  image: AssetImage('images/nsut.png'),
                                  height: 105,
                                )
//                                    Icon(
//                                      Icons.account_circle,
//                                      size: 110,
//                                      color: Colors.grey,
//                                    ),
                            ),
                            backgroundColor: isdark ? dark : Colors.white,
                          ),
                        ),
                      ),
                    )
                        : FutureBuilder(
                        future: getPhoto(),
                        builder:
                            (context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.data == null) {
                            return Center(
                              child: Transform.scale(
                                scale: 0.3,
                                child: CircularProgressIndicator(
                                  backgroundColor:
                                  isdark ? dark : Colors.white,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(kPink),
                                ),
                              ),
                            );
                          }
                          return Container(
                            height: 150.0,
                            child: InkResponse(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (Context) {
                                      return ProfilePage();
                                    }),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 55.0,
                                  backgroundColor: kPink,
                                  child: CircleAvatar(
                                    radius: 55.0,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                        "https://imsnsit.org/imsnsit/" +
                                            imageURL,
                                        httpHeaders: {
                                          'Cookie': cookie,
                                          'Referer':
                                          'https://imsnsit.org/imsnsit/' +
                                              imageURL,
                                          'User-Agent':
                                          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.105 Safari/537.36',
                                          'Host': 'www.imsnsit.org',
                                          'Origin':
                                          'https://www.imsnsit.org',
                                          'sec-ch-ua-mobile': '?0',
                                          'Connection': 'keep-alive',
                                          'Cache-Control': 'max-age=0'
                                        },
                                        width: 145,
                                      ),
                                    ),
                                    backgroundColor:
                                    isdark ? dark : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
                overflow: Overflow.visible,
              ),
              Container(
                margin: EdgeInsets.only(
                    left: 20.0, top: 20.0, right: 20.0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          getDayTodaytop(),
                          style: GoogleFonts.montserrat(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          mydate(),
                        ),
                      ],
                    ),
                    allimpdata.semester == null
                        ? isCaptchaSkipped
                        ? Container()
                        : Center(
                      child: Transform.scale(
                        scale: 0.3,
                        child: CircularProgressIndicator(
                          backgroundColor:
                          isdark ? dark : Colors.white,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(kPink),
                        ),
                      ),
                    )
                        : AutoSizeText(
                      'Semester- ${allimpdata.semester}',
                      style: GoogleFonts.montserrat(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: false,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (isCaptchaSkipped) {
                    SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                    if (sharedPreferences.containsKey('profile')) {
                      Navigator.pushReplacement(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => CaptchaScreen()));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    }
                  }
                },
                child: isCaptchaSkipped
                    ? Container(
                    height: 200.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: isdark ? dark : Colors.white,
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: isdark ? Colors.black87 : Colors.grey[300],
                          offset: const Offset(4.0, 4.0),
                          blurRadius: 3.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(
                        left: 15.0, top: 20.0, right: 15.0, bottom: 10.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/attendanceErrorHomepage.png',
                            height: 100,
                            // width: 200,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: isdark
                                        ? Colors.white
                                        : Colors.black54),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Login to continue',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      color: isdark
                                          ? Colors.white
                                          : Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ))
                    : ((attendenceDataFetched == true && allCourses==null) || (attendenceDataFetched == true &&
                    allCourses.length >= 1 &&
                    (getName(0) == "null" || getName(0) == null)))
                    ? Container(
                  height: 200.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(20)),
                    color: isdark ? dark : Colors.white,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                        color: isdark ? Colors.black87 : Colors.grey[300],
                        offset: const Offset(4.0, 4.0),
                        blurRadius: 3.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 15.0, top: 20.0, right: 15.0, bottom: 10.0),
                )
                    : Container(
                  height: 200.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(20)),
                    color: isdark ? dark : Colors.white,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                        color: isdark
                            ? Colors.black87
                            : Colors.grey[300],
                        offset: const Offset(4.0, 4.0),
                        blurRadius: 3.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(
                      left: 15.0,
                      top: 20.0,
                      right: 15.0,
                      bottom: 10.0),
                  child: attendenceDataFetched == false
                      ? Center(
                      child: CircularProgressIndicator(
                        backgroundColor:
                        isdark ? dark : Colors.white,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(kPink),
                      ))
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimationLimiter(
                        child: Container(
                          height: 150,
                          child: ListView.builder(
                            clipBehavior: Clip.hardEdge,
                            scrollDirection: Axis.horizontal,
                            itemCount: allCourses.length,
                            itemBuilder:
                                (BuildContext ctxt, int i) {
                              return Column(
                                children: [
                                  AnimationConfiguration
                                      .staggeredList(
                                    position: i,
                                    duration: const Duration(
                                        milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: -10.0,
                                      child: FadeInAnimation(
                                        child: percentIndicator(
                                          subjectName:
                                          getName(i),
                                          subjectCode:
                                          getCode(i),
                                          dPercentage:
                                          getPercent(i),
                                          color: getColor(
                                              getPercent(i)),
                                          secondColor:
                                          getSecondColor(
                                              getCode(i)),
                                          index: i,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 5.0,
                                        top: 5.0,
                                        right: 5.0,
                                        bottom: 0),
                                    height: 40,
                                    child: Text(
                                      '${getName(i)}',
                                      maxLines: 2,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      textAlign:
                                      TextAlign.center,
                                      softWrap: false,
                                      style: GoogleFonts
                                          .montserrat(),
                                    ),
                                    width:
                                    (MediaQuery.of(context)
                                        .size
                                        .width) *
                                        0.28,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          OverlayTooltipItem(
            displayIndex: 1,
              tooltipVerticalPosition:TooltipVerticalPosition.TOP,
              tooltip: (controller) =>
                Padding(
                  padding: const EdgeInsets.only(left:15),
                  child: MTooltip(
                    controller,
                    'Important Utility Features',
                  ),
                ),
            controller: _controller,
            child:Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                margin: EdgeInsets.only(
                    left: 15.0, top: 10.0, right: 15.0/*, bottom: 10.0*/),
                width: double.infinity,
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  children: [
                    shortcutButton(
                      flag: false,
                      displayText: 'Profile',
                      icon: Icons.person_sharp,
                      onPressed: () {
                        if (isCaptchaSkipped) {
                          Fluttertoast.showToast(
                              msg: "Login to continue",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.black,
                              fontSize: 14.0);
                          return;
                        }
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: ProfilePage()));
                      },
                      size: 80.0,
                    ),
                    shortcutButton(
                      flag: false,
                      displayText: 'Attendance',
                      icon: Icons.how_to_reg,
                      onPressed: () {
                        if (isCaptchaSkipped) {
                          Fluttertoast.showToast(
                              msg: "Login to continue",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.black,
                              fontSize: 14.0);
                          return;
                        }
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: Attendance(
                                  backArrowButton: true,
                                )));
                      },
                      size: 80.0,
                    ),
//
                    shortcutButton(
                      flag: false,
                      displayText: 'ToDo',
                      icon: Icons.done_all_rounded,
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: ToDoClass(
                                  backArrowButton: true,
                                )));
                      },
                      size: 80.0,
                    ),
                    shortcutButton(
                      flag: false,
                      displayText: 'Time Table',
                      icon: Icons.schedule,
                      onPressed: () {
                        if (isCaptchaSkipped) {
                          Fluttertoast.showToast(
                              msg: "Login to continue",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.black,
                              fontSize: 14.0);
                          return;
                        }
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: TimeTable(
                                  backArrowButton: true,
                                )));
                      },
                      size: 80.0,
                    ),
                    shortcutButton(
                      flag: false,
                      displayText: 'Syllabus',
                      icon: Icons.menu_book,
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: branch_sem()));
                      },
                      size: 80.0,
                    ),
                    shortcutButton(
                      flag: newFeature,
                      displayText: 'Previous Year Papers',
                      icon: Icons.library_books,
                      onPressed: () {
                        if (newFeature == true) {
                          _preffs.setBool('newFeature', false);
                        }
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: branch_sem_paper()))
                            .then((value) => setState(() {
                          newFeature = false;
                        }));
                      },
                      size: 80.0,
                    ),
                    shortcutButton(
                      flag: false,
                      displayText: 'Result',
                      icon: Icons.assessment,
                      onPressed: () {
                        if (isCaptchaSkipped) {
                          Fluttertoast.showToast(
                              msg: "Login to continue",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.black,
                              fontSize: 14.0);
                          return;
                        }
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: Result()));
                      },
                      size: 80.0,
                    ),
                    shortcutButton(
                      flag: false,
                      displayText: 'Courses',
                      icon: Icons.receipt_rounded,
                      onPressed: () {
                        if (isCaptchaSkipped) {
                          Fluttertoast.showToast(
                              msg: "Login to continue",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.black,
                              fontSize: 14.0);
                          return;
                        }
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: RegCourseScreen()));
                      },
                      size: 80.0,
                    ),
                  ],
                ),
              ),),
              timeTable == null
                  ? SizedBox(height: 0)
                  : getPresentClass() == true
                  ? GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (Context) {
                      return TimeTable(
                        backArrowButton: true,
                      );
                    }),
                  );
                },
                child: Container(
                  height: 200,
                  margin: EdgeInsets.only(
                      left: 15.0,
                      top: 5.0,
                      right: 15.0,
                      bottom: 10.0),
                  padding: EdgeInsets.only(bottom: 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(20)),
                      color: isdark ? dark : Colors.white,
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: isdark
                              ? Colors.black87
                              : Colors.grey[300],
                          offset: const Offset(4.0, 4.0),
                          blurRadius: 3.0,
                          spreadRadius: 1.0,
                        ),
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Text(
                          'Present Class',
                          style: GoogleFonts.montserrat(
                            color:
                            isdark ? Colors.white : Colors.black,
                            //letterSpacing: 1.0,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    '${getDayToday()}, ',
                                    style: GoogleFonts.montserrat(
                                      color: isdark
                                          ? Colors.white
                                          : Colors.black,
                                      //letterSpacing: 2.0,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  Text(
                                    y[1] + " " + y[0],
                                    style: GoogleFonts.montserrat(
                                      color: isdark
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //SizedBox(height: 10.0),
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Text(
                                          (time2 > 12
                                              ? '${time2 - 12}:00'
                                              : '$time2:00'),
                                          style:
                                          GoogleFonts.montserrat(
                                            color: kPink,
                                            fontWeight:
                                            FontWeight.w600,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        Text(
                                          (time2 >= 12 ? 'pm' : 'am'),
                                          style:
                                          GoogleFonts.montserrat(
                                            color: kPink,
                                            fontWeight:
                                            FontWeight.w600,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              right: 5),
                                          child: AutoSizeText(
                                            '${timeTable[getDayToday().substring(0, 3)][j]["title"]}',
                                            style: GoogleFonts
                                                .montserrat(
                                              color: kPink,
                                              fontWeight:
                                              FontWeight.w600,
                                              fontSize: 15.0,
                                            ),
                                            maxLines: 2,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            textAlign:
                                            TextAlign.start,
                                            softWrap: false,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 5.0),
                                          child: AutoSizeText(
                                            '${timeTable[getDayToday().substring(0, 3)][j]["code"]}',
                                            style: GoogleFonts
                                                .montserrat(
                                              color: isdark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 12.0,
                                              fontWeight:
                                              FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            textAlign:
                                            TextAlign.center,
                                            softWrap: false,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        AutoSizeText(
                                          '${getTeacherString(getDayToday().substring(0, 3), j)}',
                                          style:
                                          GoogleFonts.montserrat(
                                            color: isdark
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight:
                                            FontWeight.w500,
                                            fontSize: 12.0,
                                          ),
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          // textAlign: TextAlign.center,
                                          softWrap: false,
                                        ),
                                        SizedBox(height: 5.0),
                                        AutoSizeText(
                                          'Room ${timeTable[getDayToday().substring(0, 3)][j]["roomno"]}',
                                          style:
                                          GoogleFonts.montserrat(
                                            color: isdark
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight:
                                            FontWeight.w500,
                                            fontSize: 12.0,
                                          ),
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : SizedBox(
                height: 0,
              ),
              isCaptchaSkipped
                  ? Container()
                  : timetableLoaded == false
                  ? Container(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      backgroundColor: isdark ? dark : Colors.white,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(kPink),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(
                    left: 15.0, top: 5.0, right: 15.0, bottom: 10.0),
                padding: EdgeInsets.only(bottom: 20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(20)),
                    color: isdark ? dark : Colors.white,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                        color: isdark
                            ? Colors.black87
                            : Colors.grey[300],
                        offset: const Offset(4.0, 4.0),
                        blurRadius: 3.0,
                        spreadRadius: 1.0,
                      ),
                    ]),
              )
                  : timeTable == null
                  ? SizedBox(height: 0)
              // ? Text('IMS Not Responding',
              //     style: GoogleFonts.montserrat(
              //         fontSize: 15, color: Colors.white))
                  : GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (Context) {
                      return TimeTable(
                        backArrowButton: true,
                      );
                    }),
                  );
                },
                child: Container(
                  height: 200,
                  margin: EdgeInsets.only(
                      left: 15.0,
                      top: 5.0,
                      right: 15.0,
                      bottom: 10.0),
                  padding: EdgeInsets.only(bottom: 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(20)),
                      color: isdark ? dark : Colors.white,
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: isdark
                              ? Colors.black87
                              : Colors.grey[300],
                          offset: const Offset(4.0, 4.0),
                          blurRadius: 3.0,
                          spreadRadius: 1.0,
                        ),
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Text(
                          getNextClass() == true
                              ? 'Next Class'
                              : "No Class Left Today",
                          style: GoogleFonts.montserrat(
                            color: isdark
                                ? Colors.white
                                : Colors.black,
                            //letterSpacing: 1.0,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    getNextClass() == true
                                        ? getDayToday() + ", "
                                        : getDayTomorrow() + ", ",
                                    style: GoogleFonts.montserrat(
                                      color: isdark
                                          ? Colors.white
                                          : Colors.black,
                                      //letterSpacing: 2.0,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  Text(
                                    getNextClass() == true
                                        ? y[1] + " " + y[0]
                                        : w[1] + " " + w[0],
                                    style: GoogleFonts.montserrat(
                                      color: isdark
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //SizedBox(height: 10.0),
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Text(
                                          getNextClass() == true
                                              ? (time > 12
                                              ? '${time - 12}:00'
                                              : '$time:00')
                                              : (timeTable[getDayTomorrow().substring(
                                              0,
                                              3)][0]
                                          [
                                          "time"] >
                                              12
                                              ? '${timeTable[getDayTomorrow().substring(0, 3)][0]["time"] - 12}:00'
                                              : '${timeTable[getDayTomorrow().substring(0, 3)][0]["time"]}:00'),
                                          style: GoogleFonts
                                              .montserrat(
                                            color: kPink,
                                            fontWeight:
                                            FontWeight.w600,
                                            fontSize: 15.0,
                                          ),
                                        ),
//                                          ${timeTable[getDayTomorrow().substring(0, 3)][0]["time"]}:00

                                        Text(
                                          getNextClass() == true
                                              ? (time >= 12
                                              ? 'pm'
                                              : 'am')
                                              : (timeTable[getDayTomorrow().substring(
                                              0,
                                              3)][0]
                                          [
                                          "time"] >=
                                              12
                                              ? 'pm'
                                              : 'am'),
                                          style: GoogleFonts
                                              .montserrat(
                                            color: kPink,
                                            fontWeight:
                                            FontWeight.w600,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets
                                              .only(right: 5),
                                          child: AutoSizeText(
                                            getNextClass() == true
                                                ? '${timeTable[getDayToday().substring(0, 3)][i]["title"]}'
                                                : "${timeTable[getDayTomorrow().substring(0, 3)][0]["title"]} ",
                                            style: GoogleFonts
                                                .montserrat(
                                              color: kPink,
                                              fontWeight:
                                              FontWeight.w600,
                                              fontSize: 15.0,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow
                                                .ellipsis,
                                            textAlign:
                                            TextAlign.start,
                                            softWrap: false,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Padding(
                                          padding:
                                          EdgeInsets.only(
                                              right: 5.0),
                                          child: AutoSizeText(
                                            getNextClass() == true
                                                ? '${timeTable[getDayToday().substring(0, 3)][i]["code"]}'
                                                : "${timeTable[getDayTomorrow().substring(0, 3)][0]["code"]}",
                                            style: GoogleFonts
                                                .montserrat(
                                              color: isdark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 12.0,
                                              fontWeight:
                                              FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow
                                                .ellipsis,
                                            textAlign:
                                            TextAlign.center,
                                            softWrap: false,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        AutoSizeText(
                                          getNextClass() == true
                                              ? '${getTeacherString(getDayToday().substring(0, 3), i)}'
                                              : '${getTeacherString(getDayTomorrow().substring(0, 3), 0)}',
                                          style: GoogleFonts
                                              .montserrat(
                                            color: isdark
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight:
                                            FontWeight.w500,
                                            fontSize: 12.0,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          softWrap: false,
                                        ),
                                        SizedBox(height: 5.0),
                                        AutoSizeText(
                                          getNextClass() == true
                                              ?
//                                                      ? (timeTable[getDayToday()
//                                                                      .substring(
//                                                                          0, 3)]
//                                                                  [i]["room"] !=
//                                                              null ?
                                          'Room ${timeTable[getDayToday().substring(0, 3)][i]["roomno"]}'
//                                                          : "NO ROOM ALLOTED")
//                                                      : (timeTable[getDayTomorrow()
//                                                                      .substring(
//                                                                          0, 3)]
//                                                                  [0]["room"] !=
//                                                              null
                                              : 'Room ${timeTable[getDayTomorrow().substring(0, 3)][0]["roomno"]}',
//                                                          : "NO ROOM ALLOTED"),

                                          style: GoogleFonts
                                              .montserrat(
                                            color: isdark
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight:
                                            FontWeight.w500,
                                            fontSize: 12.0,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          textAlign:
                                          TextAlign.center,
                                          softWrap: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class shortcutButton extends StatelessWidget {
  shortcutButton(
      {@required this.displayText,
        this.onPressed,
        this.flag,
        @required this.size,
        @required this.icon});
  String displayText;
  Function onPressed;
  double size;
  final IconData icon;
  bool flag;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28.0,
            backgroundColor: kPink,
            child: CircleAvatar(
              radius: 27.0,
              backgroundColor: isdark ? dark : Colors.white,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                shape: CircleBorder(
                  side: BorderSide.none,
                ),
                color: isdark ? dark : Colors.white,
                onPressed: () {
                  _preffs.setBool('newFeature', false);
                  onPressed();
                },
                child: Icon(
                  icon,
                  size: 30,
                  color: isdark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onPressed,
            child: AutoSizeText(
              '$displayText',
              style: GoogleFonts.montserrat(
                letterSpacing: 0.02,
                fontSize: 12.0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

class percentIndicator extends StatefulWidget {
  percentIndicator({
    this.subjectName,
    this.subjectCode,
    this.dPercentage,
    this.color,
    this.secondColor,
    this.index,
  });
  String subjectCode;
  String subjectName;
  double dPercentage;
  Color secondColor;
  Color color;
  int index;

  @override
  _percentIndicatorState createState() => _percentIndicatorState();
}

class _percentIndicatorState extends State<percentIndicator> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceDetail(
                allCourses[widget.index].courseName,
                allCourses[widget.index].present,
                allCourses[widget.index].totalClasses,
                widget.index,
                allimpdata.rollno,
                allimpdata.year,
                allimpdata.semester),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          minWidth: (MediaQuery.of(context).size.width) * 0.28,
          child: CircularPercentIndicator(
            radius: 70.0,
            lineWidth: 4,
            curve: Curves.fastLinearToSlowEaseIn,
            animation: true,
            arcType: ArcType.FULL,
            backgroundColor: isdark ? dark : Colors.white,
            addAutomaticKeepAlive: false,
            percent: widget.dPercentage == 0
                ? 1
                : widget.dPercentage, //to be changed
            center: Text(
              ((widget.dPercentage) * 100).toStringAsFixed(1) +
                  '%', //to be changed
              style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  color: widget.secondColor,
                  fontWeight: FontWeight.w600),
            ),
            footer: Column(
              textBaseline: TextBaseline.ideographic,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.subjectCode, //to be changed
                  style: GoogleFonts.montserrat(
                      fontSize: 12.0,
                      color: widget.secondColor,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: widget.color,
          ),
        ),
      ),
    );
  }
}

// To add a badge on top of new feature
// flag == true
//                     ? Badge(
//                         // badgeContent: Padding(
//                         // padding: const EdgeInsets.all(0.0),
//                         // child: Text(
//                         // "",
//                         // style: TextStyle(fontSize: 8),
//                         // ),
//                         // ),
//                         badgeColor: kPink,
//                         shape: BadgeShape.square,
//                         borderRadius: BorderRadius.circular(8),
//                         child: Icon(
//                           icon,
//                           size: 30,
//                           color: isdark ? Colors.white : Colors.black,
//                         ),
//                       )
//                     :                     :
