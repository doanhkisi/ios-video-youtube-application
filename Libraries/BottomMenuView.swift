//
//  BottomMenuView.swift
//  demoBottomMenuView
//
//  Created by Phan Hữu Thắng on 1/6/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

protocol BottomMenuViewDelegate {
    func bottomMenuViewDidDisAppear(viewController: BottomMenuView)
    func bottomMenuViewDidSelected(viewController: BottomMenuView, index: Int)
}

public class BottomMenuViewItem: NSObject {
    var icon: UIImage?
    var title: String?
    var selectedAction: (Void ->Void)?
    init(icon: UIImage?, title: String?, selectedAction: (Void->Void)?){
        super.init()
        self.icon = icon
        self.title = title
        self.selectedAction = selectedAction
    }
    init(icon: UIImage?, title: String?) {
        super.init()
        self.icon = icon
        self.title = title
    }
    init(title: String?, selectedAction: (Void->Void)?) {
        super.init()
        self.title = title
        self.selectedAction = selectedAction
    }
    init(title: String?) {
        super.init()
        self.title = title
    }
}

public class BottomMenuView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let reuseCellIdentifierSetting: String = "MusicSettingCell"
    private var viewAlpha: UIView!
    private let tableView = UITableView()
    
    var delegate: BottomMenuViewDelegate?
    
    var items: [BottomMenuViewItem] = []
    
    var itemAgliment: ItemAlignment = .Left
    
    var didSelectedItemHandler: ((Int) ->Void)?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        viewAlpha = UIView(frame: self.view.frame)
        self.viewAlpha.backgroundColor = UIColor.blackColor()
        self.viewAlpha.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hide))
        self.viewAlpha.addGestureRecognizer(tapGesture)
        self.view .addSubview(viewAlpha)
        
        
        // TableView
        self.tableView.separatorStyle = .None
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseCellIdentifierSetting)
        self.tableView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(self.tableView)
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.viewAlpha.alpha = 0.5
        }
        
        showTableView()
    }
    
    init(items: [BottomMenuViewItem], didSelectedHandler: (Int -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.didSelectedItemHandler = didSelectedHandler
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func showInViewController(viewController: UIViewController) {
        viewController.addChildViewController(self)
        self.view.frame = viewController.view.frame
//        UIApplication.sharedApplication().windows[0].addSubview(self.view)
        viewController.view.addSubview(self.view)
        self.didMoveToParentViewController(viewController)
    }
    
    public func hide() {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.viewAlpha.alpha = 0
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.tableView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            }) { (bool) -> Void in
                self.willMoveToParentViewController(nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseCellIdentifierSetting, forIndexPath: indexPath) as UITableViewCell
        if let icon = self.items[indexPath.row].icon {
            cell.imageView?.image = icon
        }
        if let title = self.items[indexPath.row].title {
            cell.textLabel?.text = title
        }
        switch itemAgliment {
        case .Left:
            cell.textLabel?.textAlignment = NSTextAlignment.Left
            break
        case .Right:
            cell.textLabel?.textAlignment = NSTextAlignment.Right
            break
        case .Center:
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            break
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.hide()
        if self.delegate != nil {
            self.delegate?.bottomMenuViewDidSelected(self, index: indexPath.row)
        }
        
        self.items[indexPath.row].selectedAction?()
        
        didSelectedItemHandler?(indexPath.row)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showTableView(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.tableView.frame = CGRect(x: 0, y: self.view.frame.height - CGFloat(44) * CGFloat(self.items.count), width: self.view.frame.width, height: self.view.frame.height)
            }) { (bool) -> Void in
        }
    }
    
    enum ItemAlignment {
        case Left
        case Right
        case Center
    }

}