import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:get/get.dart';

import 'geofancing_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Geofencing test task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _con = Get.put(GeofencingController());
  @override
  void initState() {
    _con.onInitGeofenceService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return WillStartForegroundTask(
      onWillStart: () async {
        // You can add a foreground task start condition.
        return _con.geofenceService.isRunningService;
      },
      androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription: 'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
          visibility: NotificationVisibility.VISIBILITY_SECRET),
      iosNotificationOptions: const IOSNotificationOptions(),
      notificationTitle: 'Geofence Service is running',
      notificationText: 'Tap to return to the app',
      foregroundTaskOptions: const ForegroundTaskOptions(interval: 500, allowWakeLock: true),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Location Tracker"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text('Note: please stop and start if you change lat, log and Radius'),
                  Center(
                    child: Text(
                      'Set Location',
                      style: theme.textTheme.headline6?.copyWith(color: theme.primaryColor),
                    ),
                  ),
                  Text('First Location:', style: theme.textTheme.headline6),
                  TextField(
                      decoration: InputDecoration(hintText: "Latitude"), controller: _con.firstLocationLatTC, keyboardType: TextInputType.number),
                  TextField(
                      decoration: InputDecoration(hintText: "Longitude"), controller: _con.firstLocationLonTC, keyboardType: TextInputType.number),
                  TextField(
                      decoration: InputDecoration(hintText: "Radius"), controller: _con.firstLocationRadiusTC, keyboardType: TextInputType.number),
                  SizedBox(height: 15),
                  Text('Second Location:', style: theme.textTheme.headline6),
                  TextField(
                      decoration: InputDecoration(hintText: "Latitude"), controller: _con.secondLocationLatTC, keyboardType: TextInputType.number),
                  TextField(
                      decoration: InputDecoration(hintText: "Longitude"), controller: _con.secondLocationLonTC, keyboardType: TextInputType.number),
                  TextField(
                      decoration: InputDecoration(hintText: "Radius"), controller: _con.secondLocationRadiusTC, keyboardType: TextInputType.number),
                  Center(
                      child: ElevatedButton(
                          onPressed: _con.onSaveLocation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: const Text("Save"),
                          ))),
                  const Divider(thickness: 3),
                  ElevatedButton(onPressed: _con.onStartListening, child: Text("Start")),
                  ElevatedButton(onPressed: _con.onStopListening, child: Text("Stop")),
                  ElevatedButton(onPressed: _con.onClearListening, child: Text("Clear Log")),
                  SizedBox(height: 15),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _con.geofenceLogList.value
                          .map(
                            (e) => Text(
                              'Status: $e',
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
