//
//  ViewController.swift
//  Traits
//
//  Created by Shaw on 7/7/19.
//  Copyright © 2019 RedRain. All rights reserved.
//

import UIKit
import RxGesture

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.rx.knock.replaceWith(self.count) => rx[{ (self, count: Int) in
            print("count: \(count)")
        }]
    }
    
    private var _count = 0
    var count: Int {
        _count += 1
        return _count
    }

    deinit {
        print("\(NSString(string: #file).lastPathComponent):\(#line):\(String(describing: self)):\(#function)...")
    }
}
