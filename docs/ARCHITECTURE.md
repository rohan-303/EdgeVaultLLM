# EdgeVault LLM Architecture

## iOS Sandboxing
iOS apps cannot freely scan or open arbitrary files outside their sandbox. External SSD access is mediated by the Files picker and user consent.

## External SSD Access
The app uses `UIDocumentPickerViewController` via SwiftUI wrapper to let users choose a `.gguf` file. The URL is opened in place and treated as security-scoped.

## Security-Scoped URLs and Bookmarks
- `startAccessingSecurityScopedResource()` is called before reads.
- A bookmark (`bookmarkData(options: .minimalBookmark)`) is stored.
- On launch, bookmark data is resolved and stale bookmarks are refreshed.
- `stopAccessingSecurityScopedResource()` is called after operations.

## Why We Avoid Copying Models
Default policy stores only:
- Bookmark data
- Small metadata (file name/size/dates)
- Settings/chat/benchmarks

Model bytes are not copied unless fallback copy mode is explicitly enabled.

## Why RAM Is Still Required
External SSD avoids internal storage usage for the model file. During inference, the model and KV/cache pages are loaded/streamed into iPhone unified memory. SSD is storage, not compute memory.

## llama.cpp Bridge
Swift -> `LlamaRuntimeService` -> Objective-C++ `LlamaBridge` -> llama.cpp C/C++ APIs.

This boundary isolates native runtime complexity and provides structured Swift errors.

## Metal Plan
Architecture includes runtime capability reporting (`cpu` / `metal` / `unknown`). If Metal-enabled llama.cpp is linked and configured, backend status reports accordingly.

## Benchmark Data Flow
Benchmark screen calls `BenchmarkService`, which:
1. Loads model if needed
2. Runs fixed prompt
3. Records timings and token counters
4. Persists local JSON result
5. Supports export via share sheet
