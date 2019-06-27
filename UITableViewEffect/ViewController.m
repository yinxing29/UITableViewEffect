//
//  ViewController.m
//  UITableView
//
//  Created by 尹星 on 2019/6/27.
//  Copyright © 2019 尹星. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       *tableView;

@property (nonatomic, strong) NSIndexPath       *changeIndexPath;

@property (nonatomic, strong) UIView            *snapshotView;

@property (nonatomic, copy) NSArray             *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self p_initData];
    [self p_initView];
}

#pragma mark - 初始化
- (void)p_initData
{
    self.dataSource = @[@"0-0",@"0-1",@"0-2",@"0-3",@"0-4",@"0-5",@"0-6",@"0-7",@"0-8",@"0-9"];
}

- (void)p_initView
{
    [self.view addSubview:self.tableView];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self.tableView addGestureRecognizer:longGesture];
}

#pragma mark - ------------------------------------------------------------------------------------

#pragma mark - 懒加载
- (void)longGesture:(UILongPressGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            // 获取点击的点
            CGPoint clickPoint = [sender locationInView:self.tableView];
            // 获取点击对应的cell的indexPath
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:clickPoint];
            // 记录当前移动的indexPath
            self.changeIndexPath = indexPath;
            if (indexPath == nil) {
                return;
            }
            // 获取对应的cellm，并截屏
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            self.snapshotView = [cell snapshotViewAfterScreenUpdates:YES];
            self.snapshotView.center = clickPoint;
            // 添加截屏
            [self.tableView addSubview:self.snapshotView];
            // 隐藏cell
            cell.hidden = YES;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.snapshotView.transform = CGAffineTransformMakeScale(1.05, 1.05);
            }];
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // 获取当前点击的点
            CGPoint clickPoint = [sender locationInView:self.tableView];
            // 移动手指，改变接口的center
            self.snapshotView.center = clickPoint;
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:clickPoint];
            // 判断当前移动到的点是否存在indexPath，并且cell是否与移动的那个cell相同
            if (indexPath && (indexPath.section != self.changeIndexPath.section || indexPath.row != self.changeIndexPath.row)) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                // 当移动到一定范围，调用移动方法实现移动
                if (fabs(cell.center.y - clickPoint.y) < cell.frame.size.height) {
                    [self.tableView moveRowAtIndexPath:self.changeIndexPath toIndexPath:indexPath];
                    // 移动过后，重设changeIndexPath为交换后的cell
                    self.changeIndexPath = indexPath;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            // 移动结束，将最终移动的cell显示
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.changeIndexPath];
            self.snapshotView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [UIView animateWithDuration:0.25 animations:^{
                // 移除截图
                [self.snapshotView removeFromSuperview];
                cell.hidden = NO;
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - ------------------------------------------------------------------------------------

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    headerView.backgroundColor = [UIColor orangeColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.text = [NSString stringWithFormat:@"  %ld",section];
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    headerView.backgroundColor = [UIColor yellowColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.text = [NSString stringWithFormat:@"  %ld",section];
    [headerView addSubview:label];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
    }];
    action.backgroundColor = [UIColor redColor];
    return @[action];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *array = [self.dataSource mutableCopy];
    [array exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    self.dataSource = [array copy];
}

#pragma mark - ------------------------------------------------------------------------------------


#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 100.0, self.view.frame.size.width, self.view.frame.size.height - 200.0) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor grayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
        //        headerView.backgroundColor = [UIColor yellowColor];
        //        _tableView.tableHeaderView = headerView;
        //
        //        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
        //        footerView.backgroundColor = [UIColor orangeColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        //
        //        _tableView.sectionHeaderHeight = 40.0;
        //        _tableView.sectionFooterHeight = 40.0;
    }
    return _tableView;
}

#pragma mark - ------------------------------------------------------------------------------------

@end
