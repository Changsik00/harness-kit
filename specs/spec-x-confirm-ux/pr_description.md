fix(confirm-ux): constitution §5.7 Action Confirmation Rules 신설 — push 자동화·PR 확인 형식 단일화

## 배경

`hk-ship` 이후 push/PR 확인 인터랙션이 세션마다 달랐음:
- 어떤 세션: `Y/n` 형식, 다른 세션: `1. yes / 2. other` 형식
- 어떤 세션: 묻지 않고 자동 진행, 다른 세션: push 정보 블록에서 멈춤

원인: `hk-pr-gh §4`가 `constitution §5.2`(Plan Accept 전용)를 참조하고,
`hk-ship §5-A`에 `--no-confirm` 전달이 명시되지 않아 모델이 재량으로 판단.

## 변경 내용

### `sources/governance/constitution.md` + `.harness-kit/agent/constitution.md`

§5.7 Action Confirmation Rules 신설:
- **push**: Plan Accept 이후 정보 블록 표시 후 응답 대기 없이 즉시 실행
- **PR 확인**: `생성할까요? [Y/n]` 단일 형식 고정. 숫자 목록 금지.
- PR 인식 YES: `Y`, `y`, `yes`, `1`, `ok`, `네`, `ㅛ`
- PR 인식 NO: `N`, `n`, `no`, `아니`
- hk-ship 경유 시 확인 생략 (`--no-confirm`)

### `sources/commands/hk-ship.md` + `.claude/commands/hk-ship.md`

§5-A 변경: `/hk-pr-gh` → `/hk-pr-gh --no-confirm` 명시 + §5.7 참조

### `sources/commands/hk-pr-gh.md` + `.claude/commands/hk-pr-gh.md`

§4 참조: `constitution §5.2` → `constitution §5.7`

### `sources/commands/hk-pr-bb.md` + `.claude/commands/hk-pr-bb.md`

§4 참조: 동일 교체

## 부수 발견

`install.sh` 기존 pre-commit hook 파일에 블록 append 시 `chmod +x` 누락 버그 →
`backlog/queue.md` Icebox 등록 (별도 spec-x 처리 예정)

## 테스트

- `test-governance-dedup.sh`: ✅ PASS (sources↔installed 정합성)
