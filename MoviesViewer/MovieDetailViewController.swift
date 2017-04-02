//
//  MovieDetailViewController.swift
//  MoviesViewer
//
//  Created by Kumawat, Diwakar on 4/2/17.
//  Copyright © 2017 Kumawat, Diwakar. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    
    @IBOutlet weak var movieDetailLabel: UILabel!
    
    var adult: Bool?
    var released: String?
    var language: String?
    var popularity: Float?
    var votes: Float?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        movieDetailLabel.text = ("Adult: \(adult!) \r Released: \(released!) \r Language: \(language!) \r Popularity: \(popularity!) \r Votes: \(votes!)")

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
