//
//  MapVCLocation.swift
//  Pixel-City
//
//  Created by Andrea Garau on 26/10/2017.
//  Copyright © 2017 Andrea Garau. All rights reserved.
//

import UIKit
import CoreLocation

extension MapVC: CLLocationManagerDelegate {
    
    //Verificare se l'app ha i permessi
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    //Ogni volta che l'autorizzazione sulla localizzazione cambia, ricentra mapView sulla posizione
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
