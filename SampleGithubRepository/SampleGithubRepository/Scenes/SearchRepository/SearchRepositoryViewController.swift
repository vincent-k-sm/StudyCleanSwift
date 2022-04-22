//
//  SearchRepositoryViewController.swift
//  SampleGithubRepository
//

import UIKit
import MKUtils

protocol SearchRepositoryDisplayLogic: AnyObject {
    func displayFetchOrderResult(viewModel: SearchRepository.Search.ViewModel)
    func displayErrorAlert(viewModel: SearchRepository.Search.ViewModel)
}

class SearchRepositoryViewController: UIViewController, SearchRepositoryDisplayLogic {
   
    var interactor: SearchRepositoryBusinessLogic?
    var router: (NSObjectProtocol & SearchRepositoryRoutingLogic & SearchRepositoryDataPassing)?

    // MARK: Object lifecycle
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        Debug.print("")
    }

    // MARK: - Setup Clean Code Design Pattern 

    private func setup() {
        let viewController = self
        let interactor = SearchRepositoryInteractor()
        let presenter = SearchRepositoryPresenter()
        let router = SearchRepositoryRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: - View lifecycle
    var repos: Repositories? = nil
    
    lazy var tableView: UITableView = {
        let v = UITableView()
        v.delegate = self
        v.dataSource = self
        v.registerCell(type: SearchRepositoryTableViewCell.self)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("")
        self.setUI()
        self.requestSearchRepos()
    }
}

extension SearchRepositoryViewController {
    @objc func searchButtonTapped() {
        self.requestSearchRepos()
    }
}

extension SearchRepositoryViewController {
    private func setUI() {
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        let tableViewContraints = [
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
        ]
        NSLayoutConstraint.activate(tableViewContraints)
    }
}

extension SearchRepositoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let repos = self.repos?.repos else { return }
        if indexPath.row == (repos.count - 3) {
            self.requestSearchRepos()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Debug.print(self.repos?.repos[indexPath.row].fullName)
    }
}

extension SearchRepositoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repos?.repos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        guard let customCell = tableView.dequeueCell(withType: SearchRepositoryTableViewCell.self) as? SearchRepositoryTableViewCell else {
            return cell
        }
        if let item = self.repos?.repos[indexPath.row] {
            customCell.set(model: item)
        }
        customCell.thumbnailImageView.accessibilityLabel = "image \(String(indexPath.row))"
        cell = customCell
        return cell
    }

}

// MARK: - request data from SearchRepositoryInteractor
extension SearchRepositoryViewController {
    func requestSearchRepos() {
        let request = SearchRepository.Search.Request(query: "rxSwift", page: self.repos?.nextPage ?? 1)
        interactor?.fetchRepos(request: request)
    }
}

// MARK: - display view model from SearchRepositoryPresenter
extension SearchRepositoryViewController {
    func displayFetchOrderResult(viewModel: SearchRepository.Search.ViewModel) {
        if let repos = viewModel.repos {
            Debug.print(repos)
//            self.tableView.reloadData()
            let currentReposCount = self.repos?.repos.count ?? 0
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if repos.currentPageIndex == 1 {
                    self.repos = repos
                    self.tableView.reloadData()
                }
                else {
                    let newRepos: [IndexPath] = (0..<repos.repos.count).map({ el -> IndexPath in
                        let index = (currentReposCount + el)
                        return IndexPath(row: index, section: 0)
                    })
                    self.repos?.repos.append(contentsOf: repos.repos)
                    self.repos?.nextPage = repos.nextPage
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: newRepos, with: .fade)
                    self.tableView.endUpdates()
                }
                
            }
        }
        
    }
    
    func displayErrorAlert(viewModel: SearchRepository.Search.ViewModel) {
        if let error = viewModel.error {
            UIAlertController.showMessage(error.localizedDescription)
        }
        
    }
}
