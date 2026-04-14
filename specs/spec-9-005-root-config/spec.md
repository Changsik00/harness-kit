# Spec: spec-9-005 — rootDir config

## 개요

`harness.config.json`에 `rootDir` 필드를 추가하여 `sdd_find_root`의 상위 디렉토리 탐색을 제거한다.

## 배경 / 문제

`sdd_find_root`는 CWD에서 `/`까지 디렉토리를 하나씩 올라가며 `.harness-kit/installed.json` 또는 `.claude/state/current.json`을 찾는다. hooks가 실행될 때마다 이 탐색이 발생하고, Claude Code가 프로젝트 외부 디렉토리 접근 권한을 요청하게 된다.

## 목표

1. `install.sh` 실행 시 `harness.config.json`에 `rootDir`(절대 경로) 항상 기록
2. `sdd_find_root`가 `harness.config.json`의 `rootDir`를 직접 읽어 탐색 없이 반환
3. 권한 프롬프트 제거

## 스키마 변경

```json
{
  "rootDir": "/absolute/path/to/project",
  "backlogDir": "hk-backlog",
  "specsDir": "hk-specs"
}
```

- `rootDir`: 항상 기록 (prefix 여부 무관)
- `backlogDir` / `specsDir`: prefix 지정 시에만 추가 (기존 동작 유지)

## 성공 기준

1. `install.sh --yes` 실행 시 `harness.config.json`에 `rootDir` 기록됨
2. `sdd_find_root`가 탐색 없이 config에서 root를 반환함
3. 기존 테스트 전부 PASS
