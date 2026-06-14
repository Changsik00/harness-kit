# Task List: spec-23-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: ADR-008 작성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-23-01-prefer-extensions`

### 1-2. ADR 작성
- [x] `.harness-kit/agent/templates/adr.md` 읽고 따름
- [x] `docs/decisions/ADR-008-extension-preferential-use.md` 작성 (type: tradeoff, 한국어 산출물 규약): MCP 상시비용 vs 컨텍스트 절감, 조건부 우선 사용 채택 + 거부안 비용
- [x] Commit: `docs(spec-23-01): add ADR-008 extension preferential use`

---

## Task 2: agent.md 확장 우선 사용 규칙

### 2-1. 거버넌스 규칙 추가 (영어, 미러)
- [x] `.harness-kit/agent/agent.md` §6.5 인접에 "Extension-First (conditional)" 규칙 블록 추가
- [x] `sources/governance/agent.md` 에 byte-identical 미러
- [x] `diff -q` 동일 확인 — 총 7786w, 하드 한도 8000 미만(7000 soft-warn 은 기존 존재)
- [x] Commit: `docs(spec-23-01): add extension-first governance rule`

---

## Task 3: hk-extend 권장 톤 전환

### 3-1. 도입부 톤 조정 (미러)
- [x] `sources/commands/hk-extend.md` 도입부를 권장 톤으로 (opt-in 원칙·상시비용 경고 유지)
- [x] `.claude/commands/hk-extend.md` byte-identical 미러
- [x] `diff -q` 동일 확인
- [x] Commit: `docs(spec-23-01): make hk-extend recommend serena`

---

## Task 4: sdd drift 확장 권장 감지 (TDD)

### 4-1. 테스트 작성 (Red)
- [x] `tests/test-drift-extension-recommend.sh` 작성: (코드 파일 + 미설치 → 권장 출력) / (코드 없음 → 무출력) / (설치됨 → 무출력)
- [x] 실행 → Fail 확인 (T1 함수 미존재)
- [x] Commit: `test(spec-23-01): add failing test for extension recommend drift`

### 4-2. 구현 (Green, 미러)
- [x] `.harness-kit/bin/sdd` 에 `_drift_extension_recommend()` 추가 + `_status_drift` 연결
- [x] `sources/bin/sdd` byte-identical 미러
- [x] `bash tests/test-drift-extension-recommend.sh` → 3 PASS, `diff -q` 동일 확인
- [x] Commit: `feat(spec-23-01): recommend extension when code project lacks it`

---

## Task 5: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] `bash tests/run.sh --fast` → 내 신규 테스트 PASS. 기존 4개 실패(version-bump/wiki-structure/pr-merge-detect/update-stateful)는 **main 에서도 동일** = 사전 존재, 본 변경과 무관(검증함)
- [x] 3쌍 미러 `diff -q` 동일 (agent.md / sdd / hk-extend.md)
- [-] `sdd doctor` 워드 버짓 경고 — 7000 soft-warn 사전 존재, 하드 8000 미만(7786). Icebox 기록함 (queue.md). 본 spec 통과 기준은 8000 미만으로 충족

### 📝 산출물 작성
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] Commit: `docs(spec-23-01): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] `git push -u origin spec-23-01-prefer-extensions`
- [x] PR 생성 → https://github.com/Changsik00/harness-kit/pull/195
