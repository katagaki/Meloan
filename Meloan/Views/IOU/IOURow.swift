//
//  IOURow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import SwiftUI

struct IOURow: View {

    @State var name: String
    @State var price: Double

    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top, spacing: 4.0) {
                Text(LocalizedStringKey(name))
                Spacer()
                Text("\(price, specifier: "%.2f")")
            }
        }
    }
}
