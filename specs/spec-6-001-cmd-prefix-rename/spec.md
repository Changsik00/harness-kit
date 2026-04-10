# spec-6-001: 슬래시 커맨드 `hk-` prefix 일괄 변경

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-6-001` |
| **Phase** | `phase-6` |
| **Branch** | `spec-6-001-cmd-prefix-rename` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

harness-kit이 설치하는 슬래시 커맨드(`/align`, `/handoff` 등)가 prefix 없이 등록되어 있어, 사용자가 직접 만든 커맨드와 구분할 수 없다.

### 문제점

- 커맨드 목록에서 harness-kit 제공 vs 사용자 커스텀 구분 불가
- 다른 도구가 같은 이름의 커맨드를 설치하면 충돌 가능

### 해결 방안 (요약)

모든 harness-kit 슬래시 커맨드 파일명에 `hk-` prefix를 부여하고, 거버넌스 문서 내 참조를 일괄 갱신한다.

## 🎯 요구사항

### Functional Requirements
1. `sources/commands/` 내 모든 `.md` 파일명을 `hk-` prefix로 변경
2. 거버넌스 문서(`sources/governance/`, `agent/`) 내 커맨드 참조를 새 이름으로 갱신
3. `sources/claude-fragments/CLAUDE.md.fragment` 내 참조 갱신
4. `install.sh` 내 참조 갱신
5. `CLAUDE.md` 내 참조 갱신
6. `.claude/commands/` 도그푸딩 반영

### Non-Functional Requirements
1. 기존 커맨드와의 하위 호환: 불필요 (일괄 전환)
2. install.sh의 commands 복사 로직이 변경 없이 동작해야 함 (glob 패턴 `*.md` 사용 중이면 자동 대응)

## 🚫 Out of Scope

- 커맨드 내용 변경 (이름만 변경)
- sdd CLI 내부 로직 변경 (커맨드 참조가 없으므로)

## ✅ Definition of Done

- [ ] `sources/commands/` 내 모든 파일이 `hk-` prefix를 가짐
- [ ] 거버넌스 문서 내 모든 참조가 `hk-` prefix로 갱신됨
- [ ] `.claude/commands/` 도그푸딩 반영
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-6-001-cmd-prefix-rename` 브랜치 push 완료
