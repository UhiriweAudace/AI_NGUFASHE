//
//  AIService.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import Foundation

enum AIServiceError: Error {
    case invalidURL
    case serverError(String)
    case decodingError
    case unknown
}

class AIService {
    // TODO: change to your deployed Vercel function URL, or local `vercel dev` URL for testing.
    // Examples:
    // - Local dev: "http://127.0.0.1:3000/api/ai"
    // - Deployed: "https://your-app.vercel.app/api/ai"
    private static let vercelEndpoint = "https://portfolio-app-drab-two.vercel.app/"

    static func askAI(text: String, prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: vercelEndpoint) else {
            completion(.failure(AIServiceError.invalidURL))
            return
        }

        let requestBody = AIRequest(text: text, prompt: prompt)
        guard let data = try? JSONEncoder().encode(requestBody) else {
            completion(.failure(AIServiceError.unknown))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Optionally add an app token header for extra protection, if you set it up on Vercel
        // request.setValue("Bearer <YOUR_APP_TOKEN>", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                completion(.failure(err))
                return
            }

            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                let msg = String(data: data ?? Data(), encoding: .utf8) ?? "unknown server error"
                completion(.failure(AIServiceError.serverError(msg)))
                return
            }

            guard let d = data else {
                completion(.failure(AIServiceError.unknown))
                return
            }

            if let aiResp = try? JSONDecoder().decode(AIResponse.self, from: d) {
                completion(.success(aiResp.answer))
            } else {
                // try to decode as generic JSON to help debugging
                let text = String(data: d, encoding: .utf8) ?? ""
                completion(.failure(AIServiceError.serverError(text)))
            }
        }
        task.resume()
    }
}
