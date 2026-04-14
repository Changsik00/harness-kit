# Walkthrough: spec-9-002

> 본 문서는 *증거 로그* 입니다. "무엇을 했고 어떻게 검증했는지" 를 미래의 자신과 리뷰어에게 남깁니다.

## 📋 실제 구현된 변경사항

- [x] `sources/claude-fragments/CLAUDE.md.fragment` → `CLAUDE.fragment.md` 파일명 변경 + 내용 정리 (HARNESS-KIT 마커 제거, `.harness-kit/agent/` 경로 수정)
- [x] `install.sh` Section 15 전면 교체: 블록 직접 삽입 → 3줄 @import + `.harness-kit/CLAUDE.fragment.md` 복사
- [x] `update.sh`: 일반 업데이트 및 v0.3 마이그레이션 시 CLAUDE.md 백업 추가
- [x] `tests/test-two-tier-loading.sh`: FRAGMENT 변수 경로 `CLAUDE.md.fragment` → `CLAUDE.fragment.md` 업데이트
- [x] 도그푸딩: 이 프로젝트 `CLAUDE.md` HARNESS-KIT 블록을 3줄 @import로 전환, `.harness-kit/CLAUDE.fragment.md` 생성

## 🧪 검증 결과

### 1. 자동화 테스트

#### test-install-claude-import.sh (TDD Red→Green)
- **명령**: `bash tests/test-install-claude-import.sh`
- **결과**: ✅ ALL PASS (6/6)
- **로그 요약**:
```text
✅ .harness-kit/CLAUDE.fragment.md 존재
✅ CLAUDE.md 에 @.harness-kit/CLAUDE.fragment.md 존재
✅ 규약 내용 직접 삽입 없음 (올바른 @import 방식)
✅ fragment 에 핵심 규칙 요약 존재
✅ @import 줄 1개 (중복 없음)
✅ 기존 CLAUDE.md 내용 보존됨
```

#### 전체 테스트 (40 checks)
- `test-hook-modes.sh`: 12/12 PASS
- `test-install-layout.sh`: 7/7 PASS
- `test-install-claude-import.sh`: 6/6 PASS
- `test-governance-dedup.sh`: 8/8 PASS
- `test-two-tier-loading.sh`: 7/7 PASS

### 2. 수동 검증

1. **Action**: 임시 repo에 `install.sh --yes` 실행
   - **Result**: `.harness-kit/CLAUDE.fragment.md` 생성, `CLAUDE.md`에 3줄만 삽입
2. **Action**: 구 방식 블록이 있는 CLAUDE.md에 `install.sh --yes` 재실행
   - **Result**: 기존 블록 → @import 3줄로 교체, 사용자 내용 보존
3. **Action**: `install.sh --yes` 연속 2회 실행
   - **Result**: `@import` 줄 중복 없음 (멱등성 확인)

## 🔍 발견 사항

- update.sh는 install.sh를 재실행하는 구조라 별도 CLAUDE.md 마이그레이션 로직 불필요 — install.sh가 구 방식 블록을 자동으로 @import로 교체함
- fragment 파일에서 `<!-- HARNESS-KIT:BEGIN/END -->` 마커를 제거하는 것이 핵심 — fragment는 이제 독립 파일로 로딩되므로 마커 불필요

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + ck |
| **작성 기간** | 2026-04-14 ~ 2026-04-14 |
| **최종 commit** | `ce47970` |
