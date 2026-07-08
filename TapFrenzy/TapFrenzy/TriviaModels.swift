//
//  TriviaModels.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-08.
//
import Foundation

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Identifiable {
    var id: UUID { UUID() }

    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    var decodedQuestion: String { question.htmlDecoded }
    var decodedCorrectAnswer: String { correctAnswer.htmlDecoded }
    var decodedIncorrectAnswers: [String] { incorrectAnswers.map { $0.htmlDecoded } }
}

extension String {
   
    var htmlDecoded: String {
        var result = self

        let namedEntities: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&apos;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&rsquo;": "\u{2019}",
            "&lsquo;": "\u{2018}",
            "&rdquo;": "\u{201D}",
            "&ldquo;": "\u{201C}",
            "&hellip;": "\u{2026}",
            "&eacute;": "\u{00E9}",
            "&ouml;": "\u{00F6}",
            "&uuml;": "\u{00FC}",
            "&auml;": "\u{00E4}",
            "&ntilde;": "\u{00F1}",
            "&nbsp;": " "
        ]
        for (entity, replacement) in namedEntities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }

        return result.decodingNumericEntities()
    }

    /// Decodes numeric entities
    private func decodingNumericEntities() -> String {
        var result = ""
        let chars = Array(self)
        var i = 0
        while i < chars.count {
            if chars[i] == "&", i + 1 < chars.count, chars[i + 1] == "#" {
                var j = i + 2
                var numberString = ""
                while j < chars.count, chars[j] != ";" {
                    numberString.append(chars[j])
                    j += 1
                }
                if j < chars.count, let code = UInt32(numberString), let scalar = Unicode.Scalar(code) {
                    result.append(Character(scalar))
                    i = j + 1
                    continue
                }
            }
            result.append(chars[i])
            i += 1
        }
        return result
    }
}
