//
//  ViewController.swift
//


import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let apiKey = Bundle.main.apiKey(plist: "github")
        print(apiKey)
    }


}

