# Implementation Plan: spec-x-claude-md-slim

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-claude-md-slim` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

> Note: scaffold 의 spec.md / plan.md 템플릿이 자동 생성 시 슬러그를 중복 표기 (`spec-x-claude-md-slim-claude-md-slim`) 하는 버그가 있음 (icebox 기록됨). 본 spec 의 정식 브랜치명은 `spec-x-claude-md-slim` 단일 슬러그.

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] root `CLAUDE.md` 의 "현재 단계" 섹션 (Phase 4 도그푸딩 표기) 을 *복원하지 않고 삭제* 하는 데 동의 — 현재 phase-17 까지 완료된 상태와 불일치하는 stale 정보로 판단.
> - [ ] 릴리스 전략의 새 위치를 `docs/release-strategy.md` 로 확정 (현재 `docs/design/`, `docs/decisions/` 와 같은 레벨).

> [!WARNING]
> - [ ] 본 변경은 `install.sh` 동작에 무영향이어야 함 — `HARNESS-KIT:BEGIN/END` 마커 외 영역만 수정하므로 영향 없을 것으로 예상. 검증은 task 에서 수행.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **릴리스 전략 섹션** | `docs/release-strategy.md` 로 전체 이전, root 에는 1-2줄 포인터 | 저빈도·고용량 (~36줄). 평시 작업 토큰 절감. |
| **"현재 단계" 섹션** | 삭제 | stale (Phase 4 표기 vs 실제 phase-17 완료). 유지 시 신규 세션이 잘못된 컨텍스트로 시작. |
| **그 외 섹션** | 모두 유지 | 대상 환경 / 프로젝트 정체성 / 디렉토리 의미 / 작업 원칙 / 거버넌스 / 두 시점 공존 — 모두 고빈도·핵심 정보. |
| **포인터 표현** | `> 새 버전 출시 절차는 [`docs/release-strategy.md`](docs/release-strategy.md) 참조.` | 한 줄. 링크 클릭 가능. "release" / "배포" 검색 시 발견 가능. |

### 📑 ADR 후보

- [x] 없음 — 단순 문서 분리, 거버넌스 변경 없음.

## 📂 Proposed Changes

### Root 가이드 문서

#### [NEW] `docs/release-strategy.md`
릴리스 전략 전체를 이전. 기존 CLAUDE.md 의 line 49-84 내용 그대로 복사. 헤더는 `# 릴리스 전략 (이 저장소 전용)` 으로 변경 (h2 → h1, 단독 문서이므로).

#### [MODIFY] `CLAUDE.md`
- "## 릴리스 전략 (이 프로젝트 전용)" 섹션 (line 49-84) → 1-2줄 포인터로 축소.
- "## 현재 단계" 섹션 (line 93-95) → 삭제.
- 그 외 섹션 그대로 유지.
- 예상 결과: 108줄 → ~70줄.

### 참조 갱신

#### [VERIFY] 다른 곳의 인용 검색
- `grep -r "릴리스 전략" --include="*.md"` 으로 다른 곳에서 본 섹션을 참조하는지 확인.
- 발견 시 새 경로 (`docs/release-strategy.md`) 로 갱신.
- `.harness-kit/` 하위는 sources 복사본이므로 영향 검토 필요. 그러나 release 룰은 *이 저장소 전용* 이라 sources 에 포함될 일이 없음.

## 🧪 검증 계획 (Verification Plan)

### 수동 검증 시나리오
1. **새 세션 시작 시뮬레이션** — `wc -l CLAUDE.md` 로 70줄 이하 확인.
2. **릴리스 전략 무손실** — `diff` 로 새 파일과 기존 섹션 내용 일치 확인.
3. **포인터 발견 가능성** — `grep -i "release\|배포\|릴리스" CLAUDE.md` 로 포인터가 검색되는지 확인.
4. **install.sh 회귀 없음** — `tests/test-install-claudemd.sh` (있다면) 실행, 없으면 manual fixture install 시도.
5. **기타 참조 정합성** — `grep -r "CLAUDE.md.*릴리스\|릴리스.*CLAUDE.md" --include="*.md"` 으로 무효 참조 0건 확인.

### 단위 테스트
```bash
bash tests/run-all.sh
```

기존 모든 테스트가 PASS 해야 함. CLAUDE.md 슬림화는 테스트 픽스처와 무관하므로 회귀 없을 것으로 예상.

## 🔁 Rollback Plan

- `git revert <commit-hash>` 또는 PR 미머지 상태로 close.
- 새 파일 (`docs/release-strategy.md`) 만 단독으로 남아도 무해 (auto-load 안 됨).
- root CLAUDE.md 는 영구 보존 정보가 없으므로 rollback 안전.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
