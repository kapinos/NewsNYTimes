//
//  ArticlesViewController.swift
//  BMuseTestTask
//
//  Created by Anastasia on 2/5/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit

class ArticlesViewController: UIViewController {
    
    // MARK: -IBOutlets
    @IBOutlet weak var categoriesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var articlesTableView: UITableView!
    
    // MARK: - Properties
    private var token: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let category = getCategory(by: categoriesSegmentedControl.selectedSegmentIndex)
        downloadAndShowArticles(by: category)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        token?.invalidate()
        NewsAPI.service.resetArticles()
    }
}

// MARK: - Navigation
extension ArticlesViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArticleDetailsSegue" {
            guard let detailsVC = segue.destination as? ArticleDetailsViewController else { return }
            guard let article = sender as? Article else  { return }
            detailsVC.article = article
        }
    }
}

// MARK: - Private
private extension ArticlesViewController {
    func downloadAndShowArticles(by category: String) {
        token = NewsAPI.service.observe(\NewsAPI.articles) { _, _ in
            DispatchQueue.main.async {
                self.articlesTableView.reloadData()
            }
        }
        NewsAPI.service.fetchArticles(by: category)
    }
    
    func getCategory(by index: Int) -> String {
        var category = ""
        switch index {
        case 0: category = "home"
        case 1: category = "opinion"
        case 2: category = "world"
        case 3: category = "science"
        case 4: category = "politics"
        default: category = "home"
        }
        return category
    }
}

// MARK: - User Actions
extension ArticlesViewController {
    @IBAction func categoriesSelected(_ sender: UISegmentedControl) {
        guard let selectedCategory = sender.titleForSegment(at: sender.selectedSegmentIndex) else { return }
        downloadAndShowArticles(by: selectedCategory)
    }
}

// MARK: -UITableViewDataSource
extension ArticlesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NewsAPI.service.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        cell.configureCell(article: NewsAPI.service.articles[indexPath.row])
        return cell
    }
}


// MARK: -UITableVIewDelegate
extension ArticlesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = NewsAPI.service.articles[indexPath.row]
        performSegue(withIdentifier: "ArticleDetailsSegue", sender: article)
    }
}
