//
//  BaseViewController.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/10/19.
//  Copyright © 2019 test. All rights reserved.
//


import UIKit

class BaseViewController: UIViewController {
    public var segueHandler: ((UIStoryboardSegue, Any?) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueHandler?(segue, sender)
    }
}

