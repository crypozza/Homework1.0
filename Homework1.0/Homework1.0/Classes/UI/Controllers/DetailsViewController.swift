//
//  DetailsViewController.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 10/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation


class VehicleAnnotation:MKPointAnnotation {
    var vehicleid:Int = -1
}

class DetailsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var userIdentifier:Int = -1
    
    var vehicles:Array<Vehicle> = []
    var annotations:Array<VehicleAnnotation> = []
    
    let manager = CLLocationManager()
    
    var currentLocation:CLLocation?
    
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        manager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        
        loadAndDisplayUserData()
      

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.loadAndDisplayUserData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }

}

private extension DetailsViewController {
    
    func loadAndDisplayUserData(){
        
        API.shared.loadUserVehicles(using: Int(userIdentifier)) { error in
            
            if let error = error {
                print("Error: \(error)")
                //Frequently fails with server overload error
                self.showError()
                return
            }
            //Reload vehicle data...
            DispatchQueue.main.async {
                if let user = API.shared.fetchUser(using: self.userIdentifier) {
                    self.vehicles = user.vehicles.allObjects as! [Vehicle]
                    self.showVehicles()
                }
            }
            
        }
        
    }
    
    func showError(){
        
        let alert = UIAlertController(title: "Error", message: "Error downloading data...\nServer overload.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        let retry = UIAlertAction(title: "Try Again", style: .default){ _ in
            self.loadAndDisplayUserData()
        }
        alert.addAction(ok)
        alert.addAction(retry)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showVehicles(){
        
        for vehicle in vehicles {
            
            var annotation = annotations.filter { $0.vehicleid == vehicle.vehicleid }.first
            if annotation == nil {
                annotation = VehicleAnnotation()
                annotation!.vehicleid = Int(vehicle.vehicleid)
                annotation!.title = vehicle.user.owner.name + " " + vehicle.user.owner.surname
                annotation!.subtitle = vehicle.make + " " + vehicle.model
                annotations.append(annotation!)
                mapView.addAnnotations([annotation!])
            }
            
            print("Lat/Lon: \(vehicle.lat)/\(vehicle.lon)")
            //Update position
            annotation!.coordinate = CLLocationCoordinate2D(latitude: vehicle.lat, longitude: vehicle.lon)
            
            let region = MKCoordinateRegion(center: annotation!.coordinate, latitudinalMeters: 10000.0, longitudinalMeters: 10000.0)
            mapView.setRegion(region, animated: true)
            
        }
        
    }
    
}

extension DetailsViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annot = annotation as? VehicleAnnotation {
            
            var anotView = mapView.dequeueReusableAnnotationView(withIdentifier: "vehicles") as? MKPinAnnotationView
            if anotView == nil {
                anotView = MKPinAnnotationView(annotation: annot, reuseIdentifier: "vehicles")
                anotView?.canShowCallout = true
                anotView?.isUserInteractionEnabled = true
                anotView?.isSelected = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.onCalloutTap))
                anotView?.addGestureRecognizer(tapGesture)
            }
            
            anotView?.annotation = annot
            
            if let vehicle = (vehicles.filter{ $0.vehicleid == annot.vehicleid}).first {
            
                anotView?.tag = Int(vehicle.vehicleid)
                
                HTTPLoader.load(from: vehicle.foto) { data, error in
                    DispatchQueue.main.async {
                        if let data = data {
                            let imageView = UIImageView(image:  UIImage(data: data))
                            imageView.frame = CGRect(x: 0, y: 0, width:anotView!.bounds.width, height: anotView!.bounds.height)
                            imageView.contentMode = .scaleAspectFit
                            anotView?.leftCalloutAccessoryView = imageView
                        }
                    }
                }
                
            }
            
            return anotView
        }
        
        let reuseId = "pin"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        pinView.pinTintColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        pinView.canShowCallout = true
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
}

extension DetailsViewController {
    @objc func onCalloutTap(gesture recognizer:UITapGestureRecognizer){
        
        guard let vehicle = (vehicles.filter{ $0.vehicleid == recognizer.view!.tag}).first,
            let callout = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CalloutViewController") as? CalloutViewController else {
            return
        }
        
        self.addChild(callout)
        self.view.addSubview(callout.view)
        callout.view.frame = view.bounds
        
        callout.lon = vehicle.lon
        callout.lat = vehicle.lat
        callout.vehicleid = Int(vehicle.vehicleid)
        callout.delegate = self
        callout.labelName.text = vehicle.user.owner!.name + " " + vehicle.user.owner!.surname
        callout.labelVehicle.text = vehicle.make + " " + vehicle.model
        callout.viewColor.backgroundColor = UIColor(hexString: vehicle.color)
        callout.imageAddress = vehicle.foto
        callout.loadImage()
        
        
    }
}

extension DetailsViewController:CalloutViewControllerProtocol{
    
    func onButtonDirections(vehicleid:Int) {
        
        guard let loc = currentLocation, let vehicle = (vehicles.filter{ $0.vehicleid == vehicleid}).first else {
            return
        }
        
        self.mapView.removeOverlays( self.mapView.overlays )
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: vehicle.lat, longitude: vehicle.lon), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else {
                return
            }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
    }
    
}

extension DetailsViewController:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.first
        
    }
    
}
