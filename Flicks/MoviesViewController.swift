//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Pari, Nithya on 3/29/17.
//  Copyright © 2017 Pari, Nithya. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting data source and delegate for table to know the cell as data
        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        
        let apiKey = "f8634817a9438344d16fa643adb26970"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("ERROR!!!!")
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print("SUCCESS!!!!")
                print(dataDictionary)
                self.movies = dataDictionary["results"] as? [NSDictionary]
                self.moviesTableView.reloadData()
            }
        }
        task.resume()

        
    }
    
    class func fetchMovies(successCallBack: @escaping (NSDictionary) -> (), errorCallBack: ((Error?) -> ())?) {
        let apiKey = "f8634817a9438344d16fa643adb26970"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                errorCallBack?(error)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                //print(dataDictionary)
                successCallBack(dataDictionary)
            }
        }
        task.resume()
    }
    
    func successCallBack() {
        
    }
    func errorCallBack() {
        
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
             movieCell.posterView.setImageWith(imageURL as! URL)
        }
        
        return movieCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = moviesTableView.indexPath(for: cell)
        let movie = movies?[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")

    }
    

}
