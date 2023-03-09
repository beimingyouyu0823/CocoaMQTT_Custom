//
//  RttTableViewCell.swift
//  Example
//
//  Created by admin on 2023/3/8.
//  Copyright © 2023 emqtt.io. All rights reserved.
//

import UIKit

class RttTableViewCell: UITableViewCell {
    
    var contentValue:Double?{

        didSet{

            guard let contentValue = contentValue else { return }

            titleLabel.text = contentValue.cleanZero

        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews(){
        
        self.backgroundColor = UIColor.white
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(47)
            make.centerY.equalTo(contentView)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.right.equalTo(-47)
            make.centerY.equalTo(contentView)
        }
    }
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var contentLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.text = "Rtt"
        return label
    }()
    
        
    func setTitle(_ title:String?) -> Void {
        titleLabel.text = title
    }


}
