//
//  LWSqliteManager.h
//  Persion
//
//  Created by liyifang on 2017/5/15.
//  Copyright © 2017年 段凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWSqliteManager : NSObject

@property(nonatomic, strong)NSMutableDictionary *dataBaseFilePaths;

+(instancetype)sharedSqliteManager;
//-(NSString *)createFilePath:(NSString *)fileName;
//创建打开数据库
-(BOOL)openDatabaseWithName:(NSString *)dataBaseName;
//创建表
//-(BOOL)creatSqliteTable:(NSString *)tableName andFields:(NSArray *)fieldsArr;//表名 字段 字段约束
//插入数据
-(void)insetSqliteTable:(NSString *)tableName andFields:(NSArray *)fieldsArr andValues:(NSArray *)valuesArr;
//更新数据
-(void)updateSqliteTable:(NSString *)tableName andFieldADValues:(NSDictionary *)fieldADValuesDic andWhere:(NSDictionary *)whereDic;
//删除数据
-(void)delectedSqliteTable:(NSString *)tableName andWhere:(NSDictionary *)whereDic;
// 查找数据
-(NSMutableArray *)selectedSqliteTable:(NSString *)tableName andFieldsArr:(NSArray *)fieldsArr andBaseFieldsArr:(NSArray *)baseFieldsArr andWhere:(NSDictionary *)whereDic;
//关闭
-(void)closeDatabase;
//移除数据库 
-(void)removeDataBaseWithName:(NSString *)dataBaseName;
#pragma mark - 二次封装

//创建表:表里的字段全部为 char
-(BOOL)creatSqliteTable:(NSString *)tableName andCharFields:(NSArray *)charFieldsArr;//表名 char类型的字段
@end

@interface LWSqliteDataBaseTool : LWSqliteManager
@property(nonatomic, strong)NSString *dataBasePath;
@property(nonatomic, strong)NSMutableDictionary *tablesFieldsDic;//key:表名value:表单里所有字段组成的数组
//移除数据库
-(void)removeDataBase;
//插入数据
-(void)insetSqliteTable:(NSString *)tableName andValues:(NSArray *)valuesArr;
//清空表数据
-(void)clearDataWithTable:(NSString *)tableName;

// 查找数据
-(NSMutableArray *)selectedSqliteTable:(NSString *)tableName  andWhere:(NSDictionary *)whereDic;
@end

@interface LWSqliteTableTool : LWSqliteDataBaseTool//单表 数据库中只需一个表单时使用
-(instancetype)initWithDataBaseName:(NSString *)dataBaseName tableName:(NSString *)tableName charFields:(NSArray *)charFieldsArr;

//创建表:表里的字段全部为 char
//-(BOOL)creatSqliteTableWithCharFields:(NSArray *)charFieldsArr;//表名 char类型的字段
//插入数据
-(void)insetSqliteValues:(NSArray *)valuesArr;
//清空表数据
-(void)clearData;

// 查找数据
-(NSMutableArray *)selectedSqliteWhere:(NSDictionary *)whereDic;
@end
