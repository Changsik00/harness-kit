# Implementation Plan: spec-9-009

## 📋 Branch Strategy

- 신규 브랜치: `spec-9-009-preflight-ux`
- 시작 지점: `phase-9-install-conflict-defense`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] critique 반영: inline 방식으로 전환 (별도 preflight.sh 없음)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **구조** | inline (별도 파일 없음) | 공통 로직이 1-2개뿐, critique 권장 |
| **semver 비교** | cleanup.sh의 `semver_lt()` 패턴 복사 | 검증 완료된 구현 재사용 |
| **차단 수준** | 경고만 (exit 0) | 사용자 판단 존중 |

## 📂 Proposed Changes

### install.sh

#### [MODIFY] `install.sh`

기존 사전 점검 섹션(jq/OS/git 확인) 뒤에 preflight 블록 추가:

```text
# ── preflight 스캔 ────────────────────────────
_warn_count=0

# 이미 설치됨?
if [ -f "$TARGET/.harness-kit/installed.json" ]; then
  warn "이미 설치됨 — update.sh 사용 권장"
  _warn_count=$((_warn_count + 1))
fi

# v0.3 잔재?
if [ -f "$TARGET/agent/constitution.md" ] || [ -f "$TARGET/scripts/harness/bin/sdd" ]; then
  warn "v0.3 레이아웃 감지 — update.sh로 마이그레이션 권장"
  _warn_count=$((_warn_count + 1))
fi

# 기존 hooks?
if [ -f "$TARGET/.claude/settings.json" ] && jq -e '.hooks' "$TARGET/.claude/settings.json" >/dev/null 2>&1; then
  log "ℹ 기존 hooks 설정 있음 (키트가 덮어씀)"
fi

# 경고 있으면 추가 확인
if [ $_warn_count -gt 0 ] && [ $ASSUME_YES -eq 0 ] && [ $DRY_RUN -eq 0 ]; then
  printf "경고가 있습니다. 계속 진행할까요? [y/N] "
  read -r _ans < /dev/tty 2>/dev/null || _ans=""
  case "$_ans" in y|Y) ;; *) log "취소됨"; exit 0 ;; esac
fi
```

### update.sh

#### [MODIFY] `update.sh`

버전 표시 후, 기존 확인 프롬프트 전에 preflight 블록 추가:

```text
# semver 비교 함수 (cleanup.sh에서 가져옴)
semver_lt() { ... }

# ── preflight 스캔 ────────────────────────────
_warn_count=0

# 다운그레이드?
if semver_lt "$NEW_VER" "$PREV_VER"; then
  warn "다운그레이드: $PREV_VER → $NEW_VER"
  _warn_count=$((_warn_count + 1))
fi

# v0.3 잔재?
if [ -f "$TARGET/agent/constitution.md" ] || [ -f "$TARGET/scripts/harness/bin/sdd" ]; then
  warn "v0.3 레이아웃 잔재 감지 — cleanup 대상"
  _warn_count=$((_warn_count + 1))
fi
```

#### [MODIFY] `update.sh` — state 복원 graceful fallback

기존 state 복원 로직에 jq 파싱 실패 시 fallback 추가:

```text
if command -v jq >/dev/null 2>&1 && [ -f "$_STATE" ]; then
  _tmp="$(mktemp)"
  if jq ... "$_STATE" > "$_tmp" 2>/dev/null; then
    mv "$_tmp" "$_STATE"
    ok "state 복원 완료"
  else
    warn "state 복원 실패 — 기본값으로 초기화"
    rm -f "$_tmp"
  fi
fi
```

### 테스트

#### [NEW] `tests/test-preflight.sh`

- 시나리오 1: 깨끗한 디렉토리 → preflight 경고 0
- 시나리오 2: 이미 설치된 디렉토리 → ⚠ "이미 설치됨"
- 시나리오 3: v0.3 잔재 → ⚠ "v0.3 레이아웃 감지"
- 시나리오 4: version downgrade → ⚠ "다운그레이드"

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-preflight.sh
```

### 기존 테스트 회귀 확인
```bash
bash tests/test-install-layout.sh
bash tests/test-update.sh
```

## 🔁 Rollback Plan

- preflight는 읽기 전용 체크이므로 해당 블록 제거만으로 원복

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
