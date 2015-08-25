//
//  ViewController.m
//  LabLibrary
//
//  Created by csdc-iMac on 15/8/19.
//  Copyright (c) 2015年 csdc. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"实验室图书馆";
    
    // 读取plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Books" ofType:@"plist"];
    NSArray *tempArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    self.bookList = [NSMutableArray arrayWithArray:tempArray];
    self.searchBooks = [NSMutableArray arrayWithArray:tempArray];
//    NSLog(@"%@", self.bookList);
    
    // 去除列表多余线条
    self.tableView.tableFooterView = [[UIView alloc] init];
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
        NSArray *noBook = [[NSArray alloc] initWithObjects:@"没有搜索到任何图书", nil];
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

// 列表每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
    }
    NSUInteger row = [indexPath row];
    // 通过行数来返回对应位置的plist内容
    cell.textLabel.text = [[self.searchBooks objectAtIndex:row] objectAtIndex:0];
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
    if (![bookName isEqualToString:@"没有搜索到任何图书"]) {// 确定是图书才跳转
        // 必须通过storyboard来找到view！
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        detailVC.isbn = [[self.searchBooks objectAtIndex:[indexPath row]] objectAtIndex:1];
        detailVC.nadrNum = [[self.searchBooks objectAtIndex:[indexPath row]] objectAtIndex:2];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 选中后取消选中的颜色
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

@end
