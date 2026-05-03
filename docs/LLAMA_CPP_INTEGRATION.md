# llama.cpp Integration

## Integration Strategy
This project includes an Objective-C++ bridge scaffold (`LlamaBridge.mm/.hpp`) and Swift service layer. You can integrate llama.cpp as:
- Vendored source in repo
- Git submodule
- Prebuilt static library + headers

## Build for iOS
Typical approach:
1. Build llama.cpp for iOS target architecture(s)
2. Enable required compile flags
3. Link static library in Xcode target
4. Expose required headers to `LlamaBridge.mm`

## Swift to C++ Bridge
- Swift calls `LlamaRuntimeService`
- Service calls Objective-C++ bridge
- Bridge invokes llama.cpp APIs for load/generate/unload

## GGUF Path Passing
Resolved security-scoped URL is converted to local path string and passed to bridge `loadModel(atPath:mmapEnabled:error:)`.

## mmap Behavior
`mmap` is configurable in settings. If provider/URL semantics make mmap unreliable, service can disable mmap and retry with buffered load path.

## Metal Status
- If llama.cpp is built with Metal backend and runtime chooses it, backend reports `metal`.
- If not, backend reports `cpu`.
- This scaffold does not fake Metal.

## Current Limitation
This environment cannot complete actual Xcode/iOS linking of llama.cpp. Manual macOS/Xcode steps are required.
