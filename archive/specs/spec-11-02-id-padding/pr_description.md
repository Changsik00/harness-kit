# refactor(spec-11-02): 식별자 2자리 패딩

## 📋 Summary

### 배경 및 목적
Phase 번호가 10을 넘으면서 파일 시스템 lexicographic 정렬이 numeric 순서와 불일치. `phase-10`이 `phase-2` 앞에 오고, `spec-10-01`이 `spec-2-001` 앞에 위치하는 문제.

### 주요 변경 사항
- [x] `sdd phase new`가 2자리 패딩된 phase ID 생성 (`printf '%02d'`)
- [x] 기존 9개 backlog 파일 + 33개 spec 디렉토리 `git mv` 일괄 마이그레이션
- [x] 내부 참조(phase.md, spec.md, queue.md 등) 패딩 형식으로 갱신
- [x] 거버넌스 문서 예시 패딩 적용

### Phase 컨텍스트
- **Phase**: `phase-11` — 식별자 체계 개선 및 디렉토리 아카이브
- **본 SPEC의 역할**: 파일 시스템 정렬 보장으로 탐색성 향상

## 🎯 Key Review Points

1. **sdd 코드 변경**: `sources/bin/sdd` 1곳만 변경 (`printf '%02d'`). 나머지 파싱은 `[0-9]*`로 이미 호환
2. **대량 rename**: 186개 파일 변경이지만 대부분 `git mv` rename — 실제 content diff는 소량

## 🧪 Verification

```bash
bash tests/test-sdd-ship-completion.sh     # 8/8 PASS
bash tests/test-sdd-phase-done-accuracy.sh # 4/4 PASS
ls specs/ | head -20                       # phase 순서 = lexicographic 순서 일치
```

## 📦 Files Changed

### 🛠 Modified Files
- `sources/bin/sdd` / `.harness-kit/bin/sdd`: phase ID 생성에 `printf '%02d'` 추가
- `backlog/phase-{01..09}.md`: 리네이밍 + 내부 참조 갱신
- `backlog/queue.md`: 완료 섹션 참조 패딩 + Icebox 항목 제거
- `specs/spec-{01..09}-*`: 33개 디렉토리 리네이밍 + 내부 참조 갱신
- `sources/governance/`, `.harness-kit/agent/`: 예시 패딩

**Total**: 192 files changed (대부분 rename)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (12/12)
- [x] `ls specs/` 정렬 = numeric 순서
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-11.md`
- Walkthrough: `specs/spec-11-02-id-padding/walkthrough.md`
