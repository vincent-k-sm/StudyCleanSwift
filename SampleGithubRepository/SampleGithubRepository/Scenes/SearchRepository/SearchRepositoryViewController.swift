//
//  SearchRepositoryViewController.swift
//  SampleGithubRepository
//

import UIKit

protocol SearchRepositoryDisplayLogic: AnyObject {
    func displaySomething(viewModel: SearchRepository.Something.ViewModel)
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
        //
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

    // MARK: - Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        doSomething()
//        doSomethingElse()
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

    func doSomething() {
        let request = SearchRepository.Something.Request()
        interactor?.doSomething(request: request)
    }
//
//    func doSomethingElse() {
//        let request = SearchRepository.SomethingElse.Request()
//        interactor?.doSomethingElse(request: request)
//    }

    // MARK: - display view model from SearchRepositoryPresenter

    func displaySomething(viewModel: SearchRepository.Something.ViewModel) {
        //nameTextField.text = viewModel.name
    }
//
//    func displaySomethingElse(viewModel: SearchRepository.SomethingElse.ViewModel) {
//        // do sometingElse with viewModel
//    }
}
