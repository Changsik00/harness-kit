# feat(spec-12-02): AI 인스트럭션 멀티포맷 내보내기

## 배경

harness-kit 거버넌스가 Claude Code에만 적용되어 Cursor/Copilot 사용자는 수동으로 별도 파일을 관리해야 했다. install.sh에 옵션을 추가해 한 번에 해결한다.

## 변경 사항

- `install.sh` 수정: `--export-format=cursor|copilot` 옵션 추가
  - `cursor` → `.cursorrules` 생성
  - `copilot` → `.github/copilot-instructions.md` 생성
  - 소스: `sources/claude-fragments/CLAUDE.fragment.md`
  - 기본값 `none` — 기존 동작 완전 유지
- `tests/test-export-format.sh` 신규: TDD 5개 체크 PASS

## 테스트

```
✅ ALL 5 CHECKS PASSED (tests/test-export-format.sh)
✅ ALL 20 tests PASS (전체 테스트 스위트)
```
