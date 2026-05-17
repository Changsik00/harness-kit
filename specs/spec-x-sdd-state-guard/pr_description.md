# fix(spec-x-sdd-state-guard): sdd state 단일평면 footgun 단기 가드

## 📋 Summary

### 배경 및 목적

`sdd` 의 `state.json` 은 단일 평면 namespace 입니다. `spec` 필드 하나가 SDD-P spec 과 spec-x 를 *구분 없이* 담고, 어떤 컨텍스트인지는 `phase` 가 null 인지로 *유추* 해야 하는 암묵적 invariant 가 있습니다.

각 destructive 명령은 이 invariant 를 *호출자가 챙기는* 전제로 구현되어 있었고, 그 결과 활성 spec 보호 가드가 누락된 진입점이 3 군데 존재했습니다:

| 함수 | 라인 | 증상 |
|---|---|---|
| `phase_activate` | sdd:905-923 | `cur_phase` 충돌만 검사. 활성 spec 인지 X → `spec=null` 무조건 reset |
| `phase_new` | sdd:860-862 | 동일 패턴 |
| `spec_new` | sdd:1251-1252 | 활성 spec(spec-x 포함) 있어도 새 spec 으로 덮어씀 |

직전 운영 세션에서 spec-x 진행 중 `sdd phase activate phase-01` 호출 → 활성 spec-x 의 state 가 silent reset → hook 차단 우려 발생. 본 spec 은 이 footgun 의 단기 가드입니다.

### 주요 변경 사항

- [x] `state.sh` 에 `die_if_active_spec <action>` helper 신설
- [x] `phase_activate` / `phase_new` / `spec_new` 세 진입점에 가드 호출 추가
- [x] `--force` 플래그 신설 (`phase_new` 는 기존 플래그 의미 확장)
- [x] spec-x / SDD-P spec 별 해결 명령 분기 안내 (`sdd specx done <slug>` vs `sdd ship`)
- [x] 신설 테스트 `tests/test-sdd-state-guard.sh` 7 check
- [x] `sources/bin/` 과 `.harness-kit/bin/` 양쪽 동기화 (도그푸딩)

### Phase 컨텍스트

- **Phase**: 없음 (SDD-x)
- **본 SPEC 의 역할**: 운영 footgun 의 단기 가드. 근본 해결인 *state 공간 분할* 은 ADR 후보 (`state-namespace-split`) 로 별도 작업.

## 🎯 Key Review Points

1. **helper 위치 — `state.sh`**: state 검사 책임을 state.sh 에 응집. 호출자는 한 줄로 invoke. helper 가 호출자별 옵션 규약을 알 필요 없도록 `--force` 파싱은 호출자가 담당.
2. **메시지 분기**: `case "$active" in spec-x-*) ... esac` 으로 spec-x 와 SDD-P spec 에 다른 해결 명령 안내. 잘못된 명령 안내는 footgun 가중이라 분기 필수.
3. **`phase_new --force` 의미 확장**: 기존엔 "사전 정의 phase 우회"만 의미. 본 spec 후엔 "사전 정의 phase + 활성 spec 모두 우회". 도그푸딩 단계라 호환성 이슈 없음.
4. **회귀 보존**: 활성 spec 없는 상태에서는 기존 동작 완전 동일. 기존 `test-sdd-phase-activate.sh` 9 check, `test-sdd-spec-new-seq.sh` 등 인접 회귀 5 카테고리 모두 PASS.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-sdd-state-guard.sh        # 신설
bash tests/test-sdd-phase-activate.sh     # 회귀
bash tests/test-sdd-spec-new-seq.sh       # 회귀
bash tests/test-sdd-phase-done-accuracy.sh
bash tests/test-sdd-spec-completeness.sh
bash tests/test-sdd-ship-completion.sh
```

**결과 요약**:
- ✅ `test-sdd-state-guard.sh`: 13/13 (Check 1-7 전부)
- ✅ `test-sdd-phase-activate.sh`: 13/13 (회귀)
- ✅ `test-sdd-spec-new-seq.sh`: 5/5 (회귀)
- ✅ `test-sdd-phase-done-accuracy.sh`: 4/4 (회귀)
- ✅ `test-sdd-spec-completeness.sh`: 4/4 (회귀)
- ✅ `test-sdd-ship-completion.sh`: 9/9 (회귀)

### 수동 검증 시나리오

1. **활성 spec-x 상태 + `sdd phase activate phase-01`** → die + `sdd specx done <slug>` 안내 + state 보존 ✓
2. **활성 spec-x 상태 + `sdd phase activate phase-01 --force`** → 통과 + state 덮어쓰기 ✓
3. **활성 SDD-P spec 상태 + `sdd spec new <slug>`** → die + `sdd ship` 안내 + state 보존 ✓
4. **활성 spec 없는 상태 + 모든 명령** → 기존 동작 정상 (회귀 OK) ✓

## 📦 Files Changed

### 🆕 New Files

- `tests/test-sdd-state-guard.sh`: 신설 가드 7 check
- `specs/spec-x-sdd-state-guard/{spec,plan,task,walkthrough,pr_description}.md`

### 🛠 Modified Files

- `sources/bin/lib/state.sh` (+25): `die_if_active_spec` helper 추가
- `.harness-kit/bin/lib/state.sh` (+25): 도그푸딩 동기화
- `sources/bin/sdd` (+30, -7): 3 진입점 가드 호출 + `--force` 플래그 + help 갱신
- `.harness-kit/bin/sdd` (+30, -7): 도그푸딩 동기화

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (13/13 신설 + 35/35 회귀)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-sdd-state-guard/walkthrough.md`
- 이월 ADR 후보: `state-namespace-split` (type: decision) — 본 spec 머지 후 별도 작업
- 발견 경위: 직전 세션 (다른 컨텍스트) 의 `sdd phase activate phase-01` footgun 보고
