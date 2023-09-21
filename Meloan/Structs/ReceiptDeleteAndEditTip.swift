//
//  ReceiptDeleteAndEditTip.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/21.
//

import Foundation
import TipKit

struct ReceiptDeleteAndEditTip: Tip {
    var title: Text {
        Text("Receipt.DeleteAndEdit.Tip.Title")
    }
    var message: Text? {
        Text("Receipt.DeleteAndEdit.Tip.Text")
    }
    var image: Image? {
        Image(systemName: "square.and.pencil.circle.fill")
    }
}

