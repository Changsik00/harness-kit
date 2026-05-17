# docs(spec-16-04): Reliability Layer 포지셔닝 — 슬로건 3 곳 정렬

> ★ **PR Target**: `phase-16-reliability-layer` (main 직 PR 아님 — phase base branch 모드)
> ★ **phase-16 의 마지막 spec** — 머지 후 `/hk-phase-ship` 으로 phase done 진입

## 📋 Summary

### 배경 및 목적

외부 진단(velog `80-problem-in-agentic-coding`) 과 추가 제안서가 일관되게 지적한 키트의 *진짜 정체* — **"AI 코딩 프레임워크가 아니라 AI-assisted engineering 의 reliability 계층"** — 가 키트 어디에도 박혀있지 않았음. `grep -l "reliability layer"` 0 hit. spec-16-01 / 02 / 03 의 누적 (RCA / ADR / Stale 탐지) 이 *왜 reliability 계층인지* 의 증거가 됐지만, 그 결과를 묶어주는 한 줄 슬로건 부재.

본 PR 은 영문 한 줄 슬로건 — `Not an AI coding framework. A reliability layer for AI-assisted engineering.` — 을 README / version.json / constitution.md 3 곳에 박는다. README 는 한영 병기, version.json 은 description 필드 신설, constitution.md 는 invariant laws 정의 prefix.

### 주요 변경 사항

- [x] **README.md**: `# harness-kit` 직후 영문 italic slogan 1 줄 추가 (기존 한국어 부제 유지)
- [x] **version.json**: top-level `"description"` 필드 신설 (값 = 슬로건)
- [x] **sources/governance/constitution.md**: identity 한 줄 prefix 추가 (영문)
- [x] **`.harness-kit/agent/constitution.md`**: install 미러 동기화

### Phase 컨텍스트

- **Phase**: `phase-16` — Reliability Layer 강화
- **Base branch**: `phase-16-reliability-layer`
- **본 SPEC 의 역할**: phase-16 의 5 영역 중 **포지셔닝** 담당. spec-16-01 (RCA + type 어휘), spec-16-02 (ADR 활성화), spec-16-03 (Stale 탐지) 의 *기능적 reliability 누적* 을 *언어적 정체성* 으로 마감. **phase-16 의 마지막 spec — 머지 후 `/hk-phase-ship` 진입**.

## 🎯 Key Review Points

1. **슬로건 문구 정확성** — `Not an AI coding framework. A reliability layer for AI-assisted engineering.` (period 포함, italic). phase-16.md 의 spec-16-04 방향성과 일치.
2. **한영 병기 (README)** — 영문 italic + 빈 줄 + 기존 한국어 blockquote. 외부(영문 시야) + 내부(한국어 진입) 모두 확보.
3. **constitution.md 영문 톤 유지** — identity 한 줄도 영문 (메모리 룰 — 거버넌스 4 파일 영어 전용).
4. **회귀 없음** — 본 PR 은 문서 변경만. spec-16-03 의 `_drift_stale_adr` 단위 테스트 PASS, sdd CLI 동작 영향 없음. version.json 의 새 `description` 필드는 기존 jq filter 와 호환.

## 🧪 Verification

### 자동 테스트 (grep / jq / diff)

```bash
# 1. Phase 시나리오 3: 3 곳 hit
grep -l "reliability layer" README.md version.json .harness-kit/agent/constitution.md
# → 3 줄 출력 ✓

# 2. version.json valid + 값 확인
jq -r '.description' version.json
# → Not an AI coding framework. A reliability layer for AI-assisted engineering. ✓

# 3. install 미러 동등성
diff sources/governance/constitution.md .harness-kit/agent/constitution.md
# → 빈 출력 ✓

# 4. 회귀: spec-16-03 stale 탐지 영향 없음
bash tests/test-drift-stale-adr.sh
# → 3/3 PASS ✓
```

**결과 요약**:
- ✅ Phase 시나리오 3 PASS — 3 곳 모두 슬로건 hit
- ✅ version.json valid JSON, description 슬로건 정확
- ✅ install 미러 동기화 완료
- ✅ 회귀 없음 (단위 테스트 + sdd CLI)

### 통합 테스트
Integration Test Required = no. Phase 통합 테스트 시나리오 3 이 본 spec 의 검증 그 자체.

### 수동 검증 시나리오
1. **README 시각** — 영문 italic slogan → 한국어 blockquote 순서로 노출 ✓
2. **version.json valid** — `jq .` 에러 없이 두 필드 출력 ✓
3. **constitution 흐름** — 정체성 → invariant laws 정의로 자연스럽게 연결 ✓

## 📦 Files Changed

### 🆕 New Files
- `specs/spec-16-04-reliability-positioning/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md` — 본 spec 산출물

### 🛠 Modified Files
- `README.md` (+2, -0) — `# harness-kit` 직후 영문 italic slogan 추가
- `version.json` (+4, -1) — `description` 필드 신설 (multi-line JSON 으로 reformat)
- `sources/governance/constitution.md` (+2, -0) — identity 문장 prefix
- `.harness-kit/agent/constitution.md` (+2, -0) — install 미러 동기화
- `backlog/phase-16.md` / `backlog/queue.md` — `sdd spec new` 자동 갱신 + dedupe

**Total**: 9 files changed (5 new + 4 modified + queue/phase 마커)

## ✅ Definition of Done

- [x] 모든 단위 검증 PASS (5/5)
- [x] (해당 없음) 통합 테스트 — Integration Test Required = no
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check — bash 키트, pre-commit shellcheck 통과 (이번 spec 은 셸 변경 없음)
- [x] 사용자 검토 요청 알림 완료 (PR 머지 대기)

## 🔗 관련 자료

- Phase: `backlog/phase-16.md` (Reliability Layer 강화, base branch 모드)
- Walkthrough: `specs/spec-16-04-reliability-positioning/walkthrough.md`
- 선행 spec: spec-16-01 / 02 / 03 (RCA + ADR + Stale 탐지 — *기능적 reliability* 의 누적)
- 외부 진단: https://velog.io/@typo/80-problem-in-agentic-coding (*최종 슬로건* 영역)

## ⏭ 다음 단계

본 PR 머지 → phase-16 의 4 spec 모두 Merged → **`/hk-phase-ship`** 으로:
1. 성공 기준 4 개 정량 측정
2. 통합 테스트 3 시나리오 PASS 확인
3. User go/no-go 확인
4. Phase PR (`phase-16-reliability-layer` → `main`) 생성
