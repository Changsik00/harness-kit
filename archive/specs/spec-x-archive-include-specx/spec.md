# spec-x-archive-include-specx: sdd archive 가 완료된 spec-x 디렉토리도 정리하도록 확장

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-archive-include-specx` |
| **Phase** | (없음 — Solo Spec) |
| **Branch** | `spec-x-archive-include-specx` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-09 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
`sdd archive` 명령 (`sources/bin/sdd:1588 cmd_archive`) 은 완료된 phase 의 spec/backlog 를 `archive/` 로 이동한다. 그러나 1661 행에 `case "$base" in spec-x-*) continue ;;` 가 있어 **모든 spec-x 디렉토리를 스킵**한다.

```bash
for d in "$SDD_SPECS"/spec-${pn}-*; do
  [ -d "$d" ] || continue
  # Skip spec-x dirs
  local base
  base="$(basename "$d")"
  case "$base" in spec-x-*) continue ;; esac   # ← 문제 지점
  ...
done
```

한편 `sdd specx done <slug>` 은 `queue.md` 의 `specx` 섹션 항목을 `done` 섹션으로 옮길 뿐, 디렉토리 자체는 이동하지 않는다 (`sources/bin/sdd:1549 specx_done`). 결과적으로 spec-x 디렉토리는 **도구가 자동으로 정리할 수 없다**.

### 문제점
1. **사용자 혼란**: `sdd status` 진단은 spec-x 만 있는 specs/ 에 대해서도 "💡 specs/ 에 N개 디렉토리 — sdd archive 로 정리 가능"이라고 안내한다. 사용자가 명령을 실행하면 "이동할 항목이 없음"만 출력 — 진단과 동작이 불일치.
2. **수동 정리 부담**: spec-x 가 누적되면 사용자가 직접 `git mv specs/spec-x-* archive/specs/` 후 커밋해야 함. 본 세션에서도 23개를 수동으로 처리.
3. **archive/specs/ 비대칭**: 현재 archive/specs/ 86개 중 spec-x 는 23개 (방금 수동 이동분) — 도구의 자동 경로로는 0개. 이전까지 spec-x 는 한 번도 archive 된 적이 없음.

### 해결 방안 (요약)
`cmd_archive` 가 `queue.md` 의 `done` 섹션에서 완료된 spec-x 슬러그를 추출하여, 해당 디렉토리 (`specs/spec-x-{slug}/`) 가 존재하면 phase-bound spec 과 동일하게 `archive/specs/` 로 이동한다. spec-x 정리 자격은 **`done` 섹션 등록 여부** (즉 `sdd specx done` 호출됨) 로 판단한다.

## 🎯 요구사항

### Functional Requirements
1. **F1**: `sdd archive` 실행 시 `queue.md` 의 `<!-- sdd:done:start --> ~ <!-- sdd:done:end -->` 구간에서 `- [x] spec-x-{slug} (완료)` 패턴을 추출한다.
2. **F2**: 추출된 슬러그에 해당하는 `specs/spec-x-{slug}/` 디렉토리가 존재하면 `archive/specs/` 로 이동한다. 없으면 조용히 스킵 (이미 정리된 경우).
3. **F3**: spec-x 가 `done` 섹션에 없는 경우 (즉 `sdd specx done` 미호출) 디렉토리를 보존한다 — 기존 안전망 유지.
4. **F4**: `--dry-run` 은 spec-x 도 이동 대상 목록에 포함시키되 실제 이동은 하지 않는다.
5. **F5**: 커밋 메시지 요약과 사용자 출력에 spec-x 이동 수를 포함한다.

### Non-Functional Requirements
1. **N1**: 기존 phase-bound spec / backlog 아카이브 동작은 변경하지 않는다 (회귀 금지).
2. **N2**: `--keep=N` 의 의미는 변경하지 않는다 — phase 단위로만 적용. spec-x 는 keep 의 영향을 받지 않으며 `done` 섹션에 등록된 것은 모두 처리.
3. **N3**: `sources/bin/sdd` 와 `.harness-kit/bin/sdd` 의 일관성 유지 (도그푸딩 동기화).

## 🚫 Out of Scope
- `sdd specx done` 명령이 디렉토리도 이동하도록 변경하는 것 (별개 결정 — 현재는 queue 갱신만 담당하는 책임 분리 유지).
- `sdd status` 진단 메시지 정확도 향상 ("N개 중 K개가 archive 가능" 같은 세부 카운팅) — 본 변경으로 메시지 의미가 실질적으로 맞아짐.
- 시간 기반 spec-x keep 정책 (`--keep-specx=N` 등). spec-x 에는 phase 같은 순서 개념이 없어 의미 모호.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS — 신규 회귀 테스트 + 기존 테스트 무손상
- [ ] (Integration Test Required = no, 통합 테스트 불필요)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-archive-include-specx` 브랜치 push 완료
- [ ] PR 생성 + 사용자 검토 요청 알림 완료
