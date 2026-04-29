import CoreML
import NaturalLanguage
import Foundation
#if canImport(Flutter)
import Flutter
#endif

enum AIError: Error {
    case modelNotFound
    case modelNotLoaded
    case processingError(String)
}

class CoreMLRunner {
    private var useBuiltInNLP = false

    func loadModel(name: String, useGPU: Bool) throws {
        if name == "built_in_sentiment" {
            self.useBuiltInNLP = true
            return
        }
        
        // Original logic for custom models could go here, but for this showcase we skip it
        self.useBuiltInNLP = false
        throw AIError.modelNotFound
    }

    func runText(prompt: String) throws -> [String: Any] {
        guard useBuiltInNLP else { throw AIError.modelNotLoaded }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Use Apple's built-in NLP for sentiment analysis
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = prompt
        
        let range = prompt.startIndex..<prompt.endIndex
        tagger.setLanguage(.english, range: range)
        
        var sentimentValue: Double = 0.0
        var rawScores = [String]()
        
        tagger.enumerateTags(in: range, unit: .paragraph, scheme: .sentimentScore) { tag, tokenRange in
            if let tag = tag {
                rawScores.append(tag.rawValue)
                if let score = Double(tag.rawValue) {
                    sentimentValue = score
                }
            } else {
                rawScores.append("nil")
            }
            return true
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let inferenceTimeMs = Int((endTime - startTime) * 1000)
        
        let outputString = sentimentValue > 0.2 ? "Positive" : (sentimentValue < -0.2 ? "Negative" : "Neutral")
        
        // Debugging info
        let available = NLTagger.availableTagSchemes(for: .paragraph, language: .english).map { $0.rawValue }
        let isAvailable = available.contains(NLTagScheme.sentimentScore.rawValue)
        
        let confidence = abs(sentimentValue)

        return [
            "output": "\(outputString) [Raw: \(rawScores.joined(separator: ",")), Avail: \(isAvailable)]",
            "confidenceScore": confidence,
            "inferenceTimeMs": inferenceTimeMs
        ]
    }
    
    #if canImport(Flutter)
    func runImage(imageBytes: FlutterStandardTypedData) throws -> [String: Any] {
        throw AIError.modelNotLoaded
    }
    #endif

    func dispose() {
        self.useBuiltInNLP = false
    }
}
