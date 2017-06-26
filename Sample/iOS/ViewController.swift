//
//  ViewController.swift
//  iOS
//
//  Created by Meniny on 2017-04-23.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FireDemo.get()
        FireDemo.post()
        FireDemo.FireAPI3()
        FireDemo.escape()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

