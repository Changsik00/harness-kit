# Walkthrough: spec-27-03

> 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.
> 작업을 진행하는 동안 *지속적으로* 갱신하세요.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| `cmd_archive()` 수정 여부 | 로직 수정 / 그대로 유지 | **그대로 유지** | 코드를 직접 읽어보니 `queue.md` done 구간의 완료 phase(활성 제외)를 기본값(`--keep=0`)으로 이미 정확히 아카이브 대상에 포함시키고 있었음 — phase.md 원안의 "sdd archive 가 놓친다"는 서술과 달리 실제 버그는 없었고, 갭은 순전히 가시성이었음 |
| 연결 위치 | `cmd_archive` 내부 / `sdd status`(`_status_diagnose`) | **`sdd status`** | archive 는 이미 옳음. 필요한 건 사용자가 archive 를 실행할 계기 — `/hk-align` 마다 항상 보는 `sdd status` 가 실제 접점 |
| 로직 재사용 | 새 파싱 작성 / spec-27-02 헬퍼 재사용 | **`_backlog_completed_residue` 재사용** | 중복 구현 방지, spec-27-02 walkthrough 의 이월 항목을 그대로 이행 |

<!-- ADR 승격: 다른 spec 에 의존되거나 6개월 이상 유지될 결정 → docs/decisions/ADR-NNN-slug.md (constitution §6.3) -->
- 본 spec 의 결정 모두 단일 spec 범위 구현 세부사항 — ADR 승격 대상 아님.

## 💬 사용자 협의

- **주제**: spec.md 작성 중 phase.md 원안("`sdd archive` 가 놓친다")과 다른 사실(코드 확인 결과 버그 없음, 가시성 문제로 재정의)을 발견
  - **합의**: `🛑 사용자 검토 필요`로 명시해 사전 보고 후 Plan Accept(1) 진행 — 스코프를 `sdd status` 연결로 좁히는 데 이견 없음.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-status-backlog-residue.sh` + `bash tests/run.sh`
- **결과**: ✅ Passed (backlog-residue 2/2, 전체 81/81, FAIL 0)
```text
Test: sdd status backlog residue diagnosis
  ✓ fixture residue phase-994 surfaced in sdd status
  ✓ fixture removed → phase-994 no longer mentioned
```

### 수동 검증
1. **Action**: `bash .harness-kit/bin/sdd status` (실 저장소)
   - **Result**: 🔍 진단에 `💡 완료 phase 4개가 backlog/*.md 로 잔존 (phase-23, phase-24, phase-25, phase-26) — sdd archive 로 정리 가능` 정확히 등장.

## 🔍 발견 사항

- **GitHub 이슈 서술과 실제 코드의 괴리**: #168 제안 3 은 "`sdd archive` 가 오래된 phase 를 놓친다"고 서술했지만, 현재 `cmd_archive()` 코드는 `--keep=0` 기본값으로 완료 phase 전체(활성 제외)를 정확히 처리한다. 다운스트림 사용자의 경험은 아마 "archive 를 실행할 계기가 없어 오래 방치됐다"는 가시성 문제였을 가능성이 높다 — 이슈 서술을 그대로 구현하기보다 **코드를 먼저 읽고 실제 갭을 재정의**한 것이 이번 spec 의 핵심 판단.
- **phase-27 전체로 GitHub #168 완전 해결**: spec-27-01(인덱스 생성)·spec-27-02(doctor 통합 검사)·spec-27-03(status 가시성)으로 #168 세 제안 모두 반영 완료, GitHub 이슈 close 가능.

## 🚧 이월 항목 (Optional)

- 없음 — phase-27 의 계획된 3개 spec 모두 완료.
