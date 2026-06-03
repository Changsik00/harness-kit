# spec-x-doctor-hookspath-lefthook: doctor 의 lefthook × core.hooksPath 충돌 탐지

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-doctor-hookspath-lefthook` |
| **Phase** | 없음 (spec-x, 독립) |
| **Branch** | `spec-x-doctor-hookspath-lefthook` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-30 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

GitHub Issue #161: lefthook(`prepare: lefthook install`) + turbo 레포에서 `pnpm install` 이 전면 실패한다. lefthook v2.x 는 `core.hooksPath` 가 명시 설정돼 있으면 `lefthook install` 을 거부하고, 그 실패가 turbo 의 deps-status 체크까지 연쇄로 막는다.

### 문제점

소스 전수 검증 결과(`grep -rn 'core.hooksPath'` → 0건), **harness-kit 는 `core.hooksPath` 를 설정하지 않는다**. 즉 이 충돌은 harness 가 유발한 것도, harness 가 직접 고칠 수 있는 것도 아니다 (사용자가 `git config --unset --local core.hooksPath` 해야 해소). harness 가 `.git/hooks/pre-commit` 에 블록을 append 하는 방식(`install.sh:305-333`)은 기본 hooksPath 환경에서 정상 동작한다.

그러나 사용자 입장에서는 **turbo 의 모호한 `Command failed: pnpm install` 만 보여** 원인을 찾기 어렵다. harness 가 이 footgun 을 **조기에 감지해 1줄 진단 + 정확한 수정 명령**을 제시하면 디버깅 비용이 크게 줄어든다.

### 해결 방안 (요약)

target 프로젝트가 쓰는 `sdd doctor`(`cmd_doctor`) 와 update 시 실행되는 루트 `doctor.sh` 의 훅 점검 섹션에, "lefthook 사용 + `core.hooksPath` 로컬 설정" 조합을 감지하면 충돌 경고 + `git config --unset --local core.hooksPath` 가이드를 출력하는 비차단(warn) 체크를 추가한다.

## 🎯 요구사항

### Functional Requirements

1. **충돌 감지**: 대상 repo 에서 ① lefthook 사용(`lefthook.yml`/`.lefthook.yml`/`*.yaml` 또는 `package.json` 의 lefthook 참조) **AND** ② `git config --local --get core.hooksPath` 비어있지 않음 → warn 출력.
2. **가이드 포함**: 경고에 원인 요약 + `git config --unset --local core.hooksPath` 수정 명령 + issue #161 참조를 포함한다.
3. **양쪽 doctor 일관**: `sdd doctor`(`sources/bin/sdd cmd_doctor`) 와 루트 `doctor.sh` §6 양쪽에 동일 감지를 추가한다.
4. **정상 케이스**: lefthook 사용 + hooksPath 미설정 → pass(정상). lefthook 미사용 → 무출력(범위 외).

### Non-Functional Requirements

1. bash 3.2+ 호환, BSD 도구 호환. git 저장소 아니면 안전 탈출.
2. 비차단 — doctor 종료 코드에 영향 없음(warn 카운트만 증가). harness 가 사용자 git 설정을 자동 변경하지 않음.

## 🚫 Out of Scope

- harness 가 `core.hooksPath` 를 자동 unset/force 하는 것 (사용자 git 설정 침습 — issue 제안 #3 회피).
- lefthook 네이티브 hook 통합(`lefthook.yml` 등록) — issue 제안 #2. **Icebox 로 보류** (범위 큼, bash YAML 편집 비용). 본 spec 에서 한 줄 캡처만 수행.
- `core.hooksPath` 가 비-기본 경로라 harness hook 이 아예 실행되지 않는 별개 footgun (별도 검토).

## 📑 ADR 후보

- [ ] 있음
- [x] 없음 (국소 진단 추가)

## 🔗 관련 문서 (Related)

- GitHub Issue: #161
- 관련: `install.sh:305-333` (pre-commit append), [[spec-x-harness-footguns]] (install drift 감지 — 같은 "감지→행동" 결)

## ✅ Definition of Done

- [ ] 단위 테스트 PASS (충돌 감지 / 정상 / lefthook 미사용 케이스)
- [ ] `sdd doctor` + 루트 `doctor.sh` 양쪽 감지 동작
- [ ] Icebox 에 lefthook 네이티브 통합(#2) 한 줄 캡처
- [ ] `walkthrough.md` / `pr_description.md` ship + push + PR
- [ ] 사용자 검토 요청 알림 완료
