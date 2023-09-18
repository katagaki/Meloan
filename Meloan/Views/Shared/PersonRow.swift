//
//  PersonRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct PersonRow: View {

    var person: Person
    var isPersonWhoPaid: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            Group {
                if let photo = person.photo, let image = UIImage(data: photo) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("Profile.Generic.Circle")
                        .resizable()
                }
            }
            .frame(width: 30.0, height: 30.0)
            .clipShape(Circle())
            if isPersonWhoPaid {
                Text(verbatim: "\(person.name)\(NSLocalizedString("Person.Payer", comment: ""))")
                    .font(.body)
            } else {
                Text(verbatim: person.name)
                    .font(.body)
            }
        }
    }
}
