//
//  FYDownloadManager.m
//  FYDownload
//
//  Created by sven on 2019/4/29.
//  Copyright © 2019年 sven. All rights reserved.
//

#import "FYDownloadManager.h"
#define FYDwonloadFileListPath [NSString stringWithFormat:@"%@/%@",FYDwonloadFileHomePath,@"FYDwonloadFileList"]

@interface FYDownloadManager()
@property (nonatomic,strong) completionHandler completionHandler;
@end
@implementation FYDownloadManager
+ (FYDownloadManager *)shareManager
{
    static FYDownloadManager *shareManager = nil;
    if (!shareManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shareManager = [[FYDownloadManager alloc] init];
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"FYDownload"];
            NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
            operationQueue.maxConcurrentOperationCount = 1;
            shareManager.session = [NSURLSession sessionWithConfiguration:configuration delegate:shareManager delegateQueue:operationQueue];
        });
    }
    return shareManager;
}

- (void)addCompletionHandler:(completionHandler)completionHandler
{
    [FYDownloadManager shareManager].completionHandler = completionHandler;
}

- (void)save
{
    [NSKeyedArchiver archiveRootObject:self.downloadItemArray toFile:FYDwonloadFileListPath];
}

- (NSMutableArray<FYDownloadItem *> *)downloadItemArray
{
    if (!_downloadItemArray) {
        if ([NSKeyedUnarchiver unarchiveObjectWithFile:FYDwonloadFileListPath]) {
            _downloadItemArray = [NSKeyedUnarchiver unarchiveObjectWithFile:FYDwonloadFileListPath];
            //除了已完成或者失败、都置为暂停状态
            [_downloadItemArray enumerateObjectsUsingBlock:^(FYDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.downloadState != FYDownload_Status_complete && obj.downloadState!= FYDownload_Status_fail) {
                    obj.downloadState = FYDownload_Status_suspended;
                }
            }];
        } else {
            _downloadItemArray = [NSMutableArray array];
        }
    }
    return _downloadItemArray;
}

- (NSMutableDictionary *)urlToTaskDictionary
{
    if (!_urlToTaskDictionary) {
        _urlToTaskDictionary = [NSMutableDictionary dictionary];
    }
    return _urlToTaskDictionary;
}

- (NSMutableDictionary *)urlToItemDictionary
{
    if (!_urlToItemDictionary) {
        _urlToItemDictionary = [NSMutableDictionary dictionary];
    }
    return _urlToItemDictionary;
}
@end
