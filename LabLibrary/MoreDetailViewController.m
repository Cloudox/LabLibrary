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
    self.view.backgroundColor = kUIColorFromRGB(0xefefef);
    
    [self.navigationItem setHidesBackButton:YES];
    
    // 导航栏按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
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
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, y + 15, SCREENWIDTH - 24, 626 - y - 20)];
        textView.text = self.catalog;
        textView.textColor = [UIColor darkGrayColor];
        textView.font = [UIFont systemFontOfSize:16];
        textView.backgroundColor = kUIColorFromRGB(0xefefef);
        [self.view addSubview:textView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, textView.frame.origin.y + textView.frame.size.height, SCREENWIDTH, 0.5)];
        line.backgroundColor = [UIColor darkGrayColor];
        line.alpha = 0.5;
        [self.view addSubview:line];
    }
    
    // 豆瓣文字
    UILabel *DoubanLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 632, 195, 21)];
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
