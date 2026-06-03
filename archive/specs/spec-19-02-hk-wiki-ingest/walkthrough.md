# Walkthrough: spec-19-02 — hk-wiki-ingest 슬래시 커맨드

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| `.harness-kit/commands/` vs `.claude/commands/` | harness-kit 내부 경로에 복사 / `.claude/commands/` 에만 설치 | `.claude/commands/` 에만 설치 | `.harness-kit/commands/` 디렉토리는 install 경로가 아님. install.sh 가 `sources/commands/` → `.claude/commands/` 로 복사하므로 `.claude/commands/` 가 실제 활성 경로 |
| 힌트 출력 위치 | `cmd_archive()` 마지막 / 별도 후처리 함수 | `cmd_archive()` ok() 출력 직후 printf 1줄 추가 | archive 완료 시그널 바로 다음에 위치해야 사용자가 자연스럽게 인식. 별도 함수는 불필요한 추상화 |
| log.md 날짜 형식 | `## YYYY-MM-DD` / `### YYYY-MM-DD` | `### YYYY-MM-DD` (h3) | plan에서 정한 형식. h2는 섹션 제목용으로 예약하고, 날짜 항목은 h3로 계층 분리 |

### ADR 승격 가이드

- [x] 없음 — 모든 결정이 spec-19-02 로컬 범위 내

## 💬 사용자 협의

- **주제**: `.harness-kit/commands/` 경로 오류
  - **사용자 의견**: task.md에 `.harness-kit/commands/hk-wiki-ingest.md` 동기화 항목이 있었으나 실제로는 해당 경로가 존재하지 않음
  - **합의**: install 경로인 `.claude/commands/hk-wiki-ingest.md` 에만 설치하는 것으로 수정. task.md 체크박스 갱신 및 테스트 Check 1 기준도 `.claude/commands/` 로 교정

- **주제**: spec-19-02 시작 시점
  - **사용자 의견**: 이전 phase-19 작업(C1~W4 fix) 완료 직후 바로 이어서 시작하도록 요청
  - **합의**: phase-19-doc-knowledge-graph 브랜치 위에서 spec-19-02 브랜치를 생성하여 진행

## 🧪 검증 결과

### 1. 자동화 테스트

#### test-wiki-structure.sh
- **명령**: `bash tests/test-wiki-structure.sh`
- **결과**: ✅ 45/45 PASS
- **로그 요약**:
```text
───────────────────────────────────────────
 결과: 45/45 PASS
───────────────────────────────────────────
 ✓ ALL PASS
```

#### test-wiki-ingest.sh (신규)
- **명령**: `bash tests/test-wiki-ingest.sh`
- **결과**: ✅ 10/10 PASS
- **로그 요약**:
```text
───────────────────────────────────────────
 결과: 10/10 PASS
───────────────────────────────────────────
 ✓ ALL PASS
```

### 2. 수동 검증

1. **Action**: `sources/commands/hk-wiki-ingest.md` 내용 확인 — log.md, decisions.md, patterns.md 참조 포함 여부
   - **Result**: 6개 섹션(범위 결정, 대상 수집, walkthrough 읽기, log.md 갱신, index.md 갱신, 결과 보고) 모두 포함. 3개 파일 참조 확인.

2. **Action**: `sources/bin/sdd` cmd_archive() 끝부분 — 힌트 출력 라인 확인
   - **Result**: `ok "${ok_msg} → archive/"` 직후 `printf "  → wiki 갱신: /hk-wiki-ingest\n"` 삽입 확인. `.harness-kit/bin/sdd` 동기화 완료.

3. **Action**: `docs/wiki/log.md` 형식 확인 — `### YYYY-MM-DD` 날짜 항목 + `대상` 필드
   - **Result**: 기존 log.md에 올바른 형식 항목 존재 확인 (spec-19-01 인제스트 이벤트).

## 🔍 발견 사항

- **`.harness-kit/commands/` 경로 부재**: install.sh 출력 경로가 `.claude/commands/` 임에도 task.md가 `.harness-kit/commands/` 를 참조하도록 작성됨. 이 패턴은 다른 커맨드 spec에서도 반복될 수 있으므로 템플릿 주석 보강 고려.
- **sdd archive 힌트의 discoverability**: 힌트는 archive 완료 메시지 다음 줄에 출력되어 가시성이 높음. 단, 처음 보는 사용자는 `/hk-wiki-ingest` 가 슬래시 커맨드임을 모를 수 있어 향후 힌트 메시지에 "(슬래시 커맨드)" 부연을 추가하는 방안 검토 가능.
- **인제스트 자동화 가능성**: 현재 `/hk-wiki-ingest` 는 에이전트가 walkthrough를 읽고 수동으로 판단하는 방식. 향후 구조화된 frontmatter로 자동 파싱 파이프라인을 구축할 여지가 있음.

## 🚧 이월 항목 (Optional)

- 없음

## 🔗 관련 문서 (Related)

- 관련 wiki: [[wiki/log]], [[wiki/decisions]], [[wiki/patterns]]
- 관련 ADR: [[ADR-003-wiki-frontmatter-schema]]
- 관련 RCA: 없음

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-27 ~ 2026-05-27 |
| **최종 commit** | `02ab909` |
