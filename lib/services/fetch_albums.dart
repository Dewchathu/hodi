import 'package:flutter/material.dart';
import 'package:hodi/services/grant_permission.dart';
import 'package:photo_manager/photo_manager.dart';

Future<List<AssetPathEntity>> fetchAlbums() async {
  try{
    await grantPermissions();

    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();


    return albums;
  }catch(e){
    debugPrint('Error fetching albums: $e');
    return[];
  }
}