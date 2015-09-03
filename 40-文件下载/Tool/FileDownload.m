//
//  FileDownload.m
//  40-文件下载
//
//  Created by Mac on 14-11-3.
//  Copyright (c) 2014年 MN. All rights reserved.
//

#import "FileDownload.h"
#import "NSString+Password.h"

#define kTimeout 2.0f
#define kBytesPerTime 200000  // 每次下载的字节数


@interface  FileDownload ()
@property (nonatomic,weak) UIImage *localImage;


@end

@implementation FileDownload

//  为了开发简单，所有方法都不使用多线程，注意力集中在下载文件上


- (UIImage *)localImage{
    UIImage *image = [UIImage imageWithContentsOfFile:self.cachePath];
    return  image;
}

-(void)setCachePath:(NSString *)cachePath
{
     NSString *cache =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
     NSString *cacheMD5 = [cachePath MD5];
     _cachePath = [cache  stringByAppendingPathComponent:cacheMD5];
    
}



#pragma  mark  一段一段的从网上下载数据

-(void)downloafFileWithURL:(NSURL*)URL completion:(void(^)(UIImage *image))completion
{
    //  实现异步通信
    
    dispatch_queue_t q = dispatch_queue_create("mn", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(q,^{
        self.cachePath = [URL absoluteString];
    
    // 1. 从网上下载文件，首先首先地是需要知道文件的大小
   long long fileSize = [self fileSizeWithURL:URL];
   
   if([self localFileSize]!=fileSize){
   long long fromB = 0 ;
   long long toB = 0 ;
    // 2. 然后是分段下载文件
    
    while(fileSize > kBytesPerTime)
    {   
        toB = fromB + kBytesPerTime - 1;
        [self downloadDataWithURL:URL fromB:fromB toB:toB];
        fileSize -= kBytesPerTime;
        fromB += kBytesPerTime;
    }
    [self downloadDataWithURL:URL fromB:toB + 1 toB:toB + kBytesPerTime];
       
       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completion(self.localImage);
       }];
    
    }else{
        
       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completion(self.localImage);
        }];
   }
                        });

}


- (void)downloadDataWithURL:(NSURL*)URL fromB:(long long)fromB toB:(long long)toB
{
   /**
    NSURLRequestUseProtocolCachePolicy = 0,   // 默认的缓冲机制，内存缓存
    NSURLRequestReloadIgnoringLocalCacheData = 1,
    NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
    NSURLRequestReturnCacheDataElseLoad = 2,
    NSURLRequestReturnCacheDataDontLoad = 3,
      */
    NSString *str = [NSString stringWithFormat:@"Bytes=%lld-%lld",fromB,toB];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0f];
    
    [request setValue:str forHTTPHeaderField:@"Range"];
    
    NSURLResponse *response =nil;
   
    NSError *error=nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
   
    [self appendDataWith: data];
   
    NSLog(@"%@",response);
    
}



// 追加 分段的数据一段段的追加到文件的屁股后面
-(void)appendDataWith:(NSData*)data

{
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.cachePath];
    
    NSLog(@"%@",self.cachePath);
    
    if(!handle){
        [data writeToFile:self.cachePath atomically:YES];
    }else{
        
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle closeFile];
    }
}


//获取缓存中的文件大小，用来与网上下载下来的数据进行比较，看是否是同一个文件
- (long long)localFileSize{
    
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:self.cachePath error:NULL];
    return [dict[NSFileSize] longLongValue];
}



- (long long)fileSizeWithURL:(NSURL*)url

{
    //  除了GET请求外，其他都是用   MutableURLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:
                                    NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeout];
    
    //  现在是要做文件大小的采集，不需要下载数据，所以用head的方式
    
    //   HTTPMethod 现在学了有三种方式：GET , POST , HEAD .
    
    request.HTTPMethod = @"HEAD";
    
    NSURLResponse *response = nil;
    
    NSError *error = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"%@",response);
    
    NSLog(@"%lld",response.expectedContentLength);
    
    return  response.expectedContentLength;
}
@end
