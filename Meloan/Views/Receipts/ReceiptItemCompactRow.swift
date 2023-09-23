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
    var isPaid: Bool = false
    var person: Person?
    var hidesPhoto: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
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
            .opacity(hidesPhoto ? 0 : 1)
            Group {
                Text(LocalizedStringKey(name))
                Spacer()
                Text(format(price))
            }
            .strikethrough(isPaid)
            // TODO: Allow selection of currency per receipt
        }
        .font(.system(size: 14.0))
        .monospaced()
    }
}
