//
//  ViewController.swift
//  macOS
//
//  Created by Meniny on 2017-04-23.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import Cocoa
import Fire

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        FireDemo.get()
        
        FireDemo.upload()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

