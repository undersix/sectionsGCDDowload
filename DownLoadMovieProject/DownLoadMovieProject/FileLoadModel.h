//
//  FileLoadModel.h
//  DownLoadMovieProject
//
//  Created by yesheng on 2017/12/14.
//  Copyright © 2017年 yesheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileLoadModel : NSObject

/**
 下载顺序标记
 */
@property (nonatomic,assign) NSInteger index;

/**
 下载起始字节
 */
@property (nonatomic,assign) long long from;

/**
 下载结束字节
 */
@property (nonatomic,assign) long long to;

/**
 下载数据
 */
@property (nonatomic,strong) NSData * fileData;


@end
