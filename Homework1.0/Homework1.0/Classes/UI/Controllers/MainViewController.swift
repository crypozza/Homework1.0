//
//  MainViewController.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//

import UIKit

class MainTableCell:UITableViewCell {
    
    static let identifier = "mainTableCell"
    
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelFullname: UILabel!
    
    func setup(with user:User){
        
        labelFullname.text = user.owner.name + " " + user.owner.surname
       // imageViewAvatar.image = nil
        
        //Lazyload image
        HTTPLoader.load(from: user.owner.foto) { data, errorl in
            if let data = data {
                DispatchQueue.main.async { [weak self] in
                    self?.imageViewAvatar.image = UIImage(data: data)
                    self?.imageViewAvatar.layer.cornerRadius = 40
                    self?.imageViewAvatar.clipsToBounds = true
                }
            }
        }
    }
    
}

class MainViewController: UIViewController {

    static let detailsSegune = "segueDetails"
    
    @IBOutlet weak var tableView: UITableView!
    
    internal var users:[User] = []
    internal var selectedIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        if canReload() == true {
            downloadData()
        } else {
            showUsers()
        }

    }
    
    func downloadData(){
        API.shared.loadUsersList { _ in
            DispatchQueue.main.async {
                //Store last load date...
                UserDefaults.standard.set(Date(), forKey: "date")
                self.showUsers()
            }
        }
    }
    
    func showUsers(){
        self.users = API.shared.fetchUsers()
        self.tableView.reloadData()
    }
    
    func canReload()->Bool{
     
        guard let lastDay = UserDefaults.standard.object(forKey: "date") as? Date else {
            return true
        }
        
        return daysBetween(start: lastDay, end: Date()) >= 1
        
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }

    func openDetails(){
        
        performSegue(withIdentifier: MainViewController.detailsSegune, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DetailsViewController {
            dest.userIdentifier = Int(users[ selectedIndex ].userid)
        }
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableCell.identifier, for: indexPath) as? MainTableCell else {
            return UITableViewCell(style: .default, reuseIdentifier: MainTableCell.identifier)
        }
        
        let user = users[ indexPath.row ]
        
       cell.setup(with: user)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        
        openDetails()
    }
    
}
