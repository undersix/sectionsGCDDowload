//
//  MainViewController.m
//  DownLoadMovieProject
//
//  Created by yesheng on 2017/12/14.
//  Copyright © 2017年 \ All rights reserved.
//

#import "MainViewController.h"

#import "DownLoadQueueController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

- (void)initialize
{
    UIButton * button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"多线程分段下载后拼接" forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:button1];
    button1.frame = (CGRect) {0,104,200,30};
    [button1 addTarget:self
                action:@selector(queueDownload)
      forControlEvents:UIControlEventTouchUpInside];
}


- (void)queueDownload
{
    DownLoadQueueController * controller = [[DownLoadQueueController alloc]init];
    [self.navigationController pushViewController:controller animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
