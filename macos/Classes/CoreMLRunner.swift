import CoreML
import NaturalLanguage
import Vision
import Foundation
import AppKit
#if canImport(FlutterMacOS)
import FlutterMacOS
#endif

enum AIError: Error {
    case modelNotFound
    case modelNotLoaded
    case processingError(String)
}

class CoreMLRunner {
    private var useBuiltInNLP = false
    private var useBuiltInVision = false

    func loadModel(name: String, useGPU: Bool) throws {
        if name == "built_in_sentiment" {
            self.useBuiltInNLP = true
            return
        } else if name == "built_in_vision" {
            self.useBuiltInVision = true
            return
        }
        
        self.useBuiltInNLP = false
        self.useBuiltInVision = false
        throw AIError.modelNotFound
    }

    func runText(prompt: String) throws -> [String: Any] {
        guard useBuiltInNLP else { throw AIError.modelNotLoaded }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
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
        
        let available = NLTagger.availableTagSchemes(for: .paragraph, language: .english).map { $0.rawValue }
        let isAvailable = available.contains(NLTagScheme.sentimentScore.rawValue)
        
        let confidence = abs(sentimentValue)

        return [
            "output": "\(outputString) [Raw: \(rawScores.joined(separator: ",")), Avail: \(isAvailable)]",
            "confidenceScore": confidence,
            "inferenceTimeMs": inferenceTimeMs
        ]
    }
    
    #if canImport(FlutterMacOS)
    func runImage(imageBytes: FlutterStandardTypedData) throws -> [String: Any] {
        guard useBuiltInVision else { throw AIError.modelNotLoaded }
        
        guard #available(macOS 11.0, *) else {
            throw AIError.processingError("Image classification requires macOS 11.0+")
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard let image = NSImage(data: imageBytes.data),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw AIError.processingError("Failed to decode image bytes")
        }
        
        var bestCategory = "Unknown"
        var bestScore: Float = 0.0
        var rawDetails = ""
        
        let request = VNClassifyImageRequest { request, error in
            if let results = request.results as? [VNClassificationObservation] {
                if let topResult = results.first {
                    bestCategory = topResult.identifier
                    bestScore = topResult.confidence
                }
                rawDetails = results.prefix(3).map { "\($0.identifier)=\($0.confidence)" }.joined(separator: ", ")
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let inferenceTimeMs = Int((endTime - startTime) * 1000)
        
        return [
            "output": "\(bestCategory) [Raw: \(rawDetails)]",
            "confidenceScore": Double(bestScore),
            "inferenceTimeMs": inferenceTimeMs
        ]
    }
    #endif

    func dispose() {
        self.useBuiltInNLP = false
        self.useBuiltInVision = false
    }
}
