# iOS External Storage Guide

## Recommended SSD Format
- exFAT or APFS
- Single partition recommended

## Recommended Folder Layout
`/LLM_MODELS/model.gguf`

## Access Model Files
The app cannot silently crawl external drives. User must explicitly select files through iOS Files picker.

## Keep SSD Connected
If disconnected while loaded, reads may fail. The app surfaces a clear disconnection/access error and requires reselection/reconnect.

## Security Scope Lifecycle
- Start security-scoped access for each operation
- Resolve bookmark at launch
- Detect stale bookmarks and refresh
- Stop scope when done

## Privacy Boundary
Only bookmark metadata and app-local artifacts are stored in sandbox by default.
