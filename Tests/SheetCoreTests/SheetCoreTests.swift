import Testing
import Foundation
@testable import SheetCore

@Test func providerCatalogRespectsCredentialsAndUnifiedMode() {
    let state = ProviderCredentialState(hasOpenAIKey: true, hasAnthropicKey: true)
    let models = ModelCatalog.models(for: state, mode: .unified)

    #expect(models.contains { $0.name == "gpt-image-2" })
    #expect(models.contains { $0.provider == .anthropic })
    #expect(state.imageGenerationStatus == .availableViaOpenAI)
}

@Test func lyricCodeBlocksBecomeArtifacts() {
    let chatID = UUID()
    let message = MessageRecord(
        chatID: chatID,
        role: .assistant,
        markdown: "Here is a draft:\n```lyrics\n[Chorus]\nI keep a moon in my pocket\n```",
        provider: .openAI,
        model: "gpt-5.5"
    )

    let artifacts = MarkdownParser.lyricArtifacts(from: message)

    #expect(artifacts.count == 1)
    #expect(artifacts[0].title == "Chorus")
    #expect(artifacts[0].bodyMarkdown.contains("```lyrics"))
    #expect(artifacts[0].chatID == chatID)
}

@Test func memoryPromptIncludesEnabledHighConfidenceMemoriesOnly() {
    let memories = [
        CreativeMemory(category: .genrePreference, value: "Prefers nocturnal alt-R&B", confidence: 0.95),
        CreativeMemory(category: .avoid, value: "Avoid explicit language", confidence: 0.9, isEnabled: false),
        CreativeMemory(category: .theme, value: "Often writes about grief and ambition", confidence: 0.8)
    ]

    let prompt = MemoryPromptBuilder.prompt(for: memories)

    #expect(prompt.contains("nocturnal alt-R&B"))
    #expect(prompt.contains("grief and ambition"))
    #expect(!prompt.contains("explicit language"))
}

@Test func imageLibraryPaginatesForLazyLoading() {
    let images = (0..<12).map { index in
        GeneratedImageRecord(prompt: "cover \(index)", fileName: "image-\(index).png", createdAt: Date(timeIntervalSince1970: Double(index)))
    }
    let index = ImageLibraryIndex(allImages: images)

    let first = index.page(offset: 0, limit: 5)
    let second = index.page(offset: first.nextOffset ?? 0, limit: 5)

    #expect(first.items.count == 5)
    #expect(first.nextOffset == 5)
    #expect(second.items.count == 5)
    #expect(second.nextOffset == 10)
}
