//
//  FYDownloadItem.h
//  FYDownload
//
//  Created by sven on 2019/4/29.
//  Copyright © 2019年 sven. All rights reserved.
//

#import <Foundation/Foundation.h>
#define FYDwonloadFileHomePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
@class FYDownloadItem;
@protocol FYDownloadItemDelegate <NSObject>

@optional
- (void)downloadItem:(FYDownloadItem *)item totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
- (void)downloadItem:(FYDownloadItem *)item didCompleteWithError:(NSString *)error;
@end

typedef NS_ENUM(NSInteger,FYDownload_Status) {
    FYDownload_Status_wait,//已启动但处于等待状态
    FYDownload_Status_downloading,//正在下载
    FYDownload_Status_suspended,//暂停(当App重新启动后、所有未完成任务将被置为暂停状态)
    FYDownload_Status_fail,//失败
    FYDownload_Status_complete//完成
};

@interface FYDownloadItem : NSObject<NSCoding>

- (FYDownloadItem *)init:(NSURL *)requestUrl;

@property (nonatomic,weak) id<FYDownloadItemDelegate> delegate;

@property (nonatomic,strong) NSURL *requestUrl;
@property (nonatomic,strong) NSURL *saveUrl;//每次App重新启动后会重新生成、不可持久存储
@property (nonatomic,strong) NSData *resumeData;
@property (nonatomic,assign) int64_t countOfBytesReceived;
@property (nonatomic,assign) int64_t countOfBytesExpectedToReceive;

@property (nonatomic,assign) FYDownload_Status downloadState;
@end
