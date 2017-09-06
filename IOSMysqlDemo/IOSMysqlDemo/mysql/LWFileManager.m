//
//  LWFileManager.m
//  IOSMysqlDemo
//
//  Created by liyifang on 2017/9/5.
//  Copyright © 2017年 liyifang. All rights reserved.
//

#import "LWFileManager.h"

@implementation LWFileManager
//判断文件是否已经在沙盒中已经存在？
+(BOOL) isDirectoryExistWithPath:(NSString *)directoryPath
{
    
    BOOL isDir;
    BOOL result = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:directoryPath isDirectory:&isDir] && isDir) {
            result = YES;
    }
   
    NSLog(@"这个目录已经存在：%@",result?@"是的":@"不存在");
    return result;
}

+(BOOL) isFileExistWithPath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
}

+(BOOL)createDirectoryAtPath:(NSString *)directryPath
{
    BOOL isExist = [self isDirectoryExistWithPath:directryPath];
    if (isExist) {
        NSLog(@"文件目录已存在不用重新创建");
        return YES;
    }
   NSError *error = NULL;
   NSFileManager *fileManager = [NSFileManager defaultManager];
   BOOL isYES =  [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (isYES&&error==NULL) {
        return YES;

    }
    else
    {
        NSLog(@"创建文件目录：%@，失败信息:%@",isYES?@"成功":@"失败",error.userInfo);
    }
    return NO;
}
+(BOOL)removeFileWithPath:(NSString *)filePath
{
    BOOL isExist = [self isFileExistWithPath:filePath];
    if (!isExist) {
        NSLog(@"文件不存在，不必进行删除操作");
        return YES;
    }
     NSError *error = NULL;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isYES = [fileManager removeItemAtPath:filePath error:&error];
    if (isYES&&error==NULL) {
        return YES;
        
    }
    else
    {
        NSLog(@"删除文件：%@，失败信息:%@",isYES?@"成功":@"失败",error.userInfo);
    }
    return NO;
    
   
}
@end
