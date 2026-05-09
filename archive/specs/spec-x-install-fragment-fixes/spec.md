# spec-x-install-fragment-fixes: install.sh·fragment 잔존 버그 2건 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-install-fragment-fixes` |
| **Phase** | 없음 (spec-x) |
| **Branch** | `spec-x-install-fragment-fixes` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-06 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`와 `sources/claude-fragments/settings.json.fragment`에는 도그푸딩(2026-04-27) 중 발견된 버그 2건이 Icebox에 기록되어 있다. 이후 spec으로 수정되지 않은 채 남아 있으며, 다음 install/update 실행 시 동일 문제가 재현된다.

### 문제점

**버그 A — install.sh self-host gitignore 충돌**

`install.sh`를 harness-kit 자기 자신에게 실행(`--yes`)하면, `.harness-kit/` 디렉토리가 git으로 추적되고 있음에도 `.gitignore`에 `.harness-kit/`가 추가된다. 이후 `git status`에서 해당 디렉토리가 untracked로 보이거나 ignored로 표시되어 도그푸딩 환경이 오염된다.

- 원인: `install.sh`가 `.harness-kit/`가 이미 git-tracked인지 확인하지 않고 무조건 `.harness-kit/`를 `.gitignore`에 추가함
- 재현: `./install.sh --yes .` (자기 자신에게 실행)

**버그 B — settings.json.fragment의 git push ask 중복**

`sources/claude-fragments/settings.json.fragment`의 `ask` 섹션에 `Bash(git push)` / `Bash(git push:*)`가 포함되어 있다. install.sh의 union 머지 로직에 의해 사용자의 `settings.json`에 이미 `allow`에 `git push:*`가 있더라도 `ask` 섹션에도 추가된다. Claude Code는 `ask > allow` 우선순위를 적용하므로, 매 git push마다 권한 프롬프트가 발생한다.

- 원인: fragment의 ask 섹션에 git push가 포함되어 있으나 allow의 `Bash(git:*)`로 이미 커버됨
- 재현: 신규 설치 또는 `update.sh` 실행 후 `git push` 시 권한 프롬프트 발생

### 해결 방안 (요약)

- **버그 A**: `install.sh`의 `.gitignore` 갱신 로직에 self-host guard를 추가한다. `.harness-kit/` 하위에 git-tracked 파일이 존재하면 `.gitignore`에 `.harness-kit/` 추가를 건너뛴다.
- **버그 B**: fragment의 `ask` 섹션에서 `Bash(git push)` / `Bash(git push:*)`를 제거한다. `allow`의 `Bash(git:*)`가 이미 git push를 커버하며, check-branch.sh 훅이 main 브랜치 보호를 담당한다.

## 🎯 요구사항

### Functional Requirements

1. `install.sh --yes`를 git-tracked `.harness-kit/`가 있는 디렉토리에 실행하면 `.gitignore`에 `.harness-kit/`가 추가되지 않아야 한다.
2. 신규 설치 또는 update 후 `settings.json`의 `ask` 섹션에 `Bash(git push)` 계열 항목이 없어야 한다.
3. 기존 `--gitignore` / `--no-gitignore` 플래그 동작은 유지되어야 한다 (기존 테스트 PASS).

### Non-Functional Requirements

1. bash 3.2+ 호환 — `git ls-files` 출력 파이프는 bash 3.2에서 동작해야 함
2. 기존 테스트 시나리오 A–G(test-gitignore-config.sh) 모두 PASS 유지

## 🚫 Out of Scope

- `--no-gitignore-harness-kit` 전용 플래그 추가 (이번에는 자동 감지로 충분)
- self-host 감지 범위를 interactive 프롬프트 단계로 앞당기는 작업
- `git push`를 `ask`로 유지하는 방식의 대안적 설계 재검토

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-install-fragment-fixes` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
