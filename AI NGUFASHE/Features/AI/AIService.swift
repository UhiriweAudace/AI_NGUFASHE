//
//  AIService.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//
import Foundation

final class AIService {
    static let shared = AIService()

    // YOUR API endpoint (user-provided)
    private let endpoint = URL(string: "https://portfolio-app-drab-two.vercel.app/api/ai")!

    private init() {}

    /// Sends POST { text, prompt } and returns the server's answer string.
    func ask(text: String, prompt: String) async throws -> String {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = AIRequest(text: text, prompt: prompt)
        req.httpBody = try JSONEncoder().encode(body)

        let (data, res) = try await URLSession.shared.data(for: req)

        if let http = res as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let serverText = String(data: data, encoding: .utf8) ?? "Server error: status \(http.statusCode)"
            throw NSError(domain: "AIService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: serverText])
        }

        // Try to decode expected shapes
        if let parsed = try? JSONDecoder().decode(AIResponse.self, from: data) {
            if let answer = parsed.answer { return answer }
            if let text = parsed.text { return text }
        }

        // Fallback: return the raw JSON / string
        if let asString = String(data: data, encoding: .utf8) {
            return asString
        }

        return "No valid response from AI"
    }
}
