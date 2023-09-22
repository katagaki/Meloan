//
//  IOUTip.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/21.
//

import Foundation
import TipKit

struct IOUTip: Tip {
    var title: Text {
        Text("IOU.Tip.Title")
    }
    var message: Text? {
        Text("IOU.Tip.Text")
    }
    var image: Image? {
        Image(systemName: "filemenu.and.selection")
    }
}
