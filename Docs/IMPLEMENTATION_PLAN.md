# Sheet implementation plan

Sheet is a native Swift creative agent for lyric writing with a minimal Liquid Glass direction. The app is organized around Chat, Artifacts, Memory, and Image Library surfaces.

## 1. BYOK provider setup

Users can bring OpenAI, Anthropic, or both API keys. The app exposes OpenAI-only, Anthropic-only, and Unified Workspace modes. API keys should be stored in Keychain, never in chat persistence.

## 2. Unified provider capabilities

The core model catalog records provider, model name, display name, and capability flags for streaming, tool calling, web search, image generation, vision, and Markdown. Unified mode aggregates available providers without hiding provider-specific abilities.

## 3. Reviewable memory system

`Extract_Memory` creates memory candidates for writing style, genre preference, theme, project, constraint, inspiration, and avoid categories. Memories should enter a review queue before becoming durable context.

## 4. Lyric artifacts

Assistant lyrics are expected in fenced `lyrics` Markdown code blocks. Eligible code blocks can be persisted as lyric artifacts with title, body, source chat, source message, provider, model, tags, and version metadata.

## 5. Lazy image library

Generated images are persisted as metadata plus files on disk. The index pages image records by offset and limit so SwiftUI views can lazy-load thumbnails and avoid chat/library scroll lag.

## 6. Web search tool

`Web_Search` accepts a query, optional recency, and result count. Tool usage should be visible in chat and citations should be attached to research answers. The agent must avoid copying lyrics or closely imitating living artists.

## 7. Markdown and code rendering

Chat and artifact views should render full Markdown, preserve lyric whitespace, and add copy/save actions for fenced code blocks. Lyric code blocks are the bridge from conversation to persistent artifacts.
