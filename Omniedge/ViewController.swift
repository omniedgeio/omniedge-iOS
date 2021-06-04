//
//  ViewController.swift
//  Omniedge
//
//  Created by samuelsong on 2021/4/22.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {
    var tunnel: VPNConfigurationService?;
    @objc func handleButton() {
        if let service = tunnel {
            if !service.isStarted {
                service.installProfile { result in
                    switch result {
                    case .success:
                        print("sucess");
                        break;
                    case let .failure(error):
                        print("fail\(error)");
                        break;
                    }
                }
            }
        }
    }
    override func loadView() {
        let view = UIView();
        view.backgroundColor = UIColor.white;
        
        //setup button
        let button = UIButton.init(type: UIButton.ButtonType.system);
        //button.layer.borderColor = UIColor.red.cgColor;
        //button.layer.borderWidth = 1;
        button.setTitle("Start Omniedge", for: UIControl.State.normal);
        button.setTitleColor(UIColor.blue, for: UIControl.State.normal);
        button.setTitleColor(UIColor.red, for: UIControl.State.highlighted);
        button.addTarget(self, action: #selector(handleButton), for: UIControl.Event.touchUpInside);
        view.addSubview(button);
        button.translatesAutoresizingMaskIntoConstraints = false;
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
        ]);
        self.view = view;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tunnel = .shared;
        // Do any additional setup after loading the view.
    }


}

