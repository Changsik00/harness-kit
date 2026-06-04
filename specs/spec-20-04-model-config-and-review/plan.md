# Implementation Plan: spec-20-04

## 📋 Branch Strategy

- 브랜치: `spec-20-04-model-config-and-review` (이미 존재). Base: `phase-20-director-mode` (phase-20 base 모드).
- 첫 task 는 브랜치 확인 + 테스트(Red).

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **§6.6 은 교체**(2-tier 모델이름 표 → director/worker/scout 역할 표). 기존 모델 이름 본문 제거. 단어 예산 중립이어야.
> - [ ] **review 패널은 옵션, 기본은 단일 리뷰어 유지** — 디렉터 모드 off / 소규모 diff 는 기존 동작. 회귀 방지.

> [!WARNING]
> - [ ] `harness.config.json` 스키마 변경(`models` 키 추가). 기존 설치 환경엔 키 부재 → **기본값 fallback**(director=opus/worker=sonnet/scout=haiku) 필수. 다운스트림 update 무영향.
> - [ ] 단어 예산이 8000w 초과 시 §6.6 축소 후에도 안 되면 **멈추고 디렉터 보고** — §13 prune 은 본 spec 범위 밖.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **모델 매핑 위치** | `harness.config.json` `models: {director, worker, scout}` (별칭값) | install/프로젝트별 config. 거버넌스(agent.md)는 *역할*만, 모델 이름은 config — de-hardcode 핵심 |
| **기본값** | director=opus, worker=sonnet, scout=haiku (키 부재 시) | 기존 동작 보존 + 새 scout 티어 명시 |
| **§6.6 형태** | 역할 표(책무 중심) + "모델 → config 참조" 1줄. §6.1/§6.8 과 cross-ref, 중복 서술 제거 | 같은 파일 분절 편집 문제(사용자 지적) 해소 — 일관 점검 |
| **`sdd config models`** | 조회 전용(매핑 출력) | set 은 드문 작업 → 파일 직접 편집. ux-mode/director-mode 패턴 |
| **review 패널** | 3개 커맨드에 "패널 옵션 + 디렉터 종합 + 소규모 단일 fallback" 절 + §6.7 1줄 ref | 단일 Opus 깊이 손실 방지: 좁은 렌즈 병렬(폭) + 디렉터 종합(깊이). over-kill 방지 fallback |
| **중재 패턴** | `patterns.md` good-pattern 1개 (코드/거버넌스 변경 없음) | harness-kit 에 front/back 앱 부재 → POC 대신 패턴 기록이 현 단계 올바른 산출 |

### 📑 ADR 후보
- [ ] 있음  · [x] 없음 — §6.6 + config 로 충분.

## 📂 Proposed Changes

### 모델 역할 config (FR1-3)
- **[MODIFY] `sources/governance/agent.md` §6.6** (+ 미러 `.harness-kit/agent/agent.md`): 2-tier 모델이름 표 → director/worker/scout 역할·책무 표. 본문에서 `claude-*`/`Opus`/`Sonnet` 이름 제거, "실제 모델은 `harness.config.json` `models` 참조". §6.1(delegation)·§6.8(protocol)과 중복되는 문장 정리.
- **[MODIFY] `harness.config.json`**: `"models": {"director":"opus","worker":"sonnet","scout":"haiku"}` 추가.
- **[MODIFY] `sources/bin/sdd` + `.harness-kit/bin/sdd`**: `cmd_config` 에 `models` 케이스 + `_config_models`(매핑 조회 출력, `// 기본값` fallback). usage 1줄.

### review 패널 (FR4)
- **[MODIFY] `sources/commands/hk-code-review.md` · `hk-spec-critique.md` · `hk-phase-review.md`** (+ `.claude/` 미러 3개): "디렉터 모드 시 페르소나 패널" 절 추가 — 렌즈 목록(correctness/security/perf/test-coverage), 디렉터 병렬 디스패치→종합·중재, 소규모 diff 단일 fallback.
- **[MODIFY] `sources/governance/agent.md` §6.7** (+ 미러): review-orchestration 1줄 cross-ref.

### 중재 패턴 (FR5)
- **[MODIFY] `docs/wiki/patterns.md`**: good-pattern `mediated-design-dialogue` 1항목 (front↔back 협상 + 디렉터 중재, 종료조건·증류). 출처 태그.

### 테스트
- **[MODIFY] `tests/test-director-mode.sh`**: §6.6 역할 용어(director/worker/scout) grep + `sdd config models` 출력 검증 + (기존) 미러 parity. review 패널은 커맨드 grep 1건.

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-director-mode.sh        # 역할표 + config models + 미러
bash tests/test-director-protocol.sh    # 회귀
bash tests/test-governance-dedup.sh     # 단어 예산 + 미러 parity
```

### 수동 검증
1. `sdd config models` → director/worker/scout 매핑 출력.
2. `grep -iE "claude-|Opus|Sonnet" sources/governance/agent.md §6.6 영역` → 모델 이름 0 확인.
3. `wc -w sources/governance/agent.md sources/governance/constitution.md` → ≤8000.
4. `hk-code-review.md` 에 "페르소나 패널" + "단일 fallback" 문구 존재.

## 🔁 Rollback Plan
- 전부 추가/표 교체 — `git revert`. 예산 초과 시 §6.6 축소 재시도, 그래도 초과면 §13 prune 선행(별도 spec-x)로 에스컬레이트.
- `harness.config.json` `models` 제거 시 기본값 fallback 으로 동작 유지.

## 📦 Deliverables 체크
- [ ] task.md (작성됨)
- [ ] 사용자 Plan Accept
- [ ] (실행 후) 전 task 완료 · walkthrough/pr ship
