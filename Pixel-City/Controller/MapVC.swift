//
//  ViewController.swift
//  Pixel-City
//
//  Created by Andrea Garau on 19/10/2017.
//  Copyright © 2017 Andrea Garau. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var immaginiView: UIView!
    
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    let regionRadius: Double = 1000.0
    var screenSize = UIScreen.main.bounds
    
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        addSwipe()
    }
    
    //Aggiunge la possibilità di aggiungere un pin con un doppio tocco sulla mappa
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }

    //Ricentra la mappa quando il button viene premuto
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}



extension MapVC: MKMapViewDelegate {
    
    //Cambia colore e rende animato il pin.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Se l'unica annotazione è quella della posizione dell'utente, non la modifica
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    
    //Centra la mappa nel punto in cui si trova l'utente.
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Rilascia un pin sulla mappa.
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLabel()
        
        animateViewUp()
        addSpinner()
        addProgressLabel()
        
        //touchPoint ha coordinate dello schermo
        let touchPoint = sender.location(in: mapView)
        //touchCoordinate ha le coordinate sulla posizione reale del pin
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        //Crea un'istanza di DroppablePin, il quale sarà posto sulla mappa dopo il doppio click
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Rimuove il pin dalla mappa
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    //Aggiunge la possibilità di fare uno swipe per chiudere immaginiView
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        immaginiView.addGestureRecognizer(swipe)
    }
    
    //Aggiunge l'animazione nell'apertura di immaginiView
    func animateViewUp() {
        self.imageHeight.constant = 300
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    //Aggiunge l'animazione nella chiusura di immaginiView
    @objc func animateViewDown() {
        self.imageHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    //Aggiunge uno spinner che indica il caricamento nella immaginiView
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - (spinner?.frame.width)! / 2, y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        immaginiView.addSubview(spinner!)
    }
    
    //Rimuove lo spinner se presente
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    //Aggiunge un label che evidenzia lo stato del download delle immagini
    func addProgressLabel() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: screenSize.width / 2 - 125, y: 175, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "12/40 PHOTOS LOADED"
        immaginiView.addSubview(progressLabel!)
    }
    
    //Rimuove progressLabel dalla superview
    func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
}





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
