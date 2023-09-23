//
//  JSONs.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/23.
//

import Foundation

let taxRates: TaxRate.List = Bundle.main.decode(TaxRate.List.self,
                                                from: "TaxRates.json")!
let stateNames: StateName.List = Bundle.main.decode(StateName.List.self,
                                                    from: "StateNames.json")!
