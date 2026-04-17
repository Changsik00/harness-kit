# spec-11-003: 디렉토리 아카이브 기능

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-11-003` |
| **Phase** | `phase-11` |
| **Branch** | `spec-11-003-dir-archive` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-16 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`specs/` 디렉토리에 41개 폴더가 쌓여 있고, `backlog/`에도 11개 phase 파일이 있다. 완료된 오래된 항목을 정리할 수단이 없어 탐색이 어렵다.

### 문제점

1. `specs/` 디렉토리 폭증으로 탐색 노이즈 증가
2. 완료된 오래된 phase/spec을 정리할 자동화된 수단 부재
3. 새 세션 시작(align) 시 정리가 필요한 상태를 인지하기 어려움

### 해결 방안 (요약)

`sdd archive` 명령을 신설하여 완료된 phase의 spec/backlog 파일을 `archive/` 디렉토리로 이동. align 프로토콜에 디렉토리 수 임계값 진단을 추가하여 아카이브 제안.

## 🎯 요구사항

### Functional Requirements

1. `sdd archive [--keep=N]` — 완료된 phase의 spec 디렉토리와 backlog 파일을 `archive/specs/`, `archive/backlog/`로 `git mv`
   - `--keep=N`: 최근 N개 완료 phase를 유지 (기본값: 0 = active phase만 남김)
   - active phase와 spec-x는 항상 제외
   - `--dry-run`: 실행 없이 이동 대상만 출력
2. `archive/` 레이아웃: 원본 구조 보존 (`archive/specs/spec-01-001-slug/`, `archive/backlog/phase-01.md`)
3. `sdd status` 진단에 디렉토리 수 관련 안내 추가: `specs/`에 20개 이상 디렉토리 시 "`sdd archive`로 정리 가능" 표시
4. align 프로토콜(align.md)에 아카이브 제안 단계 추가: "완료된 항목이 많습니다. `sdd archive`로 정리하시겠습니까?" 유사 워딩
5. help 텍스트에 `archive` 명령 추가

### Non-Functional Requirements

1. `git mv` 사용으로 히스토리 추적 유지
2. 아카이브 실행 전 확인 메시지 표시 (대상 목록 + 수량)
3. `.gitignore`에 archive/ 추가하지 않음 (히스토리 보존 목적)

## 🚫 Out of Scope

- 아카이브된 항목을 sdd 명령에서 검색하는 기능 (spec-11-004에서 처리)
- 아카이브 복원(unarchive) 기능 — 필요 시 수동 `git mv`로 가능
- queue.md에서 완료 항목 제거 — queue.md는 대시보드이므로 유지

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = yes) 아카이브 테스트 PASS
- [ ] `sdd archive --dry-run` 정상 동작
- [ ] `sdd archive` 실행 후 `specs/`에 active phase 관련만 남음
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-11-003-dir-archive` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
