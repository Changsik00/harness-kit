# Implementation Plan: spec-13-06

## 📋 Branch Strategy

- 신규 브랜치: `spec-13-06-update-registry`
- 시작 지점: `phase-13-dx-enhancements` (phase base branch)
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `~/.harness-kit-registry.json` 홈 디렉토리 파일 생성 방식 동의 여부
> - [ ] 쓰기 실패 시 install 차단하지 않는 방식 동의 여부

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **저장 위치** | `~/.harness-kit-registry.json` | 중앙 집중, 프로젝트별 분산 아님 |
| **upsert 방식** | path 기준 중복 제거 후 append | jq 없으면 skip |
| **install 실패** | 경고만 (install 차단 안함) | 레지스트리 실패가 핵심 기능 방해 금지 |

## 📂 Proposed Changes

### [install.sh]

#### [MODIFY] `install.sh`
설치 완료 후 레지스트리 갱신:
```bash
# jq 있으면 ~/.harness-kit-registry.json upsert
# 없으면 warn + skip
```

### [CLI]

#### [MODIFY] `sources/bin/sdd`
`update-check` 서브커맨드:
```text
cmd_update_check() {
  # ~/.harness-kit-registry.json 없으면 안내
  # 있으면 각 항목: path, version, installedAt 출력
  # version < kitVersion 이면 ⚠ 표시
}
```

### [테스트]

#### [NEW] `tests/test-update-registry.sh`
1. `sdd update-check` 명령 인식 확인 (알 수 없는 명령 아님)
2. `sdd help`에 `update-check` 포함 확인
3. 레지스트리 없을 때 exit 0 + 안내 메시지 확인
4. 레지스트리 있을 때 프로젝트 목록 출력 확인
5. `sources/bin/sdd` ↔ `.harness-kit/bin/sdd` 동기화 확인

## 🧪 검증 계획

```bash
bash tests/test-update-registry.sh
```

## 🔁 Rollback Plan

- `sdd update-check` case 제거
- `install.sh` 레지스트리 갱신 블록 제거

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
