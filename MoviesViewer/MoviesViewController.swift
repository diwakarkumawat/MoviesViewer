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
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "MovieCell")!
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        cell.textLabel!.text = title
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
                                                                                self.movies = responseDirectory["results"] as! [NSDictionary]
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
