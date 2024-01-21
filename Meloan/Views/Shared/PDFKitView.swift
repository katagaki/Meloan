//
//  PDFKitView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/24.
//

import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {

    var document: PDFDocument

    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) { }
}
