# PR: spec-21-02 — Turbo 훅 분기 및 PostCommit 검증

## 변경 요약

- `check-plan-accept.sh` / `check-scope.sh`: Turbo 모드(`mode=turbo`) 시 모든 검사 skip (`exit 0`)
- `post-commit-verify.sh` (신규 Stop 훅): Turbo 모드 + precheck 설정 + 최근 10분 이내 커밋 조건에서만 검증 실행. 실패 시 `git revert HEAD --no-edit` 자동 수행
- `.claude/settings.json` + `sources/claude-fragments/settings.json.fragment`: Stop 훅 배열에 `post-commit-verify.sh` 추가
- `sources/hooks/`: 위 모든 변경 미러링

## 테스트

```
bash tests/test-turbo-hooks.sh  → 8/8 PASS
bash tests/test-mode-schema.sh  → 7/7 PASS
```

## 주요 결정

- Turbo 분기: `hook_resolve_mode` 직후 `[ "$(hook_state mode)" = "turbo" ] && exit 0` 한 줄 추가 — 기존 코드 최소 변경
- auto-revert: `git reset --hard` 대신 `git revert` 사용 — 이력 보존
- 10분 가드: Stop 훅이 지속적으로 실행되므로 오래된 커밋 revert 방지
