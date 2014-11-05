//
//  FileDownload.m
//  40-文件下载
//
//  Created by Mac on 14-11-3.
//  Copyright (c) 2014年 MN. All rights reserved.
//

#import "FileDownload.h"

#define kTimeout 2.0f
#define kBytesPerTime 200000  // 每次下载的字节数

@implementation FileDownload

//  为了开发简单，所有方法都不使用多线程，注意力集中在下载文件上

-(void)downloafFileWithURL:(NSURL*)URL
{
    //1. 从网上下载文件，需要知道文件的大小
   long long fileSize = [self fileSizeWithURL:URL];
   long long  fromB = 0 ;
   long long  toB = 0 ;
    
    while(fileSize > kBytesPerTime)
    {   
        toB = fromB + kBytesPerTime - 1;
        
       [self downloadDataWithURL:URL fromB:fromB toB:toB];
        
           fileSize -= kBytesPerTime;
           fromB += kBytesPerTime;
    }
  
    [self downloadDataWithURL:URL fromB:fromB toB:toB];

}


- (void)downloadDataWithURL:(NSURL*)url fromB:(long long)fromB toB:(long long)toB
{
   
    /**
    
    NSURLRequestUseProtocolCachePolicy = 0,   // 默认的缓冲机制，内存缓存
    
    NSURLRequestReloadIgnoringLocalCacheData = 1,
    NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,

    NSURLRequestReturnCacheDataElseLoad = 2,
    NSURLRequestReturnCacheDataDontLoad = 3,
   
    
    */

    NSString *str = [NSString stringWithFormat:@"Bytes=%lld-%lld",fromB,toB];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0f];
    
    [request setValue:str forHTTPHeaderField:@"Range"];
    
    NSURLResponse *reponse = nil;
    
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&reponse error:&error];
 
    [self appendDataWith:data];
    
    NSLog(@"---%@",reponse);
}

-(void)appendDataWith:(NSData*)data
{
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"apple.png"];
    NSLog(@"%@",filePath);
    
    if(!filePath){
        [data writeToFile:filePath atomically:YES];
    }else{
       
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle closeFile];
       
    }
    
 
    
}


- (long long)fileSizeWithURL:(NSURL*)url

{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:kTimeout];
    
    //  现在是要做文件大小的采集，不需要下载数据，所以用head的方式
    request.HTTPMethod = @"HEAD";
    
    NSURLResponse *response = nil;
    
    NSError *error = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"%lld",response.expectedContentLength);
    
    return  response.expectedContentLength;
}
@end
