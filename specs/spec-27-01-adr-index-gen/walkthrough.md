# Walkthrough: spec-27-01

> 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.
> 작업을 진행하는 동안 *지속적으로* 갱신하세요.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 명령 위치 | 신규 bin 스크립트 / `sdd` 서브커맨드 | **`sdd adr-index [--check]`** | 기존 단일 진입점 설계(context-cost-first) 유지 |
| 마커 치환 방식 | 기존 `sdd_marker_replace`(awk `-v content`) 재사용 / 신규 bash 라인 루프 | **신규 bash 라인 루프** | `awk -v var="multi\nline"` 가 이 macOS(BWK awk)에서 "newline in string" 으로 즉시 실패함을 실측 확인(GitHub #168 이 지적한 함정과 동일). 기존 헬퍼 수정은 범위 밖 |
| `--check` 마커 탐지 방식 | 정규식 substring 매치(`/pattern/`) / 정확한 라인 일치(`$0 == "..."`) | **정확한 라인 일치** | 최초 구현에서 substring 매치를 썼다가 README 안내 문구 자체가 마커 문법(`` `<!-- adr-index:start -->` ``)을 인용하는 바람에 그 프로즈 줄이 마커로 오인되는 버그를 실제로 겪음 — 재현·수정 후 회귀 없음 확인 |
| `sdd ship` 이 base 모드에서 spec 을 즉시 `Merged` 표시 | 그대로 둠 / `In Progress` 로 수동 보정 | **수동 보정** | 알려진 base-mode 갭(`backlog/queue.md` Icebox — "`sdd ship` base-mode 갭", spec-20-01 부터 추적 중). PR 이 phase 브랜치에 실제 머지되기 전까지는 `In Progress` 가 맞음 — 도구 버그를 이 spec 범위에서 고치지 않고 산출물만 수동 정정 |

<!-- ADR 승격: 다른 spec 에 의존되거나 6개월 이상 유지될 결정 → docs/decisions/ADR-NNN-slug.md (constitution §6.3) -->
- 본 spec 의 결정 3건 모두 단일 spec 범위 내 구현 세부사항 — ADR 승격 대상 아님.

## 💬 사용자 협의

- **주제**: GitHub #167 을 어떻게 처리할지 (spec-27-01 착수 전, phase 계획 단계)
  - **합의**: #167 은 phase-FF 로 즉시 처리, #167+#168 을 phase-27(docs-integrity) 로 승격해 진행.
- **주제**: 4개 이슈(#212/#181/#168/#167) 중 무엇을 먼저 볼지
  - **합의**: queue.md Icebox 의 기존 권장안("#167/#168 묶어서 doctor 강화 phase 승격")을 그대로 채택.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-adr-index.sh` + `bash tests/run.sh`
- **결과**: ✅ Passed (adr-index 6/6, 전체 79/79, FAIL 0)
```text
Test: sdd adr-index
  ✓ missing README.md → --check exits non-zero
  ✓ adr-index generates README.md with fixture row
  ✓ adr-index re-run is idempotent
  ✓ --check exits 0 when in sync
  ✓ --check detects drift after frontmatter edit
  ✓ regenerate resolves drift
```

### 수동 검증
1. **Action**: `bash .harness-kit/bin/sdd adr-index`
   - **Result**: `docs/decisions/README.md` 신규 생성, 기존 ADR-001~009 전부 번호순 테이블 등장.
2. **Action**: `bash .harness-kit/bin/sdd adr-index --check` (직후 재실행)
   - **Result**: `✓ ADR 인덱스 정합`, exit 0.

## 🔍 발견 사항

- **`--check` 정규식 매치의 자기 참조 버그**: 인덱스 파일 상단 안내 문구가 마커 리터럴 문자열(`` `<!-- adr-index:start -->` ``)을 그대로 인용하다 보니, `/<!-- adr-index:start -->/` 같은 regex 패턴이 그 안내 문구 줄도 "마커"로 오인해 `in_section` 을 조기에 켜버림 → 빈 줄이 인덱스 행으로 오탐되어 매번 drift 로 보고됨. 정확한 라인 일치(`$0 == "..."`)로 바꿔 해결. **일반화 가능한 교훈**: 마커 기반 파서를 작성할 때 안내 문구가 마커 문법을 언급하면 regex substring 매치는 위험 — exact match 를 기본으로.
- **macOS awk(BWK awk) `-v` 멀티라인 제약**: `awk -v c="line1\nline2"` 는 "newline in string" 으로 즉시 실패함을 실측 확인. 기존 `sdd_marker_replace` 헬퍼도 잠재적으로 이 제약에 걸릴 수 있으나(현재 호출부는 대체로 단일 라인이라 미노출), 본 spec 의 신규 기능은 처음부터 bash 라인 루프로 우회 설계.

## 🚧 이월 항목 (Optional)

- `sdd_marker_replace` 자체의 멀티라인 `-v` 취약점 — 현재 호출부에서 미노출이라 본 spec 범위 밖. 향후 멀티라인 콘텐츠를 넘기는 새 호출부가 생기면 재검토 필요 (`backlog/queue.md` 에 별도 등록하지 않음 — 발견 사항으로만 기록, 실사용 트리거 시 대응).
