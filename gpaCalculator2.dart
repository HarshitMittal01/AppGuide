import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:nsut_daily_app/constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:nsut_daily_app/result_package/requestRemote.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';
import 'custom_tooltip.dart';
import '../main.dart';
import 'package:nsut_daily_app/attendance_components/attendance_constants.dart';

var result;
//final TooltipController _controller = TooltipController();
class GpaCalculator extends StatefulWidget{
  @override
  _GpaCalculatorState createState() => _GpaCalculatorState();
}

class _GpaCalculatorState extends State<GpaCalculator> {
  final TooltipController _controller = TooltipController();
  bool done = false;
  var semester = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];
  double cg=0;
  double cr=0;
  var sem = {
    'I': [],
    'II': [],
    'III': [],
    'IV': [],
    'V': [],
    'VI': [],
    'VII': [],
    'VIII': []
  };
  var semWise = {
    'I': [],
    'II': [],
    'III': [],
    'IV': [],
    'V': [],
    'VI': [],
    'VII': [],
    'VIII': []
  };

  @override
  void initState() {
    isdark = themeChangeProvider.darkTheme;
    _controller.onDone(() {
      setState(() {
        done = true;
      });
    });
    super.initState();
  }
  var semesterData = [];
  var overallGpa = "";

  _fetchData() async {
    if (result == null) {
      result = await createResultSession();
    }
    var document = result['document'];

    for (int i = 0; i < semester.length; i++) {
      sem[semester[i]].clear();
    }

    var profileTable = document.getElementsByClassName("x");
    List data = profileTable[0].getElementsByTagName("tr");

    var tables = document.getElementsByClassName("y");

    //  SUBJECT-WISE RESULT
    List subjects = tables[0].getElementsByTagName("tr");
    subjects.removeAt(0);

    for (int i = 0; i < subjects.length; i++) {
      List each = subjects[i].getElementsByTagName("td");

      String courseName = each[2].text.toString();
      String courseCode = each[1].text;
      String grades = each[7].text;
      String semesterNo = each[4].text.toString();
      String credit = each[5].text.toString();
      var temp = [semesterNo, courseName, courseCode, grades, credit];
      sem[semesterNo].add(temp);

    }
    List wholeSem = tables[1].getElementsByTagName("tr");

    if (wholeSem[0].getElementsByTagName("td")[0].text != 'Sem') {
      subjects = tables[1].getElementsByTagName("tr");
      for (int i = 0; i < subjects.length; i++) {
        List each = subjects[i].getElementsByTagName("td");

        String courseName = each[2].text.toString();
        String courseCode = each[1].text;
        String grades = each[7].text;
        String semesterNo = each[4].text.toString();
        String credit = each[5].text.toString();
        var temp = [semesterNo, courseName, courseCode, grades, credit];
        sem[semesterNo].add(temp);

      }
      wholeSem = tables[2].getElementsByTagName("tr");
    }

    //  SEMESTER-WISE RESULT
    wholeSem.removeAt(0);

    for (int i = 0; i < wholeSem.length; i++) {
      List each = wholeSem[i].getElementsByTagName("td");

      String semesterNo = each[0].text.toString();
      String grade = each[3].text;
      semWise[semesterNo].add(grade);
    }

    setState(() {});
  }


  List<String> _selected_box = [];
  String credits()
  {
    String credit = cr.toString();
    return credit;
  }

  void creditValue(double addCredit)
  {
    cr=cr+addCredit;
  }

  String cgpa()
  {
    String gpa = cg.toString();
    return gpa;
  }

  void cgpaValue(double addCgpa,double addCredit)
  {
    cg=cg*(cr-addCredit);
    cg=cg+addCgpa*addCredit;
    cg=cg/cr;
    cg=cg*100;
    int ct = cg.floor();
    cg=ct*(0.01);
  }

  void removeCredit(double rCredit)
  {
    cr=cr-rCredit;
  }

  void removeGpa(double rGpa,double rCredit)
  {
    cg=cg*(cr+rCredit);
    cg=cg-(rCredit*rGpa);
    if(cg==0)
    {
      cg=0;
    }
    else {
      cg = cg / cr;
      cg = cg * 100;
      int ct = cg.floor();
      cg = ct * (0.01);
    }
  }

  Widget gpaCheck(String semesterNo) {
    if (sem[semesterNo].isEmpty) {
      return Container();
    } else {
      return Container(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  "Semester $semesterNo",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isdark ? Colors.white : kPink,
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: sem[semesterNo].length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 500.0,
                    child: FadeInAnimation(
                      child: resultBlock(index, semesterNo),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 20.h,
            ),
          ],
        ),
      );
    }
  }

  Widget resultBlock(int index, String semester) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 8.0, bottom: 16.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: isdark ? darkShadow : lightShadow,
              color: kPink,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(left: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isdark ? dark : Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 200,
                                child: AutoSizeText(
                                  returnData(index, semester, 1),
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: isdark ? Colors.white : darkBG,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0.0),
                                    child: AutoSizeText(
                                      returnData(index, semester, 2),
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            color:
                                            isdark ? Colors.white : darkBG,
                                            fontSize: 10.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: AutoSizeText(
                          returnData(index, semester, 4)+"/"+returnData(index, semester, 3),
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                          child:
                          Checkbox(
                              checkColor: Colors.white,
                              fillColor: MaterialStateProperty.resolveWith(getColor),
                              //const Radius _kEdgeRadius = Radius.circular(1.0),
                              //value: this.value[semester][index],
                              //value: this.newValue,
                              value: _selected_box.contains(sem[semester][index][2]),
                              onChanged: (bool value){
                                setState(() {
                                  //this.value[semester][index] = value;
                                  //this.newValue=value;
                                  if(_selected_box.contains(sem[semester][index][2]))
                                  {
                                    removeCredit(double.parse(sem[semester][index][4]));
                                    removeGpa(double.parse(sem[semester][index][3]),double.parse(sem[semester][index][4]));
                                    _selected_box.remove(sem[semester][index][2]);
                                  }
                                  else
                                  {
                                    creditValue(double.parse(sem[semester][index][4]));
                                    cgpaValue(double.parse(sem[semester][index][3]),double.parse(sem[semester][index][4]));
                                    _selected_box.add(sem[semester][index][2]);
                                  }
                                });
                              }
                          )
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String returnData(int index, String semesterNo, int loc) {
    if (sem[semesterNo].isEmpty) {
      if (loc == 3) {
        return "";
      } else if (loc == 2) {
        return 'Course not updated';
      } else {
        return '';
      }
    } else {
      return sem[semesterNo][index][loc];
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return kPink;
  }

  @override
  Widget build(BuildContext context){
    ScreenUtil.init(context, designSize: Size(414, 812), allowFontScaling: false);

    return OverlayTooltipScaffold(
        overlayColor: Colors.grey.withOpacity(0.9),
        controller: _controller,

        startWhen: (initializedWidgetLength) async {
          await Future.delayed(const Duration(milliseconds: 00));
          return initializedWidgetLength == 2 && !done;
        },
      child:SafeArea(
      child:Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: isdark ? darkBG : Colors.white,
        body: SingleChildScrollView(
          child:FutureBuilder(
            future: _fetchData(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    color: isdark ? darkBG : Colors.white,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.symmetric(vertical: 0.0.h),
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.0.h),
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Container(
                                  margin : EdgeInsets.only(top:10,bottom:20),
                                  alignment: Alignment.centerLeft,
                                  //alignment: Alignment.topLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:24.0,top: 10.0),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: kPink,
                                        size: 23,
                                      ),
                                    ),
                                  ),
                                ),
                                OverlayTooltipItem(
                                  displayIndex: 1,
                                  tooltip: (controller) =>
                                      Padding(
                                        padding: const EdgeInsets.only(left:15),
                                        child: MTooltip(
                                          controller,
                                            'Some Text Tile',
                                            ),
                                      ),
                                  controller: _controller,
                                 child:Container(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        AutoSizeText(
                                          "GPA Calculator",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: isdark ? Colors.white : Colors
                                                  .black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ),
                                OverlayTooltipItem(
                                  displayIndex: 0,
                                  tooltip: (controller) =>
                                      Padding(
                                        padding: const EdgeInsets.only(top:20,right: 15),
                                        child: MTooltip(
                                          controller,
                                          'Some Text Tile',
                                        ),
                                      ),
                                  controller: _controller,
                                  child:Center(
                                    child:Container(
                                  //alignment: Alignment.topRight,
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context) {
                                            return InstructionPopup();
                                          });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 0.0,right:24.0),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: kPink,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),),)
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top:20),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: isdark ? darkShadowTop : lightShadowTop,
                                  color: isdark ? dark : Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30)),
                                ),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: AutoSizeText(
                                          "Minimum Credits Required: 162\nTotal Credits Available: 170",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: isdark ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 30, top: 30),
                                            //width: 120,
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            decoration: BoxDecoration(
                                                boxShadow: isdark? darkShadow: lightShadow,
                                                color: isdark ? dark : Colors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(20))
                                            ),
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20.0, vertical: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  AutoSizeText(
                                                    "Credits\n" + credits(),
                                                    //"Credits\n44",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: isdark? Colors.white: Colors.black,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 30, top: 30, right: 30),
                                            //width: 120,
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            decoration: BoxDecoration(
                                                boxShadow: isdark? darkShadow: lightShadow,
                                                color: isdark ? dark : Colors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(20))
                                            ),
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20.0, vertical: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  AutoSizeText(
                                                    "CGPA\n" + cgpa(),
                                                    //"CGPA\n9.00",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: isdark? Colors.white: Colors.black,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            //_controller.start();
                                            setState(() {
                                              done = false;
                                            });
                                          },
                                          child: const Text('Start Tooltip')),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 6.0.w, bottom: 15.0.h),
                                          width: MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0, left: 8.0, right: 8.0),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(14.0)),
                                                child:
                                                ListView(
                                                  children: [
                                                    gpaCheck('I'),
                                                    gpaCheck('II'),
                                                    gpaCheck('III'),
                                                    gpaCheck('IV'),
                                                    gpaCheck('V'),
                                                    gpaCheck('VI'),
                                                    gpaCheck('VII'),
                                                    gpaCheck('VIII')
                                                  ],
                                                )
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),);
  }
}

class InstructionPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              children: [
                Center(
                    child: AutoSizeText(
                      'Instructions - How To Use\n',
                      style: codesExplainedStyle,
                    )
                ),
                Divider(
                  color: isdark ? Colors.white : Colors.black,
                  height: 20,
                  thickness: 2,
                  indent: 10,
                  endIndent: 10,
                ),
                InstructionText(text:'This feature helps you to select the courses '
                    'that you want to include for the final evaluation of your degree'),
                HeadingText(text: 'Click on the Check Box'),
                HeadingText(text: 'See Credits and Cgpa for checked courses'),
                Divider(
                  color: isdark ? Colors.white : Colors.black,
                  height: 20,
                  thickness: 2,
                  indent: 10,
                  endIndent: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InstructionText extends StatelessWidget {
  final String text;

  InstructionText({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    // height: mainCardHeight,

                    margin: EdgeInsets.only(bottom: 0.0),
                    child: InkWell(
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.7,
                                        child: AutoSizeText(text,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: isdark ? Colors.white : Colors.black87,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 15,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HeadingText extends StatelessWidget {
  final String text;

  HeadingText({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    // height: mainCardHeight,

                    margin: EdgeInsets.only(bottom: 0.0),
                    child: InkWell(
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                                child: Icon(
                                  Icons.fiber_manual_record,
                                  color: isdark ? Colors.white : Colors.black,
                                  size: 7,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.7,
                                        child: AutoSizeText(text,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: isdark ? Colors.white : Colors.black87,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
