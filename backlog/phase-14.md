# phase-14: 설치 · 배포 · 업데이트 재설계 (v1.0)

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-14-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-14` |
| **상태** | Planning |
| **시작일** | 2026-04-23 |
| **목표 종료일** | 2026-05-21 |
| **소유자** | changsik |
| **Base Branch** | 없음 (각 spec 이 main 으로 직접 머지) |
| **마일스톤** | kitVersion `1.0.0` |

## 🎯 배경 및 목표

### 현재 상황

phase-13 까지 harness-kit 은 거버넌스·훅·상태 추적 체계를 완성했다. 그러나 **"어떻게 설치하고, 어떻게 업데이트하며, 어떻게 커스터마이징하는가"** 의 바깥 계층은 여전히 최소 구현 상태다.

실사용 관점에서 점검해보니 다음 네 가지 마찰이 한 덩어리로 묶여 있음을 확인했다:

1. **설치 방법이 `git clone + install.sh` 하나뿐** — 사용자가 키트를 어디에 clone 했는지 기억해야 하고, 업데이트 시 그 경로를 다시 찾아야 함. macOS 1차 타깃임에도 Homebrew 경로가 없음
2. **`update.sh` 가 사용자 수정을 덮어씀** — `uninstall --keep-state` 는 `backlog/`·`specs/`·`state/` 만 보존. 사용자가 `.claude/commands/hk-*.md` 나 hook 을 고쳤다면 조용히 사라짐
3. **사용자 확장 지점이 없음** — 자기 슬래시 커맨드·훅을 추가하려면 `sources/` 혹은 `.claude/commands/` 에 직접 넣어야 하고, 위 (2) 때문에 업데이트마다 사라짐. "키트 소유 vs 사용자 소유" 경계 규약 부재
4. **팀 온보딩 경로 모호** — `.harness-kit/` 가 이미 체크인된 프로젝트를 새 팀원이 `git clone` 했을 때 뭘 실행해야 하는지 불명확. 전역 `sdd` CLI 가 없어서 프로젝트 내부 경로로 호출해야 함

이 네 가지는 개별 버그가 아니라 **"설치·업데이트 경로의 아키텍처 설계가 누락된 상태"** 다. 따로 풀면 규약이 어긋나므로 한 phase 로 묶어 v1.0 마일스톤과 함께 정리한다.

### 목표 (Goal)

1. **설치 UX 표준화**: macOS 는 `brew install`, Linux/CI 는 `curl | bash` 로 한 줄 설치. Windows 는 WSL2 경로로 통일
2. **업데이트 안전성 확보**: 사용자가 수정한 키트 파일은 보존 + 신버전은 `.new` 로 병치. 업데이트 실패 시 롤백 가능
3. **확장 경계 규약 수립**: 사용자 훅/커맨드를 넣을 공식 디렉토리 지정 — 업데이트가 절대 건드리지 않음
4. **팀 합류 UX 정리**: `brew install harness-kit` 후 `harness-kit attach` 한 줄로 기존 프로젝트에 합류
5. **v1.0 릴리스**: 위 4개가 안정된 시점을 기점으로 kitVersion `1.0.0` 선언

### 성공 기준 (Success Criteria) — 정량 우선

1. `brew install dennis/tap/harness-kit` 으로 설치 후 `harness-kit init <dir>` / `harness-kit update <dir>` / `harness-kit attach <dir>` 세 서브커맨드가 모두 동작
2. `curl -fsSL <url>/install.sh | bash` 로 `~/.harness-kit/` 에 키트 설치 + `PATH` 자동 등록 (zsh/bash 양쪽 rc 자동 감지)
3. 사용자가 `.claude/commands/hk-doctor.md` 를 수정한 상태에서 `harness-kit update` 실행 시, 해당 파일은 보존되고 신버전이 `hk-doctor.md.new` 로 병치. 업데이트 결과 리포트에 "보존 1건" 명시
4. `.harness-kit/extensions/{hooks,commands}/` 디렉토리가 install/update 모두에서 절대 건드려지지 않음을 검증하는 테스트 케이스 PASS
5. `harness-kit attach <dir>` 실행 시 이미 설치된 프로젝트의 로컬 bin 을 감지하고 전역 CLI 심볼릭 링크만 연결 (파일 복사 없음). 신규 설치와 구분되는 종료 메시지 출력
6. `update.sh` 가 중간에 실패하는 시나리오에서 `harness-kit rollback` 이 이전 버전으로 복구. 복구 후 `doctor` PASS
7. `sdd version` → `1.0.0`, CHANGELOG 갱신, 전체 테스트 FAIL=0, README 의 설치/업데이트 섹션 전면 개편

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> 자세한 spec/plan/task 는 `specs/spec-14-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-14-01` | extension-boundary | P0 | Backlog | `specs/spec-14-01-extension-boundary/` |
| `spec-14-02` | update-preserve-local | P0 | Backlog | `specs/spec-14-02-update-preserve-local/` |
| `spec-14-03` | update-rollback | P1 | Backlog | `specs/spec-14-03-update-rollback/` |
| `spec-14-04` | homebrew-tap | P0 | Backlog | `specs/spec-14-04-homebrew-tap/` |
| `spec-14-05` | curl-pipe-installer | P0 | Backlog | `specs/spec-14-05-curl-pipe-installer/` |
| `spec-14-06` | team-onboarding-attach | P1 | Backlog | `specs/spec-14-06-team-onboarding-attach/` |
| `spec-14-07` | version-bump-1.0.0 | P2 | Backlog | `specs/spec-14-07-version-bump-1.0.0/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`
> sdd가 ship 시 자동으로 `Merged`로 갱신합니다. `In Progress`는 active spec에 자동 마킹됩니다.

### spec-14-01 — 확장 경계 규약

- **요점**: "키트 소유 vs 사용자 소유" 경계 규약 수립. `.harness-kit/extensions/{hooks,commands}/` 보호 디렉토리 정의
- **방향성**: (1) 디렉토리 규약 추가 — install 시 빈 디렉토리 생성, update 시 `cp -r` 대상에서 완전 제외 (2) `settings.json` 에서 `extensions/hooks/*` 를 자동 병합하는 glob 지원 (3) 사용자 확장 커맨드는 `.claude/commands/user-*.md` 와 `extensions/commands/` 양쪽 중 표준 선택 (4) constitution 에 "확장 경계" 섹션 추가
- **참조**:
  - Icebox: 플러그인 확장 지점 (queue.md:28)
  - Icebox: update 사용자 수정 보존 (queue.md:26)
- **연관 모듈**: `install.sh`, `update.sh`, `uninstall.sh`, `.harness-kit/agent/constitution.md`
- **선행**: 없음. 본 phase 의 토대
- **후속**: spec-14-02 (보존 로직이 이 경계를 전제로 동작)

### spec-14-02 — 업데이트 사용자 수정 보존

- **요점**: `update.sh` 가 사용자 수정 파일을 덮어쓰지 않고 `.new` 로 병치. dpkg conffile 방식 채택
- **방향성**: (1) `installed.json` 에 설치 시점 각 키트 파일의 sha256 기록 (`files: [{path, sha256}]`) (2) update 시 현재 파일 sha 를 설치 시 sha 와 비교 — 다르면 "사용자 수정" 으로 판단하고 원본 유지 + 신버전을 `<path>.new` 로 저장 (3) 업데이트 종료 시 보존된 파일 수 + 경로 리포트 출력 (4) `harness-kit diff-new` 명령으로 `.new` 파일과 원본 비교 도우미
- **참조**: Icebox: update 사용자 수정 보존 (queue.md:26)
- **연관 모듈**: `install.sh`, `update.sh`, `.harness-kit/installed.json` 스키마
- **선행**: spec-14-01 (경계 규약이 먼저 확정돼야 어떤 파일에 sha 를 기록할지 결정 가능)

### spec-14-03 — 업데이트 롤백 / 트랜잭션화

- **요점**: `update.sh` 실패 시 이전 버전으로 복구. 업데이트 트랜잭션화
- **방향성**: (1) 업데이트 시작 시 `.harness-kit/backup-<prev-version>/` 에 전체 스냅샷 (현재는 완료 후 즉시 삭제) (2) 업데이트 성공 후 N일 유지 (기본 7일, `harness.config.json` 설정 가능) (3) `harness-kit rollback` 명령 추가 — 백업 디렉토리 존재 시 현재 상태를 `backup-failed-<ts>/` 로 옮기고 이전 스냅샷 복원 (4) 업데이트 단계별 원자성 확보 — 새 파일을 스테이징 디렉토리에 쓴 뒤 마지막에 atomic rename
- **참조**: Icebox: Update 롤백 / self-heal (queue.md:31)
- **연관 모듈**: `update.sh`, `sources/bin/sdd` (rollback 서브커맨드)

### spec-14-04 — Homebrew tap

- **요점**: `brew install dennis/tap/harness-kit` 지원. macOS 1차 배포 경로
- **방향성**: (1) 별도 레포 `homebrew-tap` 생성 + Formula 작성 (2) Formula 는 GitHub release tarball 을 받아 `~/.harness-kit/` 에 설치, `harness-kit` 실행 파일을 `/usr/local/bin` (Intel) · `/opt/homebrew/bin` (Apple Silicon) 에 symlink (3) GitHub Actions 로 release 시 Formula 자동 갱신 (4) `brew upgrade` 로 키트 버전 갱신 — 단 프로젝트에 설치된 파일 갱신은 `harness-kit update <dir>` 수동 호출
- **참조**: Icebox: 표준 배포 경로 (queue.md:27)
- **연관 모듈**: 신규 레포 `homebrew-tap`, `sources/bin/harness-kit` (신규 글로벌 CLI)

### spec-14-05 — curl-pipe installer

- **요점**: `curl -fsSL <url>/install.sh | bash` 로 글로벌 설치. Linux/CI/Homebrew 미사용자 대응
- **방향성**: (1) `scripts/bootstrap.sh` 신규 — 최신 release tarball 다운로드 → `~/.harness-kit/` 압축 해제 → `PATH` 에 `~/.harness-kit/bin` 자동 추가 (zsh/bash rc 감지) (2) 기존 `install.sh` 는 *프로젝트 설치용* 으로 역할 유지. 두 스크립트 혼동 방지를 위해 글로벌 부트스트랩은 `bootstrap.sh` 로 명명 (3) Windows 는 WSL2/Git Bash 에서 동일 스크립트 재사용 검증 (PowerShell 네이티브는 본 phase 범위 외 — Icebox 유지) (4) GPG 서명 검증은 v1.1 이후로 미룬다 (명시)
- **참조**: Icebox: 표준 배포 경로 (queue.md:27)
- **연관 모듈**: 신규 `scripts/bootstrap.sh`, README

### spec-14-06 — 팀 온보딩 attach 모드

- **요점**: `.harness-kit/` 가 이미 체크인된 프로젝트에 새 팀원이 합류하는 경로 표준화
- **방향성**: (1) `harness-kit attach <dir>` 신규 서브커맨드 — 해당 프로젝트에 `.harness-kit/` 가 존재하면 파일 복사 없이 전역 CLI 심볼릭만 연결 (또는 sheel function 등록) (2) 이미 설치 감지 시 `doctor` 자동 실행해 환경 검증 (3) `harness-kit init` 은 "신규 설치" 전용, `attach` 는 "기존 프로젝트 합류" 전용으로 역할 분리 (4) README 에 "기존 프로젝트 합류" 섹션 추가
- **참조**: Icebox: 팀 온보딩 UX (queue.md:30)
- **연관 모듈**: `sources/bin/harness-kit` (attach 서브커맨드), README

### spec-14-07 — 버전 bump (0.6.0 → 1.0.0)

- **요점**: 본 phase 완료를 반영한 kitVersion 1.0.0 릴리스
- **방향성**: (1) `VERSION`, `installed.json`, `sources/bin/sdd`, `install.sh` 내 버전 상수 일괄 갱신 (2) `CHANGELOG.md` 에 v1.0 섹션 — 배포 경로 신설/업데이트 보존/확장 경계/팀 합류 4개 축 정리 (3) README 전면 개편 — 설치 섹션 첫 줄을 `brew install` 로 교체 (4) 전체 테스트 PASS 확인 후 버전 커밋 + GitHub release 생성
- **참조**: phase-13 의 spec-13-07 방식 참조
- **연관 모듈**: `VERSION`, `install.sh`, `sources/bin/sdd`, `CHANGELOG.md`, `README.md`

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: Homebrew 설치 → 프로젝트 init → update

- **Given**: 깨끗한 macOS 환경
- **When**: `brew install dennis/tap/harness-kit` → `cd my-project && harness-kit init .` → 임의 파일 수정 → `harness-kit update .`
- **Then**: 설치 성공, 프로젝트에 `.harness-kit/` 생성, 수정 파일 보존 + `.new` 병치
- **연관 SPEC**: spec-14-02, spec-14-04

### 시나리오 2: curl-pipe 설치

- **Given**: Homebrew 미사용 Linux 환경 (예: GitHub Actions ubuntu-latest)
- **When**: `curl -fsSL <release-url>/bootstrap.sh | bash` 실행 후 새 셸 열기
- **Then**: `harness-kit --version` 이 정상 출력, `~/.harness-kit/bin` 이 `PATH` 에 포함
- **연관 SPEC**: spec-14-05

### 시나리오 3: 확장 경계 보호

- **Given**: `.harness-kit/extensions/hooks/my-hook.sh` 를 사용자가 추가
- **When**: `harness-kit update .` 실행
- **Then**: `my-hook.sh` 파일이 그대로 존재하고 수정되지 않음 (sha 동일)
- **연관 SPEC**: spec-14-01, spec-14-02

### 시나리오 4: 팀 합류 (attach)

- **Given**: `.harness-kit/` 가 이미 체크인된 프로젝트, 로컬에는 전역 `harness-kit` 미설치
- **When**: `brew install` 후 `harness-kit attach .` 실행
- **Then**: 파일 복사 없이 CLI 심볼릭만 연결, `sdd status` 정상 동작
- **연관 SPEC**: spec-14-06

### 시나리오 5: 업데이트 롤백

- **Given**: `harness-kit update .` 중간에 강제 인터럽트 (SIGINT) 로 실패
- **When**: `harness-kit rollback .` 실행
- **Then**: 이전 버전 상태 복원, `doctor` PASS
- **연관 SPEC**: spec-14-03

### 통합 테스트 실행

```bash
for t in tests/test-phase-14-*.sh; do bash "$t" 2>&1 | tail -1; done
```

## 🔗 의존성

- **선행 phase**: phase-13 (DX 향상으로 `doctor` / `pr-watch` / `run-test` 확보됨 — 본 phase 의 설치/업데이트 검증에 재사용)
- **외부 시스템**:
  - `homebrew-tap` 신규 레포 (별도 레포로 분리)
  - GitHub Actions (release 자동화 + curl-pipe 검증)
- **연관 ADR**: 없음 (v1.0 마일스톤 결정 기록은 본 phase 종료 시 ADR 로 승격 검토)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| Homebrew formula 는 별도 레포 + Anthropic 네임스페이스 이슈 가능 | 배포 차질 | 우선 `dennis/tap` 개인 tap 으로 시작. 공식 `homebrew-core` 승격은 v1.1 이후 |
| curl-pipe 는 `curl \| bash` 자체가 보안 우려 | 사용자 신뢰 저하 | SHA256 체크섬 비교 단계 포함 + GitHub release 페이지에서 수동 검증 경로 안내 |
| 체크섬 매니페스트 방식이 파일 개수에 비례해 install/update 느려짐 | UX 퇴행 | 현재 키트 파일 수가 적어 실측 후 결정. 필요 시 병렬 sha 계산 또는 증분 매니페스트 |
| `.new` 파일 방치 시 사용자가 잊어버림 | 신버전 기능 미사용 | `doctor` 에 `.new` 파일 잔존 감지 추가 + `harness-kit diff-new` 도우미 |
| Windows PowerShell 경로 누락 | 일부 사용자 미지원 | 본 phase 에서는 WSL2 만 공식 지원 선언. PowerShell 은 Icebox 유지 |
| v1.0 선언 후 breaking change 어려움 | 장기 유지보수 부담 | v1.0 은 "설치 인터페이스 안정" 선언. 내부 구조 리팩터링은 계속 가능하도록 constitution 에 명시 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (각 spec → main)
- [ ] 통합 테스트 5 개 시나리오 모두 PASS
- [ ] 성공 기준 7 항목 정량 측정 결과 기록
- [ ] `sdd version` → `1.0.0` 확인
- [ ] README 설치 섹션 전면 개편 완료
- [ ] GitHub release v1.0.0 태깅
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
