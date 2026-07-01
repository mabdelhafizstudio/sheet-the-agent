import Foundation

public enum APIProvider: String, Codable, CaseIterable, Sendable {
    case openAI
    case anthropic
}

public enum ProviderMode: String, Codable, CaseIterable, Sendable {
    case openAIOnly
    case anthropicOnly
    case unified
}

public struct ModelCapability: OptionSet, Codable, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let streaming = ModelCapability(rawValue: 1 << 0)
    public static let toolCalling = ModelCapability(rawValue: 1 << 1)
    public static let webSearch = ModelCapability(rawValue: 1 << 2)
    public static let imageGeneration = ModelCapability(rawValue: 1 << 3)
    public static let vision = ModelCapability(rawValue: 1 << 4)
    public static let markdown = ModelCapability(rawValue: 1 << 5)
}

public struct ProviderModel: Codable, Equatable, Sendable, Identifiable {
    public var id: String { name }
    public let name: String
    public let displayName: String
    public let provider: APIProvider
    public let capabilities: ModelCapability

    public init(name: String, displayName: String, provider: APIProvider, capabilities: ModelCapability) {
        self.name = name
        self.displayName = displayName
        self.provider = provider
        self.capabilities = capabilities
    }
}

public struct ProviderCredentialState: Codable, Equatable, Sendable {
    public var hasOpenAIKey: Bool
    public var hasAnthropicKey: Bool

    public init(hasOpenAIKey: Bool = false, hasAnthropicKey: Bool = false) {
        self.hasOpenAIKey = hasOpenAIKey
        self.hasAnthropicKey = hasAnthropicKey
    }

    public var availableProviders: [APIProvider] {
        var providers: [APIProvider] = []
        if hasOpenAIKey { providers.append(.openAI) }
        if hasAnthropicKey { providers.append(.anthropic) }
        return providers
    }

    public var imageGenerationStatus: ImageGenerationStatus {
        hasOpenAIKey ? .availableViaOpenAI : .requiresOpenAIKey
    }
}

public enum ImageGenerationStatus: String, Codable, Equatable, Sendable {
    case availableViaOpenAI
    case requiresOpenAIKey
}

public protocol LLMProvider: Sendable {
    var provider: APIProvider { get }
    var capabilities: ModelCapability { get }
    func availableModels() async throws -> [ProviderModel]
}

public enum ModelCatalog {
    public static let openAITextModels: [ProviderModel] = [
        ProviderModel(name: "gpt-5.5", displayName: "GPT-5.5", provider: .openAI, capabilities: [.streaming, .toolCalling, .webSearch, .vision, .markdown]),
        ProviderModel(name: "gpt-5.4-mini", displayName: "GPT-5.4 Mini", provider: .openAI, capabilities: [.streaming, .toolCalling, .webSearch, .vision, .markdown])
    ]

    public static let openAIImageModels: [ProviderModel] = [
        ProviderModel(name: "gpt-image-2", displayName: "GPT-image-2", provider: .openAI, capabilities: [.imageGeneration])
    ]

    public static let anthropicTextModels: [ProviderModel] = [
        ProviderModel(name: "claude-opus-4-1", displayName: "Claude Opus 4.1", provider: .anthropic, capabilities: [.streaming, .toolCalling, .webSearch, .vision, .markdown]),
        ProviderModel(name: "claude-sonnet-4", displayName: "Claude Sonnet 4", provider: .anthropic, capabilities: [.streaming, .toolCalling, .webSearch, .vision, .markdown])
    ]

    public static func models(for state: ProviderCredentialState, mode: ProviderMode) -> [ProviderModel] {
        switch mode {
        case .openAIOnly:
            return state.hasOpenAIKey ? openAITextModels + openAIImageModels : []
        case .anthropicOnly:
            return state.hasAnthropicKey ? anthropicTextModels : []
        case .unified:
            var models: [ProviderModel] = []
            if state.hasOpenAIKey { models += openAITextModels + openAIImageModels }
            if state.hasAnthropicKey { models += anthropicTextModels }
            return models
        }
    }
}
