# spec-14-03: install.sh .gitignore 처리 라인별 멱등화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-14-03` |
| **Phase** | `phase-14` |
| **Branch** | `spec-14-03-gitignore-idempotent` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-25 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh:402-445` 의 `.gitignore` 갱신 로직:

```bash
GI="$TARGET/.gitignore"
touch "$GI"
# harness-kit 섹션이 없으면 추가
if ! grep -q '# harness-kit' "$GI"; then
  if [ $HK_GITIGNORE -eq 1 ]; then
    _hk_line=".harness-kit/"
  else
    _hk_line="!.harness-kit/"
  fi
  {
    echo ""
    echo "# harness-kit"
    echo "$_hk_line"
    echo ".harness-backup-*/"
    echo ".claude/state/"
  } >> "$GI"
else
  # 섹션이 이미 있는 경우: .harness-kit/ 관련 라인만 라인별 보강
  if [ $HK_GITIGNORE -eq 1 ]; then
    if ! grep -q '^\.harness-kit/$' "$GI"; then
      sed -i.tmp 's|^!\.harness-kit/$|.harness-kit/|' "$GI"
      if ! grep -q '^\.harness-kit/$' "$GI"; then
        echo ".harness-kit/" >> "$GI"
      fi
      rm -f "${GI}.tmp"
    fi
  else
    # ... 동일한 패턴, !.harness-kit/ 로 ...
  fi
fi
```

### 문제점

멱등성이 **`# harness-kit` 헤더 grep 한 번** 에만 의존하기 때문에 다음 시나리오에서 중복이 발생한다:

#### 시나리오 1 — 헤더 누락
1. 초기 install: `.gitignore` 에 `# harness-kit` + 4 라인 추가
2. 사용자가 어떤 이유로 `# harness-kit` 헤더 라인만 수동 삭제
3. 재install: 헤더 부재 → 4 라인 일괄 다시 append → **`.harness-kit/`, `.harness-backup-*/`, `.claude/state/` 모두 중복**

#### 시나리오 2 — 사용자 사전 라인
1. 사용자가 install 전에 `.gitignore` 에 `.harness-kit/` 라인을 미리 적어둠 (헤더 없이)
2. 첫 install: 헤더 부재 → 4 라인 일괄 추가 → **`.harness-kit/` 가 두 번** (사용자 라인 + 키트 추가 라인)

#### 시나리오 3 — 라인 일부 누락
1. 헤더 + `.harness-kit/` 만 있고, `.harness-backup-*/` 와 `.claude/state/` 가 없는 상태 (사용자 정리)
2. 재install: 헤더 존재 → `.harness-kit/` 라인만 라인별 처리, 나머지 두 라인은 **영구 누락**

### 해결 방안 (요약)

`.gitignore` 의 4 라인을 모두 라인별 멱등 처리. 각 라인을 정확 매치 (`^...$`) grep 으로 확인 후 부재 시에만 append. 헤더 (`# harness-kit`) 도 별도 라인 검증.

핵심 함수:

```bash
_gi_ensure_line() {
  local pattern="$1" line="$2"
  if ! grep -qE "$pattern" "$GI"; then
    echo "$line" >> "$GI"
  fi
}
```

토글 (`.harness-kit/` ↔ `!.harness-kit/`) 은 sed 로 변환 후 grep — 변환 결과가 이미 있으면 추가 안 함.

## 🎯 요구사항

### Functional Requirements

1. `install.sh:402-445` 를 라인별 멱등 로직으로 재작성. 4 라인 각각:
   - `# harness-kit` (헤더)
   - `.harness-kit/` 또는 `!.harness-kit/` (gitignore 옵션에 따라)
   - `.harness-backup-*/`
   - `.claude/state/`
2. 같은 `.gitignore` 에 `bash install.sh` 를 N 회 실행해도 4 라인 각각이 정확히 1 회 존재 (`grep -c` 로 검증).
3. 사용자가 헤더만 수동 삭제 후 재install: 헤더 1 회 + 4 라인 각각 1 회 (중복 0).
4. 사용자가 `.harness-kit/` 를 미리 적어둔 후 첫 install: 그 라인 1 회 + 헤더 + 나머지 라인.
5. 라인 일부 누락 후 재install: 누락된 라인만 보강.
6. `--gitignore` 와 `--no-gitignore` 토글 시 `.harness-kit/` ↔ `!.harness-kit/` 정확히 변환 (둘이 동시에 존재하지 않음).
7. 회귀 테스트 추가 — `tests/test-gitignore-idempotent.sh` (기존 `test-gitignore-config.sh` 의 D 시나리오 확장).

### Non-Functional Requirements

1. **하위 호환**: 기존 사용자 환경 (헤더 + 4 라인 정상) 에서 재install 결과 변화 없음.
2. **사용자 커스텀 라인 보존**: 키트가 추가하지 않은 라인 (예: `node_modules/`) 은 절대 건드리지 않음.
3. **bash 3.2 호환** (spec-14-02 정책 준수): associative arrays / mapfile 사용 금지. 단순 grep + echo + sed 조합.

## 🚫 Out of Scope

- `update.sh` 의 gitignore 처리 — 이미 옵션 보존만 하고 install.sh 를 위임 호출하므로 본 spec 의 변경이 자동 반영됨.
- `.gitignore` 외 다른 파일의 멱등성 (CLAUDE.md, settings.json 등) — 본 phase 의 다른 spec 에서 다룸.
- `sdd_marker_append` 의 멱등화 — 본 spec 은 `install.sh` 의 .gitignore 만. marker 영역은 spec-14-04.
- gitignore 라인 자체의 정책 변경 (`.harness-backup-*/` 같은 라인 추가/제거) — 멱등화만 다룸.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = no 이므로 해당 사항 없음)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-14-03-gitignore-idempotent` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
