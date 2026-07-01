# Sheet

Sheet is a native Swift foundation for a minimal Liquid Glass lyric-writing agent. It supports Bring Your Own Key provider selection for OpenAI, Anthropic, or a unified workspace that can use both while preserving provider-specific capabilities.

## Core surfaces

- **Chat:** model/provider-aware messages with tool-call records.
- **Artifacts:** persistent lyric drafts extracted from fenced Markdown code blocks.
- **Memory:** reviewable creative memories such as style, genre, themes, constraints, inspirations, and avoid rules.
- **Image Library:** generated-image metadata with paginated indexing for lazy loading.

## Provider behavior

OpenAI and Anthropic are modeled as separate providers behind shared capability metadata. OpenAI can expose GPT-image-2 for image generation. Anthropic text chats can still request images only when an OpenAI key is present, because image generation is routed to the OpenAI image model.

## Lyric rendering contract

Sheet expects complete lyric drafts in fenced Markdown code blocks:

````markdown
```lyrics
[Verse 1]
...

[Chorus]
...
```
````

Those code blocks can be converted into persistent lyric artifacts.
