# docs(spec-x-phase-16-define): phase-16 (Reliability Layer) 백로그 등록

## 📋 Summary

### 배경 및 목적

외부 진단(velog: 80-problem-in-agentic-coding) 과 추가 제안서(5 축 + 5 차별화 + 포지셔닝) 를 검토한 결과, 본 키트의 *진짜* 갭이 5 영역(RCA / Knowledge Type / ADR 활성화 / Stale 탐지 / Reliability 포지셔닝) 으로 정리되었다. 본 PR 은 이를 **phase-16** 으로 묶어 **백로그에 등록만** 한다 — activate 는 별도 시점.

### 주요 변경 사항

- [x] **`backlog/phase-16-reliability-layer.md` 신규**: 메타 / 배경 / 목표 / 성공 기준 4 개(정량) / 4 개 spec 분해 + 상세 / 통합 테스트 시나리오 3 개 / 결정 기록 / 위험 요소 / Done 조건 포함.
- [x] **`backlog/queue.md` "📋 대기 Phase" 섹션 등록**: phase-16 한 줄 추가 (`없음` 대체).
- [x] **활성화 안 함**: `sdd status` 의 active phase 는 그대로 "없음".

### Phase 컨텍스트

- **Phase**: 없음 (Solo Spec — `spec-x-phase-16-define`)
- **본 SPEC 의 역할**: phase-16 *정의 자체* 를 백로그 자산으로 박아 우선순위 비교 가능한 형태로 만든다. spec-16-01~04 의 *실행* 은 후속 작업.

## 🎯 Key Review Points

1. **4 spec 분해의 응집성**: RCA + Knowledge Type 을 한 spec(16-01) 에 묶은 결정 (RCA 가 type 슬롯의 *첫 사용자*). ADR 트리거 → Stale 탐지의 *순서 의존* 명시.
2. **Out of Scope 의 명시적 거름**: Context Kernel / Capability matrix / Cost routing / Spec-Code Consistency engine 등 *Workflow engine 함정* 항목을 위험 요소 표에 박아 phase 비대화 차단.
3. **성공 기준의 정량성**: 4 개 모두 grep / 명령 실행 / 파일 생성 으로 *검증 가능* 한 형태. RCA "최소 1 회 작성" 처럼 *과도한 누적 강제 회피*.
4. **활성화 보류 정책**: 본 PR 머지 후에도 `sdd status` Active Phase = "없음" 유지. 시작 시점은 *사용자 별도 결정*.

## 🧪 Verification

### 자동 테스트
- 본 spec 은 docs only — 자동 테스트 없음.

### 수동 검증 시나리오

1. **시나리오 1**: `grep -c "spec-16-" backlog/phase-16-reliability-layer.md` → `21` (≥ 4) — 4 개 spec 후보가 표/상세/통합 테스트/결정 기록에 일관 노출.
2. **시나리오 2**: `bash .harness-kit/bin/sdd status --no-drift` → Active Phase `없음` 유지, Active Spec 만 `spec-x-phase-16-define`.
3. **시나리오 3**: `git diff main --stat` → 2 file (backlog/phase-16-* +163, queue.md +2/-1). spec-x 산출물은 ship commit 으로 별도.

## 📦 Files Changed

### 🆕 New Files

- `backlog/phase-16-reliability-layer.md` (+163): phase-16 정의 (대기 상태).
- `specs/spec-x-phase-16-define/{spec, plan, task, walkthrough, pr_description}.md`: spec-x 산출물.

### 🛠 Modified Files

- `backlog/queue.md` (+2, -1): "📋 대기 Phase" 섹션에 phase-16 한 줄 등록.

**Total**: 1 코드 디렉토리(backlog/) 변경 + spec-x 산출물 5 개.

## ✅ Definition of Done

- [x] `backlog/phase-16-reliability-layer.md` 신규 — 4 개 spec 후보 정의 완료
- [x] `backlog/queue.md` "📋 대기 Phase" 섹션 한 줄 등록
- [x] phase-16 은 *active* 가 아님 (`sdd status` 확인)
- [x] walkthrough.md / pr_description.md 작성 및 ship commit
- [x] `spec-x-phase-16-define` 브랜치 push 완료, PR 생성
- [ ] merge 후 `sdd specx done phase-16-define` 로 queue.md 갱신

## 🔗 관련 자료

- Spec: `specs/spec-x-phase-16-define/spec.md`
- Plan: `specs/spec-x-phase-16-define/plan.md`
- Walkthrough: `specs/spec-x-phase-16-define/walkthrough.md`
- Phase 정의 (본 PR 결과물): `backlog/phase-16-reliability-layer.md`
- 외부 진단 원문: https://velog.io/@typo/80-problem-in-agentic-coding
