# Spec: spec-09-005 — update.sh 리라이트

## 개요

`update.sh`를 `uninstall --keep-state + install + cleanup`의 단순한 조합으로 재작성한다.

## 배경 / 문제

현재 update.sh는 약 390줄로 다음을 직접 구현한다:

- state 수동 save/restore (install.sh가 state를 초기화하기 때문)
- v0.3→v0.4 레이아웃 마이그레이션 (사실상 dead code)
- CLAUDE.md 백업 (install.sh @import 멱등 처리로 불필요)
- `.harness-backup-*` 정리 (git이 대체)
- migration 스크립트 인프라 (파일 없음)

반면 uninstall.sh는 이미 키트 파일만 제거하고 사용자 산출물(`backlog/`, `specs/`)과 state를 보존하는 로직을 갖추고 있다.

## 목표

```
update.sh = uninstall --yes --keep-state
          + install --yes [--prefix ...] [--shell ...]
          + cleanup (.harness-backup-* 제거)
          + doctor
```

코드 390줄 → ~60줄 목표.

## 설계 결정

| 항목 | 결정 |
|---|---|
| state 보존 | `uninstall --keep-state`로 자동 처리 |
| v0.3 마이그레이션 | uninstall.sh가 이미 처리 (v0.3 잔재 제거 포함) |
| prefix 보존 | `harness.config.json`의 `rootDir`/`backlogDir`/`specsDir` uninstall 후에도 `.harness-kit/` 삭제되므로 재설치 시 prefix 재지정 필요 → `--prefix` 인자 pass-through |
| migration 스크립트 | 이 스펙에서는 제거. 향후 필요 시 별도 스펙으로 |
| cleanup | `.harness-backup-*` + `.harness-uninstall-backup-*` 정리 |

## 주의사항

`harness.config.json`은 `.harness-kit/` 안에 있으므로 uninstall 시 삭제된다.
update.sh는 uninstall 전에 prefix 값을 읽어두고 install에 전달해야 한다.

## 성공 기준

1. `update.sh --yes` 실행 후 state(phase/spec) 보존됨
2. prefix 설정이 있으면 재설치 후에도 동일 prefix 유지
3. 기존 테스트 전부 PASS
4. update.sh 코드 100줄 이하
