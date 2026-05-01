# fix(spec-14-03): make .gitignore idempotent at line level

## 📋 Summary

### 배경 및 목적

`install.sh:402-445` 의 `.gitignore` 갱신 로직이 멱등성을 `# harness-kit` 헤더 grep 단 하나에 의존했다. 그 결과 다음 케이스에서 라인 중복이 발생:

1. **헤더 누락**: 사용자가 `# harness-kit` 헤더만 수동 삭제 후 재install → 4 라인 일괄 다시 append → `.harness-kit/`, `.harness-backup-*/`, `.claude/state/` 모두 중복.
2. **사용자 사전 라인**: 사용자가 `.harness-kit/` 를 미리 적은 후 첫 install → `.harness-kit/` 가 두 번.
3. **라인 일부 누락**: `# harness-kit` + `.harness-kit/` 만 있고 `.harness-backup-*/`, `.claude/state/` 가 없는 상태에서 재install → 누락 라인 영구 보강 안 됨.

본 PR 은 4 라인 (헤더 + 3 항목) 모두를 라인별 정확 매치 grep 으로 처리하여 위 케이스를 모두 보강한다.

### 주요 변경 사항

- [x] `install.sh:402-445` 재작성 — `_gi_ensure(pattern, line)` 헬퍼로 라인별 ensure
- [x] 헤더 단독 grep + ensure (헤더만 누락 케이스)
- [x] `.harness-kit/` ↔ `!.harness-kit/` 토글은 sed 변환 후 ensure
- [x] `.harness-backup-*/`, `.claude/state/` 도 라인별 grep + ensure
- [x] 회귀 테스트 `tests/test-gitignore-idempotent.sh` 추가 — 22 검증 (D 재install / E 헤더 누락 / F 사전 라인 / G 라인 일부 누락 / H 토글)

### Phase 컨텍스트

- **Phase**: `phase-14` — 정합성 / 멱등성 버그 일괄 수정 (4 spec 중 세 번째)
- **본 SPEC 의 역할**: install.sh 의 .gitignore 처리에서 사용자 환경 다양성 (헤더 누락 / 사전 라인 / 부분 삭제) 에도 깨지지 않는 멱등성 보장.

## 🎯 Key Review Points

1. **`_gi_ensure` 의 정확 매치 (`^...$`)**: 부분 일치를 회피해야 사용자 커스텀 라인이 보존됨. 예: 사용자가 `.harness-kit/notes/` 라인을 적어둔 경우, `^\.harness-kit/$` 정확 매치라 영향 없음.
2. **토글 시퀀스**: sed 변환 → 헤더 ensure → 라인 ensure 순서. sed 가 먼저 와야 토글 후 ensure 가 부재로 판단되어 추가하지 않음.
3. **bash 3.2 호환**: 헬퍼 함수 + `grep -qE` + `echo` + `sed -i.tmp` 만 사용. spec-14-02 의 정책 ("3.2+ 호환, 4+ 전용 기능 금지") 준수.
4. **회귀 테스트의 count_line 함정**: 초기 구현 `|| echo 0` 이 grep 의 "0" 과 echo 의 "0" 을 둘 다 출력하여 "00" 이 나옴. `|| true` 로 수정 — 향후 같은 패턴 작성 시 참고.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-gitignore-idempotent.sh
```

**결과 요약**:
- ✅ D-1~D-8 (재install 멱등): 8 PASS
- ✅ E-1~E-4 (헤더 누락 보강): 4 PASS
- ✅ F-1~F-4 (사전 라인 보강): 4 PASS
- ✅ G-1~G-4 (라인 일부 누락 보강): 4 PASS
- ✅ H-1~H-2 (토글): 2 PASS
- ✅ ALL 22 CHECKS PASSED

### 회귀 점검
```bash
bash tests/test-gitignore-config.sh   # 11/11 PASS
bash tests/test-install-layout.sh     # 7/7 PASS
bash tests/test-doctor-bash-version.sh # 3/3 PASS
```

### 수동 검증 시나리오
1. 픽스처에서 헤더 누락 후 재install → 4 라인 모두 정확히 1 회 (변경 전: 헤더 1 + 다른 3 라인 2회)
2. 본 프로젝트 .gitignore 에서 모든 라인 1 회 — 기존 정상 케이스 영향 없음

## 📦 Files Changed

### 🆕 New Files
- `specs/spec-14-03-gitignore-idempotent/`: spec.md, plan.md, task.md, walkthrough.md, pr_description.md
- `tests/test-gitignore-idempotent.sh`: 22 검증 (D/E/F/G/H 시나리오)

### 🛠 Modified Files
- `install.sh` (line 402-445): `_gi_ensure` 헬퍼 + 라인별 ensure 로 재작성
- `backlog/queue.md`: active 갱신 (sdd spec new)
- `backlog/phase-14.md`: sdd:specs 마커에 spec-14-03 행 수동 추가

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (22/22)
- [x] 회귀 테스트 통과 (gitignore-config 11/11, install-layout 7/7, doctor-bash-version 3/3)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check — 본 spec 은 bash/markdown 만이라 해당 없음
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- Phase: `backlog/phase-14.md`
- Walkthrough: `specs/spec-14-03-gitignore-idempotent/walkthrough.md`
