//
//  ViewController.m
//  IOSMysqlDemo
//
//  Created by liyifang on 2017/9/5.
//  Copyright © 2017年 liyifang. All rights reserved.
//

#import "ViewController.h"
#import "LWSqliteManager.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)LWSqliteTableTool *sqliteTableTool;
@property(nonatomic, strong)UILabel *resultLable;
@end
static  NSString *dataBaseName = @"testDataBase";
static  NSString *tableName = @"testTable";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"databse======%@",self.sqliteTableTool.dataBasePath);
    [self addSubViews];
}


#pragma mark  - 懒加载 ------


-(LWSqliteTableTool *)sqliteTableTool
{
    if (!_sqliteTableTool) {
        _sqliteTableTool = [[LWSqliteTableTool alloc]initWithDataBaseName:dataBaseName tableName:tableName charFields:@[@"row",@"test1",@"test2",@"test3",@"test4"]];//创建表单
    }
    return _sqliteTableTool;
}

#pragma  mark  --------- 插入  -----------
-(void)insertData
{
     NSArray *resultArr = [self.sqliteTableTool selectedSqliteWhere:nil];
    NSString *rowString = [NSString stringWithFormat:@"row%ld",((unsigned long)resultArr.count+1)];
     [self.sqliteTableTool insetSqliteValues:@[rowString,@"value1",@"value2",@"value3",@"value4"]];
}

#pragma  mark  --------- 查询 -----------
-(void)selectedAllData//查所有数据
{
    NSArray *resultArr = [self.sqliteTableTool selectedSqliteWhere:nil];
    NSLog(@"resultArr===%@",resultArr);
    NSString *resultStr = [NSString stringWithFormat:@"%@",resultArr];
    _resultLable.text = resultStr;
}

-(void)selectedLastData//查最后一条数据
{
    NSArray *dataArr = [self.sqliteTableTool selectedSqliteWhere:nil];
    NSString *rowString = [NSString stringWithFormat:@"row%ld",((unsigned long)dataArr.count)];
    NSDictionary *dic = @{@"row":rowString};//key:字段名 value:字段对应的值
    NSArray *resultArr = [self.sqliteTableTool selectedSqliteWhere:dic];
    NSLog(@"resultArr===%@",resultArr);
    NSString *resultStr = [NSString stringWithFormat:@"%@",resultArr];
    _resultLable.text = resultStr;
}

-(void)clearData
{
    [self.sqliteTableTool clearData];
}

-(void)removeDataBaseFile
{
    [self.sqliteTableTool removeDataBase];
}
#pragma mark ----------- tableView -----------------

//添加子视图
-(void)addSubViews
{
    
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    //设置代理
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    
    _resultLable = [[UILabel alloc]initWithFrame:self.view.bounds];
    _resultLable.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _resultLable.numberOfLines = 0;
    _tableView.tableFooterView = _resultLable;
}
//UITableViewDelegate, UITableViewDataSource
//section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionNum = 1;
    return sectionNum;
}
//row数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNum = 5;
   
    return rowNum;
}
//tableViewCell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    NSString *title = @"";
    switch (indexPath.row) {
        case 0:
            title = @"插入数据";
            break;
        case 1:
             title = @"查询所有数据";
            break;
        case 2:
              title = @"查询最后一条数据";
            break;
        case 3:
            title = @"清空表单数据";
            break;
        case 4:
            title = @"删除数据库";
            break;
        default:
            break;
    }
    cell.textLabel.text = title;
    return  cell;
}
//row高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 40;
    return rowHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self insertData];// @"插入数据";
            break;
        case 1:
            [self selectedAllData]; //@"查询所有数据";
            break;
        case 2:
            [self selectedLastData];//@"查询最后一条数据";
            break;
        case 3:
            [self clearData]; // @"清空表单数据";
            break;
        case 4:
            [self removeDataBaseFile]; // @"删除数据库";
            break;
       
        default:
            break;
    }

}

@end
