# spec-x-seq-padding: Spec 시퀀스 2자리 패딩

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-seq-padding` |
| **Branch** | `spec-x-seq-padding` |
| **타입** | Refactor |
| **작성일** | 2026-04-17 |

## 변경 내용

1. `sources/bin/sdd`: `printf '%03d'` → `printf '%02d'` (spec 시퀀스 생성)
2. `archive/specs/` 43개 디렉토리 리네이밍 (`spec-01-001-*` → `spec-01-01-*`)
3. archive 내부 파일 참조 갱신
4. 거버넌스/템플릿의 `{NNN}` → `{NN}` 표기 갱신
5. README.md 예시 갱신
6. Icebox 항목 제거
