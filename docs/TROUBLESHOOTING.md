# Troubleshooting

## Model Not Opening
- Ensure file ends with `.gguf`
- Re-select via Files picker
- Confirm SSD is mounted and readable in Files app

## Bookmark Stale
- App detects stale bookmark and attempts refresh
- If refresh fails, clear bookmark and pick model again

## SSD Disconnected
- Reconnect SSD
- Return to Model Status and retry validation/load

## File Permission Denied
- Reselect file from picker to grant scope again

## Model Too Large
- Use 1B-1.7B Q4 models for iPhone 15 Plus
- Reduce context length and max tokens

## App Crashes During Load
- Verify llama.cpp library/headers match bridge expectations
- Disable mmap and retry

## Slow Generation
- Lower context/max tokens
- Reduce temperature/top-p complexity
- Keep device cool and charged

## No Metal Acceleration
- Confirm llama.cpp built with Metal backend for iOS
- Confirm target linking and runtime backend detection

## Cannot Build llama.cpp
- Follow `docs/LLAMA_CPP_INTEGRATION.md`
- Verify Xcode toolchain, SDK, and architecture settings

## Xcode Signing Issues
- Set Team and unique bundle identifier
- Ensure device provisioning includes iPhone target
