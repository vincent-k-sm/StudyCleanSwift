//
//  SearchRepositoryViewController.swift
//  SampleGithubRepository
//

import UIKit
import MKUtils

protocol SearchRepositoryDisplayLogic: AnyObject {
    func displayResult(viewModel: SearchRepository.Search.ViewModel)
    func displayErrorAlert(viewModel: SearchRepository.Search.ViewModel)
//    func displaySomethingElse(viewModel: SearchRepository.SomethingElse.ViewModel)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("")
        self.doSomeThing()
    }
    
    //MARK: - receive events from UI
    
    //@IBOutlet weak var nameTextField: UITextField!
//
//    @IBAction func someButtonTapped(_ sender: Any) {
//
//    }
//
//    @IBAction func otherButtonTapped(_ sender: Any) {
//
//    }
    
    // MARK: - request data from SearchRepositoryInteractor

//    func doSomething() {
//        let request = SearchRepository.Search.Request()
//        interactor?.doSomething(request: request)
//    }
//
//    func doSomethingElse() {
//        let request = SearchRepository.SomethingElse.Request()
//        interactor?.doSomethingElse(request: request)
//    }

    
}

extension SearchRepositoryViewController {
    @objc func searchButtonTapped() {
        self.doSomeThing()
    }
}


// MARK: - request data from SearchRepositoryInteractor
extension SearchRepositoryViewController {
    func doSomeThing() {
        let request = SearchRepository.Search.Request(query: "rxSwift", page: 1)
        interactor?.fetchRepos(request: request)
    }
}

// MARK: - display view model from SearchRepositoryPresenter
extension SearchRepositoryViewController {
    func displayResult(viewModel: SearchRepository.Search.ViewModel) {
        if let repos = viewModel.repos {
            Debug.print(repos)
        }
        
    }
    
    func displayErrorAlert(viewModel: SearchRepository.Search.ViewModel) {
        if let error = viewModel.error {
            UIAlertController.showMessage(error.localizedDescription)
        }
        
    }
}
