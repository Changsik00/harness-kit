# docs(spec-21-04): add turbo mode governance docs and /hk-turbo slash command

## 📋 Summary

### 배경 및 목적

spec-21-01~03에서 Turbo 모드 인프라(`sdd mode`, `sdd intent`, 훅 분기, `post-commit-verify`)가 완성됐으나, 거버넌스 문서에 Mode D(Turbo)가 없어 새 세션마다 Claude가 Turbo 모드를 인식하지 못했다. `/hk-turbo` 슬래시 커맨드도 없어 사용자가 명시적으로 `sdd mode turbo` 명령어를 알아야만 전환할 수 있었다.

### 주요 변경 사항
- [x] `constitution.md §2.5` Mode D (Turbo) 조항 추가 — 활성화 방법, 동작, 적용 범위 명시
- [x] `constitution.md §2.4` Decision Tree에 Step 0 (Turbo 선체크) 삽입
- [x] `agent.md §3.1` Work Type Behavior Table에 Turbo 행 추가
- [x] `.claude/commands/hk-turbo.md` 신규 생성 — 현재 모드 확인 + toggle 안내
- [x] `sources/governance/`, `sources/commands/` 동일 변경 미러링

### Phase 컨텍스트
- **Phase**: `phase-21` (Turbo 모드 추가)
- **본 SPEC 의 역할**: 인프라(spec-21-01~03) 완성 후 Claude 자신이 새 세션에서 Turbo 모드를 인식하고 올바르게 행동할 수 있도록 거버넌스 문서화

## 🎯 Key Review Points

1. **§2.5 vs §2.4 번호 역전**: Mode 목록(§2.1~2.3) 끝에 §2.5를 추가하고 Decision Tree는 §2.4 그대로 유지 — 번호 역전이 발생하나 기존 §2.4 참조 링크 보존 우선
2. **Decision Tree Step 0**: Turbo가 활성이면 Steps 1-2(PR/Phase 판단) 전체를 스킵 — Turbo는 Mode C처럼 절차 단축이 아닌 별도 모드
3. **`/hk-turbo` toggle 방식**: 단방향 활성화가 아닌 현재 모드 확인 후 역전환 — 사용자가 현재 상태를 몰라도 올바른 방향으로 안내

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-governance-update.sh
bash tests/test-turbo-hooks.sh
```

**결과 요약**:
- ✅ `test-governance-update.sh`: 6/6 PASS
- ✅ `test-turbo-hooks.sh`: 8/8 PASS (회귀 없음)

### 수동 검증 시나리오
1. **시나리오 1**: `grep "2.5 Mode D" .harness-kit/agent/constitution.md` → `### 2.5 Mode D — Turbo` 출력
2. **시나리오 2**: `grep "Turbo" .harness-kit/agent/agent.md` → §3.1 테이블 Turbo 행 출력

## 📦 Files Changed

### 🆕 New Files
- `tests/test-governance-update.sh`: 거버넌스 업데이트 검증 테스트 (6 케이스)
- `.claude/commands/hk-turbo.md`: `/hk-turbo` 슬래시 커맨드
- `sources/commands/hk-turbo.md`: 위 파일 미러

### 🛠 Modified Files
- `.harness-kit/agent/constitution.md` (+18): §2.5 Mode D + §2.4 Step 0 추가
- `.harness-kit/agent/agent.md` (+1): §3.1 Turbo 행 추가
- `sources/governance/constitution.md` (+18): 동일 미러
- `sources/governance/agent.md` (+1): 동일 미러

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (6/6)
- [x] 회귀 테스트 통과 (8/8)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-21.md`
- Walkthrough: `specs/spec-21-04-governance-update/walkthrough.md`
- 선행 spec: `specs/spec-21-01-mode-schema/`, `specs/spec-21-02-turbo-hooks/`, `specs/spec-21-03-intent-block/`
