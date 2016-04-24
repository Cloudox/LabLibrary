//
//  ViewController.m
//  LabLibrary
//
//  Created by Cloudox on 15/8/19.
//  Copyright (c) 2015年 Cloudox. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "ScanViewController.h"
#import "BookListModel.h"
#import "BookListCellView.h"

@interface ViewController ()<UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UIView *tempView;

@property (nonatomic, weak) BookListCellView *transitionCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = navigationBarColor;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"My Library";
    
    // 导航栏按钮
//    self.borderedBar  = [[UIBarButtonItem alloc] initWithTitle:@"Scan Code" style:UIBarButtonItemStyleBordered target:self action:@selector(scan)];
//    self.navigationItem.rightBarButtonItem = self.borderedBar;
    UIImage *searchImg = [self originImage:[UIImage imageNamed:@"code"] scaleToSize:CGSizeMake(25, 25)];
    UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithImage:searchImg style:UIBarButtonItemStylePlain target:self action:@selector(scan)];
    self.navigationItem.rightBarButtonItem = searchBtn;
    
    // 搜索栏操作
    self.searchBar.showsCancelButton = NO;
    self.searchBar.placeholder = @"search book";
    [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    
    // 读取plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Books" ofType:@"plist"];
    NSArray *tempArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    self.bookList = [NSMutableArray arrayWithArray:tempArray];
    self.searchBooks = [NSMutableArray arrayWithArray:tempArray];
//    NSLog(@"%@", self.bookList);
    
    // 去除列表多余线条
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //注册3D Touch,先判断是否可用
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable){
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
        NSLog(@"3D Touch  可用!");
    }else{
        NSLog(@"3D Touch 无效");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tempView removeFromSuperview];
}

-(UIImage*) originImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

- (void)scan {// 进入扫码界面
    ScanViewController *scanVC = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

// 搜索图书
- (void)searchBook:(NSString *)searchTerm {
//    NSMutableArray *allBooks = [NSMutableArray arrayWithArray:self.searchBooks];
    if ([searchTerm length] == 0) {// 没有搜索内容则显示全部书籍
        [self.searchBooks removeAllObjects];
        [self.searchBooks addObjectsFromArray:self.bookList];
    } else {// 有搜索内容则显示搜索结果
        [self.searchBooks removeAllObjects];
        [self.searchBooks addObjectsFromArray:self.bookList];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (NSArray *book in self.searchBooks) {
            
            if ([[book objectAtIndex:0] rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
                [toRemove addObject:book];
            }
        }
    
        [self.searchBooks removeObjectsInArray:toRemove];
    }
    
    if ([self.searchBooks count] == 0) {
        NSArray *noBook = [[NSArray alloc] initWithObjects:@"No matched books", nil];
        [self.searchBooks addObject:noBook];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TableView Data Source Methods
// 列表的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchBooks count];
}

// 每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookListCellView *cell = (BookListCellView *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell getHeight];
}

//给cell添加动画
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置Cell的动画效果为3D效果
    //设置x和y的初始值为0.1；
    cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
    //x和y的最终值为1
    [UIView animateWithDuration:1 animations:^{
        cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
    }];
}

// 列表每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[BookListCellView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 90) andData:[self.searchBooks objectAtIndex:indexPath.row]];
    }
//    NSUInteger row = [indexPath row];
    // 通过行数来返回对应位置的plist内容
//    cell.textLabel.text = [[self.searchBooks objectAtIndex:row] objectAtIndex:0];
    return cell;
}

#pragma mark TableView Delegate Methods
// 选中条目时搜索框放下第一响应
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    return indexPath;
}

// 选中某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *bookName =[[self.searchBooks objectAtIndex:0] objectAtIndex:0];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 选中后取消选中的颜色
    if (![bookName isEqualToString:@"No matched books"]) {// 确定是图书才跳转
        // 必须通过storyboard来找到view！
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        detailVC.isbn = [[self.searchBooks objectAtIndex:[indexPath row]] objectAtIndex:1];
        detailVC.nadrNum = [[self.searchBooks objectAtIndex:[indexPath row]] objectAtIndex:2];
        detailVC.bookTitle = [[self.searchBooks objectAtIndex:[indexPath row]] objectAtIndex:0];
        
        // 插入动画
        /*
        BookListCellView *cell = (BookListCellView *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        */
        
//        NSLog(@"%f, %f, %f, %f", cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
//        cell.frame = CGRectMake(0, SCREENHEIGHT / 2, SCREENWIDTH, [cell getHeight]);
//        [self.view addSubview:cell];
        
        
        CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
        CGRect rect = [tableView convertRect:rectInTableView toView:[tableView superview]];
        self.tempView = [[UIView alloc] initWithFrame:rect];
        self.tempView.backgroundColor = [UIColor whiteColor];
//        self.tempView.alpha = 0.5;
        [self.view addSubview:self.tempView];
        // 进行一秒钟的动画
        [UIView animateWithDuration:0.3 animations:^{
            self.tempView.transform = CGAffineTransformMakeScale(1.0, SCREENHEIGHT / rect.size.height * 2);
        }];
        
        
        double delayInSeconds = 0.2;
        __block ViewController* bself = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [bself.navigationController pushViewController:detailVC animated:NO];
        });
        
    }
}



// 滑动时收起搜索框的键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark SearchBar Delegate Methods
// 按搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = [searchBar text];
    [self searchBook:searchTerm];
}

// 对搜索框进行编辑时
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        [self searchBook:@""];
    } else {
        [self searchBook:searchText];
    }
}

// 按取消按钮时
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self searchBook:@""];
    [searchBar resignFirstResponder];
}

#pragma mark - 3D Touch
/**
 *  peek手势
 */
-(UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{

    //弹出视图的初始位置，sourceRect是peek触发时的高亮区域。这个区域内的View会高亮显示，其余的会模糊掉
    NSIndexPath *selectedPath = [self.tableView indexPathForRowAtPoint:location];
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:selectedPath];
    CGRect rect = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
    previewingContext.sourceRect = rect;
    //获取数据进行传值
    DetailViewController *childVC = [[DetailViewController alloc] init];
    return childVC;
}


@end
