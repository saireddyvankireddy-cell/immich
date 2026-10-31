import 'dart:convert';

import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';
import 'package:immich_mobile/models/search/search_filter.model.dart';

/// Server-side filters. No client-side filtering of loaded thumbnail pages.
class KakiGallerySelection {
  const KakiGallerySelection({
    this.favorite = false,
    this.mediaType = AssetType.other,
    this.thisMonth = false,
    this.screenshots = false,
  });

  final bool favorite;
  final AssetType mediaType;
  final bool thisMonth;
  final bool screenshots;

  KakiGallerySelection copyWith({bool? favorite, AssetType? mediaType, bool? thisMonth, bool? screenshots}) =>
      KakiGallerySelection(
        favorite: favorite ?? this.favorite,
        mediaType: mediaType ?? this.mediaType,
        thisMonth: thisMonth ?? this.thisMonth,
        screenshots: screenshots ?? this.screenshots,
      );

  SearchFilter apply(SearchFilter base, DateTime now) {
    final firstDay = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    return base.copyWith(
      filename: screenshots ? 'Screenshot' : null,
      mediaType: mediaType,
      date: SearchDateFilter(takenAfter: thisMonth ? firstDay : null, takenBefore: thisMonth ? nextMonth : null),
      display: base.display.copyWith(isFavorite: favorite),
    );
  }

  String encode() => jsonEncode({
    'favorite': favorite,
    'mediaType': mediaType.name,
    'thisMonth': thisMonth,
    'screenshots': screenshots,
  });

  static KakiGallerySelection decode(String raw) {
    final value = jsonDecode(raw) as Map<String, dynamic>;
    return KakiGallerySelection(
      favorite: value['favorite'] == true,
      mediaType: switch (value['mediaType']) {
        'image' => AssetType.image,
        'video' => AssetType.video,
        _ => AssetType.other,
      },
      thisMonth: value['thisMonth'] == true,
      screenshots: value['screenshots'] == true,
    );
  }
}
