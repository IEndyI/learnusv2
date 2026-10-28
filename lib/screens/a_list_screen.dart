// 화면 A: 목록 (GET /items) — LearnUs v2: 학사 일정 및 과제 목록
//
// ┌──────── 디자인 가이드 대응표: A 목록 ───────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명                    │ 비즈니스 명칭(한글) │ 원칙(P번호)   │
// │ A-1  │ AppBar                            │ LearnUs 일정/과제   │ P04 일관성    │
// │ A-2  │ ListView + Card (ItemCard)        │ 과제·공지 카드 목록 │ P08 - P01   │
// │ A-3  │ GridView (넓은 화면 ≥600dp)       │ 과제 카드 격자      │ P08 - P04   │
// │ A-4  │ LoadingView                       │ 불러오는 중 표시    │ P01 가시성    │
// │ A-5  │ ErrorView + FilledButton          │ 오류 안내·다시 시도 │ P09 오류 복구 │
// │ A-6  │ EmptyView                         │ 빈 목록 안내        │ P01 가시성    │
// │ A-7  │ IconButton + AlertDialog          │ 긴급 표시 기준 도움말 │ P10 도움말   │
// └────────────────────────────────────────────────────────────────────────────┘
// 전환: A → B 는 쌓기(Navigator.push).  적응형: LayoutBuilder 600dp 분기 1곳(A-2 ↔ A-3).
// P번호 = 닐슨 원칙 번호 (docs/디자인가이드.md 2장). 그 원칙을 보여 주는 위젯 줄 끝에 `// A-4 P01` 처럼 단다.
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import 'b_detail_screen.dart';

/// 이 너비 이상이면 넓은 화면 배치 (Material 3 window size class: medium ≥ 600dp)
const wideBreakpoint = 600.0;

class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
    this.load = fetchItems,
    this.loadNotes = fetchNotes,
  });

  /// 데이터를 가져오는 함수 — 앱은 기본값(GET), 테스트는 가짜 함수를 넣는다.
  final ItemsLoader load;
  final NotesLoader loadNotes;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Item>> _future = widget.load();

  // 다시 시도 = Future만 새로 만드는 setState (화면 안 표시 변화 — 허용)
  void _retry() {
    setState(() {
      _future = widget.load();
    });
  }

  void _open(Item item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(item: item, loadNotes: widget.loadNotes), // P07 효율성
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnUs 일정/과제'), // A-1 P04
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '긴급 표시 기준',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('긴급 표시 기준'),
                content: const Text(
                  '휴강, 마감 변경처럼 지금 바로 확인해야 하는 공지에 "긴급"이 붙습니다. (예시 안내문)',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
          ), // A-7 P10
        ],
      ),
      // STATE: items(GET 결과) → A-2/A-3 목록, A-4·A-5·A-6 상태 화면
      body: FutureBuilder<List<Item>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingView(label: '일정 및 과제를 불러오는 중…'); // A-4 P01
          }
          if (snap.hasError) {
            return ErrorView(
              title: '일정을 불러오지 못했습니다.',
              message: '${snap.error}',
              onRetry: _retry,
            ); // A-5 P09
          }
          final items = snap.data ?? const <Item>[];
          if (items.isEmpty) {
            return const EmptyView(message: '등록된 과제나 일정이 없습니다.'); // A-6 P01
          }
          return LayoutBuilder(
            // 적응형: 기기 종류가 아니라 "이 영역의 너비"로 나눈다
            builder: (context, constraints) {
              if (constraints.maxWidth >= wideBreakpoint) {
                return GridView.builder(
                  // A-3 P08 넓은 화면: 카드 격자 (적응형)
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: 140,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) => ItemCard(
                    items[i],
                    vertical: true,
                    onTap: () => _open(items[i]),
                  ),
                );
              }
              return ListView.builder(
                // A-2 폰: 카드 목록 (P08 미니멀)
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, i) =>
                    ItemCard(items[i], onTap: () => _open(items[i])),
              );
            },
          );
        },
      ),
    );
  }
}

/// 항목 카드 한 장 — LearnUs v2 과제/공지 카드 위젯
class ItemCard extends StatelessWidget {
  const ItemCard(this.item, {super.key, this.onTap, this.vertical = false});

  final Item item;
  final VoidCallback? onTap;

  /// true: 넓은 화면 격자용 · false: 폰 목록용
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isUrgent = item.isAlert;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade100 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.course,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.red.shade900 : const Color(0xFF003876),
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.dDay,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isUrgent ? Colors.red.shade900 : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              isUrgent ? Icons.warning_amber_rounded : Icons.access_time,
              size: 14,
              color: isUrgent ? Colors.red.shade700 : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.dueDate,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isUrgent ? Colors.red.shade700 : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Card(
      margin: vertical
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isUrgent ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUrgent
            ? BorderSide(color: Colors.red.shade300, width: 1.5)
            : BorderSide(color: Colors.grey.shade200),
      ),
      color: isUrgent ? Colors.red.shade50 : Colors.white, // A-2 P01
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: info,
        ),
      ),
    );
  }
}