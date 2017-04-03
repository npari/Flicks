//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Pari, Nithya on 3/29/17.
//  Copyright © 2017 Pari, Nithya. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add a pull to refresh - refresh control
        addRefreshControl()

        //Setting data source and delegate for table to know the cell as data
        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        self.networkErrorLabel.isHidden=true
        fetchMovies()
        
    }
    
    func fetchMovies() {
        let apiKey = "f8634817a9438344d16fa643adb26970"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if error != nil {
                self.networkErrorLabel.isHidden=false

            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                self.movies = dataDictionary["results"] as? [NSDictionary]
                self.moviesTableView.reloadData()
            
                //Hiding the Network error label if we get data from api
                self.networkErrorLabel.isHidden=true
            }
            
            // Tell the refreshControl to stop spinning
            self.refreshControl.endRefreshing()

        }
        task.resume()

    }
    
    func addRefreshControl() {
        
        //Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshControlAction), for: UIControlEvents.valueChanged)
        
        //add refresh control to table view
        moviesTableView.insertSubview(refreshControl, at: 0)
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction() {
        fetchMovies()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var moviesCount = 0
        if let movies = movies {
            moviesCount = movies.count
        }
        return moviesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        
        let title = movie["title"] as! String
        movieCell.titleLabel?.text = title
        
        let overview = movie["overview"] as! String
        movieCell.overviewLabel?.text = overview

        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
             let imageURL = NSURL(string: baseURL + posterPath)
             let imageURLRequest = NSURLRequest(url: imageURL as! URL)
             movieCell.posterView.setImageWith(
                imageURLRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        movieCell.posterView.alpha = 0.0
                        movieCell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            movieCell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        movieCell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
             })
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.red
        movieCell.selectedBackgroundView = backgroundView
        
        return movieCell
    }
    
    //Remove the gray selection effect
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = moviesTableView.indexPath(for: cell)
        let movie = movies?[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }

}
