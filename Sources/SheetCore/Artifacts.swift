import Foundation

public enum ArtifactKind: String, Codable, CaseIterable, Sendable {
    case lyric
    case image
    case note
}

public struct ChatSession: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var createdAt: Date
    public var updatedAt: Date
    public var providerMode: ProviderMode

    public init(id: UUID = UUID(), title: String, createdAt: Date = Date(), updatedAt: Date = Date(), providerMode: ProviderMode = .unified) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.providerMode = providerMode
    }
}

public struct MessageRecord: Codable, Equatable, Identifiable, Sendable {
    public enum Role: String, Codable, Sendable { case user, assistant, tool, system }
    public let id: UUID
    public var chatID: UUID
    public var role: Role
    public var markdown: String
    public var provider: APIProvider?
    public var model: String?
    public var createdAt: Date
    public var toolCalls: [ToolCallRecord]

    public init(id: UUID = UUID(), chatID: UUID, role: Role, markdown: String, provider: APIProvider? = nil, model: String? = nil, createdAt: Date = Date(), toolCalls: [ToolCallRecord] = []) {
        self.id = id
        self.chatID = chatID
        self.role = role
        self.markdown = markdown
        self.provider = provider
        self.model = model
        self.createdAt = createdAt
        self.toolCalls = toolCalls
    }
}

public struct LyricArtifact: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var bodyMarkdown: String
    public var tags: [String]
    public var chatID: UUID?
    public var messageID: UUID?
    public var provider: APIProvider?
    public var model: String?
    public var version: Int
    public var createdAt: Date
    public var updatedAt: Date

    public init(id: UUID = UUID(), title: String, bodyMarkdown: String, tags: [String] = [], chatID: UUID? = nil, messageID: UUID? = nil, provider: APIProvider? = nil, model: String? = nil, version: Int = 1, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.bodyMarkdown = bodyMarkdown
        self.tags = tags
        self.chatID = chatID
        self.messageID = messageID
        self.provider = provider
        self.model = model
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct GeneratedImageRecord: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var prompt: String
    public var revisedPrompt: String?
    public var fileName: String
    public var thumbnailFileName: String?
    public var provider: APIProvider
    public var model: String
    public var sourceChatID: UUID?
    public var sourceMessageID: UUID?
    public var createdAt: Date

    public init(id: UUID = UUID(), prompt: String, revisedPrompt: String? = nil, fileName: String, thumbnailFileName: String? = nil, provider: APIProvider = .openAI, model: String = "gpt-image-2", sourceChatID: UUID? = nil, sourceMessageID: UUID? = nil, createdAt: Date = Date()) {
        self.id = id
        self.prompt = prompt
        self.revisedPrompt = revisedPrompt
        self.fileName = fileName
        self.thumbnailFileName = thumbnailFileName
        self.provider = provider
        self.model = model
        self.sourceChatID = sourceChatID
        self.sourceMessageID = sourceMessageID
        self.createdAt = createdAt
    }
}

public struct ImageLibraryPage: Codable, Equatable, Sendable {
    public let items: [GeneratedImageRecord]
    public let nextOffset: Int?
}

public struct ImageLibraryIndex: Sendable {
    public var allImages: [GeneratedImageRecord]

    public init(allImages: [GeneratedImageRecord] = []) {
        self.allImages = allImages.sorted { $0.createdAt > $1.createdAt }
    }

    public func page(offset: Int, limit: Int) -> ImageLibraryPage {
        guard limit > 0, offset < allImages.count else { return ImageLibraryPage(items: [], nextOffset: nil) }
        let end = min(offset + limit, allImages.count)
        let next = end < allImages.count ? end : nil
        return ImageLibraryPage(items: Array(allImages[offset..<end]), nextOffset: next)
    }
}
