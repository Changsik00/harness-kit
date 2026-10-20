# docs/ 위치 규약

> 어떤 문서를 어디에 두는지의 기준입니다. 새 문서는 아래 표를 따릅니다.

## 어디에 두는가

| 종류 | 위치 | 파일명 | 비고 |
|---|---|---|---|
| 아키텍처 결정 (ADR) | `docs/decisions/` | `ADR-NNN-slug.md` | 인덱스는 `sdd adr-index` 가 `README.md` 에 자동 생성 |
| 장애 원인 분석 (RCA) | `docs/rca/` | `RCA-NNN-slug.md` | 재발 방지 규칙으로 이어질 때 |
| 합성 지식 (wiki) | `docs/wiki/` | `decisions.md` `patterns.md` 등 | `/hk-wiki-ingest` 로 갱신. 수기 편집 지양 |
| 설계 문서 (장문 기획·리뷰) | `docs/design/` | `Title_YYYY-MM-DD.md` | 일회성 설계 스냅샷 |
| 운영·가이드 (현행 기준 문서) | `docs/` 루트 | `kebab-case.md` | `project-guide.md`, `release-strategy.md`, `assumption-registry.md` 처럼 *살아 있는* 문서만 |
| 회고·버그 리포트 | `docs/` 루트 (레거시) → 신규는 아래 참조 | | |

## 신규 문서 판단 순서

1. 결정의 *이유* 가 핵심이면 ADR. (재검토 대상이 되는 선택)
2. 한 번 터진 *장애의 원인* 이면 RCA.
3. 특정 spec 안에서 끝나는 내용이면 해당 spec 의 `walkthrough.md` (별도 문서 만들지 않음).
4. 이슈 트래커(GitHub issue)로 충분한 버그 리포트는 문서화하지 않는다.
5. 위 어디에도 안 맞고 계속 갱신될 문서면 `docs/` 루트, 일회성 스냅샷이면 `docs/design/`.

## 현재 문서 분류

| 파일 | 분류 | 비고 |
|---|---|---|
| `project-guide.md` | 운영·가이드 | CLAUDE.md 가 포인터로 참조 |
| `release-strategy.md` | 운영·가이드 | "배포하자" 명령의 절차 |
| `assumption-registry.md` | 운영·가이드 | 모델 매핑 변경 시 재검토 |
| `design/Harness_*_2026-04-09.md` | 설계 스냅샷 | 초기 설계·리뷰 |
| `retrospective-2026-04-10-dogfooding-v1.md` | 회고 (레거시 위치) | 이동하지 않음 — archive 문서가 이 경로를 인용 |
| `harness-kit-bug-01-*.md`, `harness-kit-bug-02-*.md` | 버그 리포트 (레거시 위치) | 해결 완료(spec-14-01, 14-02). 이동하지 않음 — archive 문서가 인용 |

> 레거시 위치의 파일은 archive 된 spec 문서가 경로를 인용하므로 옮기지 않습니다. 새 버그 리포트·회고는 위 판단 순서를 따릅니다.
