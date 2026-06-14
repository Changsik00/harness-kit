# feat(spec-22-01): extend — Serena(LSP) opt-in 설치 커맨드

## 📋 Summary

### 배경 및 목적
Claude Code 기본 루프는 코드 탐색을 텍스트(`Grep`/`Read`)로 해 심볼 rename·find-references 같은 리팩토링이 LSP 기반 IDE 대비 느리고 토큰 왕복이 많다. LSP 코드 인텔리전스(Serena MCP)가 이를 개선하지만 MCP 는 상시 컨텍스트 비용이 들어, 키트의 "컨텍스트 비용 0 우선" 원칙·ceremony cost 절감 노력과 충돌한다. 이를 양립시키기 위해 **외부 도구를 opt-in(default-off)으로 붙이는 extend** 경로를 열고, 그 1호로 Serena 설치 커맨드를 제공한다.

### 주요 변경 사항
- [x] `sdd extend serena` 헬퍼 신설 — 선행조건 점검 / 스코프 검증(local·user) / `--dry-run` / 멱등 / `--remove`
- [x] 등록은 Claude Code 네이티브 `claude mcp add --scope` 에 위임 (키트가 설정 파일 직접 편집 안 함)
- [x] `/hk-extend` 슬래시 커맨드 — uxMode 분기 스코프 질문 후 헬퍼 호출
- [x] ADR-007 — extend opt-in 규약(default-off / 등록 위임 / 검증 3개 후 추출)
- [x] README extend 섹션 + 슬래시 커맨드 행

### Phase 컨텍스트
- **Phase**: `phase-22` (extend)
- **본 SPEC 의 역할**: extend 개념의 첫 구현이자 검증 대상. 레지스트리 추상화 없이 Serena 한 개를 정직하게 구현 → 후속 확장 누적 시 ADR-007 기준으로 일반화.

## 🎯 Key Review Points

1. **스코프 정책**: `local` 기본 / `user` 옵션 / 커밋되는 `.mcp.json`(`project`) 제외 — opt-in 원칙(켠 사람만 비용)을 지키는 핵심 결정.
2. **등록 위임**: 키트가 `~/.claude.json` 을 소유하지 않으므로 `installed.json` 흔적은 보조 기록이고 진짜 SSOT 는 `claude mcp list`. 이 분리가 의도적임.
3. **테스트 격리**: 외부 `uv`/`claude` 를 PATH stub + 상태파일로 모사하고 `PATH=/usr/bin:/bin` 으로 제한 — 머신 독립. `lib/extend.sh` 의 인용/공백 안전(배열 사용, eval 없음) 확인.
4. **Serena 실행 커맨드**: `uvx --from git+… serena start-mcp-server --context claude-code --project …` — 공식 문서 기준. uv 미설치 머신이라 end-to-end 는 미검증(이월).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-extend.sh
bash tests/run.sh --fast   # 회귀(매니페스트 정합 포함)
```

**결과 요약**:
- ✅ `test-extend` T1~T6: 통과 (스코프 거부 / 선행조건 graceful / dry-run / 등록·기록 / 멱등 / remove)
- ✅ `test-install-manifest-sync`: 통과 (커맨드 추가 자동 동기화)

### 수동 검증 시나리오
1. **dry-run**: `sdd extend serena --scope local --dry-run` → 구성될 `claude mcp add …` 출력, 부작용 없음
2. **선행조건 부재**: `uv` 없는 환경 → 안내 후 graceful 종료(비파괴), 등록 시도 없음

## 📦 Files Changed

### 🆕 New Files
- `sources/bin/lib/extend.sh`: `sdd extend` 헬퍼
- `sources/commands/hk-extend.md`: `/hk-extend` 슬래시 커맨드
- `docs/decisions/ADR-007-extend-opt-in.md`: extend opt-in 규약
- `tests/test-extend.sh`: 헬퍼 검증(6 케이스)
- `backlog/phase-22.md`, `specs/spec-22-01-extend-serena/*`: phase/spec 산출물

### 🛠 Modified Files
- `sources/bin/sdd` (+6): `extend` dispatch + lib source + help 항목
- `README.md` (+24): extend 섹션 + 커맨드 행

**Total**: 10 files changed (+789 / -1)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (test-extend 6/6)
- [x] 회귀(`tests/run.sh --fast`) 통과
- [x] `walkthrough.md` ship commit
- [x] `pr_description.md` ship commit
- [x] 사용자 검토 요청 (스코프 정책 / Serena 커맨드 핀)

## 🔗 관련 자료

- Phase: `backlog/phase-22.md`
- Walkthrough: `specs/spec-22-01-extend-serena/walkthrough.md`
- ADR: `docs/decisions/ADR-007-extend-opt-in.md`
