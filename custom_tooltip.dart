import 'package:flutter/material.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';

class MTooltip extends StatefulWidget {
  final TooltipController controller;
  final String title;

  MTooltip(this.controller,this.title);
  @override
  _MTooltipState createState() => _MTooltipState(controller,title);
}

class _MTooltipState extends State<MTooltip> {
  final TooltipController controller;
  final String title;

  _MTooltipState(this.controller,this.title);

  //final size = MediaQuery.of(context).size;
  //final currentDisplayIndex = controller.nextPlayIndex + 1;
  //final totalLength = controller.playWidgetLength;

  @override
  Widget build(BuildContext context) {
    //return Scaffold(
     return Container(
      width: MediaQuery.of(context).size.width * .7,
      margin: EdgeInsets.only(top:10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              InkWell(
                onTap: () {
                  controller.dismiss();
                },
                child: Icon(Icons.cancel_outlined,
                    color: Colors.black.withOpacity(.6), size: 18),
              )
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[100],
          ),
          const SizedBox(
            height: 16,
          ),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: controller.nextPlayIndex > 0 ? 1 : 0,
                    child: TextButton(
                      onPressed: () {
                        controller.previous();
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Prev',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    //opacity: totalLength == 1 ? 0 : 1,
                    opacity: controller.playWidgetLength == 1 ? 0 : 1,
                    child: Text(
                      //'$currentDisplayIndex OF $totalLength',
                      (controller.nextPlayIndex + 1).toString()+' OF ' + (controller.playWidgetLength).toString(),
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.next();
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10),
                      child: Text(
                        //currentDisplayIndex == totalLength ? 'Got it' : 'Next',
                        (controller.nextPlayIndex + 1) == controller.playWidgetLength ? 'Got it' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    //),
    );
  }
}