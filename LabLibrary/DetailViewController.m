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
    
    if (self.isFromScan) {
        // 导航栏按钮，加入到图书库
        UIImage *addImg = [UIImage imageNamed:@"add"];
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:addImg style:UIBarButtonItemStylePlain target:self action:@selector(addToBookList)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
    // 获取标题
    self.titleLabel.text = self.bookTitle;
    
    // 设置实验室编号
    NSString *nadr = [NSString stringWithFormat:@"No.%@", [self.nadrNum isEqualToString:@""] ? @"no number yet" : self.nadrNum];
    self.nadrLabel.text = nadr;
    
    self.author.textColor = cmGreen;
    self.nadrLabel.textColor = cmGreen;
    
    self.catalogLabel.textColor = cmGreen;
    self.catalogLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *catalogTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCatalog)];
    [self.catalogLabel addGestureRecognizer:catalogTap];
    
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

- (void)viewCatalog {
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

// 加入到本地
- (void)addToBookList {
    // 读取plist
    
    // 获取应用程序沙盒的Documents目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    // 得到完整的文件名
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"Books.plist"];
    
    NSArray *tempArray = [[NSArray alloc] initWithContentsOfFile:filename];
    NSMutableArray *bookList = [NSMutableArray arrayWithArray:tempArray];
    NSArray *lastBook = [bookList lastObject];
    NSInteger lastNumber = [[lastBook objectAtIndex:2] integerValue];
    lastNumber ++;
    self.nadrLabel.text = [NSString stringWithFormat:@"No.%ld", lastNumber];// 修改编号label
    NSArray *newBook = [NSArray arrayWithObjects:self.bookTitle, self.isbn, [NSString stringWithFormat:@"%ld", lastNumber], nil];
    [bookList addObject:newBook];
    
    // 写入
    [bookList writeToFile:filename atomically:YES];
     
    [self addSuccessAnimation];
}

// 添加成功的动画
- (void)addSuccessAnimation {
    UILabel *successLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - 200) / 2, (SCREENHEIGHT - 100) / 2, 200, 100)];
    successLabel.backgroundColor = [UIColor whiteColor];
    // view显示为圆角
    successLabel.layer.cornerRadius = 8.0;
    // 加边框
    successLabel.layer.borderWidth = 1.0;
    successLabel.layer.borderColor = [cmGreen CGColor];
    [successLabel.layer setCornerRadius:4.0];
    successLabel.textAlignment = NSTextAlignmentCenter;
    successLabel.font = [UIFont systemFontOfSize:20];
    successLabel.text = @"Add Success!";
    successLabel.alpha = 0;
    
    [self.view addSubview:successLabel];
    // 进行动画
    [UIView animateWithDuration:0.3 animations:^{
        successLabel.alpha = 1;
    }];
    
    // 动画收起
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.8 animations:^{
            successLabel.frame = CGRectMake(SCREENWIDTH - 30, 5, 10, 5);
            successLabel.alpha = 0;
        }];
    });
    
    // 隐藏图标
    double delayInSeconds2 = 1.5;
    __block DetailViewController* bself = self;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        // 隐藏添加按钮
        for (UIView *view in bself.navigationController.navigationBar.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                [view setHidden:YES];
            }
        }
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
                self.bookTitle =[self.infoDic objectForKey:@"title"];
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

#pragma mark - 3D Touch
/**
 *  3D Touch 上移显示的视图
 */
/*
-(NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"我就是我" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"click---我就是我");
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"你还是你" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"click---你还是你");
    }];
    
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"她还是她" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"click---她还是她");
    }];
    //想要显示多个就定义多个 UIPreviewAction
    NSArray *actions = @[action1,action2,action3];
    return actions;
    
}
*/


@end
