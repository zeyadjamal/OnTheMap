//
//  TheSubclassOfAllCllassViewController.swift
//  OnThe Map
//
//  Created by zico on 5/17/19.
//  Copyright © 2019 mansoura Unversity. All rights reserved.
//

import UIKit
class TheSubclassOfAllCllassViewController: UIViewController {
    var locationsData: LocationsData?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStudentLocations()
    }
    func setupUI() {
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addLocationTapped(_:)))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshLocationsTapped(_:)))
        navigationItem.rightBarButtonItems = [plusButton, refreshButton]
    }
    @objc private func addLocationTapped(_ sender: Any) {
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "betweenTheFristAndTheEnd") as! UINavigationController
        present(navController, animated: true, completion: nil)
    }
    @objc private func refreshLocationsTapped(_ sender: Any) {
        loadStudentLocations()
    }
    private func loadStudentLocations() {
        let ai = self.startAnActivityIndicator()
        API.Parser.getStudentLocations { (data) in
            ai.stopAnimating()
            guard let data = data else {
                self.Alert(title: "Error", message: "No internet connection found")
                return
            }
            guard data.studentLocations.count > 0 else {
                self.Alert(title: "Error", message: "No pins found")
                return
            }
            self.locationsData = data
        }
    }

}
