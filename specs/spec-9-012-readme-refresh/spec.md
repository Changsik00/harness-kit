# spec-9-012: README v0.4.0 최신화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-9-012` |
| **Phase** | `phase-9` |
| **Branch** | `spec-9-012-readme-refresh` |
| **상태** | Planning |
| **타입** | Docs |
| **Integration Test Required** | no |
| **작성일** | 2026-04-16 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

README.md가 v0.3.0 기준으로 작성되어 있으나, phase-9에서 디렉토리 레이아웃이 `.harness-kit/`으로 전면 변경되었다.

### 문제점

1. **설치 레이아웃 불일치**: `agent/`, `scripts/harness/` 구조를 안내하지만 실제는 `.harness-kit/` 사용
2. **버전 배지**: `0.3.0` → `0.4.0` 미반영
3. **CLAUDE.md 접근법**: "HARNESS-KIT 블록 추가" 안내이지만 실제는 `@import` 3줄 방식
4. **경로 참조**: `agent/constitution.md`, `bin/sdd` 등 구 경로 산재
5. **NOW/NEXT 언급**: queue.md에서 제거됨 (spec-9-011)
6. **누락 항목**: `--no-gitignore` 옵션, `cleanup.sh`, `/hk-cleanup` 커맨드, Post-Merge Protocol
7. **sdd archive 설명**: state 초기화 + NEXT 안내 기능 미반영

### 해결 방안 (요약)

README.md 전체를 v0.4.0 기준으로 갱신. 설치 레이아웃, 경로, 워크플로, FAQ를 현행 코드와 일치시킨다.

## 🎯 요구사항

### Functional Requirements

1. 버전 배지 `0.3.0` → `0.4.0` 갱신
2. 설치 레이아웃 트리를 `.harness-kit/` 구조로 교체
3. CLAUDE.md 안내를 `@import` 방식으로 갱신
4. 모든 구 경로 참조를 신 경로로 교체
5. queue.md NOW/NEXT 언급 제거, `sdd status`로 대체
6. 누락 항목 추가: `--no-gitignore`, `cleanup.sh`, `/hk-cleanup`
7. sdd archive 설명에 state 초기화 + NEXT 안내 반영
8. 워크플로 다이어그램에 Post-Merge Protocol 반영

### Non-Functional Requirements

1. 기존 문서 구조(섹션 순서) 유지
2. README 배지는 `0.5.0` 선반영 (VERSION 파일은 phase PR 시 갱신)

## 🚫 Out of Scope

- 새 섹션 추가 (Tutorial, Contributing 등)
- 영문 README 작성
- docs/ 하위 문서 갱신

## ✅ Definition of Done

- [ ] README.md 내 모든 경로가 `.harness-kit/` 레이아웃과 일치
- [ ] 버전 배지 및 VERSION 파일이 `0.4.0`
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-9-012-readme-refresh` 브랜치 push 완료
