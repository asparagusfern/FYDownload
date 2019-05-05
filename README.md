# FYDownload
基于NSURLSessionDownloadTask实现多任务文件下载，支持断点下载

#import "FYDownloadManager+Task.h"
使用FYDownloadManager的分类FYDownloadManager+Task来创建和管理下载任务

eg:
获取所有下载任务
[FYDownloadManager shareManager].downloadItemArray

开启一个新的下载任务
FYDownloadItem *item = [[FYDownloadItem alloc] init:[NSURL URLWithString:@"http://ultravideo.cs.tut.fi/video/ShakeNDry_3840x2160_30fps_420_8bit_AVC_MP4.mp4"]];
[[FYDownloadManager shareManager] addDownload:item];
[[FYDownloadManager shareManager] start:item.requestUrl];

监听下载进度       
1.添加进度监听
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStateChange:) name:@"FYDownload_Status" object:nil];

2.监听回调
- (void)downloadStateChange:(NSNotification *)no {
NSURL *requestUrl = no.userInfo[@"requestUrl"];
FYDownloadItem *currentItem = no.userInfo[@"item"];
NSLog(@"%@___%@",currentItem.countOfBytesReceived,currentItem.countOfBytesExpectedToReceive);
}
