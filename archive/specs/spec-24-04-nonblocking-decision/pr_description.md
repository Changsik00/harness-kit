feat(spec-24-04): non-blocking decisions (effective ux-mode + auto rule)

## 📋 Summary

### 배경 및 목적

auto 의 안전판(정지규칙 ②③ + 결정 로그)은 24-03 까지 완성됐다. 본 spec 은 auto 의 *핵심 동작* — ADR-009 규약 2 "결정 지점에서 멈추지 않고 기본값+로그로 진행" — 을 구현한다.

### 주요 변경 사항
- [x] **effective ux-mode resolver** — `sdd config ux-mode effective`: `mode=auto` 면 `text`(논블로킹 강제), 아니면 저장값. agent 의 ask-mode 해석 SSOT.
- [x] **agent.md §8.4 auto 규칙**(린) — 결정 지점 → 기본값 채택 + `sdd decision` 로깅, 미대기. ① 방향 모호 시에만 hard stop.

### Phase 컨텍스트
- **Phase**: `phase-24` (auto-mode)
- **본 SPEC 의 역할**: auto 가 *실제로 멈추지 않게* 하는 동작 규약. 정지규칙 ①(방향 모호)도 여기서 정의. 24-03(②③ 엔진·결정 로그) 위에 올라타 24-05(phase-ship 체크포인트)로 이어짐. (성공 기준 #2)

## 🎯 Key Review Points

1. **규율 방식**: 논블로킹 결정은 hook 이 아니라 *resolver + 거버넌스 서술* 로 규율(agent 가 `AskUserQuestion` 을 안 부르는 행위라 hook 으로 못 막음). 사후 검토는 `sdd decision`(24-03).
2. **기존 동작 불변**: `effective` 는 조기 return — `ux-mode` 조회/설정/toggle 경로 변경 없음(test-sdd-config 회귀 0).
3. **단어 예산**: agent.md +64w(7786→7850), 한도 8000 미만.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-ask-mode-auto.sh
cat sources/governance/constitution.md sources/governance/agent.md | wc -w   # 7850 ≤ 8000
```

**결과 요약**:
- ✅ `test-ask-mode-auto`: 5/5
- ✅ 회귀: test-sdd-config 7/7, test-mode-auto 6/6
- ✅ 전체 스위트: 71/71
- ✅ 거버넌스 단어수: 7850 / 8000

### 수동 검증 시나리오
1. `sdd mode auto` → `ux-mode effective` = `text` (저장값 interactive 여도)
2. `sdd mode governed` + interactive → `effective` = `interactive`

## 📦 Files Changed

### 🆕 New Files
- `tests/test-ask-mode-auto.sh`: effective resolver 테스트

### 🛠 Modified Files
- `sources/bin/sdd` (+ 미러): `config ux-mode effective` + help
- `sources/governance/agent.md` (+ 미러): §8.4 auto 논블로킹 결정 규칙
- `backlog/phase-24.md` / `backlog/queue.md`: spec 표 정합성 보정(24-01/02/03 Merged) + Icebox(sdd ship 미경유 머지 갭)

## ✅ Definition of Done

- [x] 모든 테스트 통과 (신규 5 + 전체 71/71) + 단어수 ≤ 8000
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint(shellcheck 미설치 — skip) / secret 통과
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-24.md`
- ADR: `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md` (auto 규약 2)
