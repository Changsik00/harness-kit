# Backlog Queue

> 본 문서는 *대시보드* 입니다. "지금 무엇을 하고 있고, 다음에 무엇을 해야 하는가"를 한눈에 보기 위함.
> sdd 가 마커 사이를 자동 갱신하므로 마커 (`<!-- sdd:... -->`) 는 그대로 두세요.
> 🧊 Icebox 섹션만 사람이 직접 편집합니다.

## 📦 진행 중 Phase

<!-- sdd:active:start -->
- **phase-14** — install-distribution-v1 — 0/0 spec — (다음: 첫 spec 생성 대기)
<!-- sdd:active:end -->

## 📥 spec-x 대기

<!-- sdd:specx:start -->
없음
- [ ] spec-x-fix-archive-test-expectation — fix-archive-test-expectation
<!-- sdd:specx:end -->

## 🧊 Icebox

> 아이디어·보류 항목 보관소. 실행 불가. 관련 항목이 쌓이면 Phase로, 단발이면 spec-x로 승격.

- [ ] 크로스 에이전트 호환 (AGENTS.md) — Cursor/Copilot/Codex 등에서 프로젝트 컨텍스트를 인식할 수 있도록 install.sh에서 AGENTS.md 자동 생성. 현재 Claude Code 전용으로 충분하나, 멀티 에이전트 환경이 보편화되면 재검토. (보류 2026-04-11)
- [ ] 크로스 플랫폼 지원 — 현재 macOS + bash 4.0+ 전용. Linux CI 환경(GitHub Actions 등)은 bash 호환이라 즉시 가능하나, Windows는 WSL2 필수. 검토 사항: (1) GitHub Actions CI에서 테스트 자동화 (2) Linux 공식 지원 선언 (3) WSL2 설치 가이드 추가. macOS 외 실사용자가 나타나면 승격.
- [ ] update 시 사용자 수정 보존 — 현재 `update.sh` 는 uninstall + install 로 키트 파일(`.claude/commands/hk-*.md`, `scripts/harness/hooks/`, `agent/` 등)을 전부 덮어씀. `--keep-state` 는 `backlog/`/`specs/`/`state/` 만 보존. 해법 후보: (1) **체크섬 매니페스트** — `installed.json` 에 설치 시점 sha256 기록, 업데이트 시 현재 sha ≠ 설치 시 sha 면 "사용자 수정"으로 판단하고 스킵 + `.new` 병치 (dpkg conffile 방식, 추천), (2) 3-way merge (`git merge-file` — bash 구현 복잡), (3) 오너십 분리 (kit 소유 vs user override 디렉토리 — 현재 `hk-*.md` 직접 수정 UX 깨짐). 사용자가 키트 파일을 직접 고치는 유스케이스가 실제로 등장하면 승격. (보류 2026-04-23)
- [ ] 표준 배포 경로 (Homebrew + curl-pipe) — 현재 `git clone && ./install.sh` 부트스트랩만 지원. 목표: Windows + macOS 양쪽 설치 편의. 구성 (1) **Homebrew tap** (`brew install dennis/tap/harness-kit`) — macOS 1차 타깃, `brew upgrade` 로 자동 갱신 (2) **curl-pipe installer** (`curl -fsSL .../install.sh \| bash`) — Linux/CI/Homebrew 미사용자, rustup·deno·bun 방식 (3) **Windows 경로** — WSL2/Git Bash 는 curl-pipe 재사용, 네이티브 PowerShell 은 `iwr ... \| iex` 별도 스크립트 검토 (또는 WSL2 필수로 선언). UX: 글로벌 `harness-kit` CLI → 프로젝트에서 `harness-kit init` / `harness-kit update` 호출. npx/npm 은 Node.js 런타임 오염으로 제외. v1.0 마일스톤 후보 (배포 경로 변경 시 README·문서·설치 가이드 전체 영향). (보류 2026-04-23)
- [ ] **[우선순위 ①]** 플러그인/사용자 커스텀 확장 지점 — 사용자가 자기 hook·slash command 를 추가하고 싶을 때 현재 `sources/` 혹은 `.claude/commands/` 에 직접 넣으면 update 시 삭제/덮어쓰기됨. 공식 확장 디렉토리 규약 부재. 해법 후보: (1) `.harness-kit/extensions/{hooks,commands}/` 보호 디렉토리 — install/update 가 절대 건드리지 않음 (2) `settings.json` 에서 사용자 확장 경로를 명시적으로 merge. 위 "update 사용자 수정 보존" 이슈와 **반드시 같이 설계** 해야 정합성 확보 (둘 다 "키트 소유 vs 사용자 소유" 경계 문제). (보류 2026-04-23)
- [ ] **[우선순위 ②]** Claude Code 버전 호환성 매트릭스 — Claude Code 가 hook API·슬래시 커맨드 포맷·settings.json 스키마 바꾸면 키트가 조용히 깨짐. 실사용 중 터지면 디버깅 난이도 최상. 해법: `doctor` 에 CC 버전 감지 + 지원 매트릭스 (`supported-cc-versions.json`) 비교 + 미지원 버전 경고. 향후 CC breaking change 대응 공지 채널도 필요. (보류 2026-04-23)
- [ ] **[우선순위 ③]** 팀 온보딩 UX — `.harness-kit/` 가 이미 체크인된 프로젝트를 새 팀원이 `git clone` 했을 때 뭘 해야 하는지 불명확. 현재 설치 안 해도 hook 동작은 하지만 전역 `sdd` CLI 는 없음 (scripts/harness/bin 은 프로젝트 내부 경로). 해법 후보: (1) `harness-kit init` 이 "이미 설치됨" 감지 시 로컬 CLI 심볼릭만 연결하는 `--attach` 모드 (2) README 에 "기존 프로젝트 합류" 섹션 표준화. 배포 경로 이슈와 묶어서 설계 (`brew install` 후 `harness-kit attach`). (보류 2026-04-23)
- [ ] Update 롤백 / self-heal — `update.sh` 가 중간에 깨지면 프로젝트가 반쪽 상태로 멈춤. 현재 백업 디렉토리는 완료 후 자동 삭제 (update.sh:155~162). 해법: (1) 업데이트 성공 후 N일 유지 (2) `harness-kit rollback` 명령으로 이전 버전 복구 (3) update 트랜잭션화 — 전체 성공 전까지 새 파일을 스테이징 디렉토리에 놓고 마지막에 atomic swap. 우선순위: 중 (실제로 실패하는 케이스 나타나면 승격). (보류 2026-04-23)
- [ ] 사용량 관찰 / 도그푸딩 루프 — 어떤 슬래시 커맨드가 실제로 쓰이는지, 어떤 hook 에서 실패가 많은지 데이터 없음. 해법: opt-in 로컬 로깅 (`.harness-kit/usage.log` — timestamp + command + exit code) + `harness-kit stats` 요약. 외부 전송 없으므로 privacy 우려 없음. `docs/design/` 의 설계 결정을 실측으로 검증하는 용도. 우선순위: 중 (도그푸딩 규모가 nextmarket-api 외로 확장되면 승격). (보류 2026-04-23)
- [ ] 언어별 스타터 프리셋 — 현재 NestJS 1차 타깃으로 hook (`run-test` 등) 이 고정. Next.js·Python·Go 등에 install 시 언어별 프리셋 자동 선택: `install.sh --preset nestjs|next|python|go`. 해법: `sources/presets/{lang}/` 디렉토리에 언어별 hook·settings 조각 + auto-detect (package.json·pyproject.toml·go.mod 존재 여부). 우선순위: 낮음 (실사용자가 NestJS 외로 요구하면 승격). (보류 2026-04-23)
- [ ] CI 통합 가이드 & 템플릿 — GitHub Actions 에서 SDD 검증 (`doctor`, `plan accept` 여부, 브랜치/커밋 규약 lint) 을 강제할 수 있지만 공식 레시피 없음. 해법: `.github/workflows/harness-kit-check.yml` 예시 + `harness-kit ci-check` 명령 (exit code 로 PR 차단 가능). 우선순위: 낮음 (CI 검증을 요구하는 팀이 생기면 승격). (보류 2026-04-23)

## 📋 대기 Phase

<!-- sdd:queued:start -->
| Phase | 제목 | 상태 | SPECs |
|-------|------|------|-------|
<!-- sdd:queued:end -->

## ✅ 완료

<!-- sdd:done:start -->
| Phase | 제목 | SPECs |
|-------|------|-------|
| [phase-01](phase-01.md) | 설치/운영 마찰 해소 | 2 (Merged) |
| [phase-02](phase-02.md) | 토큰 최적화 & 거버넌스 경량화 | 3 (Merged) |
| [phase-03](phase-03.md) | macOS 네이티브 설치 모드 | 1 (Merged) |
| [phase-04](phase-04.md) | 옵셔널 Sub-agent 리뷰 시스템 | 2 (Merged) |
| [phase-05](phase-05.md) | spec-kit 패턴 도입 & 크로스 에이전트 | 1 (Merged) |
| [phase-06](phase-06.md) | SDD UX 개선 및 커맨드 정리 | 2 (Merged) |
| [phase-07](phase-07.md) | SDD 프로세스 일관성 및 품질 강화 | 4 (Merged) |
- **phase-08** — 작업 관리 모델 재정립 — completed 2026-04-12
- **phase-09** — 설치 충돌 방어 — completed 2026-04-17
- **phase-10** — sdd 상태 진단 신뢰성 강화 — completed 2026-04-16
- **phase-11** — 식별자 체계 개선 및 디렉토리 아카이브 — completed 2026-04-17
- [x] spec-x-sdd-ux-fixes (완료)
- **phase-12** — 프로젝트 확장성 강화 — completed 2026-04-22
<!-- sdd:done:end -->

---

## 📖 사용 방법

| 명령 | 동작 |
|---|---|
| `sdd phase new <slug>` | 새 Phase 생성 → 진행 중으로 등록 |
| `sdd phase new <slug> --base` | Phase base branch 모드로 생성 (opt-in) |
| `sdd spec new <slug>` | 진행 중 Phase에 다음 spec 등록 |
| `sdd plan accept` | spec Plan Accept → 실행 모드 진입 |
| `sdd ship` | spec 완료 처리 → Merged 갱신 + state 초기화 + NEXT 안내 |
| `sdd phase done <N>` | Phase 완료 → 완료 섹션으로 이동 |

자세한 사용법: `agent/constitution.md` §3 Work Type Model, `agent/agent.md`
