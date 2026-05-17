# Implementation Plan: spec-x-hk-update-remote

## 📋 Branch Strategy

- 브랜치: `spec-x-hk-update-remote` (이미 생성 완료, `main` 기준)
- 별도 phase 없음 — Solo Spec

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 원격 curl 방식이 1차 안내, 로컬 클론은 fallback 으로 강등하는 정책에 동의
> - [ ] 비-GitHub origin 은 기존처럼 로컬 fallback 만 안내 (graceful skip) 정책 유지

> [!WARNING]
> - 사용자가 이미 `git clone ~/harness-kit` 을 유지하는 흐름에 익숙해져 있을 수 있으므로, fallback 1줄은 반드시 남긴다.
> - `get.sh` 가 매번 main zip 을 받아오므로, 사용자가 `--version <ver>` 핀을 원할 수 있다 — 안내에 같이 노출한다.

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
사용자 (다른 프로젝트의 CWD)
   │ /hk-update 실행
   ▼
에이전트가 hk-update.md 절차 따라:
   1. installed.json 에서 kitOrigin / kitVersion 읽기
   2. raw version.json 으로 최신 버전 조회
   3. 업데이트 가능 시 정보 블록 + [Y/n]
   4. 승인 시 ▼
   ┌──────────────────────────────────────────────┐
   │ 권장: bash <(curl ... get.sh) --update       │ ← (변경 핵심)
   │ Fallback: bash <kit-dir>/update.sh .         │
   └──────────────────────────────────────────────┘
       ↓ (사용자가 직접 실행)
   get.sh 가 main.zip 다운로드 → 내부 update.sh 호출
```

### 주요 결정

| 항목 | 전략 | 이유 |
|:---|:---|:---|
| **1차 안내** | `bash <(curl ... get.sh) --update` | 로컬 클론 없는 사용자도 즉시 동작. install 과 인터페이스 일치 |
| **2차(Fallback)** | `bash <kit-dir>/update.sh .` | 오프라인 / 개발 중 클론 보유자용. 호환성 유지 |
| **비-GitHub** | 원격 안내 생략, 로컬 fallback 만 표시 | `get.sh` 가 GitHub raw 가정 |
| **owner/repo 도출** | 기존 §2 로직 재사용 (`sed 's\|git@github.com:\|\|; s\|https://github.com/\|\|; s\|\.git$\|\|'`) | 추가 코드 없이 일관 |
| **자동 실행 금지** | 슬래시 커맨드는 안내만, 사용자가 직접 입력 | 파괴적 작업 보호 (기존 §90 안전 원칙 유지) |

## 📂 Proposed Changes

### A. /hk-update 슬래시 커맨드 안내 본문

#### [MODIFY] `sources/commands/hk-update.md`

§5 "업데이트 실행" 섹션을 다음과 같이 교체:

```markdown
### 5. 업데이트 실행

승인 시, kitOrigin 에서 `owner/repo` 를 도출해 권장 명령을 출력합니다.

**1차 (권장) — 원격 직접 실행 (로컬 클론 불필요)**:

  bash <(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh) --update

자동 수락:    ... --update --yes
특정 버전 핀: bash <(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh) --version <ver> --update

**2차 (Fallback) — 로컬 클론 보유 / 오프라인**:

  bash <kit-dir>/update.sh .

  # <kit-dir> 를 모르면: git clone <kitOrigin> ~/harness-kit && bash ~/harness-kit/update.sh .

비-GitHub 저장소(`kitOrigin` 이 github.com 이 아닌 경우)는 1차 안내를 생략하고 2차만 출력합니다.

> **에이전트가 직접 실행하지 않습니다** — 사용자가 직접 입력해야 합니다.
> (update.sh 는 uninstall → install 재실행으로 파일을 교체하는 파괴적 작업)
```

근거 스니펫(참고용, 코드 변경 아님):

```bash
# get.sh 가 --update 를 이미 지원함 (get.sh:95-97)
elif [ "$UPDATE" -eq 1 ]; then
  bash "$KIT_DIR/update.sh" "$TARGET_DIR" $YES_FLAG
```

### B. sdd status 의 kit 업데이트 알림 문구 일관화

#### [MODIFY] `sources/bin/sdd`

라인 338:

기존:
```bash
printf "  ${C_YLW}kit: %s 사용 가능 (현재 %s) — /hk-update 또는 update.sh${C_RST}\n" ...
```

변경:
```bash
printf "  ${C_YLW}kit: %s 사용 가능 (현재 %s) — /hk-update${C_RST}\n" ...
```

이유: 새 정책에서는 사용자가 직접 `update.sh` 를 호출하는 것이 *fallback* 이고 1차 권장이 아님. `sdd status` 라인이 짧아지고, 진입점이 `/hk-update` 하나로 깔끔해진다. 상세 명령은 `/hk-update` 가 알아서 안내한다.

### C. README 키트 진입점 표 보완

#### [MODIFY] `README.md` (line ~317-318)

기존:
```markdown
| `install.sh [TARGET]` | 설치 ... |
| `update.sh [TARGET]` | 키트 갱신 (state 보존) |
```

변경:
```markdown
| `install.sh [TARGET]` | 설치 ... |
| `update.sh [TARGET]` | 키트 갱신 (state 보존, 로컬 clone 보유 시) |
| `bash <(curl ... get.sh) --update` | 원격 갱신 (로컬 clone 불필요, 권장) |
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
본 spec 은 문서 변경만 포함하므로 자동 단위 테스트 없음. 대신 다음 정적 점검을 수행:

```bash
# 1. hk-update.md 의 새 명령 라인 존재 확인
grep -q 'curl -fsSL .* get.sh) --update' sources/commands/hk-update.md

# 2. 로컬 fallback 라인이 여전히 존재 (하위 호환)
grep -q 'bash <kit-dir>/update.sh' sources/commands/hk-update.md

# 3. sdd status 알림 라인 갱신
grep -q '/hk-update' sources/bin/sdd

# 4. README 표에 원격 갱신 명령 라인 추가됨
grep -q 'curl .* get.sh) --update' README.md
```

### 수동 검증 시나리오
1. `/hk-update` 슬래시 커맨드 본문(`sources/commands/hk-update.md`)을 처음부터 끝까지 읽었을 때, 안내가 **원격 curl 1줄 → 로컬 fallback** 순서로 자연스럽게 흐르는지 확인.
2. `bash get.sh --update --help` 를 실제로 호출했을 때 의도된 분기(`get.sh:95`)로 들어가는지 (코드 변경 없으므로 회귀 없음 확인).
3. README 표가 한 화면 안에서 두 경로(로컬/원격)의 차이를 분명히 보여주는지.

## 🔁 Rollback Plan

- 문서 3개(`hk-update.md`, `sdd`, `README.md`)만 변경되므로 `git revert <commit>` 한 번으로 즉시 복구 가능.
- 사용자가 이미 새 안내대로 원격 명령을 외워 쓰고 있더라도, `get.sh --update` 는 별도 변경이 없으므로 계속 동작.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
