//
//  DownLoadQueueController.m
//  DownLoadMovieProject
//
//  Created by yesheng on 2017/12/14.
//  Copyright © 2017年  All rights reserved.
//

#import "FileLoadModel.h"

#import "DownLoadQueueController.h"

#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height

static NSString * downLoadStr = @"http://flv2.bn.netease.com/videolib3/1604/28/fVobI0704/SD/fVobI0704-mobile.mp4";

@interface DownLoadQueueController ()


/**
 下载文件的字节数
 */
@property (nonatomic,assign) long long totalSize;

/**
 下载文件名称
 */
@property (nonatomic,copy) NSString * fileName;

/**
 队列下载数据存储数组
 */
@property (nonatomic,strong) NSMutableArray * fileModels;

/**
 存储的数据
 */
@property (nonatomic,strong) NSMutableData * storeData;

/**
 视频播放web
 */
@property (nonatomic,strong) UIWebView * webView;
@end

@implementation DownLoadQueueController



- (NSMutableData*)storeData
{
    if (!_storeData) {
        _storeData = [NSMutableData dataWithCapacity:0];
      
        
    }
    return _storeData;
}

- (UIWebView*)webView;
{
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, mainWidth, 200)];
        [self.view addSubview:_webView];
    }
    return _webView;
}


- (NSMutableArray*)fileModels
{
    if (!_fileModels) {
        _fileModels = [NSMutableArray arrayWithCapacity:0];
    }
    return _fileModels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    [self webView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSURLResponse * response = [self getLoadFileLength];
    self.totalSize = [response expectedContentLength];
    NSLog(@"%lld",_totalSize);
    [self queueForDownload];
}


/**
 获取下载文件的响应体 同步方法HEAD请求获取

 @return 响应体
 */
- (NSURLResponse*)getLoadFileLength
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[self downLoadURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0f];
    
    [request setHTTPMethod:@"HEAD"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error){
        NSLog(@"detail error:%@",error.localizedDescription);
    }
    return response;
}


/**
 转行URL

 @return URL
 */
- (NSURL*)downLoadURL
{
    return [NSURL URLWithString:downLoadStr];
}


/**
 下载方法
 */
- (void)queueForDownload
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_t group = dispatch_group_create();
    
    //每段分布字节数
    long long perTime = self.totalSize/3;
    long long fizeSize = self.totalSize;
    long long from = 0;
    long long to = 0;
    NSInteger index = 0;
    while (fizeSize > perTime) {
        to = from + perTime - 1;
        dispatch_group_async(group, queue, [self createDownLoadFrom:from to:to index:index]);
        fizeSize -= perTime;
        from += perTime;
        index ++;
    }
    //末尾端字节数下载
    to = from + perTime - 1;
    dispatch_group_async(group, queue, [self createDownLoadFrom:from to:to index:index]);
    
    dispatch_group_notify(group, queue, ^{
        
        [self.fileModels sortUsingComparator:^NSComparisonResult(FileLoadModel * obj1, FileLoadModel* obj2) {
            return obj1.index > obj2.index;
        }];
        
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString * fullPath = [path stringByAppendingPathComponent:self.fileName];
        
        for (FileLoadModel * model in self.fileModels) {
            [self.storeData appendData:model.fileData];
        }
        [self.storeData writeToFile:fullPath atomically:YES];
        self.storeData = nil;
        
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:fullPath]];
        [self.webView loadRequest:request];
    });
}


/**
 线程任务代码块

 @param from 起始字节
 @param to 结束字节
 @param index 模型属性标记
 @return 线程任务代码块
 */
- (dispatch_block_t)createDownLoadFrom:(long long)from to:(long long)to index:(NSInteger)index
{
    return dispatch_block_create(DISPATCH_BLOCK_BARRIER, ^{
        NSLog(@"当前线程-----%@",[NSThread currentThread]);
        
        FileLoadModel * model = [[FileLoadModel alloc]init];
        model.from = from;
        model.to = to;
        model.index = index;
        
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSString * rangeStr = [NSString stringWithFormat:@"Bytes=%lld-%lld",from,to];
        NSLog(@"range范围%@",rangeStr);
        
        NSMutableURLRequest * requset = [NSMutableURLRequest requestWithURL:[self downLoadURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0f];
        //设置请求头
        [requset setValue:rangeStr  forHTTPHeaderField:@"Range"];
        
        
        NSURLSession * session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask * task = [session dataTaskWithRequest:requset completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"下载的数据大小-------%lu",data.length);
                self.fileName = [response suggestedFilename];
                model.fileData = data;
                @synchronized (self) {
                    [self.fileModels addObject:model];
                }
            }
            dispatch_semaphore_signal(semaphore);
        }];
        [task resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
