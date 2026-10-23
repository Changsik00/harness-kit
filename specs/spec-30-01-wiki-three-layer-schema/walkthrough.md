# Walkthrough: spec-30-01

> 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| ADR `supersedes`/`superseded_by` 도입 | 30-01 에 포함 / 제외 | **제외** (열린 질문으로 이월) | ADR 템플릿·doctor ADR 검사 코드까지 건드려 문서 spec 성격을 벗어남. 번복은 우선 `threads.md` + 변경 이력으로 추적 |
| 검증 가능 주장 표기 | 30-01 에서 문법 확정 / 30-02 로 미룸 | **마커 문법·위치만 30-01 에서 확정** (`<!-- verify: <키> -->` 를 표 바로 위 줄) | 30-02 의 lint 가 대상을 찾으려면 표기가 먼저 있어야 함. 키별 검증 방법은 30-02 |
| 인제스트 행동의 테스트 | 결정론 테스트 시도 / 정적 계약 + 수동 | **정적 계약 테스트(문구·섹션·마커·크기) + 실사용 검증 이월** | 인제스트는 LLM 절차라 행동을 결정론적으로 고정할 수 없음. 계약 테스트는 *문구가 있는지*만 보장함을 명시 |
| 크기 상한 강제 | doctor 경고 / 테스트만 | **테스트만** (components 200 / direction 150 / threads 300줄) | doctor 경고화는 30-02 범위 |
| `test-wiki-structure.sh` Check 7 | 유지 / 갱신 | **갱신** (`wiki/decisions.md` → `direction.md` 참조 확인) | 구 조회 규칙에 묶인 단언. 규칙이 바뀌었으므로 단언도 새 규칙을 따라야 함 |
| 계획 외 `doctor.sh` 1줄 | 중단 후 재정렬 / 보정 | **보정 후 spec Proposed Changes 에 사후 기재** | 템플릿 추가 시 `test-doctor-templates`(#204)가 `doctor.sh` 필수 템플릿 목록과의 일치를 강제 — 템플릿 추가의 필연적 결과, 1줄, 가역적 |

<!-- ADR 승격: 후보 `wiki-update-in-place-with-history` (type: convention). 사용자 결정 대기 -->

## 💬 사용자 협의

- **주제**: wiki 3층 구조 spec 시작과 Plan Accept
  - **합의**: §11.3 재검증 후 조정 2건(마커 규약 30-01 포함, ADR supersedes 제외)을 반영해 진행. Plan Accept(1).
- **주제**: append-only 폐지, 충돌 시 사용자 확인 (2026-10-22 설계 합의)
  - **합의**: 이력 보존 의무로 대체, 충돌은 임의 덮어쓰기 금지

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-wiki-schema-v2.sh`, 전체 `bash tests/run.sh`
- **결과**: ✅ Passed — 전체 PASS 88 / FAIL 0
```text
✓ wiki schema v2 PASS   (Case 1 템플릿 / 2 schema 문구 / 3 ingest 계약 / 4 시범 페이지 / 5 verify 마커 / 6 격하 배너 / 7 fragment 조회 순서)
PASS: 88  FAIL: 0  SKIP: 0
```

### 수동 검증
1. **Action**: `sdd doctor` wiki layer 확인
   - **Result**: 고아 링크 없음, wiki 최신. 잔존 WARN 3건(stale 문서 11, governance 7902w, 완료 phase 2개 잔존)은 본 spec 이전부터 있던 것.
2. **Action**: 새 규약으로 `/hk-wiki-ingest` 실사용 (수동 시나리오 1)
   - **Result**: **미수행 — 이월.** phase-28·29 archive 후 phase 종료 시점 인제스트에서 (a) 영향 컴포넌트만 갱신 (b) 매핑 불가 시 질문 (c) 이력 보존 (d) 충돌 확인을 확인하고 phase-30 walkthrough 에 기록한다. 따라서 성공 기준 4(행동 검증)는 현재 *정적 계약까지만* 충족.

## 🔍 발견 사항

- 템플릿을 추가하면 `doctor.sh` 의 필수 템플릿 목록도 갱신해야 한다 (`test-doctor-templates` 가 강제). 템플릿 추가 시 체크리스트 후보.
- `CLAUDE.fragment.md` 는 150단어 상한(`test-two-tier-loading`)이 있어 조회 규칙 문구를 늘리기 어렵다. 첫 안(160w)은 상한 초과 → 148w 로 압축. 규칙이 더 늘면 fragment 가 아니라 schema 로 내려야 함.
- `.harness-kit/CLAUDE.fragment.md` 는 원본 fragment 와 serena 확장 블록만큼 달라(`hk-extend` 마커) `cp` 로 동기화하면 안 된다. 같은 줄을 각각 편집했다.
- 격하된 `decisions.md`/`patterns.md` 는 아직 `kind: synthesis` 이고 `index.md` 에서도 같은 종류로 표시된다 — 별도 kind 를 두지 않은 것은 ADR-003 네임스페이스를 건드리지 않기 위함. 필요하면 spec-30-03 에서 재검토.

## 🚧 이월 항목

- 새 규약으로 인제스트 실사용 검증 → phase-30 종료 시점 (phase-28·29 archive 후)
- ADR `supersedes`/`superseded_by` 필요성 → spec-30-03 에서 판단
- `threads.md` 실제 작성, 남은 컴포넌트 페이지 → spec-30-03
- `verify` 키별 검증기, 크기 상한 doctor 경고 → spec-30-02
