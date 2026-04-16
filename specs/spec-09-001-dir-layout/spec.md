# spec-09-001: 디렉토리 레이아웃 마이그레이션 — .harness-kit/ 은닉 구조 전환

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-09-001` |
| **Phase** | `phase-09` |
| **Branch** | `spec-09-001-dir-layout` |
| **Base Branch PR Target** | `phase-09-install-conflict-defense` (hk-ship 시 자동 생성) |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-14 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`는 대상 프로젝트에 다음 디렉토리를 생성한다:
- `agent/` — 거버넌스 문서 + 템플릿
- `scripts/harness/bin/` — sdd 메타 명령
- `scripts/harness/hooks/` — hook 스크립트
- `scripts/harness/lib/` — 헬퍼 라이브러리

`settings.json` fragment의 hook 경로도 `scripts/harness/hooks/*.sh`로 고정되어 있다.

### 문제점

1. **`agent/` 이름 충돌**: LangChain, LangGraph, 자체 AI 에이전트 코드 등이 이미 `agent/` 디렉토리를 사용하는 프로젝트가 많다. harness-kit 설치 시 기존 `agent/` 내용을 덮어쓰거나 git 충돌을 유발한다.
2. **`scripts/` 네임스페이스 오염**: 거의 모든 프로젝트가 `scripts/`를 사용한다. `scripts/harness/`라는 서브디렉토리를 쓰지만 여전히 프로젝트 `scripts/` 영역에 침입한다.
3. **가시성 vs. 격리**: harness-kit의 파일들은 프로젝트 산출물이 아닌 *도구*이므로 숨김 디렉토리(`.harness-kit/`)에 격리하는 것이 적절하다.
4. **참조 불일치 위험**: governance 문서, slash commands, doctor.sh 등이 하드코딩된 경로(`scripts/harness/bin/sdd`, `agent/constitution.md`)를 참조하고 있어, 경로 변경 시 일부가 누락되면 silently 오동작한다.

### 해결 방안 (요약)

harness-kit이 설치하는 모든 *도구* 파일을 `.harness-kit/` 숨김 디렉토리 아래로 이동한다. `install.sh`, `update.sh`, `uninstall.sh`, `doctor.sh`, `sources/bin/sdd`, `sources/governance/`, `sources/commands/`, `sources/claude-fragments/settings.json.fragment`의 경로 참조를 전면 교체한다. `update.sh`에는 v0.3 이하 old-layout 감지 및 자동 마이그레이션 로직을 추가한다. harness-kit 자신(dogfooding)도 동일한 새 레이아웃으로 마이그레이션한다.

## 📊 레이아웃 변경 개요

```
Before (v0.3)                    After (v0.4)
─────────────────────────────    ────────────────────────────────
agent/                       →   .harness-kit/agent/
  constitution.md                  constitution.md
  agent.md                         agent.md
  align.md                         align.md
  templates/                       templates/

scripts/harness/             →   .harness-kit/
  bin/sdd                          bin/sdd
  bin/bb-pr                        bin/bb-pr
  bin/lib/                         bin/lib/
  hooks/                           hooks/
  lib/ (있는 경우)                  lib/

                              추가:
                                 .harness-kit/installed.json
```

`backlog/`, `specs/`는 이 스펙에서 변경하지 않는다 (spec-09-003 scope).

## 🎯 요구사항

### Functional Requirements

1. `install.sh` 실행 후 대상 프로젝트 루트에 `agent/`, `scripts/harness/` 디렉토리가 생성되지 않는다.
2. `install.sh` 실행 후 `.harness-kit/agent/`, `.harness-kit/bin/`, `.harness-kit/hooks/` 가 생성된다.
3. `install.sh`가 `.harness-kit/installed.json`을 생성한다 (kitVersion, installedAt 포함).
4. `install.sh`의 `.gitignore` 처리가 `!.harness-kit/` un-ignore를 추가한다 (숨김 디렉토리 미추적 방지).
5. `settings.json` fragment의 hook 경로가 `.harness-kit/hooks/*.sh`를 참조한다.
6. `sources/governance/` 문서 내 모든 `scripts/harness/bin/sdd` 참조가 `.harness-kit/bin/sdd`로, `agent/` 참조가 `.harness-kit/agent/`로 교체된다.
7. `sources/commands/` 슬래시 커맨드 내 경로 참조가 동일하게 교체된다.
8. `update.sh` 실행 시 v0.3 old-layout(`agent/` 존재 + `.harness-kit/` 부재) 감지 후 자동 마이그레이션한다.
9. `uninstall.sh`가 `.harness-kit/`를 제거 대상으로 처리한다.
10. `doctor.sh`가 `.harness-kit/` 기반으로 경로를 점검한다.
11. harness-kit 프로젝트 자체(dogfooding)가 신규 레이아웃(`agent/` → `.harness-kit/agent/`, `scripts/harness/` → `.harness-kit/`)으로 마이그레이션된다.
12. `VERSION`이 `0.4.0`으로 갱신된다.

### Non-Functional Requirements

1. **backward compatibility**: v0.3 프로젝트에서 `update.sh`를 실행하면 사용자 데이터(`backlog/`, `specs/`) 손실 없이 마이그레이션 완료.
2. **안전망**: 마이그레이션 전 `.harness-backup-{TS}/` 백업 자동 생성.
3. **테스트 가능성**: 기존 `tests/` 스크립트가 신규 레이아웃 기준으로 계속 동작.
4. **sdd 경로 변경 후 즉시 동작**: dogfooding 마이그레이션 후 `.harness-kit/bin/sdd status` 호출 가능.

## 🚫 Out of Scope

- CLAUDE.md @import 방식 전환 (spec-09-002)
- `backlog/`, `specs/` 경로 충돌 감지 및 config 시스템 (spec-09-003)
- install/update.sh preflight 문의 UX (spec-09-004)
- `.gitattributes` linguist-vendored 설정
- atomic install (`.harness-kit-installing/` 패턴)

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`bash tests/test-install-layout.sh`)
- [ ] 통합 테스트: `install.sh --yes <tmpdir>` 실행 후 `.harness-kit/` 생성 확인, `agent/` 미생성 확인
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-09-001-dir-layout` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
