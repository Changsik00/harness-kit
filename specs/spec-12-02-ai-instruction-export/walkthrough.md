# Walkthrough: spec-12-02 AI 인스트럭션 멀티포맷 내보내기

## 무엇을 만들었나

`install.sh`에 `--export-format` 옵션 추가. harness-kit 거버넌스 요약(`CLAUDE.fragment.md`)을 Cursor(`.cursorrules`) 또는 GitHub Copilot(`.github/copilot-instructions.md`) 포맷으로 자동 생성한다.

## 사용법

```bash
# Cursor IDE용
bash install.sh --yes --export-format=cursor /path/to/project

# GitHub Copilot용
bash install.sh --yes --export-format=copilot /path/to/project

# 기본값 (none) — 기존 동작 유지
bash install.sh --yes /path/to/project
```

## 핵심 흐름

```
install.sh --export-format=cursor|copilot
  └── _export_ai_instructions()
        ├── 소스: sources/claude-fragments/CLAUDE.fragment.md
        ├── cursor  → <TARGET>/.cursorrules
        └── copilot → <TARGET>/.github/copilot-instructions.md
              └── 이미 존재 시 경고 후 덮어쓰기
```

## 변경 파일

| 파일 | 변경 | 설명 |
|---|---|---|
| `install.sh` | 수정 | `--export-format` 옵션 + `_export_ai_instructions()` 함수 |
| `tests/test-export-format.sh` | 신규 | TDD 테스트 5개 |
