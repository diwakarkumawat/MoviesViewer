//
//  MoviesViewController.swift
//  MoviesViewer
//
//  Created by Kumawat, Diwakar on 4/1/17.
//  Copyright © 2017 Kumawat, Diwakar. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var movieTableView: UITableView!
    
    var movies: [NSDictionary]?
    
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
        
        // pass the details
        detailViewController.adult = adult
        detailViewController.released = releaseDate
        detailViewController.popularity = popularity
        detailViewController.votes = votes
        
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageUrl = NSURL(string: baseUrl + posterPath)
        cell.movieImageView.setImageWith(imageUrl! as URL)
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        
        print("row \(indexPath.row)")
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
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
