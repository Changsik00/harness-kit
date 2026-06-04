---
description: 디렉터 모드 토글 — on/off/toggle/상태 조회
---

directorMode 를 변경합니다. 다음 명령을 실행하고 결과를 그대로 출력하세요:

```bash
bash .harness-kit/bin/sdd config director-mode $ARGUMENTS
```

on 시 디렉터 프로토콜(spec-20-02)이 적용됩니다.
인수 없이 호출하면 현재 상태를 조회합니다.
변경된 값은 다음 세션부터 적용됩니다.
