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
    let answer: String
}
