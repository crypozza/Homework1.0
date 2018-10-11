//
//  CalloutViewController.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 11/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import Contacts

protocol CalloutViewControllerProtocol {
    func onButtonDirections(vehicleid:Int)
}

class CalloutViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelVehicle: UILabel!
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var labelAddress: UILabel!
    
    var delegate:CalloutViewControllerProtocol?
    var imageAddress = ""
    var vehicleid:Int = -1
    var lon:Double = 0
    var lat:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelAddress.text = ""
        
        let location = CLLocation(latitude: lat, longitude: lon)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first, let address = placemark.postalAddress {
                self.labelAddress.text = CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
            }
        }
    }
    
    func loadImage(){
        HTTPLoader.load(from: imageAddress) { data, error in
            DispatchQueue.main.async { [weak self] in
                if let data = data {
                    self?.imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    @IBAction func onButtonDirection(_ sender: Any) {
        
        delegate?.onButtonDirections(vehicleid: vehicleid)
        closeController()
    }
    
    @IBAction func onButtonClose(_ sender: Any) {
        
        closeController()

    }
    
    private func closeController(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}
