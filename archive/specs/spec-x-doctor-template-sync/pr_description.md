fix(spec-x-doctor-template-sync): doctor.sh 템플릿 목록 동기화 — plan.md 오탐 제거

Closes #204

## 📋 Summary

### 배경 및 목적
install.sh / update 말미 루트 `doctor.sh` 점검 `[3/7]` 에서 폐기된 `plan.md` 를 필수 템플릿으로 체크 → `✗ plan.md 없음` FAIL 1건 → "진단 실패" 종료. plan.md 는 flat 레이아웃에서 spec.md 에 통합돼 폐기됐고, 테스트·`sdd`·커맨드는 모두 이를 반영하나 **루트 doctor.sh 만 stale** 했다.

### 주요 변경 사항
- [x] `doctor.sh` 필수 템플릿 목록을 실제 `sources/templates/*.md` 와 **동기화** — `plan.md` 제거(유령) + `phase-ship.md` 추가(누락)
- [x] **회귀 테스트** `tests/test-doctor-templates.sh` — 목록 == 실제 템플릿 invariant 고정(재드리프트 봉인)

## 🎯 Key Review Points

1. **양방향 drift**: 이슈는 plan.md 만 보고했으나 같은 원인의 반대 증상(phase-ship.md 누락)도 함께 정리. 근본 원인 = "doctor.sh 목록 ≠ 실제 템플릿".
2. **재발 방지**: 1줄 수정이 아니라 `목록 == sources/templates/*.md` 를 테스트로 박아 봉인.

## 🧪 Verification
```bash
bash tests/test-doctor-templates.sh   # 3/3
bash doctor.sh                        # [3/7] FAIL 0 (plan.md 오탐 사라짐)
bash tests/run.sh                     # 76/76 (FAIL 0)
```

## 📦 Files Changed
- `doctor.sh`: 템플릿 목록 동기화 (plan.md 제거, phase-ship.md 추가)
- `tests/test-doctor-templates.sh`: 신규 — 목록 정합 회귀 테스트

## ✅ Definition of Done
- [x] doctor.sh plan.md 미체크 + phase-ship.md 체크
- [x] 회귀 테스트 PASS (목록 == 실제 템플릿)
- [x] `bash doctor.sh` FAIL 0
- [x] 전체 회귀 76/76
- [x] walkthrough / pr_description ship + push + PR

## 🔗 관련 자료
- GitHub #204
