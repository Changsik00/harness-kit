---
description: 완료된 phase 의 spec/backlog 를 archive/ 디렉토리로 정리
---

프로젝트의 `specs/` 와 `backlog/` 디렉토리가 많아졌을 때 이 명령으로 완료 항목을 아카이브합니다.

## 1. 미리보기 (dry-run)

먼저 이동 대상을 확인합니다:

```bash
./.harness-kit/bin/sdd archive --dry-run
```

출력을 사용자에게 보여주고 다음을 안내합니다:

```
📦 아카이브 미리보기 완료.

옵션:
  1) 실행 — 위 항목을 archive/ 로 이동
  2) --keep=N — 최근 N개 완료 phase 유지 (예: sdd archive --keep=1)
  3) 취소
```

사용자가 선택할 때까지 대기합니다.

## 2. 실행

사용자가 실행을 선택하면:

```bash
./.harness-kit/bin/sdd archive
```

`--keep=N` 을 선택한 경우:

```bash
./.harness-kit/bin/sdd archive --keep=N
```

## 3. 결과 보고

실행 후 결과를 보고합니다:

```
✅ 아카이브 완료
  - spec 디렉토리: N개 → archive/specs/
  - backlog 파일: N개 → archive/backlog/
  - 자동 커밋 생성됨

현재 specs/ 에 남은 디렉토리: M개
```

> 💡 아카이브된 항목은 `sdd spec list`, `sdd phase list` 에서 `(archived)` 표시로 계속 조회 가능합니다.
