//
//  UIViewController+Extension.swift
//  CombineLoginDemo
//
//  Created by FicowShen on 2020/8/27.
//  Copyright © 2020 ficow. All rights reserved.
//

import UIKit

extension UIViewController {
    func showErrorAlert(error: Error) {
        showAlert(title: "Error", message: error.localizedDescription, actions: [("OK", nil)])
    }
    
    func showAlert(title: String,
                   message: String,
                   actions: [(title: String, handler: ((UIAlertAction) -> Void)?)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { (title, handler) in
            let action = UIAlertAction(title: title, style: .default, handler: handler)
            alert.addAction(action)
        }
        
        present(alert, animated: true, completion: nil)
    }
}
