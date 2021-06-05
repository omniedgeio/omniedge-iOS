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
    
    @objc func handleStop() {
        if let service = tunnel {
            if service.isStarted {
                service.stop();
            }
        }
    }
    @objc func handleStart() {
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
            } else {
                service.start();
            }
        }
    }
    override func loadView() {
        let view = UIView();
        view.backgroundColor = UIColor.white;
        
        //start button
        let startButton = UIButton.init(type: UIButton.ButtonType.system);
        //button.layer.borderColor = UIColor.red.cgColor;
        //button.layer.borderWidth = 1;
        startButton.setTitle("Start", for: UIControl.State.normal);
        startButton.setTitleColor(UIColor.blue, for: UIControl.State.normal);
        startButton.setTitleColor(UIColor.red, for: UIControl.State.highlighted);
        startButton.addTarget(self, action: #selector(handleStart), for: UIControl.Event.touchUpInside);
        view.addSubview(startButton);
        startButton.translatesAutoresizingMaskIntoConstraints = false;
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            startButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
        ]);
        
        //stop button
        let stopButton = UIButton.init(type: UIButton.ButtonType.system);
        //button.layer.borderColor = UIColor.red.cgColor;
        //button.layer.borderWidth = 1;
        stopButton.setTitle("Stop", for: UIControl.State.normal);
        stopButton.setTitleColor(UIColor.blue, for: UIControl.State.normal);
        stopButton.setTitleColor(UIColor.red, for: UIControl.State.highlighted);
        stopButton.addTarget(self, action: #selector(handleStart), for: UIControl.Event.touchUpInside);
        view.addSubview(stopButton);
        stopButton.translatesAutoresizingMaskIntoConstraints = false;
        let topAlign = NSLayoutConstraint(item:stopButton, attribute:.top, relatedBy:.equal, toItem:startButton,
                                          attribute: .bottom, multiplier: 1.0, constant: 20);
        NSLayoutConstraint.activate([
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor),
            topAlign,
            stopButton.widthAnchor.constraint(equalTo: startButton.widthAnchor),
            stopButton.heightAnchor.constraint(equalTo: startButton.heightAnchor),
        ]);

        self.view = view;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tunnel = .shared;
        // Do any additional setup after loading the view.
    }


}

