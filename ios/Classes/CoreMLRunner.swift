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
        
        // The sentiment score is between -1.0 (very negative) and 1.0 (very positive).
        let (tag, _) = tagger.tag(at: prompt.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        let sentimentValue = Double(tag?.rawValue ?? "0") ?? 0.0
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let inferenceTimeMs = Int((endTime - startTime) * 1000)
        
        let outputString = sentimentValue > 0.2 ? "Positive" : (sentimentValue < -0.2 ? "Negative" : "Neutral")
        
        // For sentiment, confidence can be represented by the magnitude
        let confidence = abs(sentimentValue)

        return [
            "output": "\(outputString) [Raw Score: \(sentimentValue)]",
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
