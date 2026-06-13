# PR: spec-21-03 — Intent 블록 커맨드

## 변경 요약

- `sdd intent "<goal>" [--test <cmd>] [--files <list>]` — `.claude/state/intent.yaml` 생성
- `sdd intent show` / `sdd intent clear` — 조회·삭제
- `sdd status` — Active Intent 행 추가 (intent 설정 시)
- `post-commit-verify.sh` — intent.yaml `test` 필드 우선 실행, 없으면 precheck fallback
- `sources/bin/sdd` + `sources/hooks/post-commit-verify.sh` 동일 변경 미러링

## 테스트

```
bash tests/test-intent-block.sh  → 9/9 PASS
bash tests/test-turbo-hooks.sh   → 8/8 PASS (precheck fallback 회귀 없음)
bash tests/test-mode-schema.sh   → 7/7 PASS
```

## 주요 결정

- intent.yaml 파싱: grep/sed (yq 의존성 없음, bash 3.2 호환)
- intent.test 우선 / precheck fallback: intent 가 작업-로컬, precheck 는 프로젝트-전역으로 역할 분리
- intent.yaml 위치: `.claude/state/` (이미 gitignored — 세션-로컬)
