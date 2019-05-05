//
//  FYDownloadManager+Task.h
//  FYDownload
//
//  Created by sven on 2019/4/29.
//  Copyright © 2019年 sven. All rights reserved.
//

#import "FYDownloadManager.h"

@interface FYDownloadManager (Task)<NSURLSessionDownloadDelegate>

- (void)addDownload:(FYDownloadItem *)downloadItem;

- (void)startAll;

- (void)suspendedAll;

- (void)removeAll;

- (void)start:(NSURL *)url;

- (void)suspended:(NSURL *)url;

- (void)remove:(NSURL *)url;
@end
