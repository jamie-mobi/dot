# 0011 — On-device Tag suggestions with Foundation Models

Date: 06/11/2026. Status: accepted.

## Context

The user wants Dot to suggest Tags for a Note with Apple's AI, shown on their own line with an AI icon, where a click adds the Tag. The user asked to explore Apple's [`foundation-models-utilities`](https://github.com/apple/foundation-models-utilities) package for this.

## Decision

- **Dot calls the `FoundationModels` framework directly**, with `SystemLanguageModel(useCase: .contentTagging)` and guided generation (`@Generable GeneratedTagsDTO`). One short prompt per Note, one structured answer.
- **`foundation-models-utilities` is not added.** It provides a chat-completions client for hosted or local servers, conversation-history modifiers and a skills system. Tag suggestion is one prompt with no history or tools, so the package adds nothing it needs, and its chat-completions client would take Note text off the Mac, which `ARCHITECTURE.md` rules out. Revisit it if Dot grows a multi-turn assistant.
- **Off by default.** Settings › General › Suggest Tags turns it on. The toggle explains when Apple Intelligence is unavailable (Mac not eligible, turned off, model not ready).
- **Nothing is written until the user clicks a suggestion.** A click adds the Tag to the `tags` Property (creating the frontmatter or the Property when absent), through the same edit path as the Properties form. Suggestions are held in memory per window and never stored in the Pack or the Index.
- **The model sees** the Note's name, its body (frontmatter removed, at most 6,000 characters), its Tags and up to 60 of the Pack's most used Tags, so it can reuse the Pack's spelling. Notes under 12 words get no suggestions.
- **Model output is cleaned by a pure use case** (`TagSuggestionUseCase.tags(from:existing:packTags:)`): lower-case, spaces to hyphens, only characters Obsidian allows in a Tag, no all-digit Tags, no repeats, no Tags the Note has, at most five.

## Consequences

- Needs macOS 26 with Apple Intelligence on. Everything else in Dot works without it.
- Analytics log only `tag_suggestion_added`, never the Tag itself.
- The prompt lives in `TagSuggestionPrompt`; changing it changes what users see, so test it on real Notes.
