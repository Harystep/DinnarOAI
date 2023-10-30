//
//  UIScrollView.swift
//  campus
//
//  Created by Lizheng Pang on 2020/10/26.
//  Copyright © 2020 Lizheng Pang. All rights reserved.
//

import Foundation
import UIKit
let NoMoreDataDefultTitle = "没有更多了~"
extension UIScrollView{
    private struct AssociatedKey {
        static var noMoreDataTitle: String = NoMoreDataDefultTitle
    }
    func addRefreshHeader( refreshBlock:@escaping (()->Void)){
        self.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            refreshBlock()
        })
    }
    func addRefreshFooter( refreshBlock:@escaping (()->Void)){
        let footer = MJRefreshAutoStateFooter.init {
            refreshBlock()
        }
        footer.setTitle(AssociatedKey.noMoreDataTitle, for: .noMoreData)
        footer.isHidden = true
        self.mj_footer = footer
    }
    func setFooterMoreDataTitle(text:String){
        if let footer:MJRefreshAutoStateFooter =  self.mj_footer as? MJRefreshAutoStateFooter{
            footer.setTitle(text, for: .noMoreData)
        }
        AssociatedKey.noMoreDataTitle = text
    }
    func hideFooter(hidden:Bool){
        self.mj_footer?.isHidden = hidden
    }
    func endRefresh(endHeader:Bool = true,endFooter:Bool = true){
        if endHeader{
            if let header = self.mj_header{
                header.endRefreshing()
            }
        }
        if endFooter{
            if let footer = self.mj_footer{
                footer.isHidden = false
                footer.endRefreshing()
            }
        }
        
    }
    func endLoadWithNoMoreData(){
        if let footer = self.mj_footer{
            footer.isHidden = false
            footer.endRefreshingWithNoMoreData()
        }
    }
    func ignoredContentInsetBottom(){
        if DataTool.isiPhoneXScreen(){
            var edge = self.contentInset
            edge.bottom = 34
            self.contentInset = edge
            self.mj_footer?.ignoredScrollViewContentInsetBottom = 34
        }
    }
    func setBottomSafeHeight(height:CGFloat){
        var edge = self.contentInset
        edge.bottom = height
        self.contentInset = edge
    }
    
}
