//
//  AppItemWebViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/21/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import FontAwesome_swift

class V2TWebViewController: V2TViewController, UIWebViewDelegate {
    
    private var theBool: Bool = true
    private var myTimer: NSTimer!

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var linkString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .Plain, target: self, action: #selector(self.dissmis))
        navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(image: UIImage.fontAwesomeIconWithName(FontAwesome.RotateLeft, textColor: TubeTrends.Settings.foregroundColor, size: CGSize(width: 26, height: 26)), style: .Plain, target: self, action: #selector(self.refresh))
        navigationItem.rightBarButtonItem = rightBarButton
        
        let url = NSURL (string: linkString);
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
        webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dissmis() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refresh() {
        webView.reload()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.progressView.progress = 0.0
        self.theBool = false
        self.myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: #selector(self.timerCallback), userInfo: nil, repeats: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.theBool = true
    }
    
    func timerCallback() {
        if self.theBool {
            if self.progressView.progress >= 1 {
                self.progressView.hidden = true
                self.myTimer.invalidate()
            } else {
                self.progressView.progress += 0.1
            }
        } else {
            self.progressView.progress += 0.05
            if self.progressView.progress >= 0.95 {
                self.progressView.progress = 0.95
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
