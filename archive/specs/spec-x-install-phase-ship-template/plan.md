# Implementation Plan: spec-x-install-phase-ship-template

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-install-phase-ship-template`
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **scope 한정**: install.sh 1줄 fix + 테스트 1개 추가. 템플릿 복사 로직 리팩토링은 out-of-scope (별 spec).

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **install.sh 수정** | 하드코딩 리스트에 `phase-ship.md` 추가 | 1줄 변경, 즉시 정정. 디렉토리 sync 방식 리팩토링은 별 spec |
| **테스트 위치** | `tests/test-install-layout.sh` 에 통합 | 기존 픽스처 재사용. install 직후 검증 위치로 응집도 ↑ |
| **테스트 방식** | 8개 파일 명시적 리스트 검증 | "디렉토리 내용 일치" 같은 동적 비교는 향후 `--minimal` 옵션 등으로 깨질 위험. 8개 명시가 정합성 ↑ |

## 📂 Proposed Changes

### 1. install.sh

#### [MODIFY] `install.sh` (line 262)

```diff
-for f in queue.md phase.md spec.md plan.md task.md walkthrough.md pr_description.md; do
+for f in queue.md phase.md phase-ship.md spec.md plan.md task.md walkthrough.md pr_description.md; do
   do_cp "$KIT_DIR/sources/templates/$f" "$TARGET/.harness-kit/agent/templates/$f"
 done
```

### 2. tests/test-install-layout.sh

#### [MODIFY] `tests/test-install-layout.sh`

신규 검증 블록 추가 — install 직후 fixture 디렉토리에 8개 템플릿 모두 존재 확인:

```bash
echo "▶ Check N: 8개 템플릿 모두 존재"
for f in queue.md phase.md phase-ship.md spec.md plan.md task.md walkthrough.md pr_description.md; do
  check
  if [ -f "$FIXTURE_DIR/.harness-kit/agent/templates/$f" ]; then
    pass "templates/$f 존재"
  else
    fail "templates/$f 없음"
  fi
done
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-install-layout.sh
bash tests/test-update.sh   # install 동작에 의존하므로 회귀 확인
```

### 회귀 sweep (Ship 직전)

```bash
for t in tests/test-*.sh; do bash "$t" || echo "FAIL: $t"; done
```

## 🔁 Rollback Plan

- `git revert <commit>` — 1줄 변경이라 위험 zero. 기존 install 받은 사용자도 영향 없음 (순수 추가).

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
