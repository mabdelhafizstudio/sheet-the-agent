import Foundation

public enum CreativeMemoryCategory: String, Codable, CaseIterable, Sendable {
    case writingStyle
    case genrePreference
    case theme
    case project
    case constraint
    case inspiration
    case avoid
}

public struct CreativeMemory: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var category: CreativeMemoryCategory
    public var value: String
    public var confidence: Double
    public var sourceMessageID: UUID?
    public var isEnabled: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(id: UUID = UUID(), category: CreativeMemoryCategory, value: String, confidence: Double, sourceMessageID: UUID? = nil, isEnabled: Bool = true, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.category = category
        self.value = value
        self.confidence = confidence
        self.sourceMessageID = sourceMessageID
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum ToolName: String, Codable, CaseIterable, Sendable {
    case webSearch = "Web_Search"
    case extractMemory = "Extract_Memory"
    case saveArtifact = "Save_Artifact"
    case generateImage = "Generate_Image"
}

public struct ToolCallRecord: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var name: ToolName
    public var argumentsJSON: String
    public var resultSummary: String?
    public var createdAt: Date

    public init(id: UUID = UUID(), name: ToolName, argumentsJSON: String, resultSummary: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.argumentsJSON = argumentsJSON
        self.resultSummary = resultSummary
        self.createdAt = createdAt
    }
}

public struct WebSearchRequest: Codable, Equatable, Sendable {
    public var query: String
    public var recencyDays: Int?
    public var resultCount: Int

    public init(query: String, recencyDays: Int? = nil, resultCount: Int = 5) {
        self.query = query
        self.recencyDays = recencyDays
        self.resultCount = resultCount
    }
}

public struct ExtractMemoryRequest: Codable, Equatable, Sendable {
    public var chatID: UUID
    public var sourceMessageID: UUID
    public var transcriptWindow: String

    public init(chatID: UUID, sourceMessageID: UUID, transcriptWindow: String) {
        self.chatID = chatID
        self.sourceMessageID = sourceMessageID
        self.transcriptWindow = transcriptWindow
    }
}

public enum MemoryPromptBuilder {
    public static func prompt(for memories: [CreativeMemory], limit: Int = 8) -> String {
        let active = memories
            .filter(\.isEnabled)
            .sorted { $0.confidence > $1.confidence }
            .prefix(limit)
        guard !active.isEmpty else { return "" }
        return active.map { "- [\($0.category.rawValue)] \($0.value)" }.joined(separator: "\n")
    }
}

public enum SheetSystemPrompt {
    public static let base = """
    You are Sheet, a minimal, emotionally intelligent lyric-writing agent. Help the user tap into their inner lyricist and write their heart out.

    Rules:
    - Generate complete lyric drafts inside fenced Markdown code blocks tagged `lyrics`.
    - Use full Markdown for explanations, revision plans, tables, and code-like structure.
    - Use web search when the user needs current, factual, or cultural research.
    - Do not reproduce copyrighted lyrics or imitate a living artist too closely.
    - Prefer practical songwriting actions: hooks, verses, bridges, rhyme options, emotional rewrites, and artifact-ready drafts.
    - Propose memory extraction only for stable user preferences, project facts, constraints, and inspirations.
    """
}
