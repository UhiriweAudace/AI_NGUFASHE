//
//  AIModel.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import Foundation

struct AIRequest: Codable {
    let text: String
    let prompt: String
}

struct AIResponse: Codable {
    // accept several possible shapes; prefer "answer", fallback to "answer" or raw "text"
    let answer: String?
    let text: String?
}
