# Walkthrough: spec-21-03

## 작업 요약

3 commit: test(TDD Red) → feat(sdd intent) → feat(post-commit-verify 연동)

## 발견 및 결정

### intent.yaml 파싱 — yq 없이 grep/sed
yq 를 쓰면 간단하지만 설치 보장이 없다. `grep -E "^goal:" | sed 's/^goal:[[:space:]]*//'` 패턴으로 충분히 파싱 가능하다는 것을 확인. 단순 scalar 값만 쓰는 intent.yaml 스키마에 적합.

### intent.test 우선 / precheck fallback 구조
처음에는 둘을 모두 실행하는 방안도 고려했지만, "intent = 이 작업을 위한 특화 검증"이라는 의미상 intent.test 가 더 구체적이다. 결론: intent.test 있으면 precheck 는 실행하지 않는다. precheck 는 "세션 독립적인 프로젝트 품질 기준"이고 intent.test 는 "지금 이 작업의 통과 기준"으로 역할을 분리.

### Guard 2 재설계
spec-21-02 에서 Guard 2 는 "precheck 없으면 exit" 하나였다. spec-21-03 에서는 "intent.test 도 없고 precheck 도 없으면 exit"로 조건이 확장됐다. 둘 중 하나라도 있으면 Guard 3(시간 체크)까지 진행.

### T08 테스트 — 직접 intent.yaml 작성
T08/T09 는 `sdd intent` 커맨드 미구현 상태(TDD Red)에서도 테스트해야 하므로, fixture 안에 intent.yaml 을 직접 작성하는 방식으로 테스트를 설계했다. 이 덕분에 T08/T09 는 `sdd intent` 구현 여부와 독립적으로 `post-commit-verify.sh` 의 intent 연동 로직만 검증한다.

## 검증 결과

```
bash tests/test-intent-block.sh  → PASS=9 FAIL=0
bash tests/test-turbo-hooks.sh   → PASS=8 FAIL=0
bash tests/test-mode-schema.sh   → PASS=7 FAIL=0
```
