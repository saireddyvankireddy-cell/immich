import 'package:flutter_test/flutter_test.dart';
import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';
import 'package:immich_mobile/models/search/search_filter.model.dart';
import 'package:immich_mobile/presentation/pages/search/kaki_gallery_filters.dart';

void main() {
  const base = SearchFilter(
    people: {},
    location: SearchLocationFilter(),
    camera: SearchCameraFilter(),
    date: SearchDateFilter(),
    rating: SearchRatingFilter(),
    display: SearchDisplayFilters(isNotInAlbum: false, isArchive: false, isFavorite: false),
    mediaType: AssetType.other,
  );

  test('combined filters are sent to server and survive preset storage', () {
    const selection = KakiGallerySelection(
      favorite: true,
      mediaType: AssetType.image,
      thisMonth: true,
      screenshots: true,
    );
    final restored = KakiGallerySelection.decode(selection.encode());
    final query = restored.apply(base, DateTime(2026, 10, 31));
    expect(query.display.isFavorite, true);
    expect(query.mediaType, AssetType.image);
    expect(query.filename, 'Screenshot');
    expect(query.date.takenAfter, DateTime(2026, 10));
    expect(query.date.takenBefore, DateTime(2026, 11));
  });

  test('clear selection removes gallery filters', () {
    final query = const KakiGallerySelection().apply(base, DateTime(2026, 10, 31));
    expect(query.isEmpty, true);
  });
}
