# Walkthrough: spec-6-001

## 📋 실제 구현된 변경사항

- [x] `sources/commands/` 9개 파일 → `hk-` prefix rename
- [x] `.claude/commands/` 9개 파일 → `hk-` prefix rename (도그푸딩)
- [x] `sources/governance/` 3개 파일 내 커맨드 참조 갱신
- [x] `agent/` 3개 파일 내 커맨드 참조 갱신 (도그푸딩)
- [x] `sources/claude-fragments/CLAUDE.md.fragment` 참조 갱신
- [x] `install.sh` 참조 갱신
- [x] `CLAUDE.md` 참조 갱신

## 🧪 검증 결과

```text
$ ls sources/commands/ | grep -v "^hk-"  → 결과 없음 (모두 hk- prefix)
$ grep -r "/(align|plan-accept|gh-pr|bb-pr)" sources/governance/ agent/ CLAUDE.md  → 구 이름 참조 0건
```

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-11 |
| **최종 commit** | `7c33a3f` |
