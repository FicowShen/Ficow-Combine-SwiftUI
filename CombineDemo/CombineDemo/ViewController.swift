//
//  ViewController.swift
//  CombineDemo
//
//  Created by FicowShen on 2020/6/24.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import UIKit

func log(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
    let filename = file.split(separator: "/").last?.replacingOccurrences(of: ".swift", with: "") ?? "-"
    print("🐤\(filename) \(function)[\(line)]:")
    items.forEach { print($0, separator: "", terminator: "") }
    print()
}

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    let simpleDemo = SimpleDemo()
    let connectableDemo = ConnectablePublisherDemo()
    let customSubscriberWithBackPressureDemo = CustomSubscriberWithBackPressureDemo()
    let subjectsDemo = SubjectsDemo()
    let notificationPublisherDemo = NotificationPublisherDemo()
    let timerPublisherDemo = TimerPublisherDemo()
    let kvoPublisherDemo = KVOPublisherDemo()
    let asyncCodeDemo = AsyncCodeDemo()
    let publishersDemo = CombinePublishersDemo()
    let operatorsDemo = CommonOperatorsDemo()
    let schedulersDemo = CombineSchedulersDemo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        simpleDemo.run()
//        connectableDemo.run()
//        customSubscriberWithBackPressureDemo.run()
//        subjectsDemo.run()
//        notificationPublisherDemo.run()
//        timerPublisherDemo.run()
//        kvoPublisherDemo.run()
//        asyncCodeDemo.run()
//        publishersDemo.run()
//        operatorsDemo.run()
        schedulersDemo.run()
    }
    
    @IBAction func presentProfilePage(_ sender: Any) {
        let profilePage = ProfileViewController(viewModel: .init())
        self.present(profilePage, animated: true, completion: nil)
    }
}

