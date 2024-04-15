import 'package:flutter/cupertino.dart';
import 'package:hodi/models/media.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:transparent_image/transparent_image.dart';

Future<List<Media>> fetchMedias({
  required AssetPathEntity albums,
  required int page,
})async{
  List<Media> medias = [];

  try{
    final List<AssetEntity> entities = await albums.getAssetListPaged(page: page, size: 38);

    for(var entity in entities){
      Media media = Media(
          assetEntity: entity, 
          widget:FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: AssetEntityImageProvider(
              entity,
              thumbnailSize: const ThumbnailSize.square(500),
              isOriginal: false,
            ),
            fit: BoxFit.cover,
          )
      );

      medias.add(media);
    }
  }catch(e){
    debugPrint('Error fetching media: $e');
  }

  return medias;
}