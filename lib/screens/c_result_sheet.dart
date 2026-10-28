// 화면 C: 결과(임의) — 덮기(modal) 예시 · LearnUs v2 과제 제출 체크리스트 및 양식 안내
//
// ┌──────── 디자인 가이드 대응표: C 결과(임의) ─────────────────────────────────┐
// │ 번호 │ Flutter 위젯명                   │ 비즈니스 명칭(한글)  │ 원칙(P번호)   │
// │ C-1  │ showModalBottomSheet + 손잡이    │ 제출 체크리스트 시트 │ P03 통제·자유 │
// │ C-2  │ Text(bodyMedium)                 │ 선택 과제 기준 문구  │ P01 가시성    │
// │ C-3  │ ListTile × 3                     │ 필수 제출 항목 목록  │ P06 재인      │
// │ C-4  │ Text(bodySmall, 회색)            │ 예시 안내 고지       │ P10 도움말    │
// └────────────────────────────────────────────────────────────────────────────┘
//
// ⚠ 실제 계산·추천·검색 로직 없음 (안내 5장: "실제 비즈니스 로직"은 감점).
//   어떤 항목에서 열어도 아래 _presetResults(미리 정한 값)를 그대로 보여 준다.
//   진짜 기능은 기획 문서의 "AI 활용 기회"로만 설명한다.
import 'package:flutter/material.dart';

import '../models.dart';

/// 미리 정한(하드코딩) 결과 — LearnUs v2 과제 제출 필수 확인 사항
const _presetResults = [
  (title: '제출 파일 형식 검증 (PDF/ZIP)', reason: '강의 계획서에 명시된 지정 포맷 준수 여부 확인'),
  (title: '마감 기한 및 지각 페널티 확인', reason: '마감 직전 트래픽 몰림 방지 및 시간 단위 자동 체크'),
  (title: '표절 검사(카피킬러) 사전 링크', reason: '대학 기준 유사도 15% 이하 유지 권장 안내'),
];

class ResultSheet extends StatelessWidget {
  const ResultSheet({super.key, required this.baseItem});

  final Item baseItem;

  /// 덮기(modal): 지금 화면 위에 잠깐 띄우고 닫는다.
  static Future<void> show(BuildContext context, Item item) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true, // C-1 P03
      isScrollControlled: true,
      builder: (_) => ResultSheet(baseItem: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '과제 제출 안내 및 체크리스트',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '[${baseItem.course}] ${baseItem.title}',
              style: text.bodyMedium?.copyWith(
                color: const Color(0xFF003876),
                fontWeight: FontWeight.w600,
              ),
            ), // C-2 P01
            const SizedBox(height: 12),
            for (final (i, r) in _presetResults.indexed) // C-3 P06
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF003876),
                  foregroundColor: Colors.white,
                  child: Text('${i + 1}'),
                ),
                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(r.reason),
              ),
            const SizedBox(height: 10),
            Text(
              '※ 프로토타입 예시 화면입니다. 실제 파일 업로드 및 저장 기능은 지원하지 않습니다.',
              style: text.bodySmall?.copyWith(color: Colors.grey.shade600),
            ), // C-4 P10
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}