//
//  ViewController.swift
//  Example
//
//  Created by CrazyWisdom on 15/12/14.
//  Copyright © 2015年 emqtt.io. All rights reserved.
//

import UIKit
import CocoaMQTT
import SnapKit


class ViewController: UIViewController {
    
    var timer: Timer?
    //用户当前选择时间，默认100秒
    let curDeTime:Int = 100
    var dataArray = [Double]()

    private var netSocketTool: LatencyAsyncSocketTool?
    
    private let kCellID = "RttTableViewCell"
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 30
        tableV.backgroundColor = .white
        tableV.tableHeaderView = UIView()
        tableV.register(RttTableViewCell.self, forCellReuseIdentifier: kCellID)
        tableV.tableFooterView = UIView()
        return tableV
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        
        self.netSocketTool = LatencyAsyncSocketTool()
        self.netSocketTool?.asyncSocketOpen()
        netSocketTool?.pingFinished = { [weak self] time in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dataArray.append(time)
                self.tableView.reloadData()
                print(self.dataArray)
            }
        }

    }
    
    func timerConfige(_ success: @escaping (_ finish : Bool) -> Void){
        
        var duration: Int = curDeTime + 1
        timer = Timer(timeInterval: 0.3, repeats: true, block: { [weak self] _ in
            
            duration -= 1
            let pingCount = (self?.curDeTime ?? 0) - duration
            
            self?.netSocketTool?.sendData(pingCount)
            if duration <= 0 {
                //是否需要断开连接
                self?.netSocketTool?.mqtt?.disconnect()
                self?.timer?.invalidate()
                self?.timer = nil
                success(true)
            }
        })
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    
    func setUpViews(){
        view.addSubview(connectButton)
        view.addSubview(disConnectButton)
        view.addSubview(clearButton)
        view.addSubview(tableView)
        
        connectButton.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalToSuperview().offset(80)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        disConnectButton.snp.makeConstraints { make in
            make.left.equalTo(connectButton.snp.right).offset(30)
            make.top.equalTo(connectButton.snp.top)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        clearButton.snp.makeConstraints { make in
            make.left.equalTo(disConnectButton.snp.right).offset(30)
            make.top.equalTo(connectButton.snp.top)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(connectButton.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    private lazy var connectButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("连接", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickConnectButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var disConnectButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("断开", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickdisConnectButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("清除", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickClearConnectButton), for: .touchUpInside)
        return button
    }()

    
    @objc private func didClickConnectButton(){
        self.netSocketTool?.asyncSocketConnect()
        self.netSocketTool?.connectSuccess = { [weak self] in
            self?.timerConfige { finish in
                    print("rtt测试完成")
                 //   guard let self = self else{ return }
                }
        }
 
    }
    
    @objc private func didClickdisConnectButton(){
        
        self.netSocketTool?.mqtt?.disconnect()
        self.netSocketTool?.startCount = 0
        self.timer?.invalidate()
        self.timer = nil
        
        let value = self.dataArray.map({ Float($0) }).reduce(0, +) / Float(self.dataArray.count)
        guard value.isNaN == false else { return }
        print("平均数\(Int(value))")
        
        guard let maxValue = self.dataArray.map({ (Float($0) ) }).sorted().last else { return }
        print("最大数\(Int(maxValue))")
    }
    
    @objc private func didClickClearConnectButton(){
        self.dataArray.removeAll()
        self.tableView.reloadData()
    }
}

extension ViewController {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 2 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconnect"
        }

        print("[TRACE] [\(prettyName)]: \(message)")
    }
}

extension Optional {
    // Unwrap optional value for printing log only
    var description: String {
        if let self = self {
            return "\(self)"
        }
        return ""
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        let cell:RttTableViewCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! RttTableViewCell
        cell.contentValue = cellData
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
