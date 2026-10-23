---
description: wiki 레이어 증분 갱신 — archive된 spec이 바꾼 컴포넌트 페이지만 제자리에서 갱신한다
---

`sdd archive` 후 이 명령으로 `docs/wiki/` 를 최신 상태로 유지합니다. 갱신 **단위는 walkthrough 가 아니라 영향받은 컴포넌트 페이지**입니다.

> 규약은 `docs/wiki/schema.md` 를 먼저 읽고 따른다 (3층 구조 · 제자리 갱신 + 변경 이력 · 충돌 시 사용자 확인 · 출처 필수 · 크기 상한). 컴포넌트 페이지 양식: `.harness-kit/agent/templates/wiki-component.md`.

## 1. 인제스트 범위 결정

먼저 `docs/wiki/log.md` 의 마지막 항목 날짜를 확인합니다.

```bash
grep "^### " docs/wiki/log.md | tail -1
```

- **기본 모드**: 마지막 인제스트 날짜 이후에 archive된 spec만 처리
- **`--all` 모드**: 전체 `archive/specs/` 대상 (사용자가 명시 요청 시)

사용자가 `--all` 을 요청했는지 확인 후 범위를 결정합니다.

## 2. 대상 spec 목록 수집

```bash
# 마지막 인제스트 날짜 이후 archive된 walkthrough 목록
find archive/specs -name "walkthrough.md" | sort
```

마지막 인제스트 날짜와 각 walkthrough의 git 커밋 날짜를 비교해 신규 항목을 필터링합니다:

```bash
git log --format="%ad %s" --date=short -- archive/specs/*/walkthrough.md | head -20
```

처리 대상 목록을 사용자에게 보여주고 확인을 받습니다:

```
📋 인제스트 대상 (마지막 인제스트: YYYY-MM-DD 이후)
  - archive/specs/spec-XX-XX-slug/walkthrough.md
  ...
  총 N개

계속할까요? [Y/n]
```

대상이 없으면 `이미 최신 상태입니다. 인제스트할 항목 없음.` 으로 종료합니다.

## 3. 영향 컴포넌트 결정 (기계적 매핑)

각 대상 spec 의 `spec.md` 에서 **Proposed Changes** 의 파일 경로를 모으고, `docs/wiki/components/*.md` 의 frontmatter `covers:` 접두와 매칭해 영향 컴포넌트를 정합니다. 한 경로가 여러 컴포넌트에 걸릴 수 있습니다.

- 매칭된 컴포넌트 → 4단계로
- **어느 `covers:` 에도 맞지 않는 항목** → 임의로 분류하지 말고 사용자에게 묻는다: `새 컴포넌트 페이지 / direction.md / 버림`
- 프로젝트 방향·원칙에 관한 변화(예: 정책 번복, No-Go 결정)는 `direction.md` 후보

## 4. 영향 컴포넌트 페이지 갱신

영향받은 컴포넌트 페이지만 읽고, 각 spec 의 walkthrough(📌 결정 기록 · 🔍 발견 사항)와 ADR 에서 **현재 설계가 바뀐 것 / 번복 / 반복 / 보류**를 추려 반영합니다. 🚧 이월 항목은 메모만(`backlog/queue.md` 에 이미 있음), `기술 부채`·`반복·미결` 에는 *결정을 미룬 것*만 옮깁니다.

**갱신 원칙** (상세는 schema.md):
- **제자리 갱신**: 현재 서술을 고친다. 낡은 문장 옆에 새 문장을 덧붙여 모순을 쌓지 않는다.
- **변경 이력 보존**: 주장이 바뀌면 덮어쓰기 *전에* `## 변경 이력` 에 `날짜 · 이전 → 현재 · 이유 · 출처` 를 한 줄 남긴다. 이력은 지우지 않는다.
- **충돌은 사용자 확인 후 반영**: 새 근거가 기존 "현재 설계" 주장과 모순되면 임의로 덮어쓰지 않는다. (기존 주장 / 새 근거 / 제안 갱신)을 보여 주고 확인받는다. 확인 전에는 `## 반복·미결` 에 `⚠ 충돌 대기: <한 줄>` 로만 기록한다.
- **출처 필수**: 모든 사실 주장에 출처(경로·spec·ADR)를 단다. 확인하지 못한 것은 `(미확인)`. 해석은 "판단" 표시.
- **원문 확인**: 코드/설정에 대한 주장은 walkthrough 의 서술을 믿지 말고 현재 파일에서 직접 확인한다 (시범에서 요약 서술이 사실과 달랐던 사례가 있음).
- 같은 내용이 이미 있으면 추가하지 않고 출처만 보강한다.
- 코드에서 기계적으로 확인 가능한 표·목록은 바로 위에 `<!-- verify: <키> -->` 마커를 유지한다.
- 페이지가 크기 상한(components 200줄 / direction 150줄 / threads 300줄)을 넘으면 오래된 변경 이력을 한 줄 요약으로 압축한다.
- frontmatter `sources:` 보강, `updated:` 를 오늘 날짜로.

## 5. threads.md 반영

번복(이전 입장이 뒤집힘), 반복(같은 문제 재발), 미결(결정을 미룸)이 **둘 이상의 컴포넌트에 걸치거나 오래 이어진** 경우 `docs/wiki/threads.md` 에 스레드 항목을 추가·갱신합니다(상태 · 경과 · 관련 페이지). 파일이 아직 없으면 사용자에게 만들지 묻습니다.

> `docs/wiki/decisions.md`·`patterns.md` 는 **출처별 로그(격하)** 입니다. 이 명령은 더 이상 이 두 파일을 직접 편집하지 않습니다. 새 항목을 로그에도 남기고 싶으면 사용자가 요청할 때만 추가합니다.

## 6. log.md 갱신

`docs/wiki/log.md` 에 인제스트 이벤트를 **맨 위 항목으로** 추가합니다 (최신 우선):

```markdown
### YYYY-MM-DD — <이벤트 제목>
- **대상**: <처리한 spec 목록>
- **갱신된 wiki 페이지**: components/hooks.md, direction.md (갱신 없으면 생략)
- **변경 요약**: <1~3줄 — 바뀐 입장은 "이전 → 현재" 로>
- **충돌 대기**: <있으면 목록, 없으면 생략>
```

`docs/wiki/index.md` 의 "최근 인제스트" 항목과 새 페이지 행도 갱신합니다.

## 7. 결과 보고

```
✅ wiki 인제스트 완료

  처리된 spec: N개
  갱신된 페이지:
    - docs/wiki/components/<name>.md (현재 설계 +a, 변경 이력 +b)
    - docs/wiki/threads.md (스레드 +c)
    - docs/wiki/log.md (이벤트 추가)
  ⚠ 충돌 대기: K건  (사용자 확인 필요)
  분류 보류: M건  (사용자 선택 필요)

  커밋 여부: 변경사항을 커밋하시겠습니까? [Y/n]
```

사용자가 Y이면:
```bash
git add docs/wiki/
git commit -m "docs(wiki): ingest YYYY-MM-DD — N spec"
```
