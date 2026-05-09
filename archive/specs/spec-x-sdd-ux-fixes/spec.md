# spec-x-sdd-ux-fixes: SDD UX 개선 및 잔여 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-sdd-ux-fixes` |
| **Branch** | `spec-x-sdd-ux-fixes` |
| **타입** | Fix + Feature |
| **작성일** | 2026-04-17 |

## 배경

1. `sdd specx new` 명령 부재로 spec-x 생성 시 SDD 절차(plan/task/Plan Accept)가 강제되지 않음
2. `sdd phase done`이 archive된 phase.md에서 제목을 찾지 못해 queue.md에 `?` 표시
3. `sdd archive`가 spec-x 디렉토리를 제외하여 정리 불완전
4. README "프로젝트 구조 (개발자용)" 섹션이 본문과 중복

## 요구사항

1. **`sdd specx new <slug>`**: spec-x용 디렉토리 생성 + 템플릿 복사 (spec/plan/task/walkthrough) + state 설정. queue.md specx 섹션 등록
2. **`sdd phase done` archive fallback**: phase.md가 `archive/backlog/`에 있을 때도 제목 추출
3. **queue.md done 섹션 수정**: phase-08, 09, 10, 11의 `?` → 실제 제목
4. **`sdd archive`에 spec-x 포함**: 완료된 spec-x도 `archive/specs/`로 이동
5. **README 개발자용 섹션 제거**
