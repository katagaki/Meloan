//
//  NoReceiptHintView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/24.
//

import SwiftUI

struct NoReceiptHintView: View {
    var body: some View {
        VStack(alignment:. center, spacing: 6.0) {
            Spacer()
            Image(systemName: "doc.questionmark")
            Text("Shared.NoReceipt")
                .font(.body)
            Spacer()
        }
    }
}
