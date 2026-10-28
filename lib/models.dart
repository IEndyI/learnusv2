// 데이터 모양 — db.json의 한 항목을 화면이 쓰기 좋은 객체로 바꾼다.
// 형식이 틀린 항목은 null을 돌려준다 → 목록에서 빠질 뿐 앱이 멈추지 않는다 (Dart 3 패턴 매칭).

class Item {
  const Item({
    required this.id,
    required this.course,
    required this.title,
    required this.dueDate,
    required this.dDay,
    this.isAlert = false,
    required this.aiSummary,
    required this.content,
    this.tags = const [],
  });

  final int id;
  final String course;
  final String title;
  final String dueDate;
  final String dDay;
  final bool isAlert;
  final String aiSummary;
  final String content;
  final List<String> tags;

  static Item? fromJson(Object? json) {
    return switch (json) {
      {
        'id': dynamic rawId,
        'course': String course,
        'title': String title,
        'dueDate': String dueDate,
        'dDay': String dDay,
        'aiSummary': String aiSummary,
        'content': String content,
      } =>
        Item(
          id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
          course: course,
          title: title,
          dueDate: dueDate,
          dDay: dDay,
          isAlert: json['isAlert'] is bool ? json['isAlert'] as bool : false,
          aiSummary: aiSummary,
          content: content,
          tags: switch (json['tags']) {
            List<Object?> t => t.whereType<String>().toList(),
            _ => const [],
          },
        ),
      _ => null,
    };
  }
}

class Note {
  const Note({
    required this.id,
    required this.itemId,
    required this.text,
    required this.date,
  });

  final int id;
  final int itemId;
  final String text;
  final String date;

  static Note? fromJson(Object? json) {
    return switch (json) {
      {
        'id': dynamic rawId,
        'itemId': dynamic rawItemId,
        'text': String text,
        'date': String date,
      } =>
        Note(
          id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
          itemId: rawItemId is int ? rawItemId : int.tryParse(rawItemId.toString()) ?? 0,
          text: text,
          date: date,
        ),
      _ => null,
    };
  }
}