fix(spec-25-04): 정지규칙 ② 2층 모델 명문화 + 차단 승격 준비 (W3)

## 📋 Summary

### 배경 및 목적
auto 의 비가역 행동 방어는 settings `deny`(프롬프트 없는 완전 차단)와 `check-irreversible` ②(멈추고 대기)가 겹치는데 경계가 명문화돼 있지 않았다. 그 결과 auto 가 정당한 복구(`git reset --hard`)에서 deny 에 막혀 *프롬프트도 없이 데드락*되고(phase-review W3), 정작 hook 은 그 명령을 감지조차 못 했다.

### 주요 변경 사항
- [x] **2층 모델 명문화**: deny = never-justify(rm -rf /·sudo·force push) / hook ② = context-dependent(reset --hard·rebase --onto·clean -fd, "멈추고 확인"). hook 헤더에 분류표.
- [x] **hook 감지 확장**: `check-irreversible` 가 `git reset --hard`·`git rebase --onto` 를 감지(warn). 플립 시 hook 이 그 층을 단독으로 떠맡을 *준비*.
- [x] **승격 준비**: block 경로(exit 2)를 테스트로 고정. 적격일(2026-06-26) hook 헤더 명시.
- [x] **이번엔 플립/deny 미변경**: warn 기본 유지, deny 그대로(이중 방어 → 보호 공백 0).

### Phase 컨텍스트
- **Phase**: `phase-25` 마지막 spec, base 브랜치 `phase-25-auto-reliability`
- **역할**: phase-review W3 해소. 실제 warn→block 플립 + deny→hook 이관은 1주 운영(2026-06-26) 후 phase-FF.

## 🎯 Key Review Points

1. **왜 지금 플립 안 하나**: check-irreversible 는 2026-06-19 추가(3일째) → CLAUDE.md #5 "1주 후 승격" 미달. 키트 자기 원칙 준수를 위해 준비만.
2. **무공백 보장**: reset --hard 감지는 warn(동작 변화 0) + deny 가 실제 차단 유지 → warn 창 보호 공백 없음.
3. **칸0 의 TDD coarseness 발견**: red/green 분리 커밋에서 칸0 경고(walkthrough 기록).

## 🧪 Verification
```bash
bash tests/test-stop-rules.sh   # 17/17 (T9·T9b·T9c·T9d·T10b 추가)
bash tests/run.sh               # 75/75 (FAIL 0)
```

## 📦 Files Changed
### 🛠 Modified Files
- `sources/hooks/check-irreversible.sh`: reset --hard·rebase --onto 감지 + 2층 모델 헤더
- `tests/test-stop-rules.sh`: 감지/경계/block 케이스
- `.harness-kit/hooks/check-irreversible.sh`: 미러

**Total**: 3 files (+ spec 산출물)

## ✅ Definition of Done
- [x] test-stop-rules 갱신 PASS + 전체 회귀 75/75
- [x] reset --hard·rebase --onto 경고 감지 + block 경로 고정
- [x] 2층 모델 + 승격 적격일 hook 헤더 명문화
- [x] 플립/deny 미변경 (warn 기본 유지)
- [x] sources ↔ 설치본 미러 동일
- [x] walkthrough / pr_description ship + 브랜치 push

## 🔗 관련 자료
- Phase: `backlog/phase-25.md` (phase-FF: 6/26 플립 기등록) / ADR-009 규약 ②
- phase-review W3
