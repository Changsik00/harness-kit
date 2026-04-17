# spec-11-02: 식별자 2자리 패딩

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-11-02` |
| **Phase** | `phase-11` |
| **Branch** | `spec-11-02-id-padding` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-16 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

Phase/Spec 번호가 10을 넘으면서 `phase-10`이 `phase-2` 앞에 정렬되고, `spec-10-01`이 `spec-2-001` 앞에 온다. 파일 시스템 lexicographic 정렬이 numeric 순서와 불일치.

### 문제점

1. `ls specs/` 출력에서 phase 순서가 뒤섞여 탐색이 어렵다
2. `ls backlog/` 에서도 `phase-10.md`가 `phase-2.md` 앞에 위치
3. Icebox에 이미 "식별자 2자리 패딩" 항목 존재 (queue.md)

### 해결 방안 (요약)

Phase 번호를 2자리 제로패딩으로 통일 (`phase-01`, `spec-01-01`). sdd CLI의 ID 생성 로직 수정 + 기존 디렉토리/파일 일괄 마이그레이션 + 거버넌스 예시 갱신.

## 🎯 요구사항

### Functional Requirements

1. `sdd phase new`가 2자리 패딩된 phase ID 생성 (`phase-01`, `phase-12` 등)
2. 기존 단일 자릿수 phase 파일/디렉토리 일괄 리네이밍 (9개 backlog 파일 + 33개 spec 디렉토리)
3. phase.md 내부의 spec ID 참조도 패딩 형식으로 갱신
4. queue.md 내부 참조 갱신
5. 거버넌스 문서의 예시를 패딩 형식으로 갱신
6. state.json의 현재 phase/spec 값이 있으면 패딩 형식으로 갱신

### Non-Functional Requirements

1. `git mv` 사용으로 rename detection 유지
2. 마이그레이션은 단일 커밋으로 묶어 diff 최소화
3. sdd의 기존 파싱 로직(`[0-9]*` 패턴)은 패딩/비패딩 모두 호환 — 추가 변경 최소화

## 🚫 Out of Scope

- Spec 시퀀스 번호(001~) 변경 — 이미 3자리 패딩
- spec-x 네임스페이스 — 영향 없음
- 테스트 fixture의 ID 패딩 — 기능상 문제 없으므로 본 spec에서는 제외 (sdd 파싱이 양쪽 모두 호환)

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = yes) 기존 테스트 전체 PASS
- [ ] `ls specs/` 출력이 phase 순서대로 정렬됨
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-11-02-id-padding` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
