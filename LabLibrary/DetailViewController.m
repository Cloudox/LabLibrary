//
//  DetailViewController.m
//  LabLibrary
//
//  Created by Cloudox on 15/8/19.
//  Copyright (c) 2015年 Cloudox. All rights reserved.
//

#import "DetailViewController.h"
#import "MoreDetailViewController.h"


@interface DetailViewController ()

@property (nonatomic, strong) NSDictionary *infoDic;// 来自豆瓣的数据
@property (nonatomic, copy) NSString *catalog;// 目录内容

@property (nonatomic, strong) UIImageView *bigImageView;// 大图视图
@property (nonatomic, strong) UIView *bgView;// 阴影视图

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"Book Detail";
    self.navigationController.navigationBar.tintColor = navigationBarColor;
    
    self.catalog = @"";
    
    self.infoDic = [[NSDictionary alloc] init];
    
    // 导航栏按钮
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithTitle:@"Catalog" style:UIBarButtonItemStyleBordered target:self action:@selector(moreDetail)];
    self.navigationItem.rightBarButtonItem = settingButton;
    
    // 获取标题
    self.titleLabel.text = self.bookTitle;
    
    // 设置实验室编号
    NSString *nadr = [NSString stringWithFormat:@"No.%@", [self.nadrNum isEqualToString:@""] ? @"no number yet" : self.nadrNum];
    self.nadrLabel.text = nadr;
    
    self.author.textColor = cmGreen;
    self.nadrLabel.textColor = cmGreen;
    
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewImage)];
    [self.imageView addGestureRecognizer:imageTap];
    
    [self askForData];
}

// 大图视图
- (UIImageView *)bigImageView {
    if (nil == _bigImageView) {
        _bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH - 300) / 2, (SCREENHEIGHT - 360) / 2, 300, 360)];
        _bigImageView.image = [UIImage imageNamed:@"book_front_cover"];
        if ([self.infoDic objectForKey:@"images"]) {
            [_bigImageView setImage:self.imageView.image];
        }
        _bigImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissBigImage)];
        [_bigImageView addGestureRecognizer:imageTap];
    }
    return _bigImageView;
}

// 阴影视图
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _bgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissBigImage)];
        [_bgView addGestureRecognizer:bgTap];
    }
    return _bgView;
}

- (void)moreDetail {
    MoreDetailViewController *moreDetailVC = [[MoreDetailViewController alloc] init];
    moreDetailVC.catalog = self.catalog;
    [self.navigationController pushViewController:moreDetailVC animated:NO];
    [UIView transitionWithView:self.navigationController.view duration:1 options:UIViewAnimationOptionTransitionFlipFromRight animations:nil completion:nil];
}

// 查看大图
- (void)viewImage {
    [self bigImageView];
    CGRect originFram = _bigImageView.frame;
    _bigImageView.frame = self.imageView.frame;
    [self.view addSubview:_bigImageView];
    [UIView animateWithDuration:0.3 animations:^{
        // 改变大小
        _bigImageView.frame = originFram;
        // 改变位置
        _bigImageView.center = self.view.center;// 设置中心位置到新的位置
    }];

    [self bgView];
    [self.view addSubview:_bgView];
    [self.view bringSubviewToFront:_bigImageView];
}

// 收起大图
- (void)dismissBigImage {
    [self.bgView removeFromSuperview];
    
    [UIView animateWithDuration:0.3 animations:^{
        // 改变大小
        _bigImageView.frame = self.imageView.frame;
        // 改变位置
        _bigImageView.center = self.imageView.center;// 设置中心位置到新的位置
    }];
    
    double delayInSeconds = 0.3;
    __block DetailViewController* bself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [bself.bigImageView removeFromSuperview];
        bself.bigImageView = nil;
        bself.bgView = nil;
    });
}

// 请求数据
- (void)askForData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];// 添加菊花;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];// 启动状态栏网络请求指示
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{// 分线程
        NSString *url = [NSString stringWithFormat:@"https://api.douban.com/v2/book/isbn/%@?alt=json", self.isbn];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
        NSString *str = [[NSString alloc] initWithBytes:[response bytes] length:[response length] encoding:NSUTF8StringEncoding];
        //    NSLog(@"%@", str);
        NSData *responseUTF = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        self.infoDic = [NSJSONSerialization JSONObjectWithData:responseUTF options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"error: %@", [error description]);
            return;
        }
        NSString *resultStr = [[NSString alloc] initWithData:responseUTF encoding:NSUTF8StringEncoding];
        NSLog(@"%@", resultStr);
        
        dispatch_async(dispatch_get_main_queue(), ^{// UI主线程
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];// 关闭状态来网络请求指示
            
            // 书籍标题
            if ([self.bookTitle isEqualToString:@""]) {
                self.titleLabel.text = [self.infoDic objectForKey:@"title"];
            }
            
            // 获取书籍图片
            NSDictionary *images = [self.infoDic objectForKey:@"images"];
            NSString *imageUrlStr = [images objectForKey:@"large"];
            NSURL *imageURL = [NSURL URLWithString:imageUrlStr];
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
            [self.imageView setImage:image];
            
            // 获取作者信息
            NSArray *authorArray = [[NSArray alloc] init];
            authorArray = [self.infoDic objectForKey:@"author"];
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
            
            // 获取简介
            NSString *summary = [[NSString alloc] init];
            summary = [self.infoDic objectForKey:@"summary"];
            if (summary.length > 0) {// 判断是否存在简介
                self.summary.text = summary;
//                NSLog(@"%@", self.summary.text);
            } else {
                self.summary.text = @"No Summary Data";
            }
            
            // 获取目录
            self.catalog = [self.infoDic objectForKey:@"catalog"];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];// 收起菊花
        });
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
