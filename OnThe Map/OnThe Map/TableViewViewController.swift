//
//  TableViewViewController.swift
//  OnThe Map
//
//  Created by zico on 5/17/19.
//  Copyright © 2019 mansoura Unversity. All rights reserved.
//

import UIKit

class TableViewViewController: TheSubclassOfAllCllassViewController ,UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override var locationsData: LocationsData? {
        didSet {
            guard let locationsData = locationsData else { return }
            locations = locationsData.studentLocations
        }
    }
    var locations: [StudentLocation] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        API.deleteSession { (error) in
            self.dismiss(animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell" ,for: indexPath )
        cell.textLabel?.text = "\(locations[indexPath.row].firstName ?? "") \(locations[indexPath.row].lastName ?? "")"
        cell.detailTextLabel?.text = (locations[indexPath.row].mapString)
        
        //cell.studentLocation = locations[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let urlString = locations[indexPath.row].mediaURL else {
            Alert(title: "Invalid URL1", message: "Invalid mediaURL")
            return
        }
        guard let url = URL(string: urlString) else{
            Alert(title: "Invalid URL2", message: "Invalid mediaURL")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
}
