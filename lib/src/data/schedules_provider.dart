import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

part "schedules_provider.g.dart";

Schedule _november(int day, String title, String description, {int? until}) => (
  title: title,
  description: description,
  start: DateTime.utc(2026, 11, day),
  end: DateTime.utc(2026, 11, until ?? day),
);

/// Every schedule, shared by the calendar and the registration page.
// shortcut: samples kept in memory (gone on restart), move behind a
// repository once they come from the API.
@Riverpod(keepAlive: true)
class Schedules extends _$Schedules {
  @override
  List<Schedule> build() => [
    _november(10, "청년부 수련회", "1박 2일, 가평 수양관", until: 11),
    _november(10, "특별 새벽기도", "새벽 5시 30분, 본당", until: 12),
    _november(10, "화요 기도 모임", "저녁 8시, 본당 2층 소예배실"),
    _november(10, "청년부 임원 회의", "기도 모임 후 30분, 다음 달 수련회 준비"),
    _november(10, "찬양팀 연습", "오후 6시, 본당"),
    _november(10, "새가족 환영 준비", "오후 5시, 1층 로비 데코 및 선물 포장"),
    _november(10, "중보기도 모임", "밤 9시 30분, 온라인"),
    _november(15, "주일 예배", "오전 11시, 본당"),
    _november(21, "가을 야외 예배", "오전 10시 교회 앞 집합, 도시락 지참"),
  ];

  void add(Schedule schedule) => state = [...state, schedule];
}
