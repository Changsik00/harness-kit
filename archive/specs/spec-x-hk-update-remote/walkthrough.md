# Walkthrough: spec-x-hk-update-remote

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| `/hk-update` 가 다른 프로젝트에서 "파일을 찾을 수 없음" 에러 발생 | (A) 안내 메시지만 원격 curl 1차로 교체 / (B) `update.sh` 자체에 자동 자기-fetch 모드 추가 | (A) | `get.sh --update` 가 이미 동일 기능을 제공 (`get.sh:95-97`). 추가 코드 없이 안내만 정렬하면 됨. (B) 는 파괴적 작업의 안전 표면을 키워 reject. |
| 비-GitHub origin (`kitOrigin`) 처리 | (A) 원격 안내 생략 + 로컬 fallback 만 / (B) 강제로 raw URL 추정 | (A) | `get.sh` 가 GitHub raw URL 을 가정하므로 추측이 빗나가면 무의미한 에러 출력. graceful skip 이 자연. |
| 로컬 클론 사용자 흐름 | (A) 완전 제거 / (B) 2차 fallback 으로 유지 | (B) | 개발자/오프라인 환경 보호. 또한 사용자가 이미 외운 명령을 깨뜨리지 않음. |

## 💬 사용자 협의

- **주제**: 다른 프로젝트에서 `/hk-update` 가 "파일을 찾을 수 없음" 으로 실패하는 원인 진단
  - **사용자 의견**: `bash <(curl ... get.sh)` 형식으로 원격에서 바로 받아 갱신하면 어떻겠냐는 제안
  - **합의**: `/hk-update` 의 §5 안내를 원격 curl 1차 + 로컬 fallback 2차 형태로 전환. `get.sh` 의 `--update` 분기가 이미 존재하므로 안내만 바꿔도 충분하다는 점을 함께 확인.

## 🧪 검증 결과

### 1. 자동화 테스트

본 spec 은 문서 변경만 포함하므로 자동 단위 테스트 없음. 대신 정적 grep 점검으로 대체:

- **명령**: `grep -qF 'get.sh) --update' sources/commands/hk-update.md` → ✅ PASS
- **명령**: `grep -qF 'bash <kit-dir>/update.sh' sources/commands/hk-update.md` → ✅ PASS (fallback 보존)
- **명령**: `grep -n '/hk-update' sources/bin/sdd` → ✅ line 338 갱신 확인
- **명령**: `grep -qF 'curl ... get.sh) --update' README.md` → ✅ PASS

### 2. 수동 검증

1. **Action**: `sources/commands/hk-update.md` §5 본문을 처음부터 끝까지 읽어 흐름 확인
   - **Result**: 원격 1차 → fallback 2차 → 비-GitHub graceful skip → 안전 문구 순서가 자연스럽게 이어짐.
2. **Action**: `get.sh:95-97` 의 `--update` 분기 재확인 (코드 변경 없음 — 회귀 위험 0)
   - **Result**: 동일하게 `bash "$KIT_DIR/update.sh" "$TARGET_DIR" $YES_FLAG` 호출. 안내만 정렬된 상태로 정합.

## 🔍 발견 사항

- 처음 `grep -E 'curl -fsSL .* get\.sh\)'` 패턴이 매칭 실패. 라인은 존재하나 grep regex 가 `<owner>` 같은 메타 문자 + `)` 이스케이핑 조합에서 예상과 다르게 동작. **검증용 grep 은 가능하면 `-F` 고정 문자열을 쓰는 게 안전**. task.md 의 검증 명령을 `-qF` 로 다시 적었다.
- `update.sh` 자체는 손대지 않았지만, `get.sh --update` 가 매번 main zip 을 받아오므로 사용자가 특정 버전을 핀하고 싶을 때 `--version <ver>` 를 노출해줘야 자연스럽다 — 안내에 명시.
- 사용자의 원래 에러 메시지("파일을 찾을 수 없음")는 `update.sh` 를 PATH 에 없는 단독 명령으로 입력했거나, kit 디렉토리 경로가 더 이상 존재하지 않는 머신에서 실행했을 때의 전형적 증상. 원격 안내로 전환하면 *kit 디렉토리 존재 가정* 자체가 사라져 해당 에러 클래스가 제거된다.

## 🚧 이월 항목

- 없음.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-13 |
| **최종 commit** | ship 후 갱신 |
