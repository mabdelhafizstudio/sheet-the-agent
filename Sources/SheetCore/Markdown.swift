import Foundation

public struct MarkdownCodeBlock: Equatable, Sendable {
    public let language: String?
    public let content: String
    public let range: Range<String.Index>

    public var isLyricCandidate: Bool {
        guard let language = language?.lowercased() else { return true }
        return ["lyrics", "lyric", "markdown", "md", "text"].contains(language)
    }
}

public enum MarkdownParser {
    public static func codeBlocks(in markdown: String) -> [MarkdownCodeBlock] {
        var blocks: [MarkdownCodeBlock] = []
        var searchStart = markdown.startIndex

        while let fenceStart = markdown[searchStart...].range(of: "```") {
            let headerStart = fenceStart.upperBound
            guard let headerEnd = markdown[headerStart...].firstIndex(of: "\n") else { break }
            let rawLanguage = markdown[headerStart..<headerEnd].trimmingCharacters(in: .whitespacesAndNewlines)
            let language = rawLanguage.isEmpty ? nil : rawLanguage
            let contentStart = markdown.index(after: headerEnd)
            guard let fenceEnd = markdown[contentStart...].range(of: "```") else { break }
            let content = String(markdown[contentStart..<fenceEnd.lowerBound])
            blocks.append(MarkdownCodeBlock(language: language, content: content, range: fenceStart.lowerBound..<fenceEnd.upperBound))
            searchStart = fenceEnd.upperBound
        }

        return blocks
    }

    public static func lyricArtifacts(from message: MessageRecord, titleProvider: (String) -> String = defaultTitle) -> [LyricArtifact] {
        codeBlocks(in: message.markdown)
            .filter(\.isLyricCandidate)
            .filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { block in
                LyricArtifact(
                    title: titleProvider(block.content),
                    bodyMarkdown: "```lyrics\n\(block.content.trimmingCharacters(in: .newlines))\n```",
                    chatID: message.chatID,
                    messageID: message.id,
                    provider: message.provider,
                    model: message.model
                )
            }
    }

    public static func defaultTitle(from lyric: String) -> String {
        lyric.split(separator: "\n")
            .first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }?
            .trimmingCharacters(in: CharacterSet(charactersIn: "#[] "))
            .prefix(48)
            .description ?? "Untitled Lyric"
    }
}
