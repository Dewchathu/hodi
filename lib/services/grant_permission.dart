import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> grantPermissions() async{
  try{
    final bool cameraGranted = await Permission.camera.isGranted;
    final bool storageGranted = await Permission.storage.isGranted;
    final bool mediaGranted = await Permission.accessMediaLocation.isGranted;

    if(!cameraGranted || !storageGranted || !mediaGranted){
      final Map<Permission, PermissionStatus>statuses = await [
        Permission.camera,
        Permission.storage,
        Permission.accessMediaLocation,
      ].request();

      if((statuses[Permission.camera] == PermissionStatus.permanentlyDenied)||
          (statuses[Permission.storage] == PermissionStatus.permanentlyDenied) ||
          (statuses[Permission.accessMediaLocation] == PermissionStatus.permanentlyDenied)){
        await openAppSettings();
      }
    }
  }catch(e){
    debugPrint('Error granting permissions: $e');
  }
}