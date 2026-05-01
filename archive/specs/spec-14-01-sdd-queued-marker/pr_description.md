# fix(spec-14-01): remove dead sdd:queued marker from queue templates

## 📋 Summary

### 배경 및 목적

`backlog/queue.md` 의 "📋 대기 Phase" 섹션에는 `<!-- sdd:queued:start ~ end -->` 마커가 정의되어 있고, 상단 안내문은 sdd 가 마커 사이를 자동 갱신한다고 명시한다. 그러나 **`sdd` 바이너리에는 `queued` 마커를 R/W 하는 코드가 0건** — 한 번 채워진 표는 영구 stale 이고 안내문은 거짓 정보가 된다 (Bug #01).

본 PR 은 두 옵션 (구현 vs 제거) 의 trade-off 를 분석한 뒤 **Option B (제거)** 를 채택. queued 섹션을 Icebox 와 동일한 "사람이 직접 편집" 정책으로 통일했다.

### 주요 변경 사항

- [x] `sources/templates/queue.md` 와 `.harness-kit/agent/templates/queue.md` 에서 `sdd:queued` 마커 + 표 헤더 제거
- [x] queue.md 상단 안내문을 "자동 갱신 마커 (`active`/`specx`/`done`) vs 사람 편집 섹션 (`Icebox`/`대기 Phase`)" 로 분리 표현
- [x] "📋 대기 Phase" 섹션 본문에 사람 편집 안내문 추가 (Icebox 톤 통일)
- [x] 본 프로젝트 `backlog/queue.md` 에도 동일 변경 (도그푸딩)
- [x] 회귀 테스트 `tests/test-sdd-queued-marker-removed.sh` 추가 — 마커 부활 시 즉시 감지
- [x] phase-14 (정합성/멱등성 버그 일괄 수정) 정의 + 본 PR 의 근거 자료 (`docs/harness-kit-bug-01-...md`) 포함

### Phase 컨텍스트

- **Phase**: `phase-14` — 정합성 / 멱등성 버그 일괄 수정 (4 spec 중 첫 번째)
- **본 SPEC 의 역할**: dead marker 제거로 안내문/현실 일관성 회복 → 사용자/에이전트가 잘못된 가정을 갖지 않도록.

## 🎯 Key Review Points

1. **Option B 선택 근거**: spec.md 의 trade-off 표 — 현재까지 모든 phase 가 직렬 진행이라 queued 가 동시에 여러 개였던 적 없음 (YAGNI). Icebox 와 정책 통일이 멘탈 모델 단순.
2. **회귀 테스트의 픽스처 패턴**: 기존 `test-sdd-queue-redesign.sh` 와 동일한 패턴 (`.harness-kit/installed.json` + `.claude/state/current.json` 셋업). 향후 sdd 스모크 테스트 작성 시 재활용 가능.
3. **하위 호환성**: 기존 사용자 프로젝트는 `update.sh` 가 `queue.md` 를 건드리지 않으므로 마커가 그대로 남을 수 있음. 그래도 sdd 동작에는 영향 없음 (R/W 코드 자체가 부재).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-queued-marker-removed.sh
```

**결과 요약**:
- ✅ Phase 1 (템플릿 검증): 2/2 통과
- ✅ Phase 2 (sdd 명령 정상 동작): 5/5 통과
- ✅ ALL 7 CHECKS PASSED

### 회귀 점검
```bash
bash tests/test-sdd-queue-redesign.sh    # 5/5 PASS
bash tests/test-sdd-status-cross-check.sh # 7/7 PASS
```

### 수동 검증 시나리오
1. **템플릿 grep**: `grep -rn "sdd:queued" sources/templates/ .harness-kit/agent/templates/` → 0 매치
2. **본 프로젝트 sdd 동작**: `bash .harness-kit/bin/sdd status` → Active Phase = phase-14 정상

## 📦 Files Changed

### 🆕 New Files
- `backlog/phase-14.md`: phase-14 (정합성/멱등성 버그 일괄 수정) 정의 — 4 spec 작업 지도
- `docs/harness-kit-bug-01-sdd-queued-marker-unimplemented.md`: 본 PR 의 근거 자료 (도그푸딩 중 발견된 버그 리포트)
- `specs/spec-14-01-sdd-queued-marker/`: spec.md, plan.md, task.md, walkthrough.md, pr_description.md
- `tests/test-sdd-queued-marker-removed.sh`: 회귀 테스트 (Phase 1: 템플릿, Phase 2: sdd 명령 정상 동작)

### 🛠 Modified Files
- `sources/templates/queue.md`: 마커 + 표 헤더 제거, 상단 안내문 재작성
- `.harness-kit/agent/templates/queue.md`: 동일 변경 (도그푸딩 동기화)
- `backlog/queue.md`: 본 프로젝트 적용 + phase-13 done + phase-14 active 갱신

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (7/7)
- [x] 회귀 테스트 통과 (queue-redesign 5/5, status-cross-check 7/7)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check — 본 spec 은 bash/markdown 만이라 해당 없음
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- Phase: `backlog/phase-14.md`
- Walkthrough: `specs/spec-14-01-sdd-queued-marker/walkthrough.md`
- 버그 리포트: `docs/harness-kit-bug-01-sdd-queued-marker-unimplemented.md`
