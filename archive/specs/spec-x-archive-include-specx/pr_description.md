# fix(spec-x-archive-include-specx): sdd archive 가 완료된 spec-x 디렉토리도 정리하도록 확장

## 📋 Summary

### 배경 및 목적
`sdd archive` 는 완료된 phase 의 spec/backlog 만 `archive/` 로 이동하고, 모든 spec-x 디렉토리는 명시적으로 SKIP 했다 (`sources/bin/sdd:1661 case "$base" in spec-x-*) continue ;;`). 그 결과:
- spec-x 디렉토리는 도구의 자동 경로로는 한 번도 archive 된 적이 없음 (`archive/specs/` 86개 중 23개는 직전 세션에서 수동 `git mv` 로 처리한 분)
- `sdd status` 진단은 spec-x 만 있는 specs/ 에 대해서도 "sdd archive 로 정리 가능"으로 잘못 안내 → 도구 동작과 진단 불일치
- 사용자는 누적된 spec-x 를 수동으로 정리해야 함

### 주요 변경 사항
- [x] `cmd_archive` 가 `queue.md` `done` 섹션의 `spec-x-{slug}` 슬러그를 추출하여 해당 디렉토리를 archive 대상에 포함시키도록 확장
- [x] spec-x archive 자격 게이트 = `sdd specx done <slug>` 호출 여부 (`done` 섹션 등록). 미등록 spec-x 는 보존
- [x] `--keep=N` 의미 비변경 — phase 단위로만 적용, spec-x 는 모두 처리
- [x] 회귀 테스트 신규 2건 추가 (`tests/test-sdd-dir-archive.sh` Check 7/8) + 기존 Check 4 의미 명확화
- [x] dogfood sync: `.harness-kit/bin/sdd` 갱신 + `.gitignore` install drift revert (사이드 발견: pre-commit.sh untracked 상태 노출되어 함께 tracking)

### Phase 컨텍스트
- **Phase**: 없음 — Solo Spec (`spec-x`)
- **본 SPEC 의 역할**: SDD 도구의 빈 구멍을 메워 도그푸딩 환경의 정합성 회복.

## 🎯 Key Review Points

1. **archive 자격 판정 (`sources/bin/sdd` `done_specx` 추출)**: queue.md 의 `done` 섹션 awk 파싱이 `spec-x-{slug}` 패턴을 정확히 잡아내는지. 슬러그 정규식 `spec-x-[a-z0-9][a-z0-9-]*` 가 본 프로젝트의 슬러그 컨벤션과 일치.
2. **조기 return 조건의 변경**: `done_phases` 가 비어도 `done_specx` 가 있으면 진행. 이전 단순 조건 (`-z "$done_phases"`) 을 조합 조건으로 확장.
3. **`--keep=N` 동작 비변경**: spec-x 는 keep 의 영향을 받지 않음 — keep=N 로 모든 phase 가 유지된 상태에서도 spec-x 만 별도로 처리됨 (`phases_kept_by_flag` 플래그로 메시지 분기).
4. **Check 4 의미 변경 (코드 비변경)**: "spec-x 디렉토리는 이동되지 않음" → "done 섹션 미등록 spec-x 디렉토리는 보존됨". fixture 가 spec-x 를 done 에 등록하지 않아 결과는 동일하지만, 의미가 안전망으로 재해석됨.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-dir-archive.sh         # 14/14 PASS (신규 Check 7,8 포함)
bash tests/test-sdd-archive-search.sh      # 11/11 PASS (회귀)
bash tests/test-sdd-status-cross-check.sh  # 7/7   PASS (회귀)
```

### 수동 검증 시나리오
1. **신규**: queue.md done 섹션에 `- [x] spec-x-foo (완료)` + `specs/spec-x-foo/` 존재 → `sdd archive` → `archive/specs/spec-x-foo/` 이동 확인
2. **dry-run**: 동일 상태에서 `sdd archive --dry-run` → 이동 대상으로 표시되지만 실제 이동 없음 확인
3. **안전망**: queue.md done 에 등록되지 않은 spec-x → archive 대상에서 제외 (보존)
4. **백워드 호환**: phase 만 done 인 기존 시나리오 → 출력 한 줄 (`spec-x 디렉토리: 0개`) 추가 외 동작 동일

## 📦 Files Changed

### 🆕 New Files
- `.harness-kit/hooks/pre-commit.sh`: PR #96 의 sources/hooks/pre-commit.sh 가 install 됐지만 `.gitignore` 의 `.harness-kit/` 라인에 가려 untracked 였던 산출물. drift revert 와 함께 tracking.
- `specs/spec-x-archive-include-specx/{spec,plan,task,walkthrough,pr_description}.md`: 본 spec 산출물.

### 🛠 Modified Files
- `sources/bin/sdd` (+58, -8): `cmd_archive` 에 spec-x 추출/수집/이동 경로 추가. 빈 검사·요약·dry-run·커밋 메시지 통합.
- `.harness-kit/bin/sdd` (+58, -8): dogfood sync.
- `tests/test-sdd-dir-archive.sh` (+62, -4): Check 7/8 신규 추가 + Check 4 주석 갱신.

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (32/32 across 3 files)
- [x] 통합 테스트 — 해당 없음 (Integration Test Required = no)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] bash syntax 통과 (`bash -n sources/bin/sdd`)
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- Spec: `specs/spec-x-archive-include-specx/spec.md`
- Plan: `specs/spec-x-archive-include-specx/plan.md`
- Walkthrough: `specs/spec-x-archive-include-specx/walkthrough.md`
- 직전 세션의 수동 archive 커밋: `e191968 chore: archive 23 merged spec-x directories to archive/specs/`
