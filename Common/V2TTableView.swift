//
//  V2TTableView.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 12/5/15.
//  Website: https://v2t.mobi
//  Copyright © 2015 V2T Multimedia. All rights reserved.
//

import UIKit

class V2TTableView: UITableView {
    
    @IBInspectable var showTableViewHeader: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        if let headerView = self.tableHeaderView {
//            var headerFrame = headerView.frame
//            if showTableViewHeader {
//                headerFrame.size.height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
//            } else {
//                headerFrame.size.height = 0
//            }
//            headerView.frame = headerFrame
//            self.tableHeaderView = headerView
//        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
