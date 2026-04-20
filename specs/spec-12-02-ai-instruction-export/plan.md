# Implementation Plan: spec-12-02

## 📋 Branch Strategy

- 신규 브랜치: `spec-12-02-ai-instruction-export`
- 시작 지점: `main`

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] `--export-format` 기본값이 `none`이므로 기존 사용자에게 영향 없음 — 확인 필요

## 🎯 핵심 전략

### 아키텍처 컨텍스트

```
install.sh --export-format=cursor|copilot|none
  └── _export_ai_instructions()
        ├── 소스: sources/claude-fragments/CLAUDE.fragment.md
        ├── cursor  → <TARGET>/.cursorrules
        └── copilot → <TARGET>/.github/copilot-instructions.md
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **소스 파일** | `CLAUDE.fragment.md` 그대로 복사 | 번역/요약 없이 일관성 유지 |
| **기존 파일** | 경고 후 덮어쓰기 | `--yes` 플래그와 일관된 동작 |
| **기본값** | `none` | 기존 install 사용자 영향 없음 |
| **update.sh** | 이번 범위 제외 | 범위 최소화 |

## 📂 Proposed Changes

### [MODIFY] `install.sh`
`--export-format=cursor|copilot|none` 옵션 파싱 및 `_export_ai_instructions()` 함수 추가

### [NEW] `tests/test-export-format.sh`
- Check 1: `--export-format` 미지정 → `.cursorrules` 생성 안 됨
- Check 2: `--export-format=cursor` → `.cursorrules` 생성
- Check 3: `.cursorrules` 내용이 CLAUDE.fragment.md를 포함
- Check 4: `--export-format=copilot` → `.github/copilot-instructions.md` 생성
- Check 5: 파일 이미 존재 시 덮어쓰기 경고 출력

## 🧪 검증 계획

```bash
bash tests/test-export-format.sh
```

### 수동 검증 시나리오
1. `bash install.sh --yes --export-format=cursor /tmp/test-proj` → `.cursorrules` 확인
2. `bash install.sh --yes --export-format=copilot /tmp/test-proj` → `.github/copilot-instructions.md` 확인

## 🔁 Rollback Plan

- `.cursorrules` / `.github/copilot-instructions.md` 삭제

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
