# Research: ActivityWatch server, Python (aw-server) vs Rust (aw-server-rust)

**Date:** 2026-10-08
**Installed:** ActivityWatch 0.14.0 classic bundle (aw-qt), `/Applications/ActivityWatch.app`, Apple Silicon, macOS 27
**Primary sources:** the [aw-server](https://github.com/ActivityWatch/aw-server), [aw-server-rust](https://github.com/ActivityWatch/aw-server-rust), [aw-qt](https://github.com/ActivityWatch/aw-qt), [aw-core](https://github.com/ActivityWatch/aw-core), [aw-webui](https://github.com/ActivityWatch/aw-webui) and [activitywatch](https://github.com/ActivityWatch/activitywatch) repos, the [docs repo](https://github.com/ActivityWatch/docs) / [docs.activitywatch.net](https://docs.activitywatch.net), the v0.14.0 release notes and blog posts, plus measurements on this machine.

## Verdict: switch, with caveats. Now is the cheapest time to do it.

- **Your claim is correct.** ActivityWatch says in several places that aw-server-rust is the planned default. The current wording is in the v0.14.0 docs: aw-server-rust "is the future default" ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)). They give no date. v0.14.0 (2026-10-06) still makes the Python server the default in the classic app, and aw-server-rust is the default only in the experimental Tauri app ([release notes](https://github.com/ActivityWatch/activitywatch/releases/tag/v0.14.0)).
- **For you:** your database is small (11 MB, about 18k events since 2026-09-01). Speed is therefore not the reason to switch, although on your own data aw-server-rust ran the same queries 7 to 20 times faster (§4). The real reasons:
  1. The server you run is going away as the default.
  2. aw-server-rust already includes a heartbeat-merge fix. The Python server in the 0.14.0 bundle does not have that fix, and it matters for watchers that aw-qt restarts (§7).
  3. aw-server-rust already returns the `merge_events_by_keys` results that the next Python release will switch to (§2).
  4. The move only gets more expensive as data piles up.
- **Caveats:**
  1. Your categories and dashboards (`settings.json`) are **not** migrated automatically. You must copy them yourself (§3).
  2. You lose the Swagger API browser at `/api/`.
  3. aw-server-rust used more resident memory in a single, unscientific sample (§4).
  4. Rolling back loses whatever was written while on Rust, unless you export it and import it again.

## Comparison table

| Topic | aw-server (Python), your current server | aw-server-rust |
|---|---|---|
| Official status | Default in the classic (aw-qt) app ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)) | "the future default"; default in aw-tauri; also bundled in the classic app ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)) |
| In your bundle | `Contents/MacOS/aw-server` (running) | `Contents/Frameworks/aw-server-rust`, reports `aw-server 0.14.0` (local check) |
| REST API, web UI, queries, settings, import/export | yes | yes ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)) |
| Query cache for finished days | yes | yes, but All-time is not cached on large DBs ([aw-server-rust#784](https://github.com/ActivityWatch/aw-server-rust/issues/784)) |
| API key auth | no | yes ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)) |
| Swagger API browser at `/api/` | yes | no ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html), [README](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/README.md)) |
| Timestamp precision | milliseconds | nanoseconds ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)) |
| Data store | `~/Library/Application Support/activitywatch/aw-server/peewee-sqlite.v2.db` | `~/Library/Application Support/activitywatch/aw-server-rust/sqlite.db` ([dirs.rs](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/dirs.rs#L649-L656)) |
| Settings (categories, views) | `aw-server/settings.json` file ([settings.py](https://github.com/ActivityWatch/aw-server/blob/ce55bbd432550d8b911226d9093e462467d1e8db/aw_server/settings.py#L15)) | key/value rows inside `sqlite.db`, **not** imported from `settings.json` |
| Default port | 5600 (testing 5666) | 5600 (testing 5666) ([config.rs](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/config.rs#L148-L154)) |
| Heartbeat merge after out-of-order heartbeat | buggy in 0.14.0; fixed on master after the release ([aw-server#177](https://github.com/ActivityWatch/aw-server/pull/177)) | fixed since 2026-01 ([aw-server-rust#555](https://github.com/ActivityWatch/aw-server-rust/pull/555)), included in 0.14.0 |
| `merge_events_by_keys` output | keeps only the key fields; keeps events that lack the key (0.14.0) | keeps all data of the first event; drops events that lack a key. Python master now matches ([aw-core#173](https://github.com/ActivityWatch/aw-core/pull/173)) |
| Speed on your data (median, §4) | 42–418 ms | 3–49 ms |
| RSS on your machine (§4, single sample) | 37 MB idle, about 87 MB after queries | about 109 MB after import, 158 MB after queries |
| Open issues / open PRs (2026-10-08) | 15 / 22 | 41 / 45 |
| Last commit | 2026-10-06 | 2026-10-06 |

## 1. Official stance: is aw-server-rust the planned default?

**Yes. This is verified, and it has been the plan since 2020.** Statements from oldest to newest:

| Date | Where | Wording | Author |
|---|---|---|---|
| 2020-04-28 | [activitywatch#424 "The Great Migration"](https://github.com/ActivityWatch/activitywatch/issues/424) (still open) | "**bundle: aw-server-python to aw-server-rust** — This is the big one. aw-server-rust has been properly battle-tested by now (especially in aw-android) and is ready to become the default." It also says the Python peewee→sqlite migration was "indefinitely postponed in favor of switching to aw-server-rust". | ErikBjare (maintainer) |
| 2020-05-22, updated 2022-06-08 | [docs: Migrating](https://docs.activitywatch.net/en/latest/migrating.html) ([source](https://github.com/ActivityWatch/docs/blob/master/src/migrating.rst)) | "In an upcoming version, ActivityWatch will switch the default server implementation from aw-server … to aw-server-rust. The reason for this is that aw-server-rust has far superior performance, and has almost full feature parity" | Erik Bjäreholt |
| 2021-09-16 | [aw-server README](https://github.com/ActivityWatch/aw-server/blob/ce55bbd432550d8b911226d9093e462467d1e8db/README.md?plain=1#L10), added in [aw-server#78](https://github.com/ActivityWatch/aw-server/pull/78) | "In the future this will no longer be the default server used by ActivityWatch, instead we will be using aw-server-rust. The fate of this repo is uncertain, but it will likely be around and maintained for a while" | Michael Bianco (merged into the official repo) |
| 2025-08-20 | [activitywatch README](https://github.com/ActivityWatch/activitywatch/blob/15705a798ef4e5bb938fd9a1bcbf5dcc1c865dfc/README.md?plain=1#L255) (commit bd4c5e6) | "`aw-server-rust` - A Rust implementation that is the planned future default" | Erik Bjäreholt |
| 2026-10-06 | [docs: Server comparison](https://docs.activitywatch.net/en/latest/server-compare.html) ([docs#200](https://github.com/ActivityWatch/docs/commit/7bac302543e600da9eff1600b9f96e5b28f2fc37)) | aw-server is "the default server in the classic app (aw-qt)". aw-server-rust is "the server in the new Tauri app (aw-tauri), also bundled with the classic app. **It is the future default.**" | docs, v0.14.0 update |

**Is it already the default anywhere?** Yes, in **aw-tauri**. The v0.14.0 release notes say the Tauri app "runs the Rust server inside the app". The Tauri blog post says: "With aw-server-rust as the default server, it leads to a reliable and highly performant application" ([introducing-tauri](https://activitywatch.net/blog/introducing-tauri/)). It is also the only server on Android ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)).

**What has not happened yet:** in v0.14.0 the classic app "ships too and stays the default", because the Tauri app is "less battle-tested so far" ([release notes](https://github.com/ActivityWatch/activitywatch/releases/tag/v0.14.0), [v0.14.0 announcement](https://activitywatch.net/blog/activitywatch-v0-14-0/)). The Python server is still being maintained: it got commits on 2026-10-06, including fixes after the release. I found no date or version for the switch, and no announcement that the Python server will be deprecated. *Unverified:* when the switch will happen.

## 2. Feature parity

- **REST API.** aw-server-rust mounts `/api/0/info`, `/api/0/buckets` (CRUD, events, heartbeat, count, CSV/JSON export), `/api/0/query`, `/api/0/import`, `/api/0/export` and `/api/0/settings` ([endpoints/mod.rs](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/endpoints/mod.rs#L244-L285)). The docs list REST API, web UI, queries, settings and import/export as ✅ for both servers ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)).
- **What only one of them has:**
  - Only Python: the interactive API browser at `/api/`.
  - Only Rust: API-key auth, SQLCipher encryption (opt-in build feature, not in release builds) and Android ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)).
  - The aw-server-rust README lists only the Swagger/OpenAPI explorer as missing ([README](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/README.md)).
- **Query2.** Since v0.14.0, a parity test suite (`scripts/tests/query_parity/` in the activitywatch repo) runs both servers on the same events and compares every transform plus the canonical web UI and aw-client queries ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)). The documented differences that remain:
  - Timestamp precision (ms vs ns).
  - The output shape of `merge_events_by_keys`, `split_url_events` and `tag`. Python drops fields that are not merge keys, so on aw-server the web UI lists that color rows by category show default colors. "aw-server is being changed to match aw-server-rust" ([aw-core#173](https://github.com/ActivityWatch/aw-core/pull/173), [activitywatch#1466](https://github.com/ActivityWatch/activitywatch/issues/1466)). aw-core#173 was merged on 2026-10-06 **after** the commit that v0.14.0 pins (`b1f04b5`, 2026-09-27; checked with `git ls-tree v0.14.0 aw-core`). Your Python server therefore still has the old behavior, and the next release will change it anyway.
  - `chunk_events_by_key` is deprecated in both servers.
- **Old missing-query-features issue:** every item in [aw-server-rust#66](https://github.com/ActivityWatch/aw-server-rust/issues/66) is checked off.
- **Web UI.** Both bundle aw-webui. The v0.14.0 submodule commit of aw-server-rust (`f4b4a1a`, 2026-10-06) is "build(deps): updated aw-webui". *Unverified:* whether the two bundled webui builds are byte-identical.

## 3. Storage and migration

- **Python:** a peewee SQLite DB at `~/Library/Application Support/activitywatch/aw-server/peewee-sqlite.v2.db`, currently 11 MB plus a 4 MB WAL. Settings are a separate JSON file in the config dir, `aw-server/settings.json` ([settings.py#L15](https://github.com/ActivityWatch/aw-server/blob/ce55bbd432550d8b911226d9093e462467d1e8db/aw_server/settings.py#L15)). Your `settings.json` holds `classes` (categories), `views` (dashboards), `active_set_ids` and UI preferences.
- **Rust:** its own schema at `<data_dir>/activitywatch/aw-server-rust/sqlite.db`. On macOS, `dirs::data_dir()` is `~/Library/Application Support`. Its config is `config.toml` in the same folder ([dirs.rs](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/dirs.rs#L86-L108)). Settings are stored as rows inside the DB ([endpoints/settings.rs](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/endpoints/settings.rs)).
- **The two servers do not share data.** The docs say they "store data in their own databases" ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)).
- **Automatic import.** On first start, when no Rust DB exists, aw-server-rust imports the Python peewee DB ([migrating](https://docs.activitywatch.net/en/latest/migrating.html)). The code runs this only for the default profile and only when `--dbpath` is not given ([main.rs#L198](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/main.rs#L198)). The import:
  - reads `bucketmodel` (key, id, type, client, hostname, created) and events. It does **not** read bucket `datastr` ([legacy_import.rs#L119](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-datastore/src/legacy_import.rs#L119)). That loses nothing for you, because none of your buckets has non-empty `datastr` (local query).
  - deduplicates on master, so a rerun is idempotent ([legacy_import.rs](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-datastore/src/legacy_import.rs)).
  - runs only once. If a Rust DB already exists, it is skipped. To run it again, move the Rust DB away ([migrating](https://docs.activitywatch.net/en/latest/migrating.html)).
- **Settings are not migrated.** Nothing in the import code or the server reads `settings.json`: grepping aw-server-rust for `settings.json` finds only client-side helpers. The web UI loads settings from the server and **falls back to browser localStorage** for keys the server lacks. It then saves what it shows back to the server ([aw-webui settings.ts](https://github.com/ActivityWatch/aw-webui/blob/master/src/stores/settings.ts)). If you open the web UI on a Rust server with no settings, it can therefore pick up stale localStorage values and write them back. Copy the settings **before** you open the web UI (step 6 below).
- **Manual alternative:** "Export all" / "Import all" in the web UI, or `GET /api/0/export` then `POST /api/0/import` ([migrating](https://docs.activitywatch.net/en/latest/migrating.html)). I tested the API route on your data and it worked (§4).
- **Going back:** "Importing an aw-server-rust export into aw-server-python is untested and might break in unexpected ways" ([migrating](https://docs.activitywatch.net/en/latest/migrating.html)). The DB schema migrations of aw-server-rust "may mean that you can't downgrade" ([migrating](https://docs.activitywatch.net/en/latest/migrating.html)).

## 4. Performance and resource use

**Official benchmark** (v0.14.0; 9-year DB with 9.2M events, 1.8 GB, on an M2 Mac; Year view as 365 daily queries) ([release notes](https://github.com/ActivityWatch/activitywatch/releases/tag/v0.14.0), [server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)):

| Server | First load | Repeat load |
|---|---:|---:|
| aw-server (Python) | 41 s | 0.6 s |
| aw-server-rust | 32 s | 0.2 s |

- With the old single-request Year query, the two took 120 s (Python, which timed out) and 19 s (Rust).
- aw-server-rust does not yet cache All-time views on large DBs ([aw-server-rust#784](https://github.com/ActivityWatch/aw-server-rust/issues/784)).
- A 2020 user report on migrating said a monthly review dropped from 30–40 s to 10 s ([aw-server-rust#139](https://github.com/ActivityWatch/aw-server-rust/issues/139)).

**Measured on your data (2026-10-08).** Method:
1. Exported all buckets from the live Python server: `GET /api/0/export`, 10 MB, 0.68 s.
2. Ran the bundled `aw-server-rust` on a scratch DB on port 5699, with `--dbpath` (no auto-import) and a scratch `-c` config.
3. Imported the export: `POST /api/0/import`, 0.13 s.
4. Ran each query 5× against both servers over 2026-09-01 → 2026-10-09.

The scratch server was then stopped. Its scratch DB lives only in the session scratchpad. The live Python server was only read.

| Query | Python median | Rust median |
|---|---:|---:|
| Canonical-style desktop query (flood, AFK filter, categorize, merge by app) | 42 ms | 3 ms |
| `query_bucket` on `aw-watcher-claude-tools` (13,595 events) | 418 ms | 49 ms |
| `merge_events_by_keys(claude-tools, ["tool_name"])` | 343 ms | 24 ms |

- Event counts and total durations matched. The desktop totals differ by 23 s, because the live Python bucket kept receiving events after the export.
- **Memory** (RSS, one sample, not a controlled benchmark):
  - Python aw-server: 37 MB after 19 h idle, 79–87 MB after serving the export and the queries.
  - aw-server-rust: 109 MB just after importing the 10 MB export, 158 MB after the queries.
- I found no official memory comparison. *Unverified:* steady-state RSS of aw-server-rust after a normal day of heartbeats.

## 5. Maintenance activity (2026-10-08)

| | aw-server | aw-server-rust |
|---|---|---|
| Last commit | 2026-10-06, `fix(api): replace the merged heartbeat event by id…` (#177) | 2026-10-06, `build(deps): bump rustls` (#797); also `fix(dirs)…` (#791) and `fix(server): warn … no index.html` (#794) |
| Open issues / PRs | 15 / 22 | 41 / 45 |
| Stars | 127 | 317 |
| Ships in | classic app (default) | classic app (opt-in), Tauri app (default), Android |

- Both are actively maintained.
- aw-server-rust carries the new work: sync, auth, the query cache, the performance tracking issue [#671](https://github.com/ActivityWatch/aw-server-rust/issues/671), and Android.
- Neither tracker has an open aw-server-rust issue specific to macOS that I could find. The open aw-server-rust issues about import and correctness are [#767](https://github.com/ActivityWatch/aw-server-rust/issues/767), where a re-import duplicates events when a redact privacy rule is active (you have no such rule configured that I know of: *unverified*), and the aw-sync issues #690–#694, which do not apply unless you enable aw-sync.
- A Windows-only data-path bug in v0.14.0 was fixed in [#791](https://github.com/ActivityWatch/aw-server-rust/pull/791). It does not affect macOS ([dirs.rs](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/dirs.rs#L110-L119)).

## 6. Running aw-server-rust under aw-qt on macOS

- **The binary is already installed.** It is `/Applications/ActivityWatch.app/Contents/Frameworks/aw-server-rust`, and `--version` prints `aw-server 0.14.0` (local check). aw-qt searches its own module dir and the parent dir (`Contents/Frameworks`), plus `Contents/MacOS` on Darwin ([manager.py#L84-L98](https://github.com/ActivityWatch/aw-qt/blob/54a9135b4a50df2560d4be700a62ca88b27f51dd/aw_qt/manager.py#L84-L98)). Your aw-qt log says "Found 6 bundled modules", which is consistent with that: aw-server, aw-watcher-afk, -window, -input, aw-server-rust and aw-sync. *Inferred:* the log does not list the module names at INFO level.
- **Config.** Put `"aw-server-rust"` in place of `"aw-server"` in `autostart_modules` in `~/Library/Application Support/activitywatch/aw-qt/aw-qt.toml` ([migrating](https://docs.activitywatch.net/en/latest/migrating.html)). If both are listed, aw-qt starts `aw-server-rust` and **does not** start `aw-server` ([manager.py#L400-L408](https://github.com/ActivityWatch/aw-qt/blob/54a9135b4a50df2560d4be700a62ca88b27f51dd/aw_qt/manager.py#L400-L408)).
- **Ports.** Both servers default to 5600 (testing 5666) ([config.rs#L148-L154](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/config.rs#L148-L154)), so they cannot both run on the defaults. 5699 is not a default of either. I used it only for the side-by-side test. Your watchers hard-code 5600/5666 (for example `aw_watcher_herdr/__main__.py:335`), which is fine as long as aw-server-rust stays on 5600.
- **Local finding: an orphaned Python server.** The running `aw-server` (PID 64269, up 19 h) is older than the running `aw-qt` (up 12 h). aw-qt probes for an external server already on the port ([manager.py#L178-L200](https://github.com/ActivityWatch/aw-qt/blob/54a9135b4a50df2560d4be700a62ca88b27f51dd/aw_qt/manager.py#L178-L200)), so quitting aw-qt may leave that process running and holding port 5600. Kill it explicitly when you switch.
- **Alternative: aw-tauri.** It runs aw-server-rust by default and has configurable `discovery_paths` for modules ([aw-tauri lib.rs](https://github.com/ActivityWatch/aw-tauri/blob/master/src-tauri/src/lib.rs)). The project still calls it experimental, so the conservative path is aw-qt with aw-server-rust.

## 7. Compatibility risk for your watchers and queries

- **aw-client (Python) heartbeats and bucket creation.** aw-server-rust has `POST /api/0/buckets/<id>` (an existing bucket returns 304, as aw-client expects), `POST …/events` and `POST …/heartbeat?pulsetime=` ([endpoints/bucket.rs](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-server/src/endpoints/bucket.rs)). The web extension, Android and aw-tauri watchers all use these same endpoints against aw-server-rust.
  - aw-watcher-herdr uses `heartbeat(..., queued=True)` and `insert_events`.
  - aw-watcher-claude uses `create_bucket` and `insert_events`, with its own `state.json` for exactly-once delivery.
  - Neither depends on server-specific behavior. Low risk.
- **Heartbeat correctness favors Rust.** The 0.14.0 Python server overwrites the wrong event after an out-of-order heartbeat, for example "when a watcher restarts mid-period and re-sends a transition". That loses data and leaves two events with the same timestamp ([aw-server#177](https://github.com/ActivityWatch/aw-server/pull/177), merged after the release). aw-qt now restarts crashed watchers automatically, so this case is real for your custom watchers. aw-server-rust has replaced by event id since [#555](https://github.com/ActivityWatch/aw-server-rust/pull/555) (2026-01-25), which is in the 0.14.0 submodule commit `f4b4a1a` (checked with `git merge-base --is-ancestor`) ([datastore.rs#L1058](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-datastore/src/datastore.rs#L1058)).
- **Query differences you will see**, measured on your data:
  1. `merge_events_by_keys` keeps the whole `data` of the first event in each group on Rust. On the 0.14.0 Python server it keeps only the keys. Code that reads only the merge keys is unaffected. Code that assumes *only* the keys are present (for example, iterating `data` and treating every field as a key) will see extra fields.
  2. **Events missing a merge key:** Rust drops them ([merge.rs#L47](https://github.com/ActivityWatch/aw-server-rust/blob/c535d77af495681e4b3960c4e4f5991e1c04a3c7/aw-transform/src/merge.rs#L47)). The 0.14.0 Python server returned them as one `{}` group: `merge_events_by_keys(claude-tools, ["tool"])` returned 1 event and 119,986 s on Python, and 0 events on Rust. A key that is present with a `null` value groups the same on both. aw-core master now drops these events too ([merge_events_by_keys.py#L20-L38](https://github.com/ActivityWatch/aw-core/blob/5d34ffeb47870d07baa55943cbba19cfe1fac67c/aw_transform/merge_events_by_keys.py#L20-L38)), so this change is coming to the Python server as well.
  3. `split_url_events` and `tag` output shapes also change ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)). Your `aw-insights` skill script (`~/.claude/skills/aw-insights/scripts/aw_evidence.py`) uses `merge_events_by_keys` and `split_url_events`. Check it after the switch.
- **Dashboards and categories.** These work once `settings.json` is copied over (§3). Your custom views use only built-in visualization types: top_apps, top_titles, top_urls, top_domains, top_browser_titles, top_editor_*, category_tree, category_sunburst, top_categories and timeline_barchart. On Rust, category coloring in top-title lists improves, because `$category` survives the merge ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)).
- **The `query_cache` key in your aw-server.toml** applies only to the Python server. aw-server-rust has its own query cache ([server-compare](https://docs.activitywatch.net/en/latest/server-compare.html)).

## How to switch

1. **Back up while the Python server is still running:**
   ```sh
   B=~/ActivityWatch-backup-$(date +%F); mkdir -p "$B"
   curl -s http://localhost:5600/api/0/export > "$B/export.json"
   cp ~/Library/Application\ Support/activitywatch/aw-server/settings.json "$B/"
   sqlite3 ~/Library/Application\ Support/activitywatch/aw-server/peewee-sqlite.v2.db ".backup '$B/peewee-sqlite.v2.db'"
   ```
2. **Stop everything.** Quit ActivityWatch from the tray. Then make sure no Python server is left, because one was orphaned earlier (§6):
   ```sh
   pgrep -fl 'MacOS/aw-server$' && pkill -f 'MacOS/aw-server$'
   curl -s -m 2 http://localhost:5600/api/0/info || echo "port 5600 free"
   ```
3. **Edit** `~/Library/Application Support/activitywatch/aw-qt/aw-qt.toml`. Replace `"aw-server"` with `"aw-server-rust"` and keep the rest:
   ```toml
   autostart_modules = ["aw-server-rust", "aw-watcher-afk", "aw-watcher-window", "aw-watcher-ask-away-custom", "aw-watcher-herdr", "aw-watcher-claude"]
   ```
4. **Start ActivityWatch.** On first start, aw-server-rust imports `peewee-sqlite.v2.db` into `~/Library/Application Support/activitywatch/aw-server-rust/sqlite.db`. Your DB is 11 MB, so this takes seconds. Logs go to `~/Library/Logs/activitywatch/aw-server-rust/`. While the server is down, watchers buffer heartbeats in aw-client's persist-queues and flush them when it comes back.
5. **Verify** before you open the web UI:
   ```sh
   curl -s http://localhost:5600/api/0/info          # version should end in "(rust)"
   sqlite3 -readonly ~/Library/Application\ Support/activitywatch/aw-server/peewee-sqlite.v2.db \
     "select b.id,count(e.id) from bucketmodel b left join eventmodel e on e.bucket_id=b.key group by b.id;"
   # compare with: curl -s http://localhost:5600/api/0/buckets/<id>/events/count
   ```
6. **Copy the settings** (categories, views and so on) **before** you open the web UI (§3 explains why):
   ```sh
   python3 -I - <<'EOF'
   import json, pathlib, urllib.request
   p = pathlib.Path.home() / "Library/Application Support/activitywatch/aw-server/settings.json"
   for k, v in json.loads(p.read_text()).items():
       req = urllib.request.Request(f"http://localhost:5600/api/0/settings/{k}",
             data=json.dumps(v).encode(), headers={"Content-Type": "application/json"}, method="POST")
       print(k, urllib.request.urlopen(req).status)
   EOF
   ```
7. **Open the web UI and hard-refresh it** (Cmd-Shift-R). A user who migrated got 404s until they did ([aw-server-rust#139](https://github.com/ActivityWatch/aw-server-rust/issues/139)). Check Settings → Categories and your custom Activity views.
8. **Check the query consumers** listed in §7: the `aw-insights` scripts and any saved queries that use `merge_events_by_keys` / `split_url_events` / `tag`.
9. **To roll back:** put `"aw-server"` back in `aw-qt.toml`. The Python DB is untouched, but it lacks everything recorded while you were on Rust. To carry those events back, export them from Rust and import them into Python. The docs call that direction "untested" ([migrating](https://docs.activitywatch.net/en/latest/migrating.html)).

## Sources

- Release notes v0.14.0: https://github.com/ActivityWatch/activitywatch/releases/tag/v0.14.0
- Blog: https://activitywatch.net/blog/activitywatch-v0-14-0/ (Erik Bjäreholt, 2026-10-06), https://activitywatch.net/blog/introducing-tauri/ (Brian Vuku, 2026-10-06)
- Docs: https://docs.activitywatch.net/en/latest/server-compare.html (source commit [7bac302](https://github.com/ActivityWatch/docs/commit/7bac302543e600da9eff1600b9f96e5b28f2fc37)), https://docs.activitywatch.net/en/latest/migrating.html
- Issues and PRs: [activitywatch#424](https://github.com/ActivityWatch/activitywatch/issues/424), [activitywatch#1466](https://github.com/ActivityWatch/activitywatch/issues/1466), [aw-server#78](https://github.com/ActivityWatch/aw-server/pull/78), [aw-server#177](https://github.com/ActivityWatch/aw-server/pull/177), [aw-server#180](https://github.com/ActivityWatch/aw-server/pull/180), [aw-core#173](https://github.com/ActivityWatch/aw-core/pull/173), [aw-server-rust#66](https://github.com/ActivityWatch/aw-server-rust/issues/66), [#139](https://github.com/ActivityWatch/aw-server-rust/issues/139), [#555](https://github.com/ActivityWatch/aw-server-rust/pull/555), [#671](https://github.com/ActivityWatch/aw-server-rust/issues/671), [#767](https://github.com/ActivityWatch/aw-server-rust/issues/767), [#784](https://github.com/ActivityWatch/aw-server-rust/issues/784), [#791](https://github.com/ActivityWatch/aw-server-rust/pull/791)
- Source at the commits I read: aw-server-rust `c535d77`, aw-server `ce55bbd`, aw-qt `54a9135`, aw-core `5d34ffe`, activitywatch `15705a7`. The v0.14.0 submodule pins are aw-server-rust `f4b4a1a`, aw-server `5bf925f`, aw-core `b1f04b5` and aw-qt `82ea774`.
- Local: `/Applications/ActivityWatch.app` (0.14.0), `~/Library/Application Support/activitywatch/{aw-qt/aw-qt.toml, aw-server/aw-server.toml, aw-server/settings.json, aw-server/peewee-sqlite.v2.db}`, `~/Library/Logs/activitywatch/aw-qt/`, and the side-by-side benchmark run on 2026-10-08.
