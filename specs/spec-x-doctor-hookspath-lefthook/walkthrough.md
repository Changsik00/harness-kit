# Walkthrough: spec-x-doctor-hookspath-lefthook

> GitHub Issue #161 대응 — lefthook × core.hooksPath 충돌을 doctor 가 조기 진단.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 대응 방식 | 자동 unset / 진단·안내 / 네이티브 통합 | 진단·안내(warn) | 실패 원인은 사용자 hooksPath 라 harness 가 직접 못 고침. 진단+가이드가 최대 레버리지 |
| 감지 위치 | sdd doctor only / 양쪽 | sdd doctor + 루트 doctor.sh | 일상 진단은 sdd doctor, update 시엔 루트 doctor.sh — 둘 다 target repo 대상이라 일관성 필요 |
| 감지 조건 | hooksPath 설정만 / lefthook AND hooksPath | lefthook AND hooksPath | 소음 방지 — lefthook 없으면 hooksPath 설정은 이 이슈와 무관 |
| 네이티브 통합(#2) | 지금 구현 / Icebox | Icebox 보류 | bash YAML 편집 비용 + 사용자 파일 침습, NestJS 1차 타깃. over-engineering 회피 |

### ADR 승격 가이드
- [ ] 있음
- [x] 없음

## 💬 사용자 협의

- **주제**: issue #161 대응 범위
  - **합의**: ① doctor 감지(now) + ② lefthook 네이티브 통합(Icebox) + ③ 이슈에 정정 코멘트 게시 — 사용자 "그대로 진행" 승인

## 🧪 검증 결과

### 자동화 테스트 (단위)

| 테스트 | 결과 |
|---|---|
| `test-doctor-hookspath-lefthook.sh` (신규) | ✅ 4/4 (sdd doctor warn / 루트 doctor.sh warn / 정상 pass / lefthook 미사용 무경고) |
| `test-hk-doctor.sh` | ✅ 7/7 (회귀) |
| `test-doctor-wiki.sh` | ✅ (회귀) |

```text
test-doctor-hookspath-lefthook: PASS 4 FAIL 0
```

### 수동 검증
1. **Action**: temp git repo + `lefthook.yml` + `git config --local core.hooksPath <repo>/.git/hooks` → `sdd doctor`
   - **Result**: `⚠ lefthook + core.hooksPath 충돌 — git config --unset --local core.hooksPath (issue #161)` 출력
2. **Action**: hooksPath unset 후 재실행
   - **Result**: `✓ lefthook 환경 — core.hooksPath 미설정 (정상)`

## 🔍 발견 사항

- **리포트 근본 원인 정정**: #161 본문은 "harness 가 core.hooksPath 를 설정한다"고 추정했으나, 소스 전수 grep(`core.hooksPath` → 0건) 결과 **harness 는 절대 건드리지 않음**. harness 는 `.git/hooks/pre-commit` 에 블록 append 만 한다(`install.sh:305-333`). 따라서 리포트 제안 #1(hooksPath 미설정)은 무의미 — 이슈에 정정 코멘트 게시함.
- **실제 실패는 harness 외부 원인**: lefthook v2.x 가 hooksPath 명시 설정 시 install 거부 → 이건 사용자가 unset 해야만 풀림. harness 가 할 수 있는 최선은 "모호한 turbo 실패를 1줄 진단으로 전환".
- **별개 fragility 발견**: `.git/hooks/pre-commit` append 방식은 이후 `lefthook install` 디스패처 재생성 시 harness 블록이 덮일 수 있음 → Icebox(#2 네이티브 통합)로 캡처.
- 이번 변경은 spec-x-harness-footguns 의 "감지→행동 연결" 패턴과 같은 결(install drift 경고 ↔ hooksPath 충돌 경고).

## 🚧 이월 항목

- **lefthook 네이티브 hook 통합** → `backlog/queue.md` Icebox 추가 (#2, fragility 근본 해소용)
- core.hooksPath 가 비-기본 경로라 harness hook 이 아예 실행 안 되는 별개 footgun → 추후 검토

## 🔗 관련 문서 (Related)

- GitHub Issue: #161 (+ 정정 코멘트)
- 관련: [[spec-x-harness-footguns]] (install drift 감지)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-30 |
| **최종 commit** | (ship 시 갱신) |
