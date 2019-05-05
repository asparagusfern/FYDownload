//
//  FYDownloadManager+Task.h
//  FYDownload
//
//  Created by sven on 2019/4/29.
//  Copyright © 2019年 sven. All rights reserved.
//

#import "FYDownloadManager.h"

@interface FYDownloadManager (Task)<NSURLSessionDownloadDelegate>

- (void)addDownload:(FYDownloadItem *)downloadItem;//添加下载任务

- (void)startAll;//启动所有未完成任务

- (void)suspendedAll;//暂停某个任务

- (void)removeAll;//删除所有任务

- (void)start:(NSURL *)url;//开启某个任务

- (void)suspended:(NSURL *)url;//暂停某个任务

- (void)remove:(NSURL *)url;//删除某个任务
@end
