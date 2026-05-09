# feat(spec-x-sdd-ux-fixes): SDD UX 개선 및 잔여 수정

## Summary

1. **`sdd specx new <slug>`** — spec-x 생성 시 4종 템플릿(spec/plan/task/walkthrough) 자동 복사 + state 설정 + queue.md 등록. spec-x도 SDD 절차 강제
2. **`sdd phase done` archive fallback** — phase.md가 `archive/backlog/`에 있을 때도 제목 추출 가능
3. **queue.md done 제목 수정** — phase-08~11의 `?` → 실제 제목
4. **`sdd archive`에 spec-x 포함** — 완료된 spec-x도 `archive/specs/`로 이동
5. **README 개발자용 섹션 제거** — 본문과 중복

## Verification

18/18 전체 테스트 PASS
