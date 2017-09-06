//
//  LWFileManager.h
//  IOSMysqlDemo
//
//  Created by liyifang on 2017/9/5.
//  Copyright © 2017年 liyifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWFileManager : NSFileManager
+(BOOL)createDirectoryAtPath:(NSString *)directryPath;
+(BOOL)delectedFileWithPath:(NSString *)filePath;
+(BOOL)removeFileWithPath:(NSString *)filePath;
+(BOOL) isFileExistWithPath:(NSString *)filePath;
@end
