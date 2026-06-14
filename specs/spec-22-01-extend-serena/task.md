# Task List: spec-22-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: Pre-flight

- [x] Plan Accept 확인 (사용자 승인 전 코드 편집 금지)
- [x] 구현 착수 시 Serena 공식 실행 커맨드(플래그 포함) 재확인 — `--context claude-code`, local=`--project "$(pwd)"`, user=`--project-from-cwd` (oraios.github.io/serena clients 문서)

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-22-01-extend-serena`

---

## Task 2: `sdd extend` 헬퍼 핵심 (선행조건·스코프·dry-run·기록)

> 외부 의존(`uv`/`claude`) 없이 테스트 가능한 핵심 로직.

### 2-1. 테스트 작성 (TDD Red)
- [x] `tests/test-extend.sh` 작성 (스코프 검증 / 선행조건 부재 graceful / dry-run / 정상 등록 기록)
- [x] 실행 → Fail 확인 (3 FAIL)
- [x] Commit: `test(spec-22-01): add failing tests for sdd extend helper`

### 2-2. 구현 (TDD Green)
- [x] `sources/bin/lib/extend.sh` 신설
- [x] `sources/bin/sdd` 에 `extend` dispatch case + `lib/extend.sh` source + usage 항목 추가.
- [x] 테스트 실행 → Pass 확인 (4/4)
- [x] Commit: `feat(spec-22-01): add sdd extend helper with scope/dry-run/record`

---

## Task 3: 멱등성 + remove

### 3-1. 테스트 작성
- [x] `tests/test-extend.sh` 확장: T5(멱등 — 재실행 시 안내 + add 1회 유지), T6(--remove → state 제거 + installed.json 흔적 제거)
- [x] 실행 → Pass 확인 (6/6)
- [x] Commit: `test(spec-22-01): add tests for idempotency and remove`

### 3-2. 구현
- [x] 멱등 검사(`claude mcp get`) + `--remove` 경로는 Task 2-2 의 `lib/extend.sh` 에 단일 단위로 이미 구현됨 (TDD 분할이 아닌 헬퍼 통합 구현 — walkthrough 기록). 별도 commit 없음.

---

## Task 4: `/hk-extend` 슬래시 커맨드 + install 정합

### 4-1. 커맨드 작성
- [x] `sources/commands/hk-extend.md` 신설 (확장 안내 → uxMode 분기 스코프 질문 → `sdd extend serena --scope` 호출).
- [x] `test-install-manifest-sync` PASS 확인 (fixture install 자동 동기화 — 매니페스트 수정 불필요).
- [x] Commit: `feat(spec-22-01): add /hk-extend slash command`

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
