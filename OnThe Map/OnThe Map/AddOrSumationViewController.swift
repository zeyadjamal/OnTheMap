//
//  AddOrSumationViewController.swift
//  OnThe Map
//
//  Created by zico on 5/17/19.
//  Copyright © 2019 mansoura Unversity. All rights reserved.
//

import UIKit
import CoreLocation

class AddOrSumationViewController: UIViewController {

    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var linkText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationText.delegate = self
        linkText.delegate = self
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotificationsObserver()
    }
    
    @IBAction func findLocationTapped(_ sender: UIButton) {
        guard let location = locationText.text,
            let mediaLink = linkText.text,
            location != "", mediaLink != "" else {
                self.Alert(title: "Missing information", message: "Please fill both fields and try again")
                return
        }
        
        let studentLocation = StudentLocation(mapString: location, mediaURL: mediaLink)
        geocodeCoordinates(studentLocation)
    }
    
    private func geocodeCoordinates(_ studentLocation: StudentLocation) {
        
        let ai = self.startAnActivityIndicator()
        
        CLGeocoder().geocodeAddressString(studentLocation.mapString!) { (placeMarks, err) in
            guard err == nil else {
                ai.stopAnimating()
                self.Alert(title: "Location not found!", message: "There was a problem searching This location")
                return
            }
            ai.stopAnimating()
            guard let firstLocation = placeMarks?.first?.location else { return }
            var location = studentLocation
            location.latitude = firstLocation.coordinate.latitude
            location.longitude = firstLocation.coordinate.longitude
            self.performSegue(withIdentifier: "map", sender: location)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "map", let vc = segue.destination as? TheLastViewController {
            vc.location = (sender as! StudentLocation)
        }
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancelTapped(_:)))
        
    }
    @objc private func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
