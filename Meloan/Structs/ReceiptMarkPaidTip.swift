//
//  ReceiptMarkPaidTip.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/18.
//

import Foundation
import TipKit

struct ReceiptMarkPaidTip: Tip {
    var title: Text {
        Text("Receipt.MarkPaid.Tip.Title")
    }
    var message: Text? {
        Text("Receipt.MarkPaid.Tip.Text")
    }
    var image: Image? {
        Image(systemName: "checklist")
    }
}
