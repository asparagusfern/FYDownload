//
//  FYDownloadItem.m
//  FYDownload
//
//  Created by sven on 2019/4/29.
//  Copyright © 2019年 sven. All rights reserved.
//

#import "FYDownloadItem.h"
#import "NSString+MD5.h"

@implementation FYDownloadItem

- (FYDownloadItem *)init:(NSURL *)requestUrl
{
    return [self init:requestUrl resumeData:nil downloadState:FYDownload_Status_suspended];
}

- (FYDownloadItem *)init:(NSURL *)requestUrl
              resumeData:(NSData *)resumeData
           downloadState:(FYDownload_Status)downloadState
{
    if (self = [super init]) {
        
        if (!requestUrl) {
            
            NSAssert(requestUrl!=nil, @"FYDownloadManager_目标url不能为空");
            
        } else {
            
            if ([requestUrl isKindOfClass:[NSString class]]) {
                requestUrl = [NSURL URLWithString:(NSString *)requestUrl];
            }
            self.requestUrl = requestUrl;
            self.resumeData = resumeData;
            self.downloadState = downloadState;
        }
    }
    return self;
}

- (NSURL *)saveUrl
{
    if (!_saveUrl) {
        _saveUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp4",FYDwonloadFileHomePath,[_requestUrl.absoluteString MD5]]];
    }
    return _saveUrl;
}

- (void)setDownloadState:(FYDownload_Status)downloadState
{
    _downloadState = downloadState;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FYDownload_Status" object:nil userInfo:@{@"requestUrl":self.requestUrl,@"item":self}];
    });
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.requestUrl forKey:@"requestUrl"];
    [aCoder encodeObject:self.resumeData forKey:@"resumeData"];
    [aCoder encodeInteger:self.downloadState forKey:@"downloadState"];
    [aCoder encodeInt64:self.countOfBytesReceived forKey:@"countOfBytesReceived"];
    [aCoder encodeInt64:self.countOfBytesExpectedToReceive forKey:@"countOfBytesExpectedToReceive"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.requestUrl = [aDecoder decodeObjectForKey:@"requestUrl"];
        self.resumeData = [aDecoder decodeObjectForKey:@"resumeData"];
        self.downloadState = [aDecoder decodeIntegerForKey:@"downloadState"];
        self.countOfBytesReceived = [aDecoder decodeInt64ForKey:@"countOfBytesReceived"];
        self.countOfBytesExpectedToReceive = [aDecoder decodeInt64ForKey:@"countOfBytesExpectedToReceive"];
        if ([aDecoder decodeIntegerForKey:@"downloadState"] != FYDownload_Status_complete) {
            self.downloadState = FYDownload_Status_suspended;
        }
    }
    return self;
}

@end
