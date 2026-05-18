# AI Model Runtime

## Runtime Decision
llama.cpp via native Android integration.

## Model
Primary:
Qwen2.5 1.5B Instruct GGUF Q4

Future optional:
3B premium tier.

## Delivery Strategy
Do not bundle in APK.
Model downloaded after opt-in.

## Download Manager Requirements
- resumable downloads
- checksum validation
- corruption detection
- retries
- cancellation
- cleanup

## Runtime Lifecycle
- lazy init
- warm start caching
- unload under memory pressure

## Device Checks
- RAM threshold
- storage threshold
- CPU architecture validation
