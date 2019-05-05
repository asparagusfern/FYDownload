//
//  FYDownloadTableViewCell.m
//  FYDownload
//
//  Created by sven on 2019/4/30.
//  Copyright © 2019年 sven. All rights reserved.
//

#import "FYDownloadTableViewCell.h"
#import "FYDownloadManager.h"
@interface FYDownloadTableViewCell()<FYDownloadItemDelegate>
{
    UILabel *titleLbl;
    UIProgressView *progressView;
    UIButton *deleteBtn;
    UIButton *actionBth;
}
@end
@implementation FYDownloadTableViewCell
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
        titleLbl.numberOfLines = 0;
        titleLbl.font = [UIFont systemFontOfSize:12];
        titleLbl.textColor = UIColor.blackColor;
        [self.contentView addSubview:titleLbl];
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLbl.frame) + 10, 200, 5)];
        [self.contentView addSubview:progressView];
        
        actionBth = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLbl.frame) + 20, 0, 50, 30)];
        [actionBth addTarget:self action:@selector(touchAction:) forControlEvents:UIControlEventTouchUpInside];
        actionBth.titleLabel.font = [UIFont systemFontOfSize:10];
        [actionBth setTitle:@"开始" forState:UIControlStateNormal];
        [actionBth setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        actionBth.center = CGPointMake(actionBth.center.x, self.contentView.center.y);
        [self.contentView addSubview:actionBth];
        
        deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(actionBth.frame) + 20, 0, 50, 30)];
        [deleteBtn addTarget:self action:@selector(touchDelete:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        deleteBtn.center = CGPointMake(deleteBtn.center.x, self.contentView.center.y);
        [self.contentView addSubview:deleteBtn];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStateChange:) name:@"FYDownload_Status" object:nil];
    }
    return self;
}

- (void)touchAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellTouchAction:)]) {
        [self.delegate cellTouchAction:self];
    }
}

- (void)touchDelete:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellTouchDelete:)]) {
        [self.delegate cellTouchDelete:self];
    }
}

- (void)updataUI:(FYDownloadItem *)item
{
    self.urlStr = item.requestUrl.absoluteString;
    item.delegate = self;
    titleLbl.text = self.urlStr;
    if (item.countOfBytesExpectedToReceive != 0) {
        [progressView setProgress:(float)item.countOfBytesReceived/(float)item.countOfBytesExpectedToReceive animated:YES];
    }
    NSString *actionBthStr = nil;
    switch (item.downloadState) {
        case FYDownload_Status_wait:
        {
            actionBthStr = @"开始";
        }
            break;
        case FYDownload_Status_downloading:
        {
            actionBthStr = @"暂停";
        }
            break;
        case FYDownload_Status_suspended:
        {
            actionBthStr = @"开始";
        }
            break;
        case FYDownload_Status_fail:
        {
              actionBthStr = @"下载失败";
        }
            break;
        case FYDownload_Status_complete:
        {
            actionBthStr = @"下载完成";
        }
            break;
        default:
            break;
    }
    [actionBth setTitle:actionBthStr forState:UIControlStateNormal];
}

- (void)downloadStateChange:(NSNotification *)no
{
    NSURL *requestUrl = no.userInfo[@"requestUrl"];
    if ([requestUrl.absoluteString isEqualToString:self.urlStr]) {
        FYDownloadItem *currentItem = no.userInfo[@"item"];
        [self updataUI:currentItem];
    }
}

- (void)downloadItem:(FYDownloadItem *)item totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if ([item.requestUrl.absoluteString isEqualToString:self.urlStr]) {
        [progressView setProgress:(float)totalBytesWritten/(float)totalBytesExpectedToWrite animated:YES];
    }
}

@end
