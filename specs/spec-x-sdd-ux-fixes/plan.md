# Implementation Plan: spec-x-sdd-ux-fixes

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-sdd-ux-fixes`
- 시작 지점: `main`

## 📂 Proposed Changes

### Task 1: `sdd specx new <slug>` 명령 구현
- `sources/bin/sdd`: `cmd_specx`에 `new` 서브커맨드 추가
  - `specs/spec-x-{slug}/` 디렉토리 생성
  - 4종 템플릿 복사 (spec, plan, task, walkthrough) + 치환
  - `state.json` 에 spec 설정
  - `queue.md` specx 대기 섹션에 등록
  - help 텍스트 갱신
- `.harness-kit/bin/sdd`: 동기화

### Task 2: `sdd phase done` archive fallback + queue.md 수정
- `sources/bin/sdd`: `queue_mark_done` 함수에서 phase.md 제목 추출 시 `archive/backlog/` fallback
- `backlog/queue.md`: phase-08, 09, 10, 11의 done 항목 수동 수정
- `.harness-kit/bin/sdd`: 동기화

### Task 3: `sdd archive`에 spec-x 포함
- `sources/bin/sdd`: `cmd_archive`에서 `specs/spec-x-*` 디렉토리도 이동 대상에 추가
- `.harness-kit/bin/sdd`: 동기화

### Task 4: README 개발자용 섹션 제거
- `README.md`: "프로젝트 구조 (개발자용)" 섹션 삭제

## 🧪 검증 계획

```bash
bash tests/test-sdd-ship-completion.sh
bash tests/test-sdd-dir-archive.sh
```
