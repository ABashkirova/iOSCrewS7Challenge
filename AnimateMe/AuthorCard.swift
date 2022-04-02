//
//  AuthorCard.swift
//  AnimateMe
//
//  Created by Alexandra Bashkirova on 26.11.2021.
//

import UIKit
import SnapKit

class AuthorCardViewController: UIViewController {
    var contentScrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.layer.cornerRadius = 16
        return scrollview
    }()
    
    var background: UIImageView! = {
        let avatar = UIImageView()
        avatar.image = UIImage(named: "okno")
        avatar.contentMode = .scaleAspectFit
        avatar.clipsToBounds = true
        return avatar
    }()
    
    var avatar: UIImageView! = {
        let avatar = UIImageView()
        avatar.layer.cornerRadius = 30
        avatar.contentMode = .scaleAspectFit
        avatar.clipsToBounds = true
        return avatar
    }()
    
    var name: UILabel = {
        let name = UILabel()
        name.font = UIFont(name: "TTFirsNeue-Regular", size: 13)
        name.textAlignment = .center
        return name
    }()
    
    var theme: UILabel = {
        let theme = UILabel()
        theme.numberOfLines = 0
        theme.textAlignment = .center
        theme.font = UIFont(name: "TTFirsNeue-Medium", size: 22)
        return theme
    }()
    
    var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .natural
        descriptionLabel.font = UIFont(name: "TTFirsNeue-Regular", size: 15)
        return descriptionLabel
    }()
    
    var time: UILabel = {
        let time = UILabel()
        time.numberOfLines = 1
        time.textAlignment = .center
        time.font = UIFont.italicSystemFont(ofSize: 15)
        return time
    }()
    
    var data: DataItem?
    var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        contentScrollView.backgroundColor = UIColor(named: "orangeP")
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(background.snp.centerY)
            make.bottom.equalToSuperview()
        }
        self.contentScrollView.addSubview(avatar)
        self.contentScrollView.addSubview(name)
        self.contentScrollView.addSubview(theme)
        self.contentScrollView.addSubview(descriptionLabel)
        self.contentScrollView.addSubview(time)
       
        avatar.image = UIImage(named: data?.image ?? "")
        name.text = data?.author
        theme.text = data?.title
        descriptionLabel.text = data?.description
        time.text = data?.time
        
        avatar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.height.equalTo(240)
            make.height.equalTo(avatar.snp.width)
            make.centerX.equalToSuperview()
        }
        
        name.snp.makeConstraints { make in
            
            make.centerX.equalToSuperview()
            make.top.equalTo(avatar.snp.bottom).offset(24)
        }
        
        theme.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(name.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(theme.snp.bottom).offset(46)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        time.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(64)
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.greaterThanOrEqualToSuperview().offset(-40)
        }
    }
    
}
