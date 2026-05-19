# spec-x-rootdir-device-fix: rootDir 절대경로 다중 디바이스 크리티컬섹션 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-rootdir-device-fix` |
| **Phase** | `phase-x` |
| **Branch** | `spec-x-rootdir-device-fix` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-19 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`는 설치 시점의 절대경로(`TARGET`)를 `harness.config.json`의 `rootDir` 필드로 기록한다.

```json
{ "rootDir": "/Users/dennis/Project/ck/service-foundry" }
```

`sdd_find_root()` (`sources/bin/lib/common.sh`)는 이 값을 **우선** 사용해 프로젝트 루트를 결정한다.

```bash
root=$(jq -r '.rootDir // empty' "$d/.harness-kit/harness.config.json")
if [ -n "$root" ] && [ -d "$root" ]; then
  echo "$root"; return 0   # ← 절대경로가 유효하면 여기서 확정
fi
```

### 문제점

`harness.config.json`이 git 추적 상태(`.gitignore` 미제외)일 때 `rootDir`의 절대경로가 커밋된다. 다른 디바이스/사용자가 clone하면:

- 경로가 해당 머신에 **우연히 존재**하면 → 엉뚱한 디렉토리를 프로젝트 루트로 잡음 (사일런트 오작동)
- 경로가 존재하지 않으면 → fallback 작동하지만 설계 의도와 다른 경로로 진행될 수 있음

동일 머신에서 프로젝트를 이동해도 동일 문제 발생. 팀 환경에서 크리티컬섹션.

### 해결 방안 (요약)

`sdd_find_root()`가 `rootDir` 필드에 의존하지 않도록 변경한다. `.harness-kit/harness.config.json` 또는 `.harness-kit/installed.json`이 **존재하는 디렉토리 자체**를 루트로 삼는 파일시스템 앵커링 방식으로 전환하고, `install.sh`도 `harness.config.json`에 `rootDir`를 기록하지 않도록 수정한다.

## 🎯 요구사항

### Functional Requirements

1. `sdd_find_root()`는 `rootDir` 필드 값에 관계없이 `.harness-kit/` 디렉토리가 위치한 곳을 루트로 반환해야 한다.
2. 기존 설치본에 `rootDir` 필드가 남아 있어도 `sdd` CLI가 정상 동작해야 한다 (하위 호환).
3. 신규 `install.sh` 실행 시 `harness.config.json`에 `rootDir`를 기록하지 않는다.
4. `backlogDir`, `specsDir`, `gitignore` 필드는 기존과 동일하게 동작한다.
5. `tests/test-path-config.sh`의 `rootDir` 검증 항목이 새 동작에 맞게 수정된다.

### Non-Functional Requirements

1. bash 3.2+ 호환 유지 (macOS 기본 환경).
2. 잘못된 `rootDir`가 기록된 기존 설치본에서도 `sdd status`가 올바른 루트를 출력한다.

## 🚫 Out of Scope

- 기존 설치본의 `harness.config.json`에서 `rootDir` 필드 자동 제거 (마이그레이션 — `update.sh` 별도 작업)
- `rootDir`를 직접 참조하는 사용자 커스텀 스크립트 대응

## 📑 ADR 후보 (Architecture Decision Records)

> 본 SPEC 의 결정 중 *장기 자산* 으로 박을 가치 있는 것이 있는가? (constitution §6.3 ADR 정의)
> 비강제 — 미체크여도 ship 차단 없음.

- [x] ADR 가치 있는 결정 있음 → 후보 한 줄 요약: `sdd-root-detection-anchor` (type: decision) — 절대경로 저장 대신 파일시스템 앵커링으로 루트 탐지 전략 교체

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-path-config.sh`, `tests/test-sdd-root-detection.sh`)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-rootdir-device-fix` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
