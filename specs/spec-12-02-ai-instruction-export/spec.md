# spec-12-02: AI 인스트럭션 멀티포맷 내보내기

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-12-02` |
| **Phase** | `phase-12` |
| **Branch** | `spec-12-02-ai-instruction-export` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-20 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
harness-kit의 거버넌스(constitution.md, agent.md 등)는 Claude Code에 최적화되어 있다. 팀에 Cursor 또는 GitHub Copilot 사용자가 있으면 동일한 규칙을 수동으로 별도 파일(`.cursorrules`, `.github/copilot-instructions.md`)에 복사해야 한다.

### 문제점
- Claude Code 규약이 다른 AI IDE에 자동으로 반영되지 않음
- 수동 복사 시 규약 불일치가 생기고 유지보수 부담이 커짐
- install.sh/update.sh 실행 시 대상 포맷을 선택할 방법이 없음

### 해결 방안 (요약)
`install.sh`에 `--export-format` 옵션을 추가해 `.cursorrules` 또는 `copilot-instructions.md`를 자동 생성한다. 내용은 harness-kit의 `CLAUDE.fragment.md`(거버넌스 요약)를 기반으로 각 포맷에 맞게 wrapping한다.

## 🎯 요구사항

### Functional Requirements
1. `install.sh --export-format=cursor` → `.cursorrules` 생성 (대상 프로젝트 루트)
2. `install.sh --export-format=copilot` → `.github/copilot-instructions.md` 생성
3. 내용 소스: `sources/claude-fragments/CLAUDE.fragment.md` (거버넌스 요약)
4. 이미 파일이 존재하면 덮어쓰기 전 경고 출력
5. `--export-format=none` (기본값) → 기존 동작 유지

### Non-Functional Requirements
1. bash 3.2 호환 (macOS 기본 환경)
2. 기존 install.sh 옵션과 충돌 없음
3. 새 옵션은 `--help` 출력에 반영

## 🚫 Out of Scope

- Cursor/Copilot 설정 파일의 내용 자동 번역/요약 (그대로 복사)
- update.sh에서 --export-format 지원 (이번 spec 범위 아님)
- JetBrains AI / Windsurf 등 추가 IDE 지원

## ✅ Definition of Done

- [ ] `tests/test-export-format.sh` 전체 PASS
- [ ] `install.sh`에 `--export-format` 옵션 구현
- [ ] cursor/copilot 포맷 파일 올바르게 생성 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-12-02-ai-instruction-export` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
