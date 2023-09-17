//
//  ReceiptItemCompactRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct ReceiptItemCompactRow: View {

    var name: String
    var price: Double
    var person: Person?

    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            Text(LocalizedStringKey(name))
            Spacer()
            Text("\(price, specifier: "%.2f")")
            Group {
                if let person = person {
                    if let data = person.photo, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                    } else {
                        Image("Profile.Generic")
                            .resizable()
                    }
                } else {
                    Image("Profile.Shared")
                        .resizable()
                }
            }
            .frame(width: 16.0, height: 16.0)
            .clipShape(Circle())
            // TODO: Allow selection of currency per receipt
        }
        .font(.system(size: 14.0))
        .monospaced()
    }
}
