---
paths:
  - "lib/src/data/**/*.dart"
  - "build.yaml"
---

# Local DB (drift)

- drift lives in `lib/src/data/database/` (테이블당 파일 하나, `tables/`).
- `build.yaml` sets `store_date_time_values_as_text`, so `DateTime` columns are ISO-8601 TEXT (`DateTime.now()` → `2026-11-16T23:07:35.706 +09:00`).
- Schedule start/end store the picked day + the time of saving (same format as `created_at`); the repository turns them back into UTC-midnight dates for the app.
- Schema change → bump `schemaVersion` + add the step in `onUpgrade`.
- DB·API 클라이언트와 그 provider는 같은 파일에 둔다 (`providers/` 폴더 없음). Repository 구현체는 `data/repositories/<name>_repository_impl.dart`.
