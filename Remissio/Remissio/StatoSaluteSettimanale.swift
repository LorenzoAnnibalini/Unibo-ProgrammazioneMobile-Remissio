//
//  StatoSaluteSettimanale.swift
//  Struttura dello stato settimanale di salute
//
//  Remissio
//
//  Created by Lorenzo Annibalini on 24/04/25.
//

import Foundation
import CoreLocation

struct StatoSaluteSettimanale: Codable, Identifiable {
    var id = UUID()
    var settimana: String
    var data: Date
    var scariche: Int
    var percentualeSangue: Double
    var peso: Double
    var statoSaluteGenerale: String
    var tipologiaCacca: Double
    var latitude: Double?
    var longitude: Double?
}
