# Implementation Plan: spec-11-003

## 📋 Branch Strategy

- 신규 브랜치: `spec-11-003-dir-archive`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `sdd archive` 이름 재사용: spec-11-001에서 deprecated 경로로 유지 중인 `sdd archive`를 완전히 교체. 기존 deprecated 동작(= `sdd ship`) 대신 새 디렉토리 아카이브 동작으로 변경
> - [ ] 기본 keep=0: active phase 이외 모든 완료 항목 이동. 보수적이려면 keep=1 권장

> [!WARNING]
> - [ ] 대량 `git mv` 발생 — PR에서 rename detection 확인 필요

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **명령 이름** | `sdd archive` (재사용) | spec-11-001에서 deprecated → ship으로 이관 완료. "archive"가 디렉토리 이동의 자연스러운 이름 |
| **레이아웃** | `archive/specs/`, `archive/backlog/` | 원본 구조 미러링으로 직관적 |
| **이동 단위** | phase 단위 (해당 phase의 모든 spec + backlog 파일) | spec 단위 이동은 phase.md와 불일치 발생 |
| **align 제안** | `sdd status` 진단 + align.md 문서 | status에서 자동 감지, align에서 사용자에게 제안 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd`

1. **`cmd_archive()` 교체**: 기존 deprecated 위임 코드 → 새 디렉토리 아카이브 구현
   - queue.md의 done 섹션에서 완료 phase 목록 파싱
   - active phase, `--keep=N` 옵션으로 유지할 phase 제외
   - 대상 spec 디렉토리 + backlog 파일을 `git mv`로 `archive/`에 이동
   - `--dry-run`: 이동 대상만 출력
   - spec-x 디렉토리는 항상 제외

2. **dispatch 업데이트**: `archive)` 케이스에서 deprecated 경고 제거, 새 `cmd_archive` 호출

3. **help 텍스트 갱신**: `archive` 항목을 새 설명으로 교체

4. **status 진단**: `specs/` 디렉토리 수 20개 이상 시 아카이브 제안 진단 메시지 추가

#### [MODIFY] `.harness-kit/bin/sdd`
도그푸딩 동기화

### 거버넌스

#### [MODIFY] `sources/governance/align.md`
아카이브 제안 단계 추가 (§2 컨텍스트 점검 이후):
```
sdd status 출력에 아카이브 제안이 포함되어 있으면,
상태 보고에 포함하여 사용자에게 "완료 항목이 많습니다. sdd archive로 정리하시겠습니까?" 표시
```

#### [MODIFY] `.harness-kit/agent/align.md`
도그푸딩 동기화

### 테스트

#### [NEW] `tests/test-sdd-dir-archive.sh`
- Check 1: `sdd archive --dry-run` — 대상 목록만 출력, 파일 이동 없음
- Check 2: `sdd archive` — 완료 phase의 spec/backlog가 `archive/`로 이동
- Check 3: active phase의 spec은 이동되지 않음
- Check 4: spec-x 디렉토리는 이동되지 않음
- Check 5: `--keep=1` — 최근 1개 완료 phase 유지
- Check 6: `sdd status` — 20개+ 디렉토리 시 아카이브 제안 표시

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-dir-archive.sh
bash tests/test-sdd-ship-completion.sh
```

### 수동 검증 시나리오
1. `sdd archive --dry-run` — 이동 대상 목록 확인
2. `sdd archive` — 실행 후 `ls specs/`, `ls archive/specs/` 확인
3. `sdd status` — 아카이브 제안 메시지 확인

## 🔁 Rollback Plan

- `git revert` 단일 커밋으로 롤백 가능
- 아카이브된 파일은 `archive/` 에서 `git mv`로 복원 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship commit
