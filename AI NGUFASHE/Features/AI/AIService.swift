//
//  AIService.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import Foundation

final class AIService {
    static let shared = AIService()
    private init() {}

    struct Payload: Codable {
        let text: String
        let prompt: String
    }

    func sendToAPI(text: String, prompt: String) async throws -> String {
        guard let url = URL(string: "https://portfolio-app-drab-two.vercel.app/api/ai") else {
            throw URLError(.badURL)
        }

        let body = Payload(text: text, prompt: prompt)
        let jsonData = try JSONEncoder().encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, _) = try await URLSession.shared.data(for: request)
        return String(data: data, encoding: .utf8) ?? "Invalid response"
    }
}
