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
    NSString *url = [NSString stringWithFormat:@"http://api.douban.com/book/subject/isbn/9787508356464?alt=json"];
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
    NSString *titleStr = [[NSString alloc] initWithString:[title objectForKey:@"$t"]];
    self.titleLabel.text = titleStr;
    
    // 获取作者信息
    NSArray *array = [[NSArray alloc] init];
    array = [infoDic objectForKey:@"author"];
    NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[array objectAtIndex:0]];
    NSDictionary *authors = [[NSDictionary alloc] initWithDictionary:[dic objectForKey:@"name"]];
    NSString *author1 = [[NSString alloc] initWithString:[authors objectForKey:@"$t"]];
    self.author.text = author1;
    
    // 获取简介
    NSDictionary *summary = [[NSDictionary alloc] initWithDictionary:[infoDic objectForKey:@"summary"]];
    NSString *summaryStr = [[NSString alloc] initWithString:[summary objectForKey:@"$t"]];
    self.summary.text = summaryStr;
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
