feat(output-ux): sdd 경로 상대화 · doctor.sh 표 포맷 · agent.md §8 출력 규칙

## 배경

Warp 터미널 사용자가 `sdd specx new`, `sdd spec show` 등의 출력 경로를 클릭해서
파일을 직접 열 수 없었음. 출력이 절대 경로(`/Users/...`)여서 Warp의 경로 클릭 기능 미작동.
또한 `doctor.sh` 섹션 6 출력이 투박했고, `agent.md §8`에 출력 포맷 규칙이 없어
Claude가 세션마다 달리 행동함.

## 변경 내용

### 1. `sources/bin/sdd` + `.harness-kit/bin/sdd`

`phase_new`, `phase_show`, `spec_new`, `spec_show`, `specx_new` 함수의
경로 출력 8곳을 `${var#$SDD_ROOT/}` 파라미터 확장으로 상대경로 변환.

```
Before: ✓ 생성 완료: /Users/dennis/Project/ai/claude/specs/spec-x-foo
After:  ✓ 생성 완료: specs/spec-x-foo
```

### 2. `doctor.sh`

섹션 6(Hook 권한) 출력을 `printf` 컬럼 레이아웃 표로 변경.

```
Before: ✓ check-plan-accept.sh (executable)
        ✓ .git/hooks/pre-commit 설치됨

After:  항목                                   상태
        ──────────────────────────────────────  ──────
        check-plan-accept.sh                    ✓
        .git/hooks/pre-commit                   ✓ 설치됨
```

### 3. `sources/governance/agent.md` + `.harness-kit/agent/agent.md`

§8 Communication Rules에 하위 섹션 3개 추가:
- §8.1 File Path Format — 상대경로 필수 규칙
- §8.2 Emoji Usage — CLI 이모지 기준 표 (✓/⚠/✗/🔄/→/🚀/🔍)
- §8.3 Table vs List — 3개 이상 동종 항목 표 사용 기준

## 테스트

기존 테스트 전체 PASS (43개):
- `test-governance-dedup.sh` — sources↔installed 정합성
- `test-hook-modes.sh` — sdd 동기화
- `test-hk-doctor.sh` — doctor 출력 및 exit code
- 기타 sdd/install/update 테스트

## 호환성

bash 3.2+ 호환: `${var#prefix}` 는 POSIX 표준 파라미터 확장.
기존 기능 변경 없음 — 출력 포맷만 변경.
