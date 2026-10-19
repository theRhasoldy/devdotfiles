# Accuracy and Sourcing

Load this file when a request depends on recency ("latest", "current", "as of now").

- Establish the current date/time with `date -Is` and state it explicitly.
- Prefer official/primary sources (vendor docs, release notes, changelogs); record source dates when relevant.
- Verify APIs/library functions exist in the current version's docs (Context7 MCP when available) before use. If unverifiable, flag as UNCONFIRMED.
- Use web search only when it materially improves correctness (up-to-date APIs, recent advisories, release notes); prefer official docs.
