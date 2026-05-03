# Benchmarking

## Prompt
"Explain what local AI inference means in simple terms."

## Metrics
- Model load time
- First-token latency
- Total generation time
- Tokens generated
- Tokens/sec
- Error status
- External vs copied source mode
- Device name
- App version

## Why Tokens/Sec Varies
iPhone 15 Plus (A16) has less headroom than many desktops/laptops and may throttle thermally during long runs.

## Compare External vs Copied
If fallback copy mode is enabled, benchmark records source mode so you can compare throughput or startup differences.
