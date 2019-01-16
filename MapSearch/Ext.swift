//
//  Ext.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2019 Munesada Yohei. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // アラートを手軽に出せるように、拡張します.
    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true)
    }
    
}
