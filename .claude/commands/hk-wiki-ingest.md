---
description: wiki 레이어 증분 갱신 — archive된 spec의 walkthrough를 읽고 docs/wiki/ 페이지를 갱신한다
---

`sdd archive` 후 이 명령으로 `docs/wiki/` 를 최신 상태로 유지합니다.

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
  - archive/specs/spec-XX-XX-slug/walkthrough.md
  ...
  총 N개

계속할까요? [Y/n]
```

대상이 없으면 `이미 최신 상태입니다. 인제스트할 항목 없음.` 으로 종료합니다.

## 3. walkthrough 읽기 및 wiki 갱신

각 walkthrough.md를 순서대로 읽고 다음을 추출합니다:

- **📌 결정 기록** 섹션 → `docs/wiki/decisions.md` 갱신 후보
- **🔍 발견 사항** 섹션 → `docs/wiki/patterns.md` 갱신 후보
- **🚧 이월 항목** 섹션 → 메모만 (실행 불가 — `backlog/queue.md` 이미 반영됨)

**갱신 원칙**:
- 기존 내용을 **삭제하거나 교체하지 않는다** — 항상 증분 추가
- 이미 동일한 패턴/결정이 있으면 중복 추가하지 않고 "출처" 태그만 보강
- 합성 시 원문 인용: `출처: spec-XX-XX walkthrough §결정 기록`

`docs/wiki/decisions.md` 에 새 결정이 있으면 해당 섹션 하단에 추가합니다.
`docs/wiki/patterns.md` 에 새 패턴이 있으면 해당 섹션 하단에 추가합니다.

## 4. log.md 갱신

`docs/wiki/log.md` 에 인제스트 이벤트를 **맨 위 항목으로** 추가합니다 (최신 우선):

```markdown
### YYYY-MM-DD — <이벤트 제목>
- **대상**: <처리한 spec 목록>
- **갱신된 wiki 페이지**: decisions.md, patterns.md (갱신 없으면 생략)
- **추가된 내용 요약**: <1~3줄>
```

## 5. index.md 카탈로그 갱신 (선택)

`docs/wiki/index.md` 의 "최근 인제스트" 항목을 현재 날짜로 업데이트합니다.

## 6. 결과 보고

```
✅ wiki 인제스트 완료

  처리된 spec: N개
  갱신된 페이지:
    - docs/wiki/decisions.md (+K항목)
    - docs/wiki/patterns.md (+M항목)
    - docs/wiki/log.md (이벤트 추가)

  커밋 여부: 변경사항을 커밋하시겠습니까? [Y/n]
```

사용자가 Y이면:
```bash
git add docs/wiki/
git commit -m "docs(wiki): ingest YYYY-MM-DD — N spec"
```
