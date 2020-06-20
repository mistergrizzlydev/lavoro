//
//  PublicProfileViewController.swift
//  Lavoro
//
//  Created by Manish on 18/06/20.
//  Copyright © 2020 Manish. All rights reserved.
//

import UIKit
import ApplozicSwift
import InputBarAccessoryView

class PublicProfileViewController: BaseViewController {
    @IBOutlet weak var tableview: UITableView!
    let profileService = ProfileService()
    var profileId: String?
    var publicProfile: PublicProfile?
    var isDataLoaded = false
    @IBOutlet weak var userImage: UIImageView!
    let inputBar: InputBarAccessoryView = IMessageInputBar()
    private var keyboardManager = KeyboardManager()
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var headerView: PublicProfileHeaderView?
    
    var stateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 250/255, alpha: 1)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        fetchData()
        inputBar.topStackView.addArrangedSubview(stateView)
        manageKeyboard()
    }
    
    func setupView() {
        inputBar.delegate = self
        inputBar.inputTextView.keyboardType = .default
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        let backImage = UIImage(named: "ic_back_white")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .done, target: self, action: #selector(backButton))
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    func manageKeyboard() {
        keyboardManager.bind(to: tableview)
        keyboardManager.on(event: .didShow) { [weak self] (notification) in
            self?.bottomConstraint.constant = notification.endFrame.height
//            self?.tableview.scrollIndicatorInsets.bottom = notification.endFrame.height
        }.on(event: .didHide) { [weak self] _ in
            let barHeight = self?.inputBar.bounds.height ?? 0
            self?.bottomConstraint.constant = barHeight
//            self?.tableview.contentInset.bottom = barHeight
//            self?.tableview.scrollIndicatorInsets.bottom = barHeight
        }
    }

    func fetchData() {
        guard let profileId = profileId else {
            return
        }
        if publicProfile == nil {
            self.showLoadingView()
        }
        profileService.getPublicProfile(with: profileId) { [weak self] (success, message, publicProfile)  in
            self?.stopLoadingView()
            self?.publicProfile = publicProfile
            if let avatar = publicProfile?.avatar, let url = URL(string: avatar) {
                self?.userImage.sd_setImage(with: url, completed: nil)
                self?.isDataLoaded = true
            }
            self?.tableview.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    func refreshView() {
        fetchData()
    }
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBAction func chatButtonTap() {
        guard let profileId = profileId else {
            return
        }
        let chatManager = ALChatManager(applicationKey: ALChatManager.applicationId)
        chatManager.launchChatWith(contactId: profileId, from: self.tabBarController ?? self, configuration: ALKConfiguration())
    }
    
    @IBAction func followButtonTap(button: UIButton) {
        guard let profileId = profileId else {
            return
        }
        headerView?.stopFollowChangeAnimation()
        userService.changeFollowUser(with: profileId, isFollow: !button.isSelected) { [weak self] (success, message) in
            self?.refreshView()
            self?.headerView?.startFollowChangeAnimation()
        }
    }
    
    func sendComment(text: String) {
        guard let profileId = profileId else {
            return
        }
        self.inputBar.sendButton.startAnimating()
        profileService.postComment(with: profileId, comment: text) { [weak self] (success, message) in
            self?.inputBar.sendButton.stopAnimating()
            if success {
                self?.inputBar.inputTextView.text = ""
                self?.refreshView()
            } else {
                MessageViewAlert.showError(with: message ?? "Please try again")
            }
        }
    }
}

extension PublicProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return publicProfile?.comments.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! PublicProfileTableViewCell
        cell.setupCell(with: publicProfile?.comments[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return UIScreen.main.bounds.width  - (120  + UIScreen.main.safeAreaTop() + (self.navigationController?.navigationBar.frame.size.height ?? 0))
        }
        return ((isDataLoaded == true) ? (120 + UIScreen.main.safeAreaTop() + (self.navigationController?.navigationBar.frame.size.height ?? 0)) : 0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
        headerView = PublicProfileHeaderView.fromNib(named: "PublicProfileHeaderView")
        headerView?.setupView(with: publicProfile)
        headerView?.commentsButton.addTarget(self, action: #selector(chatButtonTap), for: .touchUpInside)
        headerView?.heartButton.addTarget(self, action: #selector(followButtonTap(button:)), for: .touchUpInside)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


extension PublicProfileViewController {
    static func showProfile(on navigation:UINavigationController?, profileId: String) {
        guard let navigation = navigation else {
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "PublicProfileViewController") as! PublicProfileViewController
        viewController.profileId = profileId
        viewController.hidesBottomBarWhenPushed = true
        navigation.pushViewController(viewController, animated: true)
        viewController.hidesBottomBarWhenPushed = false
    }
}
extension PublicProfileViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendComment(text: text)
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
//        bottomConstraint.constant = size.height + 300 // keyboard size estimate
    }
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {}
}
