//
//  DetailViewController.m
//  LabLibrary
//
//  Created by csdc-iMac on 15/8/19.
//  Copyright (c) 2015年 csdc. All rights reserved.
//

#import "DetailViewController.h"



@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"图书详情";
    NSString *url = [NSString stringWithFormat:@"http://api.douban.com/book/subject/isbn/%@?alt=json", self.isbn];
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
    NSLog(@"%@", infoDic);
    
    // 获取标题
    NSDictionary *title = [[NSDictionary alloc] initWithDictionary:[infoDic objectForKey:@"title"]];
    if ([title objectForKey:@"$t"]) {// 判断有无标题信息
        NSString *titleStr = [[NSString alloc] initWithString:[title objectForKey:@"$t"]];
        [self.titleLabel setFrame:CGRectMake(0, 100, 320, 100)];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.text = titleStr;
    } else {
        self.titleLabel.text = @"无标题信息";
    }
    
    
    
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
    NSArray *link = [[NSArray alloc] initWithArray:[infoDic objectForKey:@"link"]];
    NSDictionary *imageDic = [[NSDictionary alloc] init];
    for (int i = 0; i < [link count]; i++) {// 循环找到image的url
        imageDic = [link objectAtIndex:i];
        NSString *rel = [[NSString alloc] init];
        rel = [imageDic objectForKey:@"@rel"];
        if ([rel isEqualToString:@"image"]) {
            NSString *imageUrlStr = [[NSString alloc] init];
            imageUrlStr = [imageDic objectForKey:@"@href"];
            NSLog(@"image:%@", imageUrlStr);
            NSURL *imageURL = [NSURL URLWithString:imageUrlStr];
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
            [self.imageView setImage:image];
            break;// 找到后就结束循环
        }
    }
    
    
    // 获取作者信息
    NSArray *array = [[NSArray alloc] init];
    array = [infoDic objectForKey:@"author"];
    if ([array count] != 0) {// 确保有作者信息
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[array objectAtIndex:0]];
        NSDictionary *authors = [[NSDictionary alloc] initWithDictionary:[dic objectForKey:@"name"]];
        NSString *author1 = [NSString stringWithFormat:@"作者：%@", [authors objectForKey:@"$t"]];
        self.author.numberOfLines = 0;
        self.author.lineBreakMode = NSLineBreakByWordWrapping;
        self.author.text = author1;
    } else {
        self.author.text = @"无作者信息";
    }
    
    // 设置实验室编号
    NSLog(@"nadr:%@", self.nadrNum);
    NSString *nadr = [NSString stringWithFormat:@"实验室编号：%@", self.nadrNum];
    self.nadrLabel.text = nadr;
    
    
    // 获取简介
    NSDictionary *summary = [[NSDictionary alloc] init];
    summary = [infoDic objectForKey:@"summary"];
    if ([summary objectForKey:@"$t"]) {// 判断是否存在简介
        NSString *summaryStr = [[NSString alloc] initWithString:[summary objectForKey:@"$t"]];
        self.summary.text = summaryStr;
    } else {
        self.summary.text = @"无简介";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
