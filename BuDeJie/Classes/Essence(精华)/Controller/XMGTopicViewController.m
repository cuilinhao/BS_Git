//
//  XMGTopicViewController.m
//  BuDeJie
//
//  Created by 天下林子 on 2019/8/13.
//  Copyright © 2019 小码哥. All rights reserved.
//

#import "XMGTopicViewController.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import "XMGTopic.h"
#import <SVProgressHUD.h>
#import "XMGTopicCell.h"
#import <SDImageCache.h>


@interface XMGTopicViewController ()
/** 当前最后一条帖子数据的描述信息，专门用来加载下一页数据 */
@property (nonatomic, copy) NSString *maxtime;
/** 所有的帖子数据 */
@property (nonatomic, strong) NSMutableArray<XMGTopic *> *topics;

/** 请求管理者 */
@property (nonatomic, strong) AFHTTPSessionManager *manager;

/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;

/** 上拉刷新控件 */
@property (nonatomic, weak) UIView *footer;
/** 上拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *footerLabel;
/** 上拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isFooterRefreshing) BOOL footerRefreshing;

// 有了方法声明，点语法才会有智能提示
//- (XMGTopicType)type;
@end

@implementation XMGTopicViewController

- (XMGTopicType)type
{
    return 0;
}

/* cell的重用标识 */
static NSString * const XMGTopicCellId = @"XMGTopicCellId";

- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = XMGGrayColor(206);
    
    self.tableView.contentInset = UIEdgeInsetsMake(XMGNavMaxY + XMGTitlesViewH, 0, XMGTabBarH, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 注册cell
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([XMGTopicCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:XMGTopicCellId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarButtonDidRepeatClick) name:XMGTabBarButtonDidRepeatClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleButtonDidRepeatClick) name:XMGTitleButtonDidRepeatClickNotification object:nil];
    
    [self setupRefresh];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupRefresh
{
    // 广告条
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor blackColor];
    label.frame = CGRectMake(0, 0, 0, 30);
    label.textColor = [UIColor whiteColor];
    label.text = @"广告";
    label.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = label;
    
    // header
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, - 50, self.tableView.xmg_width, 50);
    self.header = header;
    [self.tableView addSubview:header];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = header.bounds;
    headerLabel.backgroundColor = [UIColor redColor];
    headerLabel.text = @"下拉可以刷新";
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:headerLabel];
    self.headerLabel = headerLabel;
    
    // 让header自动进入刷新
    [self headerBeginRefreshing];
    
    // footer
    UIView *footer = [[UIView alloc] init];
    footer.frame = CGRectMake(0, 0, self.tableView.xmg_width, 35);
    self.footer = footer;
    
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.frame = footer.bounds;
    footerLabel.backgroundColor = [UIColor redColor];
    footerLabel.text = @"上拉可以加载更多";
    footerLabel.textColor = [UIColor whiteColor];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:footerLabel];
    self.footerLabel = footerLabel;
    
    self.tableView.tableFooterView = footer;
}

#pragma mark - 监听
/**
 *  监听tabBarButton重复点击
 */
- (void)tabBarButtonDidRepeatClick
{
    // 重复点击的不是精华按钮
    if (self.view.window == nil) return;
    
    // 显示在正中间的不是AllViewController
    if (self.tableView.scrollsToTop == NO) return;
    
    // 进入下拉刷新
    [self headerBeginRefreshing];
}

/**
 *  监听titleButton重复点击
 */
- (void)titleButtonDidRepeatClick
{
    [self tabBarButtonDidRepeatClick];
}

#pragma mark - 数据处理
//- (XMGTopicType)type
//{
//    return XMGTopicTypeAll;
//}

/**
 *  发送请求给服务器，下拉刷新数据
 */
//MARK:---------下拉刷新数据
- (void)loadNewTopics
{
    // 1.取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    // 2.拼接参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = @"list";
    parameters[@"c"] = @"data";
    parameters[@"type"] = @(self.type);
    
    // 3.发送请求
    [self.manager GET:XMGCommonURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        //XMGAFNWriteToPlist(new_topics)
        
        // 存储maxtime
        self.maxtime = responseObject[@"info"][@"maxtime"];
        
        // 字典数组 -> 模型数据
        self.topics = [XMGTopic mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        
        // 刷新表格
        [self.tableView reloadData];
        
        // 结束刷新
        [self headerEndRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
        }
        
        // 结束刷新
        [self headerEndRefreshing];
    }];
}

/**
 *  发送请求给服务器，上拉加载更多数据
 */
- (void)loadMoreTopics
{
    // 1.取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    // 2.拼接参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = @"list";
    parameters[@"c"] = @"data";
    parameters[@"type"] = @(self.type);
    //XMGTopicTypePicture
    //    parameters[@"type"] = @(XMGTopicTypePicture);
    
    parameters[@"maxtime"] = self.maxtime;
    
    // 3.发送请求
    [self.manager GET:XMGCommonURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        // 存储maxtime
        self.maxtime = responseObject[@"info"][@"maxtime"];
        
        // 字典数组 -> 模型数据
        NSArray *moreTopics = [XMGTopic mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        // 累加到旧数组的后面
        [self.topics addObjectsFromArray:moreTopics];
        
        // 刷新表格
        [self.tableView reloadData];
        
        // 结束刷新
        [self footerEndRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
        }
        
        // 结束刷新
        [self footerEndRefreshing];
    }];
}

#pragma mark - 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 根据数据量显示或者隐藏footer
    self.footer.hidden = (self.topics.count == 0);
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMGTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:XMGTopicCellId];
    cell.topic = self.topics[indexPath.row];
    
    NSLog(@"______%s", __func__);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}


#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"______%s", __func__);
    //XMGFunc
    return self.topics[indexPath.row].cellHeight;
}

/**
 *  用户松开scrollView时调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = - (self.tableView.contentInset.top + self.header.xmg_height);
    if (self.tableView.contentOffset.y <= offsetY) { // header已经完全出现
        [self headerBeginRefreshing];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 处理header
    [self dealHeader];
    
    // 处理footer
    [self dealFooter];
    
    //清除内存的缓存
#pragma mark 清除内存的缓存
    [[SDImageCache sharedImageCache] clearMemory];
    
    //清除了内存，沙盒中还是有的，
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

/**
 *  处理header
 */
- (void)dealHeader
{
    // 如果正在下拉刷新，直接返回
    if (self.isHeaderRefreshing) return;
    
    // 当scrollView的偏移量y值 <= offsetY时，代表header已经完全出现
    CGFloat offsetY = - (self.tableView.contentInset.top + self.header.xmg_height);
    if (self.tableView.contentOffset.y <= offsetY) { // header已经完全出现
        self.headerLabel.text = @"松开立即刷新";
        self.headerLabel.backgroundColor = [UIColor grayColor];
    } else {
        self.headerLabel.text = @"下拉可以刷新";
        self.headerLabel.backgroundColor = [UIColor redColor];
    }
}

/**
 *  处理footer
 */
- (void)dealFooter
{
    // 还没有任何内容的时候，不需要判断
    if (self.tableView.contentSize.height == 0) return;
    
    // 当scrollView的偏移量y值 >= offsetY时，代表footer已经完全出现
    CGFloat ofsetY = self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.xmg_height;
    if (self.tableView.contentOffset.y >= ofsetY
        && self.tableView.contentOffset.y > - (self.tableView.contentInset.top)) { // footer完全出现，并且是往上拖拽
        [self footerBeginRefreshing];
    }
}

#pragma mark - header
- (void)headerBeginRefreshing
{
    // 如果正在下拉刷新，直接返回
    if (self.isHeaderRefreshing) return;
    
    // 进入下拉刷新状态
    self.headerLabel.text = @"正在刷新数据...";
    self.headerLabel.backgroundColor = [UIColor blueColor];
    self.headerRefreshing = YES;
    // 增加内边距
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top += self.header.xmg_height;
        self.tableView.contentInset = inset;
        
        // 修改偏移量
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x,  - inset.top);
    }];
    
    // 发送请求给服务器，下拉刷新数据
    [self loadNewTopics];
}

- (void)headerEndRefreshing
{
    self.headerRefreshing = NO;
    // 减小内边距
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top -= self.header.xmg_height;
        self.tableView.contentInset = inset;
    }];
}

#pragma mark - footer
- (void)footerBeginRefreshing
{
    // 如果正在上拉刷新，直接返回
    if (self.isFooterRefreshing) return;
    
    // 进入刷新状态
    self.footerRefreshing = YES;
    self.footerLabel.text = @"正在加载更多数据...";
    self.footerLabel.backgroundColor = [UIColor blueColor];
    
    // 发送请求给服务器，上拉加载更多数据
    [self loadMoreTopics];
}

- (void)footerEndRefreshing
{
    self.footerRefreshing = NO;
    self.footerLabel.text = @"上拉可以加载更多";
    self.footerLabel.backgroundColor = [UIColor redColor];
}

@end
