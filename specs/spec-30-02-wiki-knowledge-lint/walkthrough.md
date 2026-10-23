# Walkthrough: spec-30-02

> 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| hook 선언 위치 | `sources/hooks/` 우선 + 설치본 폴백 / `.harness-kit/hooks/` 만 | **`.harness-kit/hooks/`** (`sdd hooks` 와 동일) | 다운스트림에도 있는 경로이고 `sdd hooks`(F4)가 이미 쓰는 소스. 원본↔사본 일치는 phase-28 drift 검사가 보증. spec 초안(원본 우선)에서 의도적으로 벗어남 |
| 마커 인식 범위 | 줄 어디서나 / 줄 맨 앞 + 코드 펜스 밖 | **줄 맨 앞, 코드 펜스 밖** | schema.md 가 마커 예시를 코드 블록·인라인 코드로 싣는다. 허용 범위가 넓으면 자기 문서를 오탐 |
| 표 파싱 | 열 위치 고정 / 헤더의 '기본' 열 탐색 | **헤더에서 '기본' 열을 찾음** | 컬럼 순서가 바뀌어도 동작. 헤더에 '기본' 이 없으면 대조하지 않음(조용한 통과 가능성 — 아래 발견 사항 참조) |
| 신선도 신호 A | 유지 / wiki 전체 검색 / 제거 | **운영 파일(index·log·schema) 제외 wiki 전체 검색**, 경고 문구 "wiki 낡음(보조)" | 30-01 로 인제스트가 로그를 편집하지 않아 기존 정의는 영구 오탐. 제거하면 미문서화 ADR 감지를 잃음 |
| 경로 존재 검사 범위 | 모든 문서 / `docs/wiki/` 페이지만 | **`docs/wiki/` 페이지의 `sources:`/`covers:` 만** | ADR/RCA backfill `sources:` 는 archive 이동에 취약한 별개 문제. 이번 범위 밖 |
| 의미 lint 오탐 | 자동 수정 / 보고서만 | **보고서만** | 의미 판단은 오판 가능 — 사용자가 보고 갱신(규약 2) |
| 신호 A 테스트 위치 | `test-wiki-verify` (spec 초안) / `test-wiki-freshness` | **`test-wiki-freshness` Case 7·8** | 신선도 로직의 테스트이므로 기존 파일에 두는 것이 응집도 높음 |

## 💬 사용자 협의

- **주제**: spec-30-02 시작 (§11.3 재검증 후 spec/task 제시)
  - **합의**: 신선도 신호 A 의 의미 변경(wiki 전체 검색) 포함하여 Plan Accept(1)

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-wiki-verify.sh`, `bash tests/test-wiki-freshness.sh`, 전체 `bash tests/run.sh`
- **결과**: ✅ Passed — 전체 PASS 89 / FAIL 0
```text
✓ wiki 사실 검증 PASS   (Case 1~10)
case 7·8: ADR mentioned only in components/ is reflected / index.md excluded, warning labelled (보조)
PASS: 89  FAIL: 0  SKIP: 0
```

### 수동 검증
1. **Action**: 본 저장소 `docs/wiki/components/hooks.md` 의 `check-branch` 기본 칸을 `block` → `warn` 으로 임시 변경 후 `sdd doctor`
   - **Result**: `wiki 사실 불일치 1건: ... check-branch 기본 '**warn**' ≠ 선언 'block'` 경고 확인. 원복 후 `wiki 사실 검증 OK`. (성공 기준 2 의 "의도적으로 틀린 fixture 감지 + 본 저장소 0건")
2. **Action**: `/hk-wiki-lint` 절차를 `direction.md`·`components/hooks.md` 에 직접 수행 (명령 자체를 별도 세션에서 실행한 것은 아님 — 작성자가 같은 절차를 손으로 따름)
   - **Result**: 의미 점검 지적 3종 (아래 발견 사항). 이 중 1건(수치 낡음)은 즉시 수정(`docs(spec-30-02): refresh stale counts`).

## 🔍 발견 사항

- **첫 실측이 실제 낡음을 잡았다**: `decisions.md`/`patterns.md` frontmatter `sources:` 3건이 `specs/…` 로 남아 있었으나 이미 `archive/specs/…` 로 이동됨 → 정정(본 저장소 불일치 0건).
- **수동 의미 lint 지적**
  - ① `direction.md` 원칙 2 의 수치(`sdd` 3,240줄 / hook 16개 / 슬래시 22개)가 하루 만에 낡음(3,380줄 / 헬퍼 2개 / 23개 — 이 phase 에서 늘어난 것). 정확한 수치를 주장하면 계속 낡으므로 "(2026-10-23 실측)" 기준일을 병기. → 이런 수치 표는 `verify` 키 후보 (`counts`).
  - ② `hooks.md` §강제 수준 분류의 "차단 (block)" 행은 hook 이름 목록이 코드의 block 기본값과 일치해야 하는 기계 검증 가능 주장인데 마커가 없음 → `verify` 키 후보 (`hooks-classification`).
  - ③ `hooks.md` §기술 부채의 "설치 경로 3중", "lefthook 미착수", "shellcheck 미설치" 는 출처 표기가 없음.
- **검증기의 한계 (알고 둔 것)**: `hooks-defaults` 는 헤더에 `기본` 열이 없으면 행을 대조하지 못하고 침묵한다. 표 서식을 바꿔 검증을 무력화할 수 있으므로, 마커가 있는데 `기본` 열을 못 찾는 경우를 "검증 불가" 로 보고하는 것이 다음 개선 후보.
- **테스트 실수 2건을 Green 단계에서 고침**: (a) Case 7 의 glob 순서 가정이 틀렸음, (b) freshness Case 7 의 `grep "미반영 ADR"` 이 *통과 문구*("미반영 ADR 없음")에 매칭돼 거짓 red 였음. (b)는 구 코드에서 실제로 실패함을 stash 로 재확인한 뒤 확정.
- 새 슬래시 커맨드는 `install.sh` 가 디렉토리 glob 으로 설치하므로 별도 등록 목록이 없다(`doctor.sh` 의 템플릿 목록과 달리).

## 🚧 이월 항목

- `verify` 키 `counts`(수치 표), `hooks-classification`, 그리고 "마커 있는데 기본 열 없음 → 검증 불가" 보고 → spec-30-03 에서 컴포넌트 페이지를 쓰며 필요한 키와 함께 추가 검토
- `hooks.md` §기술 부채 출처 표기 보강 → spec-30-03
- `/hk-wiki-lint` 를 독립 세션에서 실제 실행한 오탐률 측정 → phase 종료 시 인제스트와 함께
- 이전 이월 유지: 새 규약 인제스트 실사용 검증(30-01), ADR `supersedes` 필요성(30-03)
