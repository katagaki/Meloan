//
//  MoreAppIconView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/22.
//

import Komponents
import SwiftUI

struct MoreAppIconView: View {

    var icons: [AppIcon] = [
        AppIcon("More.Customization.AppIcon.Dollar"),
        AppIcon("More.Customization.AppIcon.JapaneseYen", imageName: "AppIcon.JPY"),
        AppIcon("More.Customization.AppIcon.VietnameseDong", imageName: "AppIcon.VND")
    ]

    var body: some View {
        List {
            ForEach(icons, id: \.name) { icon in
                Button {
                    UIApplication.shared.setAlternateIconName(icon.imageName, completionHandler: { error in
                        if let error {
                            debugPrint(error.localizedDescription)
                        }
                    })
                } label: {
                    ListAppIconRow(icon)
                        .tint(.primary)
                }
                .contentShape(Rectangle())
            }
        }
        .font(.body)
        .listStyle(.insetGrouped)
        .navigationTitle("ViewTitle.More.Customization.AppIcon")
    }
}
