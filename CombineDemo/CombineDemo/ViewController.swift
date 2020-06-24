//
//  ViewController.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    let simpleDemo = SimpleDemo()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        simpleDemo.run()
    }
    
    @IBAction func presentProfilePage(_ sender: Any) {
        let profilePage = ProfileViewController(viewModel: .init())
        self.present(profilePage, animated: true, completion: nil)
    }
}

