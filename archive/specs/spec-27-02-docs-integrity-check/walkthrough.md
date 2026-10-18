# Walkthrough: spec-27-02

> 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.
> 작업을 진행하는 동안 *지속적으로* 갱신하세요.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 통합 위치 | 신규 서브커맨드 / 기존 `cmd_doctor()` 확장 | **`cmd_doctor()` 확장** | context-cost-first — `doctor` 가 이미 진단 전용 진입점 |
| `adr-index --check` 재사용 방식 | 직접 함수 호출 / 서브셸 격리 | **서브셸(`( cmd_adr_index --check )`)** | `cmd_adr_index` 는 실패 시 `exit 1` 하는데 직접 호출하면 doctor 전체가 죽음 — 서브셸로 exit 을 격리 |
| 잔존 탐지(backlog residue) 구현 위치 | doctor 안에 인라인 / 독립 공유 헬퍼 | **독립 공유 헬퍼(`_backlog_completed_residue`)** | spec-27-03(`sdd archive`)이 동일 로직을 재사용할 예정 — GitHub #168 제안 2/3 가 같은 잔존 개념을 공유하므로 중복 구현 방지 |
| doctor 의 exit code | fail 시 non-zero / 그대로 유지(정보 출력) | **그대로 유지** | 현재 doctor 는 어떤 항목도 프로세스를 차단하지 않는 순수 진단 도구 — 이번 4항목만 예외로 만들 근거 없음. 실제 차단은 향후 별도 hook 화 검토 |

<!-- ADR 승격: 다른 spec 에 의존되거나 6개월 이상 유지될 결정 → docs/decisions/ADR-NNN-slug.md (constitution §6.3) -->
- 본 spec 의 결정 모두 단일 spec 범위 구현 세부사항 — ADR 승격 대상 아님.

## 💬 사용자 협의

- **주제**: spec-27-01 머지 후 다음 spec 선택
  - **합의**: phase.md 계획대로 spec-27-02(docs-integrity-check) 진행. Plan Accept 는 critique 없이 즉시 승인(1).

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-doctor-docs-integrity.sh` + `bash tests/run.sh`
- **결과**: ✅ Passed (docs-integrity 5/5, 전체 80/80, FAIL 0)
```text
Test: sdd doctor docs-integrity
  ✓ clean state: docs 무결성 section present, no ADR FAIL
  ✓ duplicate ADR id → FAIL detected
  ✓ ADR missing frontmatter → FAIL detected
  ✓ ADR index drift → WARN detected
  ✓ completed phase residue → WARN detected
```

### 수동 검증
1. **Action**: `bash .harness-kit/bin/sdd doctor` (실 저장소 데이터)
   - **Result**: "docs 무결성" 섹션 — ADR id 중복 없음(✅) / frontmatter 전부 존재(✅) / 인덱스 정합(✅) / **완료 phase 4개 backlog 잔존(⚠️, phase-23·24·25·26)**. 실제 미아카이브 상태를 정확히 검출.

## 🔍 발견 사항

- **실 데이터로 실제 문제를 검출**: 본 저장소에 phase-23~26 이 `queue.md` 에서는 완료(done)로 표시됐지만 `backlog/phase-NN.md` 가 아직 남아있음(미아카이브)을 새 검사가 그대로 잡아냄 — 이는 spec-27-03 이 다룰 정확한 문제 상황의 실증.
- **서브셸 exit 격리 패턴**: 다른 top-level 커맨드 함수(`exit` 를 직접 호출하는)를 doctor 같은 "여러 검사를 순회하는" 함수 안에서 재사용할 때는 `( )` 서브셸로 감싸야 호출자 프로세스 전체가 죽지 않는다 — 향후 유사 재사용 시 참고할 일반 패턴.

## 🚧 이월 항목 (Optional)

- `_backlog_completed_residue` 를 `sdd archive`(또는 `sdd status` 진단)에서 재사용해 실제 경고를 내보내는 작업 — spec-27-03 에서 진행 예정 (이미 phase.md 에 계획됨).
