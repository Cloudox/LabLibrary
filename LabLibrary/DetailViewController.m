//
//  DetailViewController.m
//  LabLibrary
//
//  Created by Cloudox on 15/8/19.
//  Copyright (c) 2015年 Cloudox. All rights reserved.
//

#import "DetailViewController.h"



@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Book Detail";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];// 添加菊花;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];// 启动状态栏网络请求指示
    
    // 获取标题
    self.titleLabel.text = self.bookTitle;
    
    self.author.textColor = cmGreen;
    self.nadrLabel.textColor = cmGreen;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self askForData];
}

// 请求数据
- (void)askForData {
    
    NSString *url = [NSString stringWithFormat:@"https://api.douban.com/v2/book/isbn/%@?alt=json", self.isbn];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithBytes:[response bytes] length:[response length] encoding:NSUTF8StringEncoding];
    //    NSLog(@"%@", str);
    NSData *responseUTF = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:responseUTF options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"error: %@", [error description]);
        return;
    }
    NSString *resultStr = [[NSString alloc] initWithData:responseUTF encoding:NSUTF8StringEncoding];
    NSLog(@"%@", resultStr);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];// 关闭状态来网络请求指示
    
    // label自动换行方法——————————————————————————
    /*
     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 320, 100)];
     label.text = @"hahahahahahahahahhahahaahhaahhahahahahhahahaha";
     label.numberOfLines = 0;
     label.lineBreakMode = NSLineBreakByWordWrapping;
     [label sizeToFit];
     label.font = [UIFont systemFontOfSize:17];
     label.textAlignment = NSTextAlignmentCenter;
     [self.view addSubview:label];
     */
    // ——————————————————————————————————————————
    
    
    // 获取书籍图片
    NSDictionary *images = [infoDic objectForKey:@"images"];
    NSString *imageUrlStr = [images objectForKey:@"medium"];
    NSURL *imageURL = [NSURL URLWithString:imageUrlStr];
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
    [self.imageView setImage:image];
    
    
    // 获取作者信息
    NSArray *authorArray = [[NSArray alloc] init];
    authorArray = [infoDic objectForKey:@"author"];
    if ([authorArray count] != 0) {// 确保有作者信息
        NSString *author = @"";
        for (NSString *name in authorArray) {
            if ([author isEqualToString:@""]) {// 第一个作者
                author = name;
            } else {
                author = [NSString stringWithFormat:@"%@，%@", author, name];
            }
        }
        self.author.numberOfLines = 0;
        self.author.lineBreakMode = NSLineBreakByWordWrapping;
        self.author.text = author;
    } else {
        self.author.text = @"No Author Data";
    }
    
    
    // 设置实验室编号
    NSLog(@"nadr:%@", self.nadrNum);
    NSString *nadr = [NSString stringWithFormat:@"No.%@", self.nadrNum];
    self.nadrLabel.text = nadr;
    
    
    // 获取简介
    NSString *summary = [[NSString alloc] init];
    summary = [infoDic objectForKey:@"summary"];
    if (summary.length > 0) {// 判断是否存在简介
        self.summary.text = summary;
        NSLog(@"%@", self.summary.text);
    } else {
        self.summary.text = @"No Summary Data";
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];// 收起菊花
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
