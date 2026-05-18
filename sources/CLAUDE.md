# sources/ — 키트 원본 시점

이 디렉토리는 **harness-kit 자체** 의 원본입니다. 여기의 파일은 `install.sh` 또는 `update.sh` 를 통해 *다른 프로젝트로* 복사되어 적용됩니다.

## 핵심 주의

- **수정 영향**: 이 디렉토리의 파일을 수정해도 *이미 install 된 프로젝트* 는 자동 갱신되지 않습니다. `update.sh` 가 갱신 역할.
- **bash 3.2+ 호환**: 모든 스크립트는 bash 3.2 (macOS 기본) 에서 동작해야 합니다. bash 4+ 전용 기능 (`declare -A`, `mapfile`/`readarray`, `**` globstar, `${var,,}`/`${var^^}`, `coproc`) 금지.
- **한국어 산출물 원칙**: 거버넌스 문서 (`sources/governance/`) 외 사용자-대면 산출물 (templates, commands 설명) 은 한국어.

## 하위 디렉토리

| 경로 | install 대상 | 역할 |
|---|---|---|
| `governance/` | `.harness-kit/agent/` | constitution / agent.md / align.md (행동 규약) |
| `templates/` | `.harness-kit/agent/templates/` | spec/plan/task 등 산출물 양식 |
| `commands/` | `.claude/commands/` | 슬래시 커맨드 (`/hk-*`) |
| `hooks/` | `.claude/scripts/harness/hooks/` | 후크 스크립트 |
| `bin/` | `.harness-kit/bin/` | `sdd` 메타 명령 |
| `claude-fragments/` | `.claude/settings.json` / `CLAUDE.md` 머지 | fragment 조각 |
