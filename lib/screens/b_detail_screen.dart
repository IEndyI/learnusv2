// 화면 B: 상세 — LearnUs v2: 과제 및 공지 상세 안내 (AI 2문장 요약 포함)
//
// ┌──────── 디자인 가이드 대응표: B 상세 ───────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명                  │ 비즈니스 명칭(한글)  │ 원칙(P번호)    │
// │ B-1  │ AppBar + BackButton             │ 과제/공지 상세 제목줄│ P03 통제·자유  │
// │ B-2  │ TabBar + TabBarView             │ 과제안내 | 메모 탭   │ P06 재인       │
// │ B-3  │ AiSummaryCard + Text(과제제목)  │ AI 2문장 요약·과제명 │ P08 -P01 │
// │ B-4  │ Wrap(Chip …)                    │ 과목 및 분류 태그 칩 │ P08 미니멀     │
// │ B-5  │ OutlinedButton → SnackBar       │ 캘린더 등록(가짜)    │ STATE 표시만   │
// │ B-6  │ FilledButton → 모달 시트        │ 과제 제출 양식 확인  │ P07 효율성     │
// │ B-7  │ FutureBuilder(GET /notes)       │ 과제 관련 메모 목록  │ P01 · P09      │
// └────────────────────────────────────────────────────────────────────────────┘
// 전환: A → B 쌓기(push) · B 안에서 옆으로(tab) · B → C 덮기(modal)
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import 'c_result_sheet.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.item,
    this.loadNotes = fetchNotes,
  });

  final Item item;
  final NotesLoader loadNotes;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(item.course), // B-1 P03
          bottom: const TabBar(
            // B-2 P06
            tabs: [
              Tab(text: '과제 안내'),
              Tab(text: '과제 메모'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InfoTab(item: item),
            _NotesTab(itemId: item.id, load: loadNotes),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isUrgent = item.isAlert;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 상단 마감일 / 긴급 상태 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUrgent ? Colors.red.shade200 : Colors.blue.shade100,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isUrgent ? Icons.warning_amber_rounded : Icons.calendar_today,
                size: 18,
                color: isUrgent ? Colors.red.shade800 : const Color(0xFF003876),
              ),
              const SizedBox(width: 8),
              Text(
                '일정: ${item.dueDate} (${item.dDay})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.red.shade900 : const Color(0xFF003876),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // B-3: 과제 전체 제목
        Text(
          item.title,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // B-4: 태그 칩
        if (item.tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in item.tags)
                Chip(
                  label: Text(t, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(color: Colors.grey.shade300),
                )
            ],
          ),
        const SizedBox(height: 18),

        // B-3 AI 기능: 2문장 핵심 요약 카드 (P08 미니멀 / 요약 우선)
        _AiSummaryBox(summary: item.aiSummary),
        const SizedBox(height: 20),

        // 과제 상세 설명문 본문
        const Text(
          '상세 안내문',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            item.content,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
        const SizedBox(height: 24),

        // B-5 STATE: 저장(즐겨찾기) 예시 버튼
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('캘린더에 고정되었습니다 (예시 화면 — 실제 저장하지 않음)')),
          ),
          icon: const Icon(Icons.bookmark_border),
          label: const Text('중요 일정 등록 (예시)'),
        ),
        const SizedBox(height: 8),

        // B-6 P07: 모달 결과 시트 (C 결과 화면)
        FilledButton.icon(
          onPressed: () => ResultSheet.show(context, item),
          icon: const Icon(Icons.description_outlined),
          label: const Text('제출 양식 및 제출함 열기'),
        ),
      ],
    );
  }
}

/// B-3 AI 전용 2문장 요약 위젯 (P08)
class _AiSummaryBox extends StatelessWidget {
  const _AiSummaryBox({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFEDF2F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFCBD5E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.auto_awesome, size: 18, color: Color(0xFF003876)),
                SizedBox(width: 6),
                Text(
                  'AI 핵심 2문장 요약',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003876),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI가 요약한 내용입니다. 정확한 내용은 아래 상세 안내문을 확인하세요.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF718096)),
            ), // B-3 P01
          ],
        ),
      ),
    );
  }
}

/// B-7 '메모' 탭 (GET /notes?itemId=…)
class _NotesTab extends StatefulWidget {
  const _NotesTab({required this.itemId, required this.load});

  final int itemId;
  final NotesLoader load;

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  late Future<List<Note>> _future = widget.load(widget.itemId);

  void _retry() {
    setState(() {
      _future = widget.load(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(     // STATE: notes(GET 결과) → B-7 목록과 상태 화면
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(label: '메모를 불러오는 중…'); // B-7 P01
        }
        if (snap.hasError) {
          return ErrorView(
            title: '메모를 불러오지 못했습니다.',
            message: '${snap.error}',
            onRetry: _retry,
          ); // B-7 P09
        }
        final notes = snap.data ?? const <Note>[];
        if (notes.isEmpty) {
          return const EmptyView(message: '등록된 과제 메모가 없습니다.'); // B-7 P01
        }
        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) => ListTile(
            leading: const Icon(Icons.notes_outlined, color: Color(0xFF003876)),
            title: Text(notes[i].text),
            subtitle: Text(notes[i].date),
          ),
        );
      },
    );
  }
}