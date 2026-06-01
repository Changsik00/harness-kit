# Spec Critique: spec-x-notify-channels

> 독립 Opus 서브에이전트 비판 (Plan Accept 전). 메인 에이전트가 사용자와 함께 반영 항목 선택.

## 1. 유사 기법 조사

### 발견된 패턴/도구
- **dpkg conffile 처리**: dpkg 는 마지막 설치본의 체크섬을 보관하고, 업그레이드 시 사용자 수정 여부를 판별해 수정됐으면 덮어쓰지 않거나 `.dpkg-dist` 로 신버전을 따로 둡니다. — 현재 spec과의 비교: 본 spec 은 "런처는 무조건 덮어쓰기 / `.env.*` 는 무조건 보존" 이라는 **이분법**. dpkg 식 체크섬 비교는 YAGNI (런처=키트 관리 / `.env.*`=순수 사용자 시크릿으로 카테고리가 명확). 교훈은 "덮어쓸 때 최소한 알려라".
- **`.env.example` 컨벤션**: 변수명만 담은 placeholder 커밋 + 실제 `.env` 는 gitignore + 사용자가 복사 후 채움. — 현재 spec 이 정확히 이 컨벤션 준수. 채널별 분리 + 이중 확장자(`.env.telegram.example`)는 헬퍼가 `.env.telegram` 을 직접 source 하는 기존 구조와 정합하므로 정당.
- **cookiecutter `skip_if_file_exists`**: 본 spec 의 "실제 `.env.*` 불간섭" = skip-if-exists 의 가장 강한 형태(아예 생성 안 함). 안전 면에서 최선.
- **scaffolding CLI 의 `.env.example` 관례**: 시크릿 비우고 변수명만 노출 + "복사 후 채우라" 안내. — 본 spec 은 활성화 안내가 약함 (§2 누락 참조).

### 시사점
- 업계 표준(`.env.example` + gitignore + 절대 커밋 금지)과 본 spec 의 시크릿 안전 불변식 완전 일치. 방향 건전.
- dpkg 교훈: 런처 덮어쓰기를 install 로그에 한 줄 남기는 보강 권장.

## 2. 요구사항 비판

### 누락
- **gitignore 정리 비대칭 (실질 버그)**: install.sh §16 `# harness-kit` 블록에 `.env.telegram`/`.env.discord` 를 추가하면, uninstall.sh §7 정리 awk 가 `skip=2` 로 **딱 2줄(`.claude/state/`, `.harness-backup-*/`)만** 소비하도록 하드코딩돼 있어 `.env.*` 라인을 제거 못 함. `update.sh` = uninstall→install 이므로 **업데이트마다 라인 중복 누적**. uninstall.sh §7 awk 동반 수정 필요 (또는 gitignore 자동 관리 제거).
- **installed.json 매니페스트에 루트 파일 미기록**: uninstall 은 `installedCommands` 처럼 기록된 명단으로 정확 제거하는 패턴인데, 루트 4파일은 하드코딩 리스트로 제거됨. `sources/root/` 파일 추가/이름변경 시 drift. 최소한 "하드코딩 제거 — 명단 기록 비채택(4개 고정)" 결정 명시.
- **실행권한 / dry-run 표시**: `chmod +x` 가 dry-run 출력에 표시되는지 미명시. hook 복사처럼 `do_run "chmod +x ..."` 패턴이면 OK 이나 명시 권장.
- **`.example`↔헬퍼 키 동기화 drift**: `.env.telegram.example` 키가 notify-telegram.sh 가 읽는 변수명과 정확히 일치해야 하나 강제·검증 요구사항 없음. DoD 에 "키 일치" 추가 권장.
- **런처 무동작 위험**: `claude --channels plugin:telegram@...` 플러그인 미설치 시 런처 깔려도 무동작 — Out of Scope 이나 walkthrough 에 명기 권장.
- **CRLF/LF**: Windows 작업 환경에서 `sources/root/*.sh` 가 CRLF 로 커밋되면 macOS/Linux 에서 `bash\r` shebang 오류. `.gitattributes` (`*.sh text eol=lf`) 확인이 DoD 에 없음.

### 모순
- 해당 없음. (gitignore 비대칭은 모순이 아니라 구현 미고려 누락으로 분류.)

### 과잉 설계
- **gitignore 자동 관리 (FR5)**: 재검토 대상. (1) 사용자가 `.env.telegram` 만드는 시점은 install 한참 후. (2) uninstall 비대칭 버그를 떠안음. (3) 다수 프로젝트가 이미 `.env*` gitignore 보유 → 중복. → `.example` 내부 주석으로 대체하면 복잡도+버그 동시 제거. (단 능동 방어 유지하려면 자동 관리 + uninstall 짝맞춤.)
- **`sources/CLAUDE.md` 문서 갱신**: 과잉 아님. 다만 "사용자 활성화 안내" 에 문서 예산 쓰는 게 더 가치 있음.

### 모호함
- **"일반판으로 정규화"**: 무엇을 제거/유지하는지 기준 모호. 플러그인 버전 핀(`@claude-plugins-official`) 처리 불명확. 정규화 규칙 2~3 불릿 명시 권장.
- **§4 설치 계획 출력 갱신 누락**: install.sh dry-run "생성할 파일" 요약에 루트 파일이 안 잡힘. do_cp 출력만으로 부족.
- **"멱등 추가(gitignore)" 의미 모호**: install 단독 멱등인지 update 사이클 멱등인지 불명확 (위 누락과 직결).

## 3. 대안 제안

### 대안 A: 런처를 `.harness-kit/bin/` 에 두고 sdd 서브커맨드로 통합
- **아이디어**: `sources/root/` 신설 없이 런처를 bin glob 복사에 흡수, `.env.*` 만 루트 컨벤션 유지.
- **장점**: 새 "루트 복사" 카테고리 불필요. uninstall 이 `.harness-kit/` 통째 제거로 자동 정리. 시점 혼란 감소.
- **단점**: 루트 `./telegram.sh` 실행 UX 상실. nextmarket-api 기존 습관과 불일치.

### 대안 B: gitignore 자동 관리 제거 + `.example` 주석으로 대체
- **아이디어**: FR5 삭제. `.env.telegram.example` 첫 줄에 "복사 후 토큰 입력, .gitignore 추가, 커밋 금지" 주석.
- **장점**: uninstall 비대칭 버그 소멸. install/uninstall 변경 최소. 경고를 파일 안에 둬 정확한 시점 전달.
- **단점**: 사용자가 gitignore 추가 깜빡 시 커밋 위험 사용자 손에 남음. 능동 방어 약화.

### 대안 C: 현재 spec 유지 + uninstall gitignore 정리 awk 동반 수정 (최소 보강)
- **아이디어**: 현 접근 유지 + uninstall.sh §7 awk 가 `.env.*` 도 제거하도록 수정 + DoD 에 "update 2회 후 gitignore 비중복" 검증 추가.
- **장점**: 루트 런처 UX + 능동 커밋 방어 모두 유지. 변경 한 함수 국한.
- **단점**: `skip=2` 하드코딩 패턴이 더 fragile — gitignore 항목 변경 시 양쪽 짝맞춤 결합도 증가.

## 권장안
**대안 C (현재 spec 유지 + uninstall gitignore 정리 동반 수정)** 권장. 단 **FR5 gitignore 자동 관리가 정말 필요한지 사용자에게 한 번 더 확인** (부담스러우면 대안 B 강등이 차선 — plan.md User Review 항목화). 추가로 CRLF/LF(`.gitattributes`)와 `.example`↔헬퍼 키 동기화는 DoD 에 흡수 시 안전 이득 큼.

## 4. ADR 후보 추출
- [x] **후보 발견**: `kit-root-install-secret-safety` — type: `invariant` — "키트는 실제 시크릿을 보유·배포·덮어쓰지 않고 `.example` 만 관리". cross-spec / long-lived, 향후 채널 추가에도 적용될 키트 전반 불변식. spec 본문에 이미 동일 slug 후보 존재, "ship 시점 승격 재판단(비강제)" 방침에 동의.
- [ ] (참고) `kit-root-install-mechanism` (type: `convention`) 도 가능하나 사용처가 알림 하나뿐이라 invariant 후보에 흡수로 충분.

## 출처
- Debian conffile 처리 (Raphaël Hertzog) / DpkgConffileHandling - Debian Wiki
- Best Practices for Environment Variables Secrets Management (GitGuardian)
- .env Files and the Art of Not Committing Secrets (OpenReplay)
- cookiecutter Hooks 문서
