# Release Surface Spec

## Module

`Support/ReleaseSurface.swift` — single source for "is feature X reachable?"

## Launch Arguments

| Argument | Effect |
|----------|--------|
| `-enable_full_product_surface` | Show gated features (CI/dogfood only) |

## Gates (v0.1 Release defaults)

| Feature | Release | Full Surface |
|---------|---------|--------------|
| AoS Spearhead guide | ✅ | ✅ |
| 40k 10th / 11th | ❌ | ✅ (coming soon cards) |
| Roll evaluator | ❌ | ❌ (stub) |
| Rules Q&A | ❌ | ❌ (stub) |

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (initial scaffold) |
| Code paths | `Support/ReleaseSurface.swift` |
