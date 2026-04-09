# harness-kit

> Claude Code 를 위한 SDD (Spec-Driven Development) 거버넌스 부트스트랩 툴킷.
> 한 번 만들어두고, 다음 프로젝트에서는 한 줄로 같은 하네스를 깐다.

**Version**: 0.1.0 (alpha — 자기 자신을 만드는 중)

---

## 무엇을 하는 키트인가

Claude Code 를 그냥 켜면 강력한 일반 비서지만, *반복 가능한 절차* 와 *위반 방지* 는 약합니다. 이 키트는 그 격차를 메꿉니다.

- **거버넌스** — `constitution.md`, `agent.md` 로 에이전트의 행동 규약을 명시
- **템플릿** — Spec/Plan/Task/Walkthrough/PR 산출물 양식
- **슬래시 커맨드** — `/align`, `/spec-new`, `/plan-accept`, `/spec-status`, `/handoff`
- **Hook** — main 브랜치 보호, plan-accept 검증, 테스트 미실행 커밋 차단 (경고 모드 → 차단 모드)
- **`bin/sdd` 메타 명령** — 사람과 AI 가 같은 인터페이스로 SDD 진행
- **`install.sh`** — 대상 프로젝트에 한 번에 설치

## 설계 원칙

1. **Context Budget First** — 시스템 프롬프트에 들어가는 토큰은 비용. 가능한 모든 것을 *지연 로딩* 또는 *호출 시점*으로
2. **Cost Order: Shell > Skills > Slash > MCP** — 같은 효과면 컨텍스트 비용이 적은 쪽
3. **Enforcement > Guideline** — "MUST" 라고 적기보다 코드로 막을 수 있으면 막는다
4. **Reproducibility** — 슬래시 한 번 = 항상 같은 결과
5. **Korean Docs** — 사용자 본인의 빠른 검토를 위해

## 디렉토리 구조

```
harness-kit/
├── README.md                  # 이 파일
├── VERSION                    # 키트 버전
├── install.sh                 # 대상 프로젝트에 설치 (TODO)
├── uninstall.sh               # 정리 (TODO)
├── doctor.sh                  # 환경 점검 (TODO)
├── update.sh                  # 기존 설치 갱신 (TODO)
│
├── sources/                   # 키트 원본 source
│   ├── governance/            # constitution, agent, align
│   ├── templates/             # phase, spec, plan, task, walkthrough, pr_description
│   ├── commands/              # 슬래시 커맨드 (TODO)
│   ├── hooks/                 # 후크 스크립트 (TODO)
│   ├── bin/                   # bin/sdd 메타 명령 (TODO)
│   └── claude-fragments/      # .claude/settings.json, CLAUDE.md fragments (TODO)
│
├── stacks/                    # 언어/프레임워크 어댑터 (TODO)
│   ├── nestjs.sh
│   ├── nodejs.sh
│   └── generic.sh
│
├── tests/                     # 키트 자체 테스트
│   └── fixtures/
│
└── docs/
    ├── design/                # 설계 근거
    ├── decisions/             # ADR
    ├── USAGE.md               # 사용자 가이드 (TODO)
    └── REFERENCE.md           # 명령어 레퍼런스 (TODO)
```

## 설치 방법 (목표)

> ⚠️ **현재는 alpha 단계**. install.sh 가 아직 없습니다. Phase 3 에서 작성됩니다.

설계상 3가지 방식을 지원할 예정:

```bash
# 방법 1: 디렉토리 통째 복사
cp -r ~/Project/ai/claude ~/new-project/scripts/harness-kit
cd ~/new-project && ./scripts/harness-kit/install.sh

# 방법 2: 절대 경로로 직접 호출
~/Project/ai/claude/install.sh ~/new-project

# 방법 3: Claude Code 에 위임
# 새 프로젝트에서 claude 켜고 "~/Project/ai/claude 의 하네스 키트 설치해줘" 라고 말함
```

## 도그푸딩

본 키트의 **첫 사용자는 `nextmarket-api`** 입니다 (NestJS + StepPay 결제 프로젝트).
키트가 완성되는 즉시 그곳에 install 해 보고, 미흡한 부분을 키트로 환류합니다.

## 현재 진행 상태

- ✅ Phase 1: 이관 (nextmarket-api → harness-kit)
- ✅ Phase 2: 골격 구축
- ⏸ Phase 3: 툴킷 빌드 (8 SPEC, 사용자 승인 대기)
- ⏸ Phase 4: 도그푸딩 (nextmarket-api 에 install)
- ⏸ Phase 5: 개선 루프

## 라이선스

미정.
