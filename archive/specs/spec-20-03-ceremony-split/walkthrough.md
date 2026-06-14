# Walkthrough: spec-20-03

> SDD ceremony 분업 계약을 agent.md §6.1 에 간결 접붙임 — 디렉터=의도·게이트 / 워커=작성·실행. 새 절 없이 88w 추가.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 접붙이기 위치 | 새 절(§6.9) / §6.1 블록 | **§6.1 "Director Mode delegation" 블록 + §6.8 cross-ref 1줄** | 단어 예산 규율(§11.3). SDD task 실행 위임은 Strict Loop(§6.1) 맥락이 자연 |
| 워커 커밋 범위 | 관례 / 규칙 | **규칙으로 명문화** (spec/plan/task 산출물 포함) | spec-20-01 발견2 의 갭을 거버넌스로 박아 재발 차단 |
| 게이트 위임 | 허용 / 금지 | **Plan Accept·Ship 게이트 위임 금지** | 사람+디렉터 보유 — 워커는 작성·실행만 |

### ADR 승격 가이드
- [ ] ADR 승격 대상 있음
- [x] 없음 — ADR-005/006 의 운영적 구체화. §6.1 블록으로 충분, 신규 ADR 불필요.

## 💬 사용자 협의
- **주제**: §11.3 재검증 — 잔여 spec 단어 예산 압박
  - **합의**: 20-03 은 새 절 없이 ≤120w 접붙이기로 진행, 발견3(sdd ship 갭)은 phase 후 spec-x 로 deferral.

## 🧪 검증 결과
- **명령**: `bash tests/test-director-protocol.sh` · `test-governance-dedup.sh` · `test-director-mode.sh`
- **결과**: ✅ 10/10 · 8/8 · 10/10 PASS
- **수동**: `grep "Director Mode delegation"` → §6.1 블록 + §6.8 ref(2회), 미러 동일. 합계 7613/8000w, 블록 88w.

## 🔍 발견 사항
- **단어 예산 누적 경고** (디렉터 인지 필요): 7613/8000, 여유 387w. **spec-20-04(모델 config)가 §6.6 을 건드린다** — 역할 기반 재작성이 중립~소폭 증가라도 예산이 빠듯. → **20-04 착수 §11.3 에서 §13 Rule Prune 을 선행 spec-x 로 끼울지 판단** (Icebox "governance 단어수 초과" 항목과 연계).
- **분업 계약이 self-describing**: 이 spec 자체가 디렉터 모드로 만들어졌고, 그 워크플로를 규약화 — §6.1 블록의 규칙이 본 spec 의 작업 방식과 1:1 대응(도그푸딩 정합).

## 🚧 이월 항목
- spec-20-04(모델 config) ~ 20-06(review 패널). **20-04 전 단어 예산 prune 판단 필수.**

## 🔗 관련 문서
- 관련 ADR: [[ADR-005]], [[ADR-006]]
- 관련 메모: [[feedback-sdd-economy]]

## 📅 메타
| 항목 | 값 |
|---|---|
| **작성자** | Director(Opus) + dennis, 구현 Sonnet 워커 |
| **작성 기간** | 2026-06-04 |
| **최종 commit** | (ship 직전) |
