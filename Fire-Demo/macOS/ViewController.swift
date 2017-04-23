//
//  ViewController.swift
//  macOS
//
//  Created by Meniny on 2017-04-23.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        FireDemo.get()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

