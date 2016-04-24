//
//  MoreDetailViewController.m
//  LabLibrary
//
//  Created by Cloudox on 16/4/23.
//  Copyright © 2016年 Cloudox. All rights reserved.
//

#import "MoreDetailViewController.h"

@interface MoreDetailViewController ()

@end

@implementation MoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"Catalog";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationItem setHidesBackButton:YES];
    
    // 导航栏按钮
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = settingButton;
    
    if ([self.catalog isEqualToString:@""]) {// 没有目录内容
        self.view.backgroundColor = kUIColorFromRGB(0xefefef);
        
        UILabel *noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - 250) / 2, 200, 250, 20)];
        noResultLabel.textAlignment = NSTextAlignmentCenter;
        noResultLabel.textColor = kUIColorFromRGB(0x999999);
        noResultLabel.text = @"No Catalog Information";
        noResultLabel.font = [UIFont systemFontOfSize:18];
        [self.view addSubview:noResultLabel];
    } else {// 有目录就显示
        // 文本域
        CGFloat y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, y + 15, SCREENWIDTH - 24, 626 - y - 30)];
        textView.text = self.catalog;
        textView.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:textView];
    }
    
    UILabel *DoubanLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 626, 195, 21)];
    DoubanLabel.textAlignment = NSTextAlignmentCenter;
    DoubanLabel.textColor = [UIColor lightGrayColor];
    DoubanLabel.text = @"Data From douban.com";
    DoubanLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:DoubanLabel];
}

- (void)back {
    [UIView transitionWithView:self.navigationController.view duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft animations:nil completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
