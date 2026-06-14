# spec-x-drift-stale-adr-glob: stale ADR 탐지기 glob 오탐 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-drift-stale-adr-glob` |
| **Phase** | (없음 — spec-x) |
| **Branch** | `spec-x-drift-stale-adr-glob` |
| **상태** | Planning |
| **타입** | Fix |
| **작성일** | 2026-06-14 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`sdd status` 의 drift 섹션은 `_drift_stale_adr()` 로 ADR 본문의 backtick 경로 토큰을 추출해 실제 파일 존재 여부를 검사한다. `.harness-kit/bin/sdd` 와 미러본 `sources/bin/sdd` 가 byte-identical 로 동일한 로직을 가진다.

### 문제점

탐지기가 ADR 본문의 **glob 패턴(설명용 예시)** 을 리터럴 파일 경로로 오인한다. 예를 들어 `ADR-003-wiki-frontmatter-schema.md` 본문의 `docs/wiki/*.md`, `docs/decisions/ADR-*.md`, `docs/rca/RCA-*.md` 같은 토큰은 슬래시 + 확장자 필터를 통과하지만 `*` 가 포함되어 리터럴 파일로는 절대 존재할 수 없으므로 항상 missing 으로 잡힌다.

결과적으로 ADR-003 은 내용에 아무 문제가 없는데도 매 `sdd status` 마다 `stale ADR: 1 (missing-path)` 로 오탐된다. 거짓 경고는 신호 대비 잡음을 높여 진짜 stale ADR 을 묻히게 만든다.

### 해결 방안

`_drift_stale_adr()` 의 토큰 필터 체인에 glob 메타문자(`*`, `?`) 포함 토큰 제외 규칙을 추가한다. glob 은 리터럴 파일 경로가 아니라 패턴이므로 존재 검사 대상에서 배제한다. `.harness-kit/bin/sdd` 와 `sources/bin/sdd` 양쪽에 동일 적용한다.

## 요구사항

1. ADR 본문 backtick 토큰 중 `*` 또는 `?` 를 포함한 것은 stale 검사에서 제외한다.
2. `.harness-kit/bin/sdd` 와 `sources/bin/sdd` 가 수정 후에도 byte-identical 을 유지한다.
3. 기존 `tests/test-drift-stale-adr.sh` 의 3개 케이스는 그대로 PASS 한다 (회귀 없음).
4. ADR-003 이 더 이상 `sdd status` 에서 stale 로 잡히지 않는다.

## Out of Scope

- ADR frontmatter `sources:` 경로(archive 이동 시 끊김)에 대한 처리 — 탐지기는 frontmatter 가 아니라 본문 backtick 만 검사하므로 본 spec 범위 밖.
- 탐지기 추출 규칙 전반의 재설계 — 최소 변경 원칙.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] glob 제외는 `*`, `?` 만 대상으로 한다 (`[...]` 문자 클래스는 실제 경로에서도 드물게 쓰일 수 있어 제외 대상에서 뺀다 — 과배제 방지).

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **`_drift_stale_adr`** | URL 제외 다음 단계에 `grep -q '[*?]' && continue` 추가 | glob 은 패턴이지 파일이 아님. 제외만 추가하므로 오탐만 줄고 진짜 missing 탐지는 보존 |
| **sources 미러** | 동일 변경을 `sources/bin/sdd` 에 byte-identical 적용 | 미러 회귀 방지 (install-manifest-sync 테스트) |

## Proposed Changes

#### [MODIFY] `.harness-kit/bin/sdd`
`_drift_stale_adr()` 토큰 필터 체인 (URL 제외 직후) 에 glob 메타문자 포함 토큰 제외 한 줄 추가.

#### [MODIFY] `sources/bin/sdd`
위와 byte-identical 미러링.

#### [MODIFY] `tests/test-drift-stale-adr.sh`
glob 패턴(`docs/wiki/*.md`)만 포함한 fixture ADR 이 stale 로 잡히지 않음을 검증하는 케이스 추가.

## 검증 계획

```bash
bash tests/test-drift-stale-adr.sh
HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status
diff -q .harness-kit/bin/sdd sources/bin/sdd
```

수동 검증 시나리오:
1. 수정 후 `sdd status` 실행 — 기대 결과: `stale ADR` 라인이 사라짐.
2. `tests/test-drift-stale-adr.sh` 실행 — 기대 결과: 신규 glob 케이스 포함 전체 PASS.
3. `diff -q` — 기대 결과: 두 파일 동일(exit 0).

## ADR 후보

- [x] 없음 — 탐지 휴리스틱 버그 픽스, 아키텍처 결정 아님.

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (`tests/test-drift-stale-adr.sh`)
- [ ] `.harness-kit/bin/sdd` == `sources/bin/sdd` (byte-identical)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-drift-stale-adr-glob` 브랜치 push 완료
