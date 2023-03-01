import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofencing_test_task/notification_service.dart';
import 'package:get/get.dart';

class GeofencingController extends GetxController {
  late GeofenceService geofenceService;
  final firstLocationLatTC = TextEditingController();
  final firstLocationLonTC = TextEditingController();
  final firstLocationRadiusTC = TextEditingController();
  final secondLocationLatTC = TextEditingController();
  final secondLocationLonTC = TextEditingController();
  final secondLocationRadiusTC = TextEditingController();

  final _geofenceList = <Geofence>[];
  final geofenceLogList = <String>[].obs;

  late NotificationService notificationService;

  @override
  void onInit() {
    notificationService = NotificationService();
    initNotification();
    super.onInit();
  }

  Future<void> initNotification() async {
    await notificationService.init();
  }

  void onInitGeofenceService() {
    // Create a [GeofenceService] instance and set options.
    geofenceService = GeofenceService.instance.setup(
      allowMockLocations: true,
      printDevLog: true,
    );
    geofenceLogList.add("Initiate Geofence Service");
  }

// This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(Geofence geofence, GeofenceRadius geofenceRadius, GeofenceStatus geofenceStatus, Location location) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    notificationService.showNotification(
        "You ${geofenceStatus == GeofenceStatus.ENTER ? 'entered' : 'exited'} to ${geofence.id == "first_loc" ? 'First location' : 'Second location'}",
        "${geofence.latitude}, ${geofence.longitude}");
    geofenceLogList.add(
        "You ${geofenceStatus == GeofenceStatus.ENTER ? 'entered' : 'exited'} to ${geofence.id == "first_loc" ? 'First location' : 'Second location'} - ${geofence.latitude}, ${geofence.longitude}");
  }

// This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  //Save Location
  void onSaveLocation() {
    _geofenceList.clear();
    if (!(firstLocationLatTC.text.isEmpty) && !(firstLocationLonTC.text.isEmpty) && !(firstLocationRadiusTC.text.isEmpty)) {
      print("${firstLocationLatTC.text} - ${firstLocationLonTC.text} - ${firstLocationRadiusTC.text}");
      _geofenceList.add(
        Geofence(
          id: 'first_loc',
          latitude: double.tryParse(firstLocationLatTC.text) ?? 0.0,
          longitude: double.tryParse(firstLocationLonTC.text) ?? 0.0,
          radius: [
            GeofenceRadius(id: 'first_loc_rd', length: double.tryParse(firstLocationRadiusTC.text) ?? 0.0),
          ],
        ),
      );
    }
    if (!(secondLocationLatTC.text.isEmpty) || !(secondLocationLonTC.text.isEmpty) || !(secondLocationRadiusTC.text.isEmpty)) {
      print("${secondLocationLatTC.text} - ${secondLocationLonTC.text} - ${secondLocationRadiusTC.text}");
      _geofenceList.add(
        Geofence(
          id: 'second_loc',
          latitude: double.tryParse(secondLocationLatTC.text) ?? 0.0,
          longitude: double.tryParse(secondLocationLonTC.text) ?? 0.0,
          radius: [
            GeofenceRadius(id: 'second_loc_rd', length: double.tryParse(secondLocationRadiusTC.text) ?? 0.0),
          ],
        ),
      );
    }
    showToast("Geofence saved!!");
    geofenceLogList.add("Geofence saved!!");
  }

  //Start listening
  void onStartListening() {
    geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    geofenceService.addStreamErrorListener(_onError);
    geofenceService.start(_geofenceList).catchError(_onError);
    showToast("Start Listening Geofence Service");
    geofenceLogList.add("Start Listening Geofence Service");
  }

  //Stop listening
  void onStopListening() {
    geofenceService.removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    geofenceService.removeStreamErrorListener(_onError);
    geofenceService.clearAllListeners();
    geofenceService.stop();

    showToast("Stop Listening Geofence Service");
    geofenceLogList.add("Stop Listening Geofence Service");
  }

  //Clear Log listening
  void onClearListening() {
    geofenceLogList.clear();
  }

  void showToast(String msg) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, fontSize: 16.0);
  }
}
