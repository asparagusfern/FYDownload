//
//  FYDownloadTableViewCell.h
//  FYDownload
//
//  Created by sven on 2019/4/30.
//  Copyright © 2019年 sven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYDownloadItem.h"
@class FYDownloadTableViewCell;
@protocol FYDownloadTableViewCellDelegate <NSObject>
- (void)cellTouchAction:(FYDownloadTableViewCell *)cell;
- (void)cellTouchDelete:(FYDownloadTableViewCell *)cell;
@end
@interface FYDownloadTableViewCell : UITableViewCell
@property (nonatomic,strong) NSString *urlStr;
@property (nonatomic,weak) id<FYDownloadTableViewCellDelegate> delegate;
- (void)updataUI:(FYDownloadItem *)item;
@end
