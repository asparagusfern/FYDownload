//
//  FYDownloadManager+Task.m
//  FYDownload
//
//  Created by sven on 2019/4/29.
//  Copyright © 2019年 sven. All rights reserved.
//

#import "FYDownloadManager+Task.h"
@implementation FYDownloadManager (Task)
- (void)addDownload:(FYDownloadItem *)downloadItem
{
    //判断任务队列是否已存在
    FYDownloadItem *temDownloadItem = [self getDownloadItem:downloadItem.requestUrl];
    
    if (temDownloadItem) {
        
        NSLog(@"任务已在下载队列中!");
        
        return;
        
    } else {
        
        //保存到磁盘中
        [self.downloadItemArray addObject:downloadItem];
        [self save];
        
        //保存到内存中(url-task url-downloadItem)
        NSURLSessionDownloadTask *task = [self creatTask:downloadItem];
        [self.urlToTaskDictionary setObject:task forKey:downloadItem.requestUrl];
        [self.urlToItemDictionary setObject:downloadItem forKey:downloadItem.requestUrl];
    }
}

- (void)startAll
{
    [self.downloadItemArray enumerateObjectsUsingBlock:^(FYDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self start:obj.requestUrl];
    }];
}

- (void)suspendedAll
{
    [self.downloadItemArray enumerateObjectsUsingBlock:^(FYDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self suspended:obj.requestUrl];
    }];
}

- (void)removeAll
{
    [self.downloadItemArray enumerateObjectsUsingBlock:^(FYDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self remove:obj.requestUrl];
    }];
}

- (void)start:(NSURL *)url
{
    if (!url) {
        return;
    } else {
        //判断是否在下载任务中
        FYDownloadItem *temDownloadItem = [self getDownloadItem:url];
        if (temDownloadItem.downloadState == FYDownload_Status_fail || temDownloadItem.downloadState == FYDownload_Status_complete) {
            //如果已经下载完成或者失败
            return;
        }
        if (temDownloadItem) {
            NSURLSessionDownloadTask *task = [self.urlToTaskDictionary objectForKey:url];
            if (!task) {//这里是重启App为已存在任务创建task
                task = [self creatTask:temDownloadItem];
                [self.urlToTaskDictionary setObject:task forKey:temDownloadItem.requestUrl];
                [self.urlToItemDictionary setObject:temDownloadItem forKey:temDownloadItem.requestUrl];
            }
            temDownloadItem.downloadState = FYDownload_Status_downloading;
            [task resume];
        } else {
            NSLog(@"下载任务不存在!");
            return;
        }
        
    }
}

- (void)suspended:(NSURL *)url
{
    if (!url) {
        return;
    } else {
        //判断是否在下载任务中
        FYDownloadItem *temDownloadItem = [self getDownloadItem:url];
        if (temDownloadItem.downloadState == FYDownload_Status_fail || temDownloadItem.downloadState == FYDownload_Status_complete) {
            //如果已经下载完成或者失败
            return;
        }
        if (temDownloadItem) {
            NSURLSessionDownloadTask *task = [self.urlToTaskDictionary objectForKey:url];
            if (!task) {//这个正常情况不会执行
                task = [self creatTask:temDownloadItem];
                [self.urlToTaskDictionary setObject:task forKey:temDownloadItem.requestUrl];
                [self.urlToItemDictionary setObject:temDownloadItem forKey:temDownloadItem.requestUrl];
            }
            temDownloadItem.downloadState = FYDownload_Status_suspended;
            [self save];
            [task suspend];
        } else {
            NSLog(@"下载任务不存在!");
            return;
        }
    }
}

- (void)remove:(NSURL *)url
{
    if (!url) {
        return;
    } else {
        //判断是否在下载任务中
        FYDownloadItem *temDownloadItem = [self getDownloadItem:url];
        if (temDownloadItem) {
            NSURLSessionDownloadTask *task = [self.urlToTaskDictionary objectForKey:url];
            if (task) {
                [task cancel];
                [self.urlToTaskDictionary removeObjectForKey:temDownloadItem.requestUrl];
                [self.urlToItemDictionary removeObjectForKey:temDownloadItem.requestUrl];
            }
            [self.downloadItemArray removeObject:temDownloadItem];
            [self save];
            //删除本地下载的文件
            [[NSFileManager defaultManager] removeItemAtURL:temDownloadItem.saveUrl error:nil];
            
        } else {
            NSLog(@"下载任务不存在!");
            return;
        }
    }
}

- (FYDownloadItem *)getDownloadItem:(NSURL *)requestUrl
{
    FYDownloadItem *temDownloadItem = nil;
    
    for (FYDownloadItem *s in self.downloadItemArray) {
        if ([s.requestUrl.absoluteString isEqualToString:requestUrl.absoluteString]) {
            temDownloadItem = s;
            break;
        }
    }
    return temDownloadItem;
}

- (NSURLSessionDownloadTask *)creatTask:(FYDownloadItem *)download
{
    NSURLSessionDownloadTask *task = nil;
    
    download.downloadState = FYDownload_Status_wait;
    
    if (download.resumeData) {
        
        task = [self.session downloadTaskWithResumeData:download.resumeData];
        
    } else {
        
        task = [self.session downloadTaskWithURL:download.requestUrl];
        
    }
    
    return task;
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    
    FYDownloadItem *currentItem = nil;
    for (FYDownloadItem *item in self.downloadItemArray) {
        if ([item.requestUrl.absoluteString isEqualToString:task.currentRequest.URL.absoluteString]) {
            currentItem = item;
            break;
        }
    }
    
    if (currentItem) {
        currentItem.countOfBytesReceived = task.countOfBytesReceived;
        currentItem.countOfBytesExpectedToReceive = task.countOfBytesExpectedToReceive;
        
        if (error) {//重启时中断任务回调
            currentItem.downloadState = FYDownload_Status_suspended;
            currentItem.resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        } else {//下载结束
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            if (response.statusCode == 200 || response.statusCode == 206) {//下载成功
                currentItem.downloadState = FYDownload_Status_complete;
            } else {//下载失败
                currentItem.downloadState = FYDownload_Status_fail;
            }
        }
        [self save];

        if (currentItem.delegate && [currentItem.delegate respondsToSelector:@selector(downloadItem:totalBytesWritten:totalBytesExpectedToWrite:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [currentItem.delegate downloadItem:currentItem totalBytesWritten:task.countOfBytesReceived totalBytesExpectedToWrite:task.countOfBytesExpectedToReceive];
            });
        }
    }
}

#pragma mark NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSError *error = nil;
    FYDownloadItem *currentItem = self.urlToItemDictionary[downloadTask.currentRequest.URL];
    
    if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:currentItem.saveUrl error:&error]) {
        //文件下载完成、移动成功
        NSLog(@"%@下载完成、移动成功",currentItem.requestUrl);
    } else {
        //文件下载完成、移动失败
        NSLog(@"%@下载完成、移动失败____%@",currentItem.requestUrl,error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    FYDownloadItem *currentItem = self.urlToItemDictionary[downloadTask.currentRequest.URL];
    if ( currentItem.downloadState != FYDownload_Status_downloading) {
         currentItem.downloadState = FYDownload_Status_downloading;
    }
   
    currentItem.countOfBytesReceived = totalBytesWritten;
    currentItem.countOfBytesExpectedToReceive = totalBytesExpectedToWrite;
    if (currentItem.delegate && [currentItem.delegate respondsToSelector:@selector(downloadItem:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [currentItem.delegate downloadItem:currentItem totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        });
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"恢复下载");
}
@end
