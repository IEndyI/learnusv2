// 기본 위젯 테스트 — A 목록 화면이 mock 데이터를 렌더링하고, "?" 안내창이 열리는지 확인
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';

const _mockItems = [
  Item(
    id: 1,
    course: '컴퓨터네트워크',
    title: '[긴급] 10/22(목) 강의 휴강 안내',
    dueDate: '오늘 10:15 공지',
    dDay: '긴급',
    isAlert: true,
    aiSummary: '교수 해외 출장으로 인한 긴급 휴강',
    content: '오늘 수업은 휴강입니다.',
  ),
  Item(
    id: 2,
    course: '응용모바일프로그래밍',
    title: '중간 프로젝트 기획서 및 UI 프로토타입 제출',
    dueDate: '10월 29일 (목) 15:00',
    dDay: 'D-7',
    isAlert: false,
    aiSummary: 'LearnUs v2 프로토타입 제출',
    content: '루브릭 기준에 맞춰 제출하세요.',
  ),
];

Future<List<Item>> _mockLoad() async => _mockItems;
Future<List<Note>> _mockLoadNotes(int id) async => [];

Widget _app() => MaterialApp(
      home: ListScreen(load: _mockLoad, loadNotes: _mockLoadNotes),
    );

void main() {
  testWidgets('ListScreen renders items properly', (WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('LearnUs 일정/과제'), findsOneWidget);
    expect(find.text('컴퓨터네트워크'), findsOneWidget);
    expect(find.text('응용모바일프로그래밍'), findsOneWidget);
  });

  testWidgets('A-7 help button opens the urgent criteria dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('긴급 표시 기준'), findsOneWidget);

    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.text('긴급 표시 기준'), findsNothing);
  });
}