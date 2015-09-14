//
//  ViewController.h
//  LabLibrary
//
//  Created by csdc-iMac on 15/8/19.
//  Copyright (c) 2015年 csdc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) UIBarButtonItem *borderedBar;//右上角扫码按钮

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *bookList;// 图书总目录
@property (strong, nonatomic) NSMutableArray *searchBooks;// 搜索到的图书

@end

