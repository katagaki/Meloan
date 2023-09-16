//
//  PersonRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct PersonRow: View {

    var person: Person

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            Group {
                if let photo = person.photo, let image = UIImage(data: photo) {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    Image("Person.Generic")
                        .resizable()
                }
            }
            .frame(width: 30.0, height: 30.0)
            .clipShape(Circle())
            Text(verbatim: person.name)
                .font(.body)
        }
    }
}
