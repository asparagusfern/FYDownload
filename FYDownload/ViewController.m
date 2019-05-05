//
//  ViewController.m
//  FYDownload
//
//  Created by sven on 2019/4/29.
//  Copyright © 2019年 sven. All rights reserved.
//

#import "ViewController.h"
#import "FYDownloadManager+Task.h"
#import "FYDownloadTableViewCell.h"
#import <AVKit/AVKit.h>
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,FYDownloadTableViewCellDelegate>
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self initUI];
}

- (void)loadData
{
    //首次添加任务(演示demo使用)
    if ([FYDownloadManager shareManager].downloadItemArray.count == 0) {
        FYDownloadItem *item = [[FYDownloadItem alloc] init:[NSURL URLWithString:@"http://vfx.mtime.cn/Video/2019/03/18/mp4/190318214226685784.mp4"]];
        [[FYDownloadManager shareManager] addDownload:item];
        FYDownloadItem *item1 = [[FYDownloadItem alloc] init:[NSURL URLWithString:@"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319104618910544.mp4"]];
        [[FYDownloadManager shareManager] addDownload:item1];
    }
}

- (void)initUI
{
    [self.view addSubview:self.tableView];
}

#pragma mark FYDownloadTableViewCellDelegate
- (void)cellTouchAction:(FYDownloadTableViewCell *)cell
{
    FYDownloadItem *currentItem = [[FYDownloadManager shareManager].urlToItemDictionary objectForKey:[NSURL URLWithString:cell.urlStr]];
    if (currentItem.downloadState == FYDownload_Status_wait || currentItem.downloadState == FYDownload_Status_suspended) {
        [[FYDownloadManager shareManager] start:[NSURL URLWithString:cell.urlStr]];
    } else if (currentItem.downloadState == FYDownload_Status_downloading) {
        [[FYDownloadManager shareManager] suspended:[NSURL URLWithString:cell.urlStr]];
    }
}

- (void)cellTouchDelete:(FYDownloadTableViewCell *)cell
{
    [[FYDownloadManager shareManager] remove:[NSURL URLWithString:cell.urlStr]];
    [_tableView reloadData];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FYDownloadItem *currentItem = [[FYDownloadManager shareManager].downloadItemArray objectAtIndex:indexPath.row];
    if (currentItem.downloadState == FYDownload_Status_complete) {

        AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
        AVPlayer *avPlayer = [AVPlayer playerWithURL:currentItem.saveUrl];
        vc.player = avPlayer;
        [self presentViewController:vc animated:YES completion:^{
            [vc.player play];
        }];
        
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"下载中..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [FYDownloadManager shareManager].downloadItemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"FYDownloadTableViewCell";
    FYDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FYDownloadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    FYDownloadItem *item = [FYDownloadManager shareManager].downloadItemArray[indexPath.row];
    [cell updataUI:item];
    return cell;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 65;
    }
    return _tableView;
}
@end
