---
description: 프로젝트 정리 — 동기화 불일치, 잔여 파일, stale 요소 감지 및 정리
---

harness-kit 설치 후 누적된 불필요 요소를 감지하고 정리합니다.
에이전트는 각 항목을 **보고만** 하고, 삭제/수정은 사용자 승인 후 진행합니다.

## 1. 파일 동기화 불일치 감지

다음 쌍이 일치하는지 확인합니다:

### 1-1. 슬래시 커맨드 동기화
```bash
# sources/commands/ 에 있는데 .claude/commands/ 에 없는 파일
diff <(ls sources/commands/ | sort) <(ls .claude/commands/ | sort)
```

불일치 발견 시:
```
⚠️ 슬래시 커맨드 동기화 불일치:
  - sources/commands/hk-foo.md → .claude/commands/ 에 없음
  - .claude/commands/hk-bar.md → sources/commands/ 에 없음 (삭제 후보)
```

### 1-2. 거버넌스 동기화
```bash
diff sources/governance/constitution.md .harness-kit/agent/constitution.md
diff sources/governance/agent.md .harness-kit/agent/agent.md
diff sources/governance/align.md .harness-kit/agent/align.md
```

### 1-3. 템플릿 동기화
```bash
diff <(ls sources/templates/ | sort) <(ls .harness-kit/agent/templates/ | sort)
```

불일치 발견 시 `cp sources/... .harness-kit/agent/...` 로 동기화를 제안합니다.

## 2. 잔여 파일/디렉토리 감지

```bash
# 백업 디렉토리
ls -d .harness-backup-* 2>/dev/null

# 임시/백업 파일
find . -name '*.bak' -o -name '*.tmp' -o -name '*.orig' -o -name '*.old' -o -name '*.swp' -o -name '.DS_Store' 2>/dev/null | grep -v node_modules | grep -v .git

# 빈 디렉토리 (gitkeep 없는)
find . -type d -empty -not -path './.git/*' 2>/dev/null
```

발견 시:
```
🗑 잔여 파일/디렉토리:
  - .harness-backup-20260410-130103/ (160K)
  - tests/fixtures/ (빈 디렉토리)
삭제할까요? [Y/n]
```

## 3. sdd 바이너리 동기화

```bash
diff .harness-kit/bin/sdd sources/bin/sdd
```

불일치 시 어느 쪽이 최신인지 git log로 판단하여 동기화 방향을 제안합니다.

## 4. State 정합성 검사

```bash
bash .harness-kit/bin/sdd status --json
```

- `phase` 가 설정되어 있는데 해당 `backlog/phase-{N}.md` 파일이 없는 경우
- `spec` 이 설정되어 있는데 해당 `specs/spec-*/` 디렉토리가 없는 경우
- `baseBranch` 가 설정되어 있는데 해당 remote 브랜치가 없는 경우

## 5. 결과 보고

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧹 Cleanup Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  동기화 불일치: N건
  잔여 파일:     N건
  State 이상:    N건
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**모든 항목이 정상이면**:
```
✅ Clean — 정리할 항목 없음
```

**정리 필요 시** 항목별로 사용자 승인을 받고 실행합니다.
