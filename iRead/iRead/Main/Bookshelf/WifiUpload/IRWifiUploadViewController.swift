//
//  IRWifiUploadViewController.swift
//  iRead
//
//  Created by zzyong on 2021/2/4.
//  Copyright © 2021 zzyong. All rights reserved.
//

import PKHUD
import SnapKit
import IRCommonLib
import GCDWebServer

class IRWifiUploadViewController: IRBaseViewcontroller, GCDWebUploaderDelegate {

    var webUploader: GCDWebUploader?
    lazy var wifiView = UIImageView.init(image: UIImage(named: "wifi")?.template)
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        setupLeftBackBarButton()
        if IRNetworkManager.shared.networkState == .wifi {
            setupWebUploader()
        } else {
            setupOpenErrorState()
        }
    }
    
    deinit {
        if let webUploader = webUploader, webUploader.isRunning {
            webUploader.stop()
            IRDebugLog("Web Uploader stop")
        }
    }
    
    func commonInit() {
        view.backgroundColor = .white
        title = "WiFi-Pass the book"
        
        view.addSubview(titleLabel)
        let top = (navigationController?.navigationBar.frame.maxY ?? 0) + 30
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(top)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
        }
        
        wifiView.tintColor = .hexColor("999999")
        view.addSubview(wifiView)
        wifiView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(150)
            make.width.equalTo(98)
            make.height.equalTo(71)
            make.centerX.equalTo(view)
        }
        
        view.addSubview(warningLabel)
        warningLabel.snp.makeConstraints { (make) in
            make.top.equalTo(wifiView.snp.bottom).offset(10)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
        }
    }
    
    func setupWebUploader() {
        webUploader = GCDWebUploader.init(uploadDirectory: IRFileManager.wifiUploadPath)
        webUploader?.delegate = self
        webUploader?.title = title!
        webUploader?.header = "iRead"
        webUploader?.start()
    }
    
    func setupOpenErrorState() {
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .center
        titleStyle.lineSpacing = 15
        let font = UIFont.systemFont(ofSize: 16)
        let titleText = NSMutableAttributedString.init(string: "HTTP server failed to start", attributes: [.font: font, .foregroundColor: UIColor.lightGray, .paragraphStyle: titleStyle])
        titleLabel.attributedText = titleText
        
        let warningStyle = NSMutableParagraphStyle()
        warningStyle.alignment = .center
        warningStyle.lineSpacing = 5
        let warningColor = UIColor.hexColor("999999")
        let warning = NSMutableAttributedString.init(string: "Wi-Fi service is not connected\n", attributes: [.font: font, .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        let unlink = NSAttributedString.init(string: "Please confirm the connection status of your device", attributes: [.font:  UIFont.systemFont(ofSize: 13), .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        warning.append(unlink)
        warningLabel.attributedText = warning
    }
    
    // MARK: GCDWebUploaderDelegate
    
    func webServerDidStart(_ server: GCDWebServer) {
        
        guard let serverURLString = server.serverURL?.absoluteString else { return }
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .center
        titleStyle.lineSpacing = 15
        let font = UIFont.systemFont(ofSize: 16)
        let titleText = NSMutableAttributedString.init(string: "Type in the address bar of the computer browser\n", attributes: [.font: font, .foregroundColor: UIColor.lightGray, .paragraphStyle: titleStyle])
        let descText = NSAttributedString.init(string: serverURLString, attributes: [.font: font, .foregroundColor: UIColor.systemBlue, .paragraphStyle: titleStyle])
        titleText.append(descText)
        titleLabel.attributedText = titleText
        
        let warningStyle = NSMutableParagraphStyle()
        warningStyle.alignment = .center
        warningStyle.lineSpacing = 5
        let warningColor = UIColor.hexColor("999999")
        let warning = NSMutableAttributedString.init(string: "Wi-Fi mode is on\n", attributes: [.font: font, .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        let link = NSAttributedString.init(string: "Wi-Fi connected\n", attributes: [.font:  UIFont.systemFont(ofSize: 13), .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        let sameWifi = NSAttributedString.init(string: "Mobile phone and computer must be in the same Wi-Fi", attributes: [.font:  UIFont.systemFont(ofSize: 13), .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        warning.append(link)
        warning.append(sameWifi)
        warningLabel.attributedText = warning
    }
    
    func webServerDidConnect(_ server: GCDWebServer) {
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .center
        titleStyle.lineSpacing = 15
        let titleText = NSMutableAttributedString.init(string: "Connected please transfer\n", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.lightGray, .paragraphStyle: titleStyle])
        let descText = NSAttributedString.init(string: "Do not close this interface or lock the screen during transmission", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.red, .paragraphStyle: titleStyle])
        titleText.append(descText)
        titleLabel.attributedText = titleText
        
        wifiView.tintColor = .hexColor("73F873")
    }
    
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        HUD.dimsBackground = false
        HUD.flash(.labeledSuccess(title: "Uploaded successfully", subtitle: path.lastPathComponent), delay: 1)
        IRFileManager.shared.addEpubBookByWifiUploadBookPath(path)
    }
    
    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        HUD.dimsBackground = false
        HUD.flash(.labeledSuccess(title: "Successfully deleted", subtitle: path.lastPathComponent), delay: 1)
    }
}
