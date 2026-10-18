feat(spec-24-03): stop-rules engine + decision log (auto safety)

## 📋 Summary

### 배경 및 목적

`auto` 모드(24-01)는 plumbing 만, blast-radius 가드는 커밋시점 정렬(24-02)됐다. 하지만 ADR-009 가 규정한 auto 의 *사전 안전판* — 정지규칙 ②③ — 과 사람 검토 근거인 결정 로그가 미구현이었다. 본 spec 은 그 **기계적 엔진** 을 만든다.

### 주요 변경 사항
- [x] **②비가역 행동 정지** — `check-irreversible.sh`(PreToolUse Bash): force push·history rewrite·광범위 삭제·외부 publish 를 실행 전 감지. narrow(FP 최소화) + 경고 모드.
- [x] **③반복 실패 정지** — `post-commit-verify.sh` 에 `state.autoFailCount`, N(기본 3)회 연속 실패 시 auto-revert 대신 hard-stop(커밋 보존).
- [x] **결정 로그** — `sdd decision add/list`, active spec walkthrough 에 결정·근거 누적.

### Phase 컨텍스트
- **Phase**: `phase-24` (auto-mode)
- **본 SPEC 의 역할**: auto 의 유일한 사전 안전판(정지규칙)과 사후 검토 근거(결정 로그)를 깔아, 24-04(논블로킹 결정)·24-05(phase-ship 체크포인트)가 올라탈 토대. (성공 기준 #3)

## 🎯 Key Review Points

1. **②감지 경계(narrow)**: FP 최소화를 위해 `git reset --hard`·`--force-with-lease` 등은 *의도적 제외*. 경계는 `test-stop-rules.sh` 가 고정. 경고 모드 시작(1주 후 차단 승격).
2. **③는 auto 전용**: turbo(attended)는 기존 즉시 auto-revert 보존. 카운터/hard-stop 은 `mode=auto` 에서만.
3. **deny 리스트와의 관계**: permissions.deny 와 일부 중복하나, 본 훅은 mode-aware + 결정로그 연동 stop-rule 엔진(walkthrough 발견사항 참조).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-stop-rules.sh
bash tests/test-decision-log.sh
```

**결과 요약**:
- ✅ `test-stop-rules`: 13/13 (② 감지 10 + ③ 카운터 3)
- ✅ `test-decision-log`: 4/4
- ✅ 회귀: turbo-hooks 8/8, mode-auto 6/6, install-settings 7/7
- ✅ 전체 스위트: 70/70

### 수동 검증 시나리오
1. `git push --force` → 비가역 경고 + exit 0 / `git reset --hard` → 무경고(경계 제외)
2. auto 3회 연속 실패 → 3회째 hard-stop + 커밋 보존
3. `sdd decision add` → walkthrough 결정 로그 행 추가, `list` 로 확인

## 📦 Files Changed

### 🆕 New Files
- `sources/hooks/check-irreversible.sh` (+ 미러): ② 정지규칙 훅
- `tests/test-stop-rules.sh` / `tests/test-decision-log.sh`: 신규 테스트

### 🛠 Modified Files
- `sources/hooks/post-commit-verify.sh` (+ 미러): ③ 연속 실패 카운터
- `sources/bin/sdd` (+ 미러): `decision add/list`
- `sources/claude-fragments/settings.json.fragment` / `.claude/settings.json`: 훅 등록

**Total**: 14 files changed (+693, -3)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (신규 17 + 전체 70/70)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint(shellcheck 미설치 — skip) / secret 통과
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-24.md`
- ADR: `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md` (auto 규약 3·4)
