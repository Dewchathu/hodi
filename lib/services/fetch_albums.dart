import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'grant_permission.dart';

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