# docs(spec-15-01): upgrade-danger-audit — 4건 버그 패턴 분석 + P0 잠재 버그 발견 + 후속 spec 4개 명세

## 📋 Summary

### 배경 및 목적

최근 머지된 4건 spec-x (#82~84 + spec-14-03 gitignore) 가 모두 **"기존 사용자가 update 했을 때 무언가 깨짐"** 패턴이었다. 사용자 지적: "위험지역으로 판단되고 있고 이 부분에 대해서 심층 분석이 필요". 본 audit 은 phase-15 (upgrade-safety) 의 첫 spec — 코드 수정 0, 산출물은 분석 보고서.

### 주요 변경 사항

- [x] §4 4건 버그를 **3개 공통 패턴** 으로 압축: Schema Drift / User Content Blindness / Insufficient Idempotency
- [x] §5 install.sh / update.sh / uninstall.sh **12개 처리 단위 정책 분류표** + 위험 등급 (P0~P2)
- [x] **🚨 P0 잠재 버그 1건 발견**: `uninstall.sh:92` 의 KIT_COMMANDS 가 구 슬래시 커맨드 명단 → hk-* 영구 잔재 위험
- [x] §6 stateful fixture 시스템 **3 옵션 × 10 기준 trade-off 비교** + 권고 (옵션 A: 함수 합성)
- [x] §7 후속 spec 4개 (15-02 fixture / 15-03 회귀 테스트 / 15-04 P0 fix / 15-05 P1) 명세 초안 + **Go/No-Go: GO**
- [x] phase-15.md 갱신 — spec 표 / 위험 섹션 / 4 spec 요점

### Phase 컨텍스트

- **Phase**: `phase-15` (upgrade-safety — 기존 사용자 update 경로 안전성)
- **본 SPEC 의 역할**: phase 의 첫 spec 으로서 후속 spec 들의 윤곽 + 우선순위 결정. 코드 수정 0 (Research §9).

## 🎯 Key Review Points

1. **3개 패턴 추출 (§4.2)** — 4건 버그가 단일 패턴인지 / 정말 세 개로 나뉘는지 검증. 각 패턴이 fixture 시나리오와 1:1 매핑됨을 확인.
2. **P0 발견 (§5.3.1)** — uninstall.sh:92 의 stale 명단을 직접 코드에서 확인. install 측 (디렉토리 glob) 과 uninstall 측 (hardcoded) 의 비대칭이 근본 원인.
3. **fixture 옵션 권고 (§6.5)** — A(함수 합성) 권고 근거: YAGNI + 기존 패턴 통합 + bash 3.2 호환. 50+ 시나리오에서 B 로 마이그레이션 임계점 명시.
4. **후속 spec 분할 (§7.4)** — P0(15-04) / P1(15-05~06) / P2(15-07+, Icebox) 분류. P0 즉시 픽스, P1 본 phase 안에서, P2 후속 phase / Icebox.

## 🧪 Verification

본 spec 은 Research — 코드 수정 0. 검증은 회귀 스위트 + 산출물 자체 검토.

```bash
bash tests/test-version-bump.sh   # 전체 스위트 자동 실행
```

**결과**: ✅ 6/6 PASS + 전체 스위트 FAIL=0.

### 산출물 자체 검토 (DoD)
- ✅ §4~§7 모두 채워짐
- ✅ Trade-off Analysis ≥ 2 안 (§6 의 3 옵션 비교)
- ✅ Go/No-Go 권고 (§7.1 GO)
- ✅ phase-15.md 갱신 (spec 표 + 위험 섹션)

### 분석 깊이
- 4건 버그 spec 디렉토리 + 머지 commit diff 정독
- install.sh / update.sh / uninstall.sh 라인 단위 정독
- 기존 fixture 패턴 정독

## 📦 Files Changed

### 🆕 New Files
- `specs/spec-15-01-upgrade-danger-audit/spec.md` (450+ 줄, 7 섹션)
- `specs/spec-15-01-upgrade-danger-audit/plan.md`
- `specs/spec-15-01-upgrade-danger-audit/task.md`
- `specs/spec-15-01-upgrade-danger-audit/walkthrough.md`
- `specs/spec-15-01-upgrade-danger-audit/pr_description.md`

### 🛠 Modified Files
- `backlog/phase-15.md` — spec 표 (15-04~07 추가) + 위험 섹션 (P0 명시)
- `backlog/queue.md` — sdd 가 spec 표 자동 갱신

### 코드 변경
- **없음** (Research Spec 원칙)

## ✅ Definition of Done

- [x] §4~§7 모두 작성
- [x] Trade-off Analysis ≥ 2 안
- [x] Go/No-Go 권고
- [x] phase-15.md 갱신
- [x] 회귀 스위트 PASS
- [x] walkthrough.md / pr_description.md 작성

## 🔗 관련 자료

- Phase: `backlog/phase-15.md`
- 본 spec 산출물: `specs/spec-15-01-upgrade-danger-audit/spec.md`
- Walkthrough: `specs/spec-15-01-upgrade-danger-audit/walkthrough.md`
- 후속 spec 후보: spec-15-02 (fixture 시스템) / 15-03 (회귀 테스트) / 15-04 (P0 fix) / 15-05~07 (P1/P2)
