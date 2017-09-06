//
//  LWSqliteManager.m
//  Persion
//
//  Created by liyifang on 2017/5/15.
//  Copyright © 2017年 段凯. All rights reserved.
//

#import "LWSqliteManager.h"
#import <sqlite3.h>
#import <objc/runtime.h>// objc_getClass
#import "LWFileManager.h"

@interface LWSqliteManager ()

@end
@implementation LWSqliteManager
{
    sqlite3 *_database;
    NSString *_currentDBName;
}

+(instancetype)sharedSqliteManager
{
    static LWSqliteManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LWSqliteManager alloc]init];
    });
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

-(NSMutableDictionary *)dataBaseFilePaths
{
    if (!_dataBaseFilePaths) {
        _dataBaseFilePaths = [NSMutableDictionary dictionary];
    }
    return _dataBaseFilePaths;
}

-(NSString *)createFilePath:(NSString *)fileName{
    
    NSArray *documentArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentPath = [documentArr firstObject];
    documentPath = [documentPath stringByAppendingPathComponent:@"myFile"];
    [LWFileManager createDirectoryAtPath:documentPath];
    // xxx.db 为数据库的名字
    NSString *path = [NSString stringWithFormat:@"%@/%@.db",documentPath,fileName];
   
    return path;
}
//创建打开数据库
-(BOOL)openDatabaseWithName:(NSString *)dataBaseName
{
    
   NSString *path = [self createFilePath:dataBaseName];
   BOOL dataBaseExist = [LWFileManager isFileExistWithPath:path];
   
    if (dataBaseExist&&[dataBaseName isEqualToString:_currentDBName]&&_database) {
          return YES;
        
    }
    int databaseResult = sqlite3_open([path UTF8String], &_database);
    
    if (databaseResult != SQLITE_OK) {
        
//        NSLog(@"创建／打开数据库失败,%d",databaseResult);
        return NO;
    }
     self.dataBaseFilePaths[dataBaseName] = path;
     _currentDBName = dataBaseName;//当前数据库名字
    return YES;
}
//创建表
-(BOOL)creatSqliteTable:(NSString *)tableName andFields:(NSArray *)fieldsArr//表名 字段 字段约束
{
    NSString *dataBasePath = _dataBaseFilePaths[_currentDBName];
    BOOL dataBaseExist = [LWFileManager isFileExistWithPath:dataBasePath];
    if (!dataBaseExist) {
        NSLog(@"数据库已经不存在无法创建表单。数据库路径：%@",dataBasePath);
        return NO;
    }
    BOOL success = [self openDatabaseWithName:_currentDBName];
    if (!success) {
        return NO;
    }

    char *error;
    
    //    建表格式: create table if not exists 表名 (列名 类型,....)    注: 如需生成默认增加的id: id integer primary key autoincrement
    NSMutableString *createSQLStr = [NSMutableString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,)",tableName];
    for (NSString *field in fieldsArr) {
        [createSQLStr insertString:field atIndex:createSQLStr.length-1];
         [createSQLStr insertString:@"," atIndex:createSQLStr.length-1];
    }
    [createSQLStr deleteCharactersInRange:NSMakeRange(createSQLStr.length-2, 1)];
    const char *createSQL = [createSQLStr UTF8String];
//    NSLog(@"%s",createSQL);
    int tableResult = sqlite3_exec(_database, createSQL, NULL, NULL, &error);
    
    if (tableResult != SQLITE_OK) {
        return NO;
//        NSLog(@"创建表失败:%s",error);
    }
    return YES;
}
//插入数据
-(void)insetSqliteTable:(NSString *)tableName andFields:(NSArray *)fieldsArr andValues:(NSArray *)valuesArr
{
    NSString *dataBasePath = _dataBaseFilePaths[_currentDBName];
    BOOL dataBaseExist = [LWFileManager isFileExistWithPath:dataBasePath];
    if (!dataBaseExist) {
        NSLog(@"数据库已经不存在无法插入数据。数据库路径：%@",dataBasePath);
        return;
    }
    if (fieldsArr.count!=valuesArr.count) {
        NSLog(@"字段总数与值总数不一致，无法插入数据库");
        return;
    }
    BOOL success = [self openDatabaseWithName:_currentDBName];
    if (!success) {
        return;
    }
    
    
    sqlite3_stmt *stmt = NULL;
    //values('iosRunner','male')",
    NSMutableString *insertSQLStr = [NSMutableString stringWithFormat:@"insert into %@ ()", tableName];
    for (NSString  *field in fieldsArr) {
        [insertSQLStr insertString:field atIndex:insertSQLStr.length-1];
         [insertSQLStr insertString:@"," atIndex:insertSQLStr.length-1];
    }
    
      [insertSQLStr deleteCharactersInRange:NSMakeRange(insertSQLStr.length-2, 1)];
    [insertSQLStr appendString:@" values()"];
    for (NSString *value in valuesArr) {
       NSString *newValue = [NSString stringWithFormat:@"'%@'",value];
        [insertSQLStr insertString:newValue atIndex:insertSQLStr.length-1];
        [insertSQLStr insertString:@"," atIndex:insertSQLStr.length-1];
    }
    [insertSQLStr deleteCharactersInRange:NSMakeRange(insertSQLStr.length-2, 1)];
    const char *insertSQL = [insertSQLStr UTF8String];
    int insertResult = sqlite3_prepare_v2(_database, insertSQL, -1, &stmt, nil);
    
    if (insertResult != SQLITE_OK) {
        NSLog(@"添加失败,%d",insertResult);
    }
    else{
        //           执行sql语句
        sqlite3_step(stmt);
    }
    //        销毁stmt,回收资源
    sqlite3_finalize(stmt);
    
   
}
//更新数据
-(void)updateSqliteTable:(NSString *)tableName andFieldADValues:(NSDictionary *)fieldADValuesDic andWhere:(NSDictionary *)whereDic
{
    NSString *dataBasePath = _dataBaseFilePaths[_currentDBName];
    BOOL dataBaseExist = [LWFileManager isFileExistWithPath:dataBasePath];
    if (!dataBaseExist) {
        NSLog(@"数据库已经不存在无法更新数据。数据库路径：%@",dataBasePath);
        return;
    }
    
    BOOL success = [self openDatabaseWithName:_currentDBName];
    if (!success) {
        return;
    }
    sqlite3_stmt *stmt = NULL;
    //values('iosRunner','male')",
    NSMutableString *updateSQLStr = [NSMutableString stringWithFormat:@"update %@ set", tableName];
    [fieldADValuesDic enumerateKeysAndObjectsUsingBlock:^(NSString *fild,NSString *value, BOOL * _Nonnull stop) {
        NSString *updateStr = [NSString stringWithFormat:@" %@='%@',",fild,value];
        [updateSQLStr appendString:updateStr];
        
    }];
    [updateSQLStr deleteCharactersInRange:NSMakeRange(updateSQLStr.length-1, 1)];
    [updateSQLStr appendString: @" where"];
      __block NSInteger idx = 0;
    [whereDic enumerateKeysAndObjectsUsingBlock:^(NSString *fild,NSString *value, BOOL * _Nonnull stop) {
        NSString *updateStr;
        if (idx==0) {
            updateStr = [NSString stringWithFormat:@" %@ = '%@'",fild,value];
        }
        else
        {
            updateStr = [NSString stringWithFormat:@" and %@ = '%@'",fild,value];
        }
        idx++;
        [updateSQLStr appendString:updateStr];
    }];
    
    const char *updateSQL = [updateSQLStr UTF8String];
    int updateResult = sqlite3_prepare_v2(_database, updateSQL, -1, &stmt, nil);
    
    if (updateResult != SQLITE_OK) {
        NSLog(@"添加失败,%d",updateResult);
    }
    else{
        //           执行sql语句
        sqlite3_step(stmt);
    }
    //        销毁stmt,回收资源
    sqlite3_finalize(stmt);
    
  
}
//删除数据
-(void)delectedSqliteTable:(NSString *)tableName andWhere:(NSDictionary *)whereDic
{
     NSString *dataBasePath = _dataBaseFilePaths[_currentDBName];
    BOOL dataBaseExist = [LWFileManager isFileExistWithPath:dataBasePath];
    if (!dataBaseExist) {
        NSLog(@"数据库已经不存在无法删除数据。数据库路径：%@",dataBasePath);
        return;
    }
    
    BOOL success = [self openDatabaseWithName:_currentDBName];
    if (!success) {
        return;
    }
    
    sqlite3_stmt *stmt = NULL;
    //values('iosRunner','male')",
    NSMutableString *delectSQLStr = [NSMutableString stringWithFormat:@"delete from %@ ", tableName];
    
    if (whereDic.count>0) {
        [delectSQLStr appendString: @" where"];
        __block NSInteger idx = 0;
        [whereDic enumerateKeysAndObjectsUsingBlock:^(NSString *fild,NSString *value, BOOL * _Nonnull stop) {
            NSString *delectStr;
            if (idx==0) {
                delectStr = [NSString stringWithFormat:@" %@ = '%@'",fild,value];
            }
            else
            {
                delectStr = [NSString stringWithFormat:@" and %@ = '%@'",fild,value];
            }
            idx++;
            [delectSQLStr appendString:delectStr];
            
        }];
    }
    
    const char *delectSQL = [delectSQLStr UTF8String];
    int updateResult = sqlite3_prepare_v2(_database,delectSQL, -1, &stmt, nil);
    
    if (updateResult != SQLITE_OK) {
        NSLog(@"添加失败,%d",updateResult);
    }
    else{
        //           执行sql语句
        sqlite3_step(stmt);
    }
    //        销毁stmt,回收资源
    sqlite3_finalize(stmt);
    
  
}
// 查找数据
-(NSMutableArray *)selectedSqliteTable:(NSString *)tableName andFieldsArr:(NSArray *)fieldsArr andBaseFieldsArr:(NSArray *)baseFieldsArr andWhere:(NSDictionary *)whereDic
{
    NSString *dataBasePath = _dataBaseFilePaths[_currentDBName];
    BOOL dataBaseExist = [LWFileManager isFileExistWithPath:dataBasePath];
    if (!dataBaseExist) {
        NSLog(@"数据库已经不存在无法查询数据。数据库路径：%@",dataBasePath);
        return nil;
    }
    
    BOOL success = [self openDatabaseWithName:_currentDBName];
    if (!success) {
        return nil;
    }
    sqlite3_stmt *stmt = NULL;
    //values('iosRunner','male')",
    NSMutableString *selectSQLStr = [NSMutableString stringWithFormat:@"select"];
    if (fieldsArr) {
        [fieldsArr enumerateObjectsUsingBlock:^(NSString *field, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx==0) {
                [selectSQLStr  appendFormat:@" %@",field];
            }
            else
            {
                [selectSQLStr  appendFormat:@", %@",field];
            }
        }];

    }
    else
    {
        [selectSQLStr appendFormat:@" * "];
    }
    __block NSInteger idx = 0;
     [selectSQLStr appendFormat:@"from %@  ",tableName];
    [whereDic enumerateKeysAndObjectsUsingBlock:^(NSString *fild,NSString *value, BOOL * _Nonnull stop) {
        NSString *selectStr;
        if (idx==0) {
           
            selectStr = [NSString stringWithFormat:@" where %@ = '%@'",fild,value];
        }
        else
        {
            selectStr = [NSString stringWithFormat:@" and %@ = '%@'",fild,value];
        }
        idx++;
        [selectSQLStr appendString:selectStr];
        
    }];
   
    const char *selectSQL = [selectSQLStr UTF8String];
    int selectResult = sqlite3_prepare_v2(_database, selectSQL, -1, &stmt, nil);
    NSMutableArray *resultArr = [NSMutableArray array];
    if (selectResult != SQLITE_OK) {
        NSLog(@"查找失败,%d",selectResult);
    }
    else{
       
      
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            // 查询的结果可能不止一条,直到 sqlite3_step(stmt) != SQLITE_ROW,查询结束。
            int idx = 0;
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
           
            if (fieldsArr) {
                for (NSString *key in fieldsArr) {
                   const char *value = (const char *) sqlite3_column_text(stmt, idx);
                    resultDic[key] =  value ? objc_getClass(value):@"";
                   
                      idx++;
                }
              
            }
            else
            {   idx = 1;
                for (NSString *key in baseFieldsArr) {
                    const char *value = (const char *) sqlite3_column_text(stmt, idx);
                    NSString *valueStr = [NSString stringWithUTF8String:value];
                    resultDic[key] = value ?valueStr:@"";
                    NSLog(@"%f",[valueStr floatValue]);
                    idx++;
                }
                
            }
            [resultArr addObject:resultDic];
        }
    }
    //        销毁stmt,回收资源
    sqlite3_finalize(stmt);
    
    return resultArr;
}

#pragma mark -关闭数据库-
-(void)closeDatabase{
    int result = sqlite3_close(_database);
    if (result == SQLITE_OK) {
        //关闭数据库的时候将db置为空，是因为打开数据库的时候，我们需要用nil做判断
        _database = nil;
    }else{
        NSLog(@"关闭数据库失败");
    }
}

#pragma mark -删除数据库----
-(void)removeDataBaseWithName:(NSString *)dataBaseName
{
    NSString *dataBasePath = self.dataBaseFilePaths[dataBaseName];
    BOOL dataBaseExist = [LWFileManager isFileExistWithPath:dataBasePath];
    if (!dataBaseExist) {
        NSLog(@"数据库已经不存不必删除。数据库路径：%@",dataBasePath);
        return;
    }
   
    
   BOOL success = [LWFileManager removeFileWithPath:dataBasePath];
    if (success) {
         //关闭数据库
        [self closeDatabase];
        NSLog(@"删除数据库成功：%@",dataBasePath);
    }
    else
    {
        NSLog(@"删除数据库失败：%@",dataBasePath);
    }
   
}
#pragma mark - 二次封装

//创建表
-(BOOL)creatSqliteTable:(NSString *)tableName andCharFields:(NSArray *)charFieldsArr
{
    NSMutableArray *muField = [NSMutableArray array];
    for (NSString *field in charFieldsArr) {
     NSString *  charField = [NSString stringWithFormat:@"char %@",field];
        [muField addObject:charField];
    }
    BOOL success = [self creatSqliteTable:tableName andFields:charFieldsArr];
    return success;
}

@end

@implementation LWSqliteDataBaseTool
{
    NSString *_dataBaseName;
//    NSMutableDictionary *_tableNameDic;//key:表名 v:字段组成的数组
}
-(instancetype)initWithDataBaseName:(NSString *)name
{
    self = [super init];
    if (self) {
        _dataBaseName = name;
      
    }
    return self;
}

//
-(NSMutableDictionary *)tablesFieldsDic
{
    if (!_tablesFieldsDic) {
        _tablesFieldsDic = [NSMutableDictionary dictionary];
    }
    return _tablesFieldsDic;
}

-(NSString *)dataBasePath
{
    if (_dataBaseName==nil||[_dataBaseName isEqualToString:@""]) {
        return @"";
    }
    NSString *path = self.dataBaseFilePaths[_dataBaseName];
    return path;
}

-(void)removeDataBase
{
    [self removeDataBaseWithName:_dataBaseName];
}


-(BOOL)creatSqliteTable:(NSString *)tableName andCharFields:(NSArray *)charFieldsArr
{
    if ((tableName==nil||[tableName isEqualToString:@""])||charFieldsArr.count<=0) {
        return NO;
    }
    
    BOOL dataBaseExist = [LWFileManager isFileExistWithPath:_dataBasePath];
    if (!dataBaseExist) {
        BOOL success = [self openDatabaseWithName:_dataBaseName];
        if (!success) {
            NSLog(@"数据库已经不存并且在尝试重新创建时失败导致无法创建表单。数据库路径：%@",_dataBasePath);
            return NO;
        }
    }
  self.tablesFieldsDic[tableName] = charFieldsArr;
   BOOL  success = [super creatSqliteTable:tableName andCharFields:charFieldsArr];
    self.tablesFieldsDic[tableName] = charFieldsArr;
    return success;
}



//插入数据
-(void)insetSqliteTable:(NSString *)tableName andValues:(NSArray *)valuesArr
{
     BOOL dataBaseExist = [LWFileManager isFileExistWithPath:self.dataBasePath];
     NSArray *fields = self.tablesFieldsDic[tableName];
    if (!dataBaseExist) {//数据库不存在时 尝试重建 并创建对应表单
         BOOL success = [self openDatabaseWithName:_dataBaseName];
        if (!success) {
            NSLog(@"数据库已经不存并且在尝试重新创建时失败导致无法插入数据。数据库路径：%@",_dataBasePath);
            return;
        }
       success = [self creatSqliteTable:tableName andFields:fields];
        if (!success) {
            NSLog(@"尝试重新创建表单失败导致无法插入数据。数据库路径：%@",_dataBasePath);
            return;
        }
    }
    [self insetSqliteTable:tableName andFields:fields andValues:valuesArr];
}
//清空表数据
-(void)clearDataWithTable:(NSString *)tableName
{
//    NSArray *fields = _tableNameDic[tableName];
    [self delectedSqliteTable:tableName andWhere:nil];
}

// 查找数据
-(NSArray *)selectedSqliteTable:(NSString *)tableName  andWhere:(NSDictionary *)whereDic{
    NSArray *resultArr = nil;
    NSArray *fields = _tablesFieldsDic[tableName];
    resultArr = [self selectedSqliteTable:tableName andFieldsArr:nil andBaseFieldsArr:fields andWhere:whereDic];
    return resultArr;
}
@end

@implementation LWSqliteTableTool
{
    NSString *_tableName;
}

-(instancetype)initWithDataBaseName:(NSString *)dataBaseName tableName:(NSString *)tableName charFields:(NSArray *)charFieldsArr
{
    self = [super initWithDataBaseName:dataBaseName];
    if (self) {
        _tableName = tableName;
      BOOL result = [self creatSqliteTableWithCharFields:charFieldsArr];
        if (!result) {
            return  nil;
        }
    }
    return self;
}
-(BOOL)creatSqliteTableWithCharFields:(NSArray *)charFieldsArr
{
  return   [self creatSqliteTable:_tableName andCharFields:charFieldsArr];
}

//插入数据
-(void)insetSqliteValues:(NSArray *)valuesArr
{
    [self insetSqliteTable:_tableName andValues:valuesArr];
}
//清空表数据
-(void)clearData
{
    [self clearDataWithTable:_tableName];
}

// 查找数据
-(NSArray *)selectedSqliteWhere:(NSDictionary *)whereDic
{
    NSArray *resultArr = [self selectedSqliteTable:_tableName andWhere:whereDic];
    return resultArr;
}
@end
