//
//  ViewController.swift
//


import UIKit
import MKUtils

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let apiKey = Bundle.main.apiKey(plist: "github")
        Debug.print(apiKey)
    }


}

