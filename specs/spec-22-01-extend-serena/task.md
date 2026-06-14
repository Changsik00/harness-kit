# Task List: spec-22-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: Pre-flight

- [ ] Plan Accept 확인 (사용자 승인 전 코드 편집 금지)
- [ ] 구현 착수 시 Serena 공식 실행 커맨드(플래그 포함) 재확인 (spec 🛑 검토 항목)

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-22-01-extend-serena`

---

## Task 2: `sdd extend` 헬퍼 핵심 (선행조건·스코프·dry-run·기록)

> 외부 의존(`uv`/`claude`) 없이 테스트 가능한 핵심 로직.

### 2-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-extend.sh` 작성:
  - 스코프 검증: `project`/임의값 거부 + 사유 출력
  - 선행조건 부재(PATH stub 제거) → graceful 종료(exit 0), 등록 시도 없음
  - `--dry-run` → `claude mcp add serena --scope local -- uvx …` 문자열 출력, installed.json 미변경
  - 정상 등록(`claude`/`uv` PATH stub 주입) → `installed.json` 의 `extensions.serena.scope` 기록
- [ ] 실행 → Fail 확인
- [ ] Commit: `test(spec-22-01): add failing tests for sdd extend helper`

### 2-2. 구현 (TDD Green)
- [ ] `sources/bin/lib/extend.sh` 신설: 선행조건 점검, 스코프 검증, Serena 등록 커맨드 구성, `--dry-run`, installed.json 기록(jq in-place). bash 3.2 호환.
- [ ] `sources/bin/sdd` 에 `extend` dispatch case + `lib/extend.sh` source + usage 항목 추가.
- [ ] 테스트 실행 → Pass 확인
- [ ] Commit: `feat(spec-22-01): add sdd extend helper with scope/dry-run/record`

---

## Task 3: 멱등성 + remove

### 3-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-extend.sh` 확장:
  - 재실행 시 "이미 설치됨" 안내 + 중복 등록 차단
  - `--remove` → `claude mcp remove serena` 호출(stub 검증) + installed.json 흔적 제거
- [ ] 실행 → Fail 확인
- [ ] Commit: `test(spec-22-01): add failing tests for idempotency and remove`

### 3-2. 구현 (TDD Green)
- [ ] `lib/extend.sh` 에 멱등 검사(installed.json/`claude mcp get`) + `--remove` 경로 구현.
- [ ] 테스트 실행 → Pass 확인
- [ ] Commit: `feat(spec-22-01): make sdd extend idempotent and support --remove`

---

## Task 4: `/hk-extend` 슬래시 커맨드 + install 정합

### 4-1. 커맨드 작성
- [ ] `sources/commands/hk-extend.md` 신설: frontmatter `description` + 본문(확장 목록 안내 → 스코프 질문(uxMode 분기) → `sdd extend serena --scope <…>` 호출).
- [ ] `tests/run.sh --fast` 실행 → `test-install-manifest-sync` 등 정합 테스트 PASS 확인. 깨지면 매니페스트 목록 갱신.
- [ ] Commit: `feat(spec-22-01): add /hk-extend slash command`

---

## Task 5: ADR-007 + README extend 섹션

### 5-1. 문서 작성
- [ ] `docs/decisions/ADR-007-extend-opt-in.md` 작성(template 따름, type: decision): default-off / 등록 위임 / 검증 3개 후 추출.
- [ ] `README.md` 에 extend 섹션 추가 — Serena opt-in 설치법 + MCP 상시 컨텍스트 비용 명시.
- [ ] `bash .harness-kit/bin/sdd status` 로 stale ADR 경고 없음 확인.
- [ ] Commit: `docs(spec-22-01): add ADR-007 extend opt-in and README section`

---

## Task 6: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [ ] **전체 테스트 실행** (`bash tests/run.sh --fast`) → 모두 PASS

### 📝 산출물 작성
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-22-01): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-22-01-extend-serena`
- [ ] PR 생성 (`/hk-pr-gh`)
