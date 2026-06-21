//
//  ReceiptOCRService.swift
//  Meloan
//

import Foundation
import UIKit
import Vision

enum ReceiptOCRService {

    static func recognizeRows(in images: [UIImage]) async -> [String] {
        await Task.detached(priority: .userInitiated) {
            images.flatMap { recognizeRows(in: $0) }
        }.value
    }

    static func recognizeRows(in image: UIImage) -> [String] {
        guard let cgImage = image.cgImage else { return [] }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        // Disabled so item codes and prices aren't "corrected" into dictionary words.
        request.usesLanguageCorrection = false
        request.recognitionLanguages = recognitionLanguages()
        let handler = VNImageRequestHandler(cgImage: cgImage,
                                            orientation: cgOrientation(image.imageOrientation),
                                            options: [:])
        do {
            try handler.perform([request])
        } catch {
            debugPrint("Receipt OCR failed: \(error.localizedDescription)")
            return []
        }
        guard let observations = request.results else { return [] }
        return groupIntoRows(observations)
    }

    // MARK: - Row reconstruction

    private struct Fragment {
        let text: String
        let minX: CGFloat
        let midY: CGFloat
        let height: CGFloat
    }

    private static func groupIntoRows(_ observations: [VNRecognizedTextObservation]) -> [String] {
        let fragments: [Fragment] = observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            let box = observation.boundingBox  // normalized, origin at bottom-left
            return Fragment(text: candidate.string, minX: box.minX, midY: box.midY, height: box.height)
        }
        guard !fragments.isEmpty else { return [] }

        // Vision's y-axis points up, so larger midY means higher on the page.
        let sorted = fragments.sorted { $0.midY > $1.midY }
        let heights = sorted.map { $0.height }.sorted()
        let medianHeight = heights[heights.count / 2]
        let tolerance = max(medianHeight * 0.6, 0.008)

        var rows: [[Fragment]] = []
        for fragment in sorted {
            if let last = rows.last, let reference = last.last,
               abs(reference.midY - fragment.midY) <= tolerance {
                rows[rows.count - 1].append(fragment)
            } else {
                rows.append([fragment])
            }
        }
        return rows.map { row in
            row.sorted { $0.minX < $1.minX }
                .map { $0.text }
                .joined(separator: " ")
        }
    }

    // MARK: - Helpers

    private static func recognitionLanguages() -> [String] {
        var languages = Array(Locale.preferredLanguages.prefix(2))
        if !languages.contains(where: { $0.hasPrefix("en") }) {
            languages.append("en-US")
        }
        return languages
    }

    private static func cgOrientation(_ orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
