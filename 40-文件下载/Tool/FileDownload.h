//
//  FileDownload.h
//  40-文件下载
//
//  Created by Mac on 14-11-3.
//  Copyright (c) 2014年 MN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileDownload : NSObject
@property (nonatomic,copy) NSString *cachePath;

- (void)downloafFileWithURL:(NSURL*)URL completion:(void(^)(UIImage *image))completion;

@end
