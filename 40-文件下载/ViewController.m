//
//  ViewController.m
//  40-文件下载
//
//  Created by Mac on 14-11-3.
//  Copyright (c) 2014年 MN. All rights reserved.
//

#import "ViewController.h"
#import "FileDownload.h"

@interface ViewController ()

@property(nonatomic,strong) FileDownload *fileDownload;
@end

@implementation ViewController


-(FileDownload *)fileDownload{
    if(_fileDownload== nil){
        _fileDownload = [[FileDownload alloc] init];
    
    }
    return  _fileDownload;
}
            
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.fileDownload downloafFileWithURL:[NSURL URLWithString:@"http://127.0.0.1/157612315-7d52a251ac7a6533.jpg"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
