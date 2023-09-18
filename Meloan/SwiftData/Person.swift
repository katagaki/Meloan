//
//  Item.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/15.
//

import Foundation
import SwiftData
import UIKit

@Model
final class Person {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var photo: Data?
    @Relationship(inverse: \Receipt.personWhoPaid) var receiptsPaid: [Receipt]?
    @Relationship(inverse: \Receipt.peopleWhoParticipated) var receiptsParticipated: [Receipt]?
    var dateAdded: Date = Date()

    init(name: String) {
        self.name = name
        self.photo = nil
    }

    init(name: String, photo: Data?) {
        self.name = name
        self.photo = Person.cropPhoto(photo: photo)
    }

    func sumOwed(to personWhoPaid: Person?) -> Double {
        if let personWhoPaid = personWhoPaid {
            var sum: Double = .zero
            for receipt in receiptsParticipated ?? [] where receipt.personWhoPaid == personWhoPaid {
                sum += receipt.sumOwed(to: personWhoPaid, for: self)
            }
            return sum
        }
        return .zero
    }

    static func cropPhoto(photo data: Data?) -> Data? {
        if let data = data, let sourceImage = UIImage(data: data) {
            // From: https://www.advancedswift.com/crop-image/
            let sideLength = min(sourceImage.size.width, sourceImage.size.height)
            let sourceSize = sourceImage.size
            let xOffset = (sourceSize.width - sideLength) / 2.0
            let yOffset = (sourceSize.height - sideLength) / 2.0
            let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
            let sourceCGImage = sourceImage.cgImage!
            let croppedCGImage = sourceCGImage.cropping(to: cropRect.integral)!
            let imageRendererFormat = sourceImage.imageRendererFormat
            imageRendererFormat.opaque = false
            let circleCroppedImage = UIGraphicsImageRenderer(size: cropRect.size,
                                                             format: imageRendererFormat).image { _ in
                let drawRect = CGRect(origin: .zero, size: cropRect.size)
                UIBezierPath(ovalIn: drawRect).addClip()
                let drawImageRect = CGRect(origin: CGPoint(x: -xOffset, y: -yOffset), size: sourceImage.size)
                sourceImage.draw(in: drawImageRect)
            }
            return circleCroppedImage.pngData()
        }
        return nil
    }
}
