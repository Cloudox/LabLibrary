//
//  DetailViewController.h
//  LabLibrary
//
//  Created by csdc-iMac on 15/8/19.
//  Copyright (c) 2015年 csdc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) IBOutlet UITextView *summary;

@end