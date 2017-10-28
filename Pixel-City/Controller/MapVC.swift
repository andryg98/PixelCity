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
import Alamofire
import AlamofireImage

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
    
    var collectionView: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    //Array per le immagini
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    //Array per le foto
    var titleArray = [String]()
    var descriptionArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        addSwipe()
        
        setCollectionView()
    }
    
    func setCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
        immaginiView.addSubview(collectionView!)
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
    
    //Preleva tutti gli URL delle foto
    func retrieveURLS(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        //imageUrlArray = []
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            
            
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.titleArray.append("\(photo["title"]!)")
                self.imageUrlArray.append(postUrl);
            }
            handler(true)
        }
    }
    
    //Preleva le immagini
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        //imageArray[]
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                //Verifica se ha finito di scaricare tutte le immagini
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSession() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
        
}


