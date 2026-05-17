# spec-x-hk-update-remote: /hk-update 원격 실행 방식으로 전환

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-hk-update-remote` |
| **Phase** | `phase-x` (Solo) |
| **Branch** | `spec-x-hk-update-remote` |
| **상태** | Planning |
| **타입** | Fix (UX) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-13 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
- `/hk-update` 슬래시 커맨드는 갱신 절차로 다음을 안내합니다:
  ```
  bash <kit-dir>/update.sh .
  모르는 경우: git clone <kitOrigin> ~/harness-kit && bash ~/harness-kit/update.sh .
  ```
  (`sources/commands/hk-update.md:80-86`)
- `update.sh`는 자기 자신의 위치(`KIT_DIR`)를 기준으로 동작하므로, **kit 원본 저장소를 로컬에 클론한 디렉토리에서** 실행되어야 합니다 (`update.sh:18`).
- `get.sh`는 이미 `--update` 옵션을 지원합니다 (`get.sh:95-97`). 즉 원격에서 직접 받아 갱신하는 경로가 *기술적으로는 이미 존재*합니다.

### 문제점
- 다른 프로젝트에서 `/hk-update`를 따라 실행하면 "파일을 찾을 수 없음" 오류가 자주 발생합니다. 사용자가:
  1. harness-kit 저장소를 로컬에 클론한 적이 없거나
  2. 클론 경로를 잊었거나
  3. 클론은 있지만 다른 머신/다른 계정의 경로를 가리키는 경우
- 안내 메시지가 *로컬 클론*을 전제로 작성되어 있어, 이 사실을 모르는 사용자는 그대로 막힙니다.
- `install` 은 `bash <(curl ...)` 한 줄로 동작하는데 `update` 만 별도 클론을 요구하는 비대칭이 학습 비용을 키웁니다.

### 해결 방안 (요약)
`/hk-update` 의 갱신 안내를 **원격 curl 1줄** 방식으로 전환합니다.

```
bash <(curl -fsSL https://raw.githubusercontent.com/Changsik00/harness-kit/main/get.sh) --update
```

`get.sh --update`는 내부적으로 최신 main(또는 `--version`)을 받아 `update.sh`를 호출하므로, 로컬 클론이 없어도 동일 결과를 얻습니다. 기존 로컬 클론 경로는 오프라인/개발자용 fallback 으로 짧게만 남깁니다.

## 🎯 요구사항

### Functional Requirements
1. `/hk-update`의 §5 "업데이트 실행" 안내가 **원격 curl 방식을 1차로** 보여줘야 한다.
   - 명령: `bash <(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh) --update`
   - `<owner>/<repo>` 는 `kitOrigin`에서 도출 (기존 §2 로직 재사용)
2. 로컬 클론을 가진 사용자/오프라인 환경을 위해 **fallback 1줄**(`bash <kit-dir>/update.sh .`)을 그대로 남긴다.
3. `--yes` 자동 수락 옵션을 함께 안내한다 (`... --update --yes`).
4. 안내 끝의 "에이전트가 직접 update.sh 를 실행하지 않습니다" 안전 문구는 유지한다.
5. `sdd status`의 kit 버전 안내 문구(`sources/bin/sdd:338`)도 새 권장 명령과 일관되게 갱신한다.
6. `README.md`의 키트 진입점 표(line 318)에 원격 갱신 명령을 같이 명시한다.

### Non-Functional Requirements
1. **에이전트 자동 실행 금지**: `update.sh`(및 원격 변형)는 uninstall→install 재실행이라는 파괴적 작업이므로 사용자가 직접 입력해야 한다. 슬래시 커맨드 안에서 자동 실행하지 않는다.
2. **github.com 한정**: `get.sh` 가 GitHub raw URL을 가정하므로, 비-GitHub origin 은 graceful skip하고 기존 로컬 fallback 만 안내한다 (기존 §2 로직과 동일).
3. **하위 호환**: 기존 로컬 클론을 가진 사용자가 `bash <kit-dir>/update.sh .` 를 계속 쓸 수 있어야 한다 (스크립트 인터페이스 자체는 변경 없음).

## 🚫 Out of Scope

- `update.sh` / `get.sh` 의 인터페이스 변경 — 이미 둘 다 필요한 기능을 갖췄으므로 손대지 않는다.
- 새 슬래시 커맨드 추가, 자동 실행 모드 도입.
- 다른 원격 호스트(Bitbucket, GitLab) 지원 확장.
- 캐시(`lastVersionCheck`, `latestKnownVersion`) 동작 변경.

## ✅ Definition of Done

- [ ] `sources/commands/hk-update.md` §5 가 원격 curl 1차 + 로컬 fallback 형태로 갱신됨
- [ ] `sources/bin/sdd` 의 kit 버전 알림 문구가 새 권장 명령과 일관됨
- [ ] `README.md` 키트 진입점 표에 원격 갱신 명령 명시됨
- [ ] `walkthrough.md`, `pr_description.md` 작성 + ship commit
- [ ] `spec-x-hk-update-remote` 브랜치 push + PR 생성
