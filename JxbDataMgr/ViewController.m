//
//  ViewController.m
//  JxbDataMgr
//
//  Created by Peter on https://github.com/JxbSir 15/5/28.
//  Copyright (c) 2015年 Peter Jin   Mail:i@Jxb.name    All rights reserved.
//

#import "ViewController.h"

@implementation TestModel

@end

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView  *tbView;
@property(nonatomic,strong)NSMutableArray   *arrData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tbView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tbView.backgroundColor = self.view.backgroundColor;
    _tbView.delegate = self;
    _tbView.dataSource = self;
    _tbView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tbView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tbView];
    
//   [[JxbDataMgr sharedInstance] dropData:@"testmodel" block:nil];
    [self loadAll];
}

- (void)loadAll
{
    [[JxbDataMgr sharedInstance] queryData:@"testmodel" PrimaryValue:nil block:^(NSObject* result){
        JxbQueryResult* r = [[JxbQueryResult alloc] initWithClassDictionary:[TestModel class] dictionary:(NSDictionary*)result];
        _arrData = [NSMutableArray arrayWithArray:r.result];
        [_tbView reloadData];
        NSLog(@"loadall");
    }];
}

- (void)initData
{
    TestModel* model = [[TestModel alloc] init];
    model.name = @"小王";
    model.nick = @"小王子";
    model.qq = @"12345678";

    TestModel* model2 = [[TestModel alloc] init];
    model2.name = @"（¯﹃¯）口水";
    model2.nick = @"∫科士威";
    model2.qq = @"12412412";

    TestModel* model3 = [[TestModel alloc] init];
    model3.name = @"库克";
    model3.nick = @"匠匠";
    model3.qq = @"124124123";

    __weak typeof (self) wSelf = self;
    [[JxbDataMgr sharedInstance] insertOrUpdateData:@"testmodel" PrimaryKey:@"name" arrItems:@[model,model2,model3] block:^(NSObject* result){
        if([(NSNumber*)result boolValue])
        {
            NSLog(@"init data success");
            [wSelf loadAll];
        }
        else
        {
            NSLog(@"init data error");
        }
    }];
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrData.count > 0 ? _arrData.count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, self.view.frame.size.width - 40, 40)];
    [btn setTitle:@"Init Data" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(initData) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5;
    [vFooter addSubview:btn];
    
    return vFooter;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    if(_arrData.count > 0)
    {
        TestModel* model = [_arrData objectAtIndex:indexPath.row];
        NSString* str = [NSString stringWithFormat:@"name:%@,nick:%@,qq:%@",model.name,model.nick,model.qq];
        cell.textLabel.text = str;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        cell.textLabel.text = @"无记录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _arrData.count > 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        __weak typeof (self) wSelf = self;
        TestModel* model = [_arrData objectAtIndex:indexPath.row];
        [[JxbDataMgr sharedInstance] deleteData:@"testmodel" PrimaryValue:model.name block:^(NSObject* result){
            if([(NSNumber*)result boolValue])
            {
                NSLog(@"delete data success");
                [wSelf loadAll];
            }
            else
            {
                NSLog(@"delete data error");
            }
        }];
    }
}
@end
