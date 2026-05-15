---
description: 새 RCA (Root Cause Analysis) 작성 — id 자동 부여 + 템플릿 부트스트랩
---

운영 중 두 번 이상 반복된 *failure pattern* 을 정규 RCA 로 박습니다. 결과물은 `docs/rca/RCA-{NNN}-{slug}.md` 한 파일이며, frontmatter `type: failure-pattern` 으로 [[knowledge-type-vocabulary]] (constitution §6.4) 와 연결됩니다.

> 본 커맨드는 *부트스트랩* 용입니다. 5 섹션 (Symptom / Reproduction / Root Cause / Invariant Violated / Prevention) 의 *내용* 은 사용자가 직접 확정하거나, 에이전트의 *제안 초안* 을 검토 후 확정합니다. 자동 진단은 의도적으로 out of scope.

## 1. 사전 검증

- `docs/rca/` 디렉토리 존재 확인. 없으면 `mkdir -p docs/rca && touch docs/rca/.gitkeep`.
- `.harness-kit/agent/templates/rca.md` 존재 확인 (install 결과물). 없으면 사용자에게 `bash install.sh .` 를 안내하고 중단.

## 2. 새 RCA id 자동 부여

`docs/rca/` 안의 기존 RCA 파일을 스캔해 다음 번호를 산출합니다.

```bash
ls docs/rca/RCA-*.md 2>/dev/null \
  | sed -E 's|.*/RCA-([0-9]+)-.*|\1|' \
  | sort -n \
  | tail -1
```

- 비어 있으면 `001` 사용.
- 결과가 있으면 +1, 3 자리 zero-pad (`002`, `010`, `100`).

## 3. 사용자 입력 (AskUserQuestion)

다음 두 가지만 묻습니다:

1. **슬러그** (`slug`): kebab-case, 영문. 예: `sdd-ship-spec-add-missing`. 파일명에 사용.
2. **severity**: `critical` / `high` / `medium` / `low` 중 하나.

> 슬러그는 자유 입력, severity 는 4 선택지 (`AskUserQuestion` 의 options 필드 활용).

## 4. 템플릿 복사 + frontmatter 자동 채움

`.harness-kit/agent/templates/rca.md` 를 `docs/rca/RCA-{NNN}-{slug}.md` 로 복사하고 frontmatter 의 다음 4 필드를 치환합니다:

| 필드 | 값 |
|---|---|
| `id` | `RCA-{NNN}` (3 자리 zero-pad) |
| `type` | `failure-pattern` (고정) |
| `date` | 오늘 날짜 (YYYY-MM-DD) |
| `severity` | 사용자 입력 |
| `status` | `active` (기본값) |

본문 5 섹션은 *템플릿 그대로 골조만 남깁니다* — 사용자가 채우도록 둡니다.

## 5. (선택) 최근 발견 사항 제안

현재 활성 SPEC 의 `walkthrough.md` 에 *발견 사항* 섹션이 있거나 직전 대화에서 운영 이슈가 논의됐다면, 에이전트는 5 섹션 *초안* 을 제시합니다.

```
최근 발견 사항을 기반으로 5 섹션 초안을 제안합니다.

🔍 Symptom: <walkthrough/대화에서 추출>
🔁 Reproduction: <명령 / 조건>
🎯 Root Cause: <표면 아닌 진짜 원인>
🛡 Invariant Violated: <깨진 불변식>
🚧 Prevention: <장치 후보>

이대로 RCA 본문에 채울까요? [Y/n]
```

- Y → 초안 적용 후 사용자에게 다듬을 부분 확인.
- n → 골조만 남기고 사용자 직접 작성.

> 초안 제안은 *선택* 단계. 발견 사항이 모호하거나 사용자가 이미 노트를 갖고 있다면 건너뜁니다.

## 6. 사용자에게 보고

```
✓ RCA-{NNN} 작성 시작: docs/rca/RCA-{NNN}-{slug}.md
  type: failure-pattern / severity: <입력>
  5 섹션을 채운 뒤 commit 해 주세요:
    git add docs/rca/RCA-{NNN}-{slug}.md
    git commit -m "docs(rca-{NNN}): <한 줄 요약>"
```

본 커맨드는 commit 까지 자동으로 진행하지 않습니다 — 5 섹션이 비어 있는 상태로 commit 하지 않도록 사용자 검토 단계를 강제합니다.

## 7. type 정규 집합 회귀 (자동)

작성 후 다음 명령으로 정규 집합 위반이 없는지 점검 (에이전트가 자동 실행 권장):

```bash
grep -rh "^type:" docs/rca | sort -u
```

기대: 한 줄 — `type: failure-pattern`. 다른 값이 보이면 즉시 사용자에게 보고.
