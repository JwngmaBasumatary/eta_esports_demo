import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:dio/dio.dart';
import 'package:eta_esports_demo/constants.dart';
import 'package:eta_esports_demo/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String downloadProgress = "";
  bool downloading = false;
  bool? appInstalled;
  bool recheckAppInstalled = false;
  // bool fetchingPackage = true;

  @override
  void initState() {
    super.initState();
    checkAppInstalled();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        checkAppInstalled();
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  void checkAppInstalled() async {
    debugPrint("Checking App Installed.......");
    setState(() {
      recheckAppInstalled = false;
      appInstalled = null;
    });
    var appPackageName = await FirestoreServices().getAppPackageName();

    // setState(() {
    //   fetchingPackage = false;
    // });

    if (appPackageName != null) {
      bool isInstalled = await DeviceApps.isAppInstalled(appPackageName);

      if (isInstalled) {
        debugPrint("App Installed");
        DeviceApps.openApp(appPackageName);
        setState(() {
          recheckAppInstalled = true;
          appInstalled = null;
        });
      } else {
        debugPrint("App Not Installed");

        // setState(() {
        //   recheckAppInstalled = false;
        //   appInstalled = null;
        // });

        setState(() {
          appInstalled = isInstalled;
        });
      }
    }
  }

  void downloadApp(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(
      context: context,
      backgroundColor: Colors.blue,
      loadingText: "Please Wait ! We are Updating your application",
      textColor: Colors.white,
    );

    progressDialog.show();

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = "${tempDir.path}/eta_esports_app.apk";
    var linkToDownload = await FirestoreServices().getDownloadLink();
    debugPrint("tempPath $tempPath");
    try {
      var response = await Dio().download(
          //'https://firebasestorage.googleapis.com/v0/b/esports-tournament-app-de5e8.appspot.com/o/esports_india.apk?alt=media&token=b187b158-8df0-40c8-a422-434b1a95b8b5',
          linkToDownload,
          tempPath, onReceiveProgress: (rec, total) {
        debugPrint("progress " + "${(rec / total * 100).round()}");
        setState(() {
          downloading = true;
          downloadProgress = "${(rec / total * 100).round()} %";
        });
      });
      progressDialog.dismiss();
      debugPrint(response.statusMessage);
    } catch (e) {
      debugPrint(e.toString());
    }

    OpenFile.open(tempPath);

    setState(() {
      downloadProgress = "Download Complete";
      downloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01021B),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: Container(
                decoration: const BoxDecoration(color: Colors.blueGrey),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Image.asset(
                        Constants.appLogo,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Center(
                        child: Text(
                      " Hello Users! How are You Today?\n\n Would You Like To Play Ludo ? ",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
                    const SizedBox(
                      height: 20,
                    ),
                    recheckAppInstalled
                        ? Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  checkAppInstalled();
                                },
                                child: const Text("Continue")),
                          )
                        : appInstalled == null
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Column(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        downloadApp(context);
                                      },
                                      child: const Text("Continue")),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Text(
                                    downloadProgress,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                ],
                              )
                  ],
                ),
              )),
              // Expanded(
              //   child: Image.asset(
              //     "assets/abstract-futuristic-background-2.jpg",
              //     fit: BoxFit.fitHeight,
              //   ),
              // ),
/*              recheckAppInstalled
                  ? Center(
                      child: ElevatedButton(
                          onPressed: () {
                            checkAppInstalled();
                          },
                          child: const Text("Continue")),
                    )
                  : appInstalled == null
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  downloadApp(context);
                                },
                                child: const Text("Continue")),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              downloadProgress,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],
                        )*/
            ],
          ),
        ),
      ),
    );
  }
}
