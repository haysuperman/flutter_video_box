import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_box/video_box.dart';
// import 'package:video_box/widgets/buffer_slider.dart';
import 'package:video_player_header/video_player_header.dart' as vph;

import '../globals.dart';

class MyFullScreen implements CustomFullScreen {
  const MyFullScreen();
  @override
  void close(BuildContext context, VideoController controller) {
    print('pop...');
    Navigator.of(context).pop(controller.value.positionText);
  }

  @override
  Future open(BuildContext context, VideoController controller) async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            body: Center(child: VideoBox(controller: controller)),
          );
        },
      ),
    ).then(print);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}

class CustomLoading extends StatelessWidget {
  final String text;

  const CustomLoading(this.text, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.pink,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class OneVideoCtrl extends StatefulWidget {
  @override
  _OneVideoCtrlState createState() => _OneVideoCtrlState();
}

class _OneVideoCtrlState extends State<OneVideoCtrl> {
  VideoController vc;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    vc = VideoController(
      source: vph.VideoPlayerController.network(src1),
      looping: true,
      autoplay: true,
      color: Colors.red,
      // bufferColor: Colors.orange,
      // inactiveColor: Colors.pink,
      // background: Colors.indigo,
      // circularProgressIndicatorColor: Colors.lime,
      bottomPadding: EdgeInsets.only(bottom: 10),
      customLoadingWidget: const CustomLoading("Loading..."),
      customBufferedWidget: const CustomLoading("please wait.."),
      // options: {
      //   "name": "Ajanuw",
      // },
      customFullScreen: const MyFullScreen(),
      // controllerLiveDuration: Duration(seconds: 10),
      // bottomViewBuilder: (context, c) {
      //   var theme = Theme.of(context);
      //   return Positioned(
      //     left: c.bottomPadding.left,
      //     bottom: 0,
      //     right: 0,
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Column(
      //         children: <Widget>[
      //           Row(
      //             children: <Widget>[
      //               Text(
      //                 c.initialized
      //                     ? "${c.positionText}/${c.durationText}"
      //                     : '00:00/00:00',
      //                 style: TextStyle(color: Colors.white),
      //               ),
      //               Spacer(),
      //               Text(
      //                 c.options["name"].toString(),
      //                 style: TextStyle(color: Colors.white),
      //               ),
      //             ],
      //           ),
      //           Theme(
      //             data: theme.copyWith(
      //               sliderTheme: theme.sliderTheme.copyWith(
      //                 trackHeight: 6, // line的高度
      //                 overlayShape: SliderComponentShape.noThumb,
      //               ),
      //             ),
      //             child: BufferSlider(
      //               pointWidget: const SizedBox(),
      //               value: c.sliderValue,
      //               bufferValue: c.sliderBufferValue,
      //               onChanged: (double v) => c.seekTo(Duration(
      //                   seconds: (v * c.duration.inSeconds).toInt())),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   );
      // }
      // cover: Image.network('https://i.loli.net/2019/08/29/7eXVLcHAhtO9YQg.jpg'),
      // controllerWidgets: false,
      // cover: Text('Cover'),
      // initPosition: Duration(minutes: 23, seconds: 50)
    )
      ..addListener((c) {
        // print(c.value.positionText);
      })
      ..addFullScreenChangeListener((c, isFullScreen) async {})
      ..addPlayEndListener((c) {
        /*play end*/
      })
      ..addAccelerometerEventsListenner((controller, event) {
        if (!controller.isFullScreen) return;
        bool isHorizontal = event.x.abs() > event.y.abs();
        if (!isHorizontal) return;

        if (Platform.isIOS) {
          if (event.x > 1) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeRight]);
          } else if (event.x < -1) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeLeft]);
          }
        } else {
          if (event.x > 1) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeLeft]);
          } else if (event.x < -1) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeRight]);
          }
        }
      })
      ..initialize().then((_) {
        // initialized
      });
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('one video ctrl'),
      ),
      body: ListView(
        controller: controller,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoBox(
              controller: vc,
              children: <Widget>[
                Align(
                  alignment: Alignment(0.5, 0),
                  child: IconButton(
                    iconSize: VideoBox.centerIconSize,
                    disabledColor: Colors.white60,
                    icon: Icon(Icons.skip_next),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton(
                child: Text('play'),
                onPressed: () {
                  vc.play();
                },
              ),
              RaisedButton(
                child: Text('pause'),
                onPressed: () {
                  vc.pause();
                },
              ),
              RaisedButton(
                child: Text('full screen'),
                onPressed: () => vc.onFullScreenSwitch(context),
              ),
              RaisedButton(
                child: Text('print'),
                onPressed: () {
                  print(vc);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
