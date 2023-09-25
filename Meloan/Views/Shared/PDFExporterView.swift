//
//  PDFExporterView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/24.
//

import PDFKit
import QuickLook
import SwiftUI

struct PDFExporterView: View {

    @Environment(\.dismiss) var dismiss
    var receipt: Receipt
    @State var pdfFile: PDFDocument?

    var body: some View {
        NavigationStack {
            if let pdfFile = pdfFile {
                PDFKitView(document: pdfFile)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.primary)
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                        }
                        ToolbarItem(placement: .bottomBar) {
                            HStack {
                                Spacer()
                                ShareLink(item: pdfFile, preview: SharePreview(receipt.name, image: pdfFile)) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                    .navigationTitle("Shared.PDFExport")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            let pdfData = createPDF()
            pdfFile = PDFDocument(data: pdfData)
        }
    }

    // swiftlint:disable function_body_length
    func createPDF() -> Data {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [kCGPDFContextTitle: receipt.name + " " + Date.now.formatted(date: .abbreviated,
                                                                                           time: .omitted),
                              kCGPDFContextAuthor: Bundle.main.appName()] as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 597.6, height: 842.4),
                                             format: format)
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            // Dynamic variables
            let minX: Double = 10.0
            var minY: Double = 10.0
            // Draw title
            let titleSize = drawTitle(receipt.name,
                                      x: minX, y: minY)
            // Draw logo
            drawImage(UIImage(named: "PDF.Watermark")!, x: 597.6 - 10.0 - titleSize.height, y: 10.0,
                      width: titleSize.height, height: titleSize.height)
            minY += titleSize.height + 10.0
            drawDivider(x: minX, y: minY)
            minY += 1.0 + 20.0
            // Draw receipt items
            if !receipt.items().isEmpty {
                let purchasedItemsSubtitleSize = drawSubtitle(NSLocalizedString("Receipt.PurchasedItems", comment: ""),
                                                              x: minX, y: minY)
                minY += purchasedItemsSubtitleSize.height + 10.0
                for item in receipt.items() {
                    let itemNameSize = drawLeadingText(item.name, x: minX, y: minY)
                    let priceSize = drawPriceText(item.price, x: minX, y: minY)
                    if item.paid {
                        drawHorizontalLine(x: minX, y: minY + itemNameSize.height / 2, length: itemNameSize.width)
                        drawHorizontalLine(x: 587.6 - priceSize.width, y: minY + priceSize.height / 2, length: priceSize.width)
                    }
                    minY += max(itemNameSize.height, priceSize.height) + 10.0
                    if let person = item.person {
                        let personNameSize = drawLeadingSecondaryText(person.name, x: minX + 26.0, y: minY)
                        if let photo = person.photo {
                            drawImage(UIImage(data: photo)!, x: minX, y: minY + (personNameSize.height / 2) - 8.0)
                        } else {
                            drawImage(UIImage(named: "Profile.Generic.Circle")!,
                                      x: minX, y: minY + (personNameSize.height / 2) - 8.0)
                        }
                        minY += personNameSize.height + 10.0
                    } else {
                        let sharedNameSize = drawLeadingSecondaryText(NSLocalizedString("Shared.Shared", comment: ""),
                                                                      x: minX + 26.0, y: minY)
                        drawImage(UIImage(named: "Profile.Shared.Circle")!,
                                  x: minX, y: minY + (sharedNameSize.height / 2) - 8.0)
                        minY += sharedNameSize.height + 10.0
                    }
                }
                minY += 10.0
                drawDivider(x: minX, y: minY)
                minY += 20.0
            }
            // Draw discount items
            if !receipt.discountItems().isEmpty {
                let discountItemsSubtitleSize = drawSubtitle(NSLocalizedString("Receipt.Discounts", comment: ""),
                                                             x: minX, y: minY)
                minY += discountItemsSubtitleSize.height + 10.0
                for item in receipt.discountItems() {
                    let itemNameSize = drawLeadingText(item.name, x: minX, y: minY)
                    let priceSize = drawPriceText(item.price, x: minX, y: minY)
                    minY += max(itemNameSize.height, priceSize.height) + 10.0
                }
                minY += 10.0
                drawDivider(x: minX, y: minY)
                minY += 1.0 + 20.0
            }
            // Draw tax items
            if !receipt.taxItems().isEmpty {
                let taxItemsSubtitleSize = drawSubtitle(NSLocalizedString("Receipt.Taxes", comment: ""),
                                                        x: minX, y: minY)
                minY += taxItemsSubtitleSize.height + 10.0
                for item in receipt.taxItems() {
                    let itemNameSize = drawLeadingText(item.name, x: minX, y: minY)
                    let priceSize = drawPriceText(item.price, x: minX, y: minY)
                    minY += max(itemNameSize.height, priceSize.height) + 10.0
                }
                minY += 10.0
                drawDivider(x: minX, y: minY)
                minY += 20.0
            }
            // Draw sum before and after tax
            let totalBeforeTaxSize = drawLeadingText(NSLocalizedString("Receipt.Total.BeforeTax", comment: ""),
                                                     x: minX, y: minY)
            let totalBeforeTaxPriceSize = drawPriceText(receipt.sumOfItems(), x: minX, y: minY)
            minY += max(totalBeforeTaxSize.height, totalBeforeTaxPriceSize.height) + 10.0
            let totalAfterTaxSize = drawLeadingText(NSLocalizedString("Receipt.Total.AfterTax", comment: ""),
                                                    font: .boldSystemFont(ofSize: 16.0),
                                                    x: minX, y: minY)
            let totalAfterTaxPriceSize = drawPriceText(receipt.sum(),
                                                       font: .monospacedSystemFont(ofSize: 16.0, weight: .bold),
                                                       x: minX, y: minY)
            minY += max(totalAfterTaxSize.height, totalAfterTaxPriceSize.height) + 20.0
            drawDivider(x: minX, y: minY)
        }
        return pdfData
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable identifier_name
    func drawTitle(_ text: String,
                   x: Double, y: Double) -> CGSize {
        let largeFontAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 36.0)]
        let title = NSAttributedString(string: text, attributes: largeFontAttributes)
        let titleSize = title.size()
        let titleRect = CGRect(x: x, y: y, width: titleSize.width, height: titleSize.height)
        title.draw(in: titleRect)
        return titleSize
    }

    func drawSubtitle(_ text: String,
                      x: Double, y: Double) -> CGSize {
        let largeFontAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28.0)]
        let subtitle = NSAttributedString(string: text, attributes: largeFontAttributes)
        let subtitleSize = subtitle.size()
        let subtitleRect = CGRect(x: x, y: y, width: subtitleSize.width, height: subtitleSize.height)
        subtitle.draw(in: subtitleRect)
        return subtitleSize
    }

    func drawLeadingText(_ text: String, font: UIFont = .systemFont(ofSize: 16.0),
                         x: Double, y: Double) -> CGSize {
        let regularFontAttributes = [NSAttributedString.Key.font: font]
        let text = NSAttributedString(string: text, attributes: regularFontAttributes)
        let textSize = text.size()
        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
        text.draw(in: textRect)
        return textSize
    }

    func drawLeadingSecondaryText(_ text: String, font: UIFont = .systemFont(ofSize: 16.0),
                                  x: Double, y: Double) -> CGSize {
        let regularFontAttributes = [NSAttributedString.Key.font: font,
                                     NSAttributedString.Key.foregroundColor: UIColor.gray]
        let text = NSAttributedString(string: text, attributes: regularFontAttributes)
        let textSize = text.size()
        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
        text.draw(in: textRect)
        return textSize
    }

    func drawPriceText(_ price: Double, font: UIFont = .monospacedSystemFont(ofSize: 16.0, weight: .regular),
                       x: Double, y: Double) -> CGSize {
        let formattedText = format(price)
        return drawTrailingText(formattedText, font: font, x: x, y: y)
    }

    func drawTrailingText(_ text: String, font: UIFont = .systemFont(ofSize: 16.0),
                          x: Double, y: Double) -> CGSize {
        let regularFontAttributes = [NSAttributedString.Key.font: font]
        let text = NSAttributedString(string: text, attributes: regularFontAttributes)
        let textSize = text.size()
        let textRect = CGRect(x: 597.6 - x - textSize.width, y: y, width: textSize.width, height: textSize.height)
        text.draw(in: textRect)
        return textSize
    }

    func drawDivider(x: Double, y: Double, height: Double = 1.0) {
        // Draw divider
        let divider = UIBezierPath()
        divider.lineWidth = height
        divider.move(to: CGPoint(x: x, y: y))
        divider.addLine(to: CGPoint(x: 587.6, y: y))
        UIColor.separator.setStroke()
        divider.stroke()
    }

    func drawHorizontalLine(x: Double, y: Double, length: Double, height: Double = 1.0) {
        // Draw divider
        let divider = UIBezierPath()
        divider.lineWidth = height
        divider.move(to: CGPoint(x: x, y: y))
        divider.addLine(to: CGPoint(x: x + length, y: y))
        UIColor.black.setStroke()
        divider.stroke()
    }

    func drawImage(_ image: UIImage, x: Double, y: Double, width: Double = 16.0, height: Double = 16.0) {
        image.draw(in: CGRect(x: x, y: y, width: width, height: height))
    }
    // swiftlint:enable identifier_name
}
