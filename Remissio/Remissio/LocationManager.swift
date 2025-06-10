//
//  LocationManager.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 27/04/25.
//  Modified and Merged with Location by Gianni Tumedei on 26/05/24
//
//

import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private(set) var isMonitoring = false
    private(set) var latitude: Double? = nil
    private(set) var longitude: Double? = nil

    private let location = CLLocationManager()

    override init() {
        super.init()
        print("📍 [LocationManager] Inizializzato.")
        location.delegate = self
    }

    func requestLocation() {
        print("📡 [LocationManager] requestLocation() chiamato.")
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            print("❌ [LocationManager] Il monitoraggio dei cambiamenti significativi NON è disponibile.")
            return
        }
        
        let status = location.authorizationStatus
        print("🔐 [LocationManager] Stato autorizzazione corrente: \(status.rawValue)")

        if status == .denied {
            print("🚫 [LocationManager] Accesso alla posizione NEGATO.")
            return
        }

        location.requestWhenInUseAuthorization()
        location.startMonitoringSignificantLocationChanges()
        isMonitoring = true
        print("✅ [LocationManager] Iniziato il monitoraggio dei cambiamenti significativi.")
    }

    func stopLocationRequest() {
        if !isMonitoring {
            print("⚠️ [LocationManager] stopLocationRequest() chiamato ma il monitoraggio non è attivo.")
            return
        }
        location.stopMonitoringSignificantLocationChanges()
        isMonitoring = false
        print("🛑 [LocationManager] Monitoraggio fermato.")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("📬 [LocationManager] didUpdateLocations() chiamato.")
        
        guard let location = locations.first else {
            print("🤷‍♂️ [LocationManager] Nessuna posizione trovata.")
            return
        }

        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude

        print("✅ [LocationManager] Nuova posizione ottenuta - 🧭 Lat: \(latitude!), Lon: \(longitude!)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❗️[LocationManager] Errore nel ricevere la posizione: \(error.localizedDescription)")
        stopLocationRequest()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("🔄 [LocationManager] Autorizzazione cambiata: \(manager.authorizationStatus.rawValue)")
    }
}
