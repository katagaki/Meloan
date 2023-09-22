//
//  MoreAppIconView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/22.
//

import Komponents
import SwiftUI

struct MoreAppIconView: View {

    var icons: [AppIcon] = [AppIcon(previewImageName: "AppIcon.Dollar",
                                    name: "More.Customization.AppIcon.Dollar"),
                            AppIcon(previewImageName: "AppIcon.JapaneseYen",
                                    name: "More.Customization.AppIcon.JapaneseYen",
                                    iconName: "JPY"),
                            AppIcon(previewImageName: "AppIcon.VietnameseDong",
                                    name: "More.Customization.AppIcon.VietnameseDong",
                                    iconName: "VND")]

    var body: some View {
        List {
            ForEach(icons, id: \.name) { icon in
                ListAppIconRow(image: icon.previewImageName,
                               text: NSLocalizedString(icon.name, comment: ""),
                               iconToSet: icon.iconName)
            }
        }
        .font(.body)
        .listStyle(.insetGrouped)
        .navigationTitle("ViewTitle.More.Customization.AppIcon")
    }
}
