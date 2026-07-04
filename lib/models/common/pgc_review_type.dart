import 'package:liqliquid/http/api.dart';

enum PgcReviewType {
  long(label: '闀胯瘎', api: Api.pgcReviewL),
  short(label: '鐭瘎', api: Api.pgcReviewS),
  ;

  final String label;
  final String api;
  const PgcReviewType({
    required this.label,
    required this.api,
  });
}

enum PgcReviewSortType {
  def('榛樿', 0),
  latest('鏈€鏂?, 1),
  ;

  final int sort;
  final String label;
  const PgcReviewSortType(this.label, this.sort);
}

