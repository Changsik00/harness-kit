---
description: AskUserQuestion 모드 토글 — interactive ↔ text
---

uxMode 를 토글합니다. 다음 명령을 실행하고 결과를 그대로 출력하세요:

```bash
bash .harness-kit/bin/sdd config ux-mode toggle
```

`interactive` 면 AskUserQuestion UI 패널로 묻고, `text` 면 평문 `1)/2)` 형식으로 묻습니다.
변경된 값은 다음 세션부터 적용됩니다 (agent.md §8.4).
