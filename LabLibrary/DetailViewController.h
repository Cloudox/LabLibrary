//
//  DetailViewController.h
//  LabLibrary
//
//  Created by Cloudox on 15/8/19.
//  Copyright (c) 2015年 Cloudox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property (strong, nonatomic) NSString *isbn;// 保存图书的isbn码
@property (strong, nonatomic) NSString *nadrNum;// 保存图书的实验室编号

@property (strong, nonatomic) NSString *bookTitle;// 图书的标题

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) IBOutlet UILabel *nadrLabel;
@property (strong, nonatomic) IBOutlet UITextView *summary;

@end
