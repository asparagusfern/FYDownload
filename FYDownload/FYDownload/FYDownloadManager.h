//
//  FYDownloadManager.h
//  FYDownload
//
//  Created by sven on 2019/4/29.
//  Copyright © 2019年 sven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FYDownloadItem.h"
@class FYDownloadManager;
typedef void (^completionHandler)(void);
@interface FYDownloadManager : NSObject
@property (nonatomic,strong) NSMutableDictionary *urlToTaskDictionary;
@property (nonatomic,strong) NSMutableDictionary *urlToItemDictionary;
@property (nonatomic,strong) NSMutableArray<FYDownloadItem *> *downloadItemArray;
@property (nonatomic,strong) NSURLSession *session;
+ (FYDownloadManager *)shareManager;

- (void)save;
- (void)addCompletionHandler:(completionHandler)completionHandler;
@end
