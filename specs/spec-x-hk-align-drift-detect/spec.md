# spec-x-hk-align-drift-detect: hk-align 에 multi-device drift 자동 감지 추가

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-hk-align-drift-detect` |
| **Phase** | (없음 — Solo Spec) |
| **Branch** | `spec-x-hk-align-drift-detect` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-30 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- `hk-align` 의 bootstrap §2 (Context Check) 는 `bash .harness-kit/bin/sdd status` 를 단일 호출하고 그 출력만으로 상태 보고를 한다.
- `sdd status` 는 **로컬 파일** (`backlog/queue.md`, `backlog/phase-N.md`, `specs/`, `.claude/state/current.json`) 만 읽는다. **원격 동기 상태 / 워킹트리 잔재 / install 부산물** 은 보지 않는다.

### 문제점

지난 세션에서 다음 꼬임이 발생했다 (2026-04-30 회상):

1. **원격 behind**: 다른 device 에서 PR #91 머지 후, 이쪽 로컬 main 이 1 commit 뒤. `sdd status` 는 이를 모름 → 사용자가 "정리 됐을 것" 이라고 인지하지만 status 는 stale 정보 보고.
2. **워킹트리 잔재**: 다른 device 에서 만들던 spec-15-01 의 *이전* 초안이 staged + untracked 상태로 남음 → status 는 이를 active spec 으로 오판.
3. **repo state 불일치**: PR #91 이 phase-level 통합 PR 인데 `sdd phase done` 후처리 누락 → `phase-15.md` 는 모든 spec Merged 인데 `queue.md` 의 active 섹션이 phase-15 를 가리킴 (정합성 깨짐).
4. **install 부산물**: `.harness-kit/agent/templates/phase-ship.md` 가 다른 동료 템플릿들과 달리 untracked 단독.

위 4 가지 모두 **multi-device 환경에서 자연스럽게 발생** 하지만 현재 hk-align 으로는 자동 감지가 안 되어 사용자가 "stale state" 에 기반해 잘못된 결정을 내릴 위험.

### 해결 방안 (요약)

`sdd status` 출력에 **🔄 동기화 상태** (drift) 섹션을 추가하여 위 4 가지를 자동 감지·보고한다. hk-align 자체는 변경 최소 — 상태 요약 보고 형식에 동기화 섹션을 포함하도록만 수정. 실제 정리 동작은 수행하지 않고 **감지 + 제안** 만 한다 (사용자가 직접 `git pull` / `sdd phase done` 등을 호출).

## 📊 개념도

```
[현행]
hk-align → sdd status → 로컬 파일만 읽음 → 보고
                          ↑
                  multi-device drift 보이지 않음

[변경 후]
hk-align → sdd status → 로컬 파일 + 원격 ref + 워킹트리 + 정합성 검사
                              ↓
                   🔄 동기화 상태 섹션 추가 → 보고 → 사용자 정리 결정
```

## 🎯 요구사항

### Functional Requirements

1. **원격 동기 상태 감지**: `git fetch origin --quiet` 후 현재 브랜치 (또는 main) 가 원격 대비 behind/ahead 카운트를 보고. 오프라인 시 silent fallback (마지막 fetch 결과로).
2. **워킹트리 drift 분류**: `git status --porcelain` 결과를 분류:
   - `specs/` 안의 미커밋 디렉토리 → "다른 device 작업 잔재 의심" 으로 표시
   - `.harness-kit/` 또는 `.claude/` 안의 untracked → "install 부산물 의심" 으로 표시
   - 그 외 미커밋 → "일반 미커밋" 으로 카운트
3. **repo state 정합성 검사**: `queue.md` active 섹션의 phase 가 `phase-{N}.md` 의 spec 표를 봤을 때 모두 Merged 면 → "phase done 미실행 의심" 표시.
4. **install 부산물 감지**: `.harness-kit/agent/templates/`, `.harness-kit/hooks/`, `.claude/commands/` 안의 untracked 파일을 `sources/` 와 비교해 동일하면 "install 결과로 추정 — keep 안전" 으로, 다르면 "정체불명" 으로 분류.
5. **drift 보고 형식**: status 출력에 다음 섹션 추가:
   ```
   🔄 동기화 상태
     원격: behind 1 / ahead 0  (origin/main)
     워킹트리: 2 변경 (1 spec drift / 0 install drift / 1 일반)
     정합성: phase-15 의 모든 spec Merged 인데 active — sdd phase done 미실행 의심
     install 부산물: 1 (sources 와 동일 — keep 안전)
   ```
6. **drift 가 없을 때**: "🔄 동기화 상태: 깔끔" 한 줄로 끝낸다.
7. **--no-drift 옵션**: `sdd status --no-drift` 또는 `--brief` 시 drift 섹션 생략 (성능/오프라인 환경 고려).

### Non-Functional Requirements

1. **bash 3.2+ 호환**: 모든 신규 함수는 bash 3.2 호환 (declare -A, mapfile, ** globstar, ${var,,} 사용 금지 — CLAUDE.md §3).
2. **오프라인 robust**: `git fetch` 실패 시 stderr 무시하고 마지막 fetch 결과 사용 (또는 "원격 확인 안 됨" 표시).
3. **성능**: drift 검사 추가로 status 가 5 초 이상 지연되지 않아야 한다 (`git fetch` 가 dominant — 일반적으로 1-2 초).
4. **단일 명령 원칙 유지**: hk-align 은 여전히 `sdd status` 만 호출 (drift 호출을 별도 명령으로 빼지 않음 — agent.md §6.4).
5. **자동 정리 금지**: 감지·제안만. `git pull`, `git reset`, `sdd phase done`, `rm` 등 어느 것도 자동 실행 금지.

## 🚫 Out of Scope

- **자동 정리 동작**: pull, reset, clean 등 — 본 spec 은 감지 전용. 자동 정리는 별도 spec 에서 사용자 동의 모델과 함께 설계.
- **`hk-phase-ship` 의 `sdd phase done` 자동 호출**: 별도 spec-x 후보로 분리.
- **state.json (`current.json`) 의 git 추적**: 본 spec 은 정합성 검사 로직 안에서만 다룸.
- **GitHub API 조회**: `gh pr list` 등 호출 안 함. 순수 git 만 사용.
- **새 슬래시 커맨드 추가**: hk-align 의 행동만 풍부하게 함. 신규 `/hk-sync` 등은 만들지 않음.

## ✅ Definition of Done

- [ ] `sdd status` 출력에 🔄 동기화 상태 섹션 추가 (drift 있으면 상세, 없으면 한 줄)
- [ ] `--no-drift` 옵션 동작 (drift 섹션 생략)
- [ ] bash 3.2 호환 단위 테스트 통과 (`tests/test-sdd-drift.sh`)
- [ ] hk-align 슬래시 커맨드의 §2 / §5 (보고 형식) 갱신
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-hk-align-drift-detect` 브랜치 push 완료
- [ ] PR 생성 및 사용자 검토 요청 알림 완료
