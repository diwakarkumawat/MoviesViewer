
//
//  MoviesViewController.swift
//  MoviesViewer
//
//  Created by Kumawat, Diwakar on 4/1/17.
//  Copyright © 2017 Kumawat, Diwakar. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var movieTableView: UITableView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var resultSearchController = UISearchController()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the index path from the cell that was tapped
        let indexPath = movieTableView.indexPathForSelectedRow
        // Get the Row of the Index Path and set as index
        let index = indexPath?.row
        // Get in touch with the DetailViewController
        let detailViewController = segue.destination as! MovieDetailViewController
        // Pass on the data to the Detail ViewController by setting it's indexPathRow value
        
        // get movie details
        let movie = movies![index!]
        let adult = movie["adult"] as! Bool
        let releaseDate = movie["release_date"] as! String
        let popularity = movie["popularity"] as! Float
        let votes = movie["vote_count"] as! Float
        let language = movie["original_language"] as! String
        let title = movie["title"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageUrl = URL(string: (baseUrl + posterPath))
        
        // pass the details
        detailViewController.adult = adult
        detailViewController.released = releaseDate
        detailViewController.popularity = popularity
        detailViewController.votes = votes
        detailViewController.language = language
        detailViewController.movieLabel = title
        detailViewController.image = imageUrl
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.resultSearchController.isActive
        {
            return (self.filteredMovies?.count)!
        }
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie: NSDictionary?
        if self.resultSearchController.isActive && (filteredMovies?.count)! > 0
        {
            movie = filteredMovies![indexPath.row]
        }
        else {
            movie = movies![indexPath.row]
        }
        
        //let movie = movies![indexPath.row]
        let title = movie?["title"] as! String
        let overview = movie?["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500 1"
        let posterPath = movie?["poster_path"] as! String
        // let imageUrl = NSURL(string: baseUrl + posterPath)
        
        if let imageUrl = NSURL(string: baseUrl + posterPath) {
            cell.movieImageView.setImageWith(imageUrl as URL)
        } else {
            // photos is nil. network error?
            // Implemented using UIAlertController - before reading the requirement again - that it may not be used.
            let alertController = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                print("Ok");
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
        
        
        //cell.movieImageView.setImageWith(imageUrl! as URL)
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        
        print("row \(indexPath.row)")
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredMovies?.removeAll(keepingCapacity: false)
        //let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        // let array = (self.movies! as [NSDictionary]).filter(searchPredicate)
        // self.filteredMovies = array as! [NSDictionary]
        let searchString: NSString = searchController.searchBar.text! as NSString
        
        for item in movies! { // loop through data items
            let obj = item as NSDictionary
            let title = obj["title"] as! String
            let overview = obj["overview"] as! String
            var found: Bool? = false
            if NSString(string: title.lowercased()).contains(searchString.lowercased as String) {
                //filteredMovies?.append(obj)
                found = true
            }
            if NSString(string: overview.lowercased()).contains(searchString.lowercased as String) {
                //filteredMovies?.append(obj)
                found = true
            }
            
            if found! {
                filteredMovies?.append(obj)
            }
        }

        self.movieTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self

        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.movieTableView.tableHeaderView = self.resultSearchController.searchBar
        self.movieTableView.reloadData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        /*
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_refreshControl:)), for: UIControlEvents.valueChanged)
        */
        movieTableView.insertSubview(refreshControl, at: 0)
        refreshControlAction(refreshControl)

        
        let api_key = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(api_key)")
        let request = NSURLRequest(url: url! as URL)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,
                                                                     completionHandler: {
                (dataOrNil, response, error) in
                                                                        MBProgressHUD.hide(for: self.view, animated: true)
                                                                        if let data = dataOrNil {
                                                                            if let responseDirectory = try! JSONSerialization.jsonObject(
                                                                                with: data, options: []) as? NSDictionary {
                                                                                NSLog("response: \(responseDirectory)")
                                                                                self.movies = (responseDirectory["results"] as! [NSDictionary])
                                                                                
                                                                                self.filteredMovies = (responseDirectory["results"] as! [NSDictionary])
                                                                                
                                                                                self.movieTableView.reloadData()
                                                                            }
                                                                        }
        });
        task.resume()
        
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        
        // Configure session so that completion handler is executed on main UI thread
        let api_key = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(api_key)")
        let request = NSURLRequest(url: url! as URL)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,
                                                        completionHandler: {
                                                            (dataOrNil, response, error) in
                                                            if let data = dataOrNil {
                                                                if let responseDirectory = try! JSONSerialization.jsonObject(
                                                                    with: data, options: []) as? NSDictionary {
                                                                    NSLog("response: \(responseDirectory)")
                                                                    self.movies = (responseDirectory["results"] as! [NSDictionary])
                                                                    self.movieTableView.reloadData()
                                                                    refreshControl.endRefreshing()
                                                                }
                                                            }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
