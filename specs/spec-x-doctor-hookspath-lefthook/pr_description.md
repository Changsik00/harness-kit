fix(spec-x-doctor-hookspath-lefthook): doctor 의 lefthook × core.hooksPath 충돌 탐지

References #161

## 📋 Summary

### 배경 및 목적

Issue #161: lefthook(`prepare: lefthook install`) + turbo 레포에서 `pnpm install` 이 전면 실패. lefthook v2.x 는 `core.hooksPath` 가 명시 설정돼 있으면 `lefthook install` 을 거부하고, 그 실패가 turbo deps-status 체크까지 연쇄로 막는다.

소스 전수 검증 결과 **harness 는 `core.hooksPath` 를 설정하지 않으며**(리포트 추정 정정 — 이슈에 코멘트), 이 실패는 사용자가 `git config --unset --local core.hooksPath` 해야만 풀린다. harness 가 할 수 있는 최선은 **모호한 turbo 실패를 조기 1줄 진단으로 전환**하는 것 — 이 PR 이 그 doctor 감지를 추가한다.

### 주요 변경 사항

- [x] `sdd doctor`(`cmd_doctor`) 에 lefthook × core.hooksPath 충돌 감지 + `git config --unset --local core.hooksPath` 가이드
- [x] 루트 `doctor.sh` §6 에 동일 감지 (update 시 실행 경로 커버)
- [x] 비차단(warn) — 사용자 git 설정을 harness 가 자동 변경하지 않음
- [x] lefthook 네이티브 hook 통합(#2)은 Icebox 캡처 (범위 큼, 보류)

### 부분 대응 명시
본 PR 은 #161 의 **진단** 부분만 해소한다. fragility 근본 해소(`.git/hooks` append → lefthook.yml 등록, 제안 #2)는 Icebox 보류라 `Closes` 가 아닌 `References #161`.

## 🎯 Key Review Points

1. **감지 조건** (`sources/bin/sdd` `_check_lefthook_hookspath`, `doctor.sh` §6): `lefthook 사용(yml/yaml/package.json) AND core.hooksPath 로컬 설정` 일 때만 warn. lefthook 미사용 시 무출력(소음 방지).
2. **비침습**: harness 가 `core.hooksPath` 를 unset/force 하지 않음 — 진단·안내만 (issue 제안 #3 의도적 배제).
3. **양쪽 doctor 일관성**: sdd doctor 와 루트 doctor.sh 동일 로직.

## 🧪 Verification

```bash
bash tests/test-doctor-hookspath-lefthook.sh   # 4/4 (신규)
bash tests/test-hk-doctor.sh                   # 7/7 (회귀)
bash tests/test-doctor-wiki.sh                 # 회귀
```

**결과**: ✅ 전 스위트 PASS

### 수동 검증
1. lefthook.yml + `core.hooksPath` 설정 repo → `sdd doctor` → 충돌 warn + unset 가이드
2. unset 후 → `✓ core.hooksPath 미설정 (정상)`

## 📦 Files Changed

### 🆕 New Files
- `tests/test-doctor-hookspath-lefthook.sh`: 충돌 감지 4 케이스 단위 테스트

### 🛠 Modified Files
- `sources/bin/sdd` / `.harness-kit/bin/sdd`: `cmd_doctor` 에 `_check_lefthook_hookspath`
- `doctor.sh`: §6 동일 감지
- `backlog/queue.md`: Icebox 에 lefthook 네이티브 통합(#2) 캡처

**Total**: 5 files changed

## ✅ Definition of Done

- [x] 단위 테스트 PASS (감지 / 정상 / 범위외)
- [x] sdd doctor + 루트 doctor.sh 양쪽 동작
- [x] Icebox 캡처
- [x] `walkthrough.md` / `pr_description.md` ship
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- GitHub Issue: #161 (+ 정정 코멘트)
- Walkthrough: `specs/spec-x-doctor-hookspath-lefthook/walkthrough.md`
