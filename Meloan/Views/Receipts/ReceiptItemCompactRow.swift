//
//  ReceiptItemCompactRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct ReceiptItemCompactRow: View {

    @AppStorage(wrappedValue: "", "CurrencySymbol", store: defaults) var currencySymbol: String
    var name: String
    var price: Double
    var isPaid: Bool = false
    var person: Person?
    var hidesPhoto: Bool = false
    @State var displayedPrice: String = ""

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
                Text(displayedPrice)
            }
            .strikethrough(isPaid)
            // TODO: Allow selection of currency per receipt
        }
        .font(.system(size: 14.0))
        .monospaced()
        .onAppear {
            displayedPrice = format(price)
        }
        .onChange(of: price, { _, _ in
            displayedPrice = format(price)
        })
        .onChange(of: currencySymbol) { _, _ in
            displayedPrice = format(price)
        }
    }
}
