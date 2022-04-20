//
//  SearchRepositoryRouter.swift
//  SampleGithubRepository
//

import UIKit

@objc protocol SearchRepositoryRoutingLogic {
    //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol SearchRepositoryDataPassing {
    var dataStore: SearchRepositoryDataStore? { get }
}

class SearchRepositoryRouter: NSObject, SearchRepositoryRoutingLogic, SearchRepositoryDataPassing {
    weak var viewController: SearchRepositoryViewController?
    var dataStore: SearchRepositoryDataStore?

    deinit {
        //
    }
}

extension SearchRepositoryRouter {
    // MARK: Routing (navigating to other screens)
    //func routeToSomewhere() {

    //        let destinationVC = SomewhereViewController()
    //        var destinationDS = destinationVC.router!.dataStore!
    //        passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //        navigateToSomewhere(source: viewController!, destination: destinationVC)
        
    /// segue
    //    if let segue = segue {
    //        let destinationVC = segue.destination as! SomewhereViewController
    //        var destinationDS = destinationVC.router!.dataStore!
    //        passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //    } else {
    //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //        let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //        var destinationDS = destinationVC.router!.dataStore!
    //        passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //        navigateToSomewhere(source: viewController!, destination: destinationVC)
    //    }
    //}

    
    // MARK: Navigation to other screen
    //func navigateToSomewhere(source: SearchRepositoryViewController, destination: SomewhereViewController) {
    
    //    let options = TransitionOptions(
    //        direction: .fade,
    //        style: .linear,
    //        duration: .main
    //    )
    //    self.presentVcOveral(source: source, destination: destination, options: options)
    
    /// segue
    //    source.show(destination, sender: nil)
    //}
    
    // MARK: Passing data to other screen

    //    func passDataToSomewhere(source: SearchRepositoryDataStore, destination: inout SomewhereDataStore) {
    //        destination.name = source.name
    //    }
}
