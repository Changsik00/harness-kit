# spec-9-002: CLAUDE.md @import 방식 전환

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-9-002` |
| **Phase** | `phase-9` |
| **Branch** | `spec-9-002-claude-md-import` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-14 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`는 대상 프로젝트의 `CLAUDE.md` 끝에 `<!-- HARNESS-KIT:BEGIN -->` ~ `<!-- HARNESS-KIT:END -->` 블록 전체(약 15줄)를 직접 append한다. `update.sh`도 이 블록을 통째로 교체한다.

### 문제점

1. **merge conflict 위험**: 팀원이 동시에 `CLAUDE.md`를 수정하면 harness-kit 블록이 conflict를 일으킨다.
2. **CLAUDE.md 비대화**: 설치 후 `CLAUDE.md`가 harness-kit 내용으로 길어져 사용자 지침과 섞인다.
3. **update 시 기존 내용 손상 위험**: `HARNESS-KIT:BEGIN/END` 블록 교체 로직이 사용자가 블록 사이에 내용을 추가한 경우 삭제한다.
4. **단일 파일 의존**: harness-kit 규약 업데이트 시 `CLAUDE.md` 자체를 수정해야 하므로 사용자 커스텀과 충돌한다.

### 해결 방안 (요약)

`CLAUDE.md`의 `HARNESS-KIT` 블록을 단 3줄의 `@import` 참조로 교체한다. 실제 내용은 `.harness-kit/CLAUDE.fragment.md`에 별도 관리하며, `update.sh`는 `CLAUDE.md`를 건드리지 않고 fragment 파일만 교체한다.

## 📊 개념도

```
[현재]
CLAUDE.md
  ├── 사용자 내용 (위)
  └── <!-- HARNESS-KIT:BEGIN -->
      ## 에이전트 운영 규약 ...   ← 15줄 직접 삽입
      <!-- HARNESS-KIT:END -->

[목표]
CLAUDE.md
  ├── 사용자 내용 (위)
  └── <!-- HARNESS-KIT:BEGIN -->
      @.harness-kit/CLAUDE.fragment.md   ← 1줄 @import
      <!-- HARNESS-KIT:END -->

.harness-kit/CLAUDE.fragment.md   ← 실제 규약 내용 (update.sh만 수정)
```

## 🎯 요구사항

### Functional Requirements

1. **install.sh**: `CLAUDE.md`에 `HARNESS-KIT` 블록 삽입 시 전체 내용 대신 3줄(@import 형식)만 추가한다.
2. **install.sh**: `@.harness-kit/CLAUDE.fragment.md` 파일을 `.harness-kit/` 디렉토리에 생성한다.
3. **update.sh**: `CLAUDE.md`는 수정하지 않고 `.harness-kit/CLAUDE.fragment.md`만 교체한다.
4. **기존 설치 마이그레이션**: `update.sh`가 구 방식(블록 직접 삽입)을 감지하면 3줄 @import 방식으로 전환한다.
5. **fragment 내용**: 현재 `sources/claude-fragments/CLAUDE.md.fragment`의 내용을 유지(핵심 규칙 요약 포함).
6. **fragment 경로 업데이트**: `sources/claude-fragments/CLAUDE.md.fragment` → `sources/claude-fragments/CLAUDE.fragment.md` 으로 파일명 정리 (설치 대상: `.harness-kit/CLAUDE.fragment.md`).

### Non-Functional Requirements

1. **기존 CLAUDE.md 내용 보존**: 설치/업데이트 시 사용자가 작성한 `CLAUDE.md` 내용을 절대 삭제하지 않는다.
2. **멱등성**: `install.sh`를 두 번 실행해도 `@import` 줄이 중복 삽입되지 않는다.
3. **test-two-tier-loading.sh 유지**: 기존 검증 테스트가 새 구조에서도 통과해야 한다.

## 🚫 Out of Scope

- Claude Code가 실제로 `@import`를 파싱하는 방식 변경 (Claude Code 내부 동작, 키트 범위 밖)
- `CLAUDE.md` 내 사용자 내용 자동 정리 또는 재구성
- fragment 내용의 동적 생성 (kitVersion, projectName 등 변수 치환)

## ✅ Definition of Done

- [ ] `install.sh`: HARNESS-KIT 블록에 3줄 @import만 삽입
- [ ] `.harness-kit/CLAUDE.fragment.md` 생성 (install 시)
- [ ] `update.sh`: fragment 파일만 교체, CLAUDE.md 본문 불변
- [ ] `update.sh`: 구 방식(블록 직접 삽입) → @import 마이그레이션 로직
- [ ] `test-install-claude-import.sh` 통과
- [ ] `test-two-tier-loading.sh` 통과
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-9-002-claude-md-import` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
