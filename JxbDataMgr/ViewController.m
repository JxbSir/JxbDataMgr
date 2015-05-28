//
//  ViewController.m
//  JxbDataMgr
//
//  Created by Peter on 15/5/28.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "ViewController.h"

@implementation TestModel

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",NSHomeDirectory());
    
//    TestModel* model = [[TestModel alloc] init];
//    model.test1 = @"1";
//    model.test2 = @"2";
//    model.test3 = @"3";
//    
//    TestModel* model2 = [[TestModel alloc] init];
//    model2.test1 = @"4";
//    model2.test2 = @"5";
//    model2.test3 = @"6";
//    
//    TestModel* model3 = [[TestModel alloc] init];
//    model3.test1 = @"7";
//    model3.test2 = @"8";
//    model3.test3 = @"9";
//    
//    [[JxbDataMgr sharedInstance] insertOrUpdateData:@"testmodel" PrimaryKey:@"test1" arrItems:@[model,model2,model3] block:^(NSObject* result){
//        NSLog(@"%@",result);
//    }];
    
    [[JxbDataMgr sharedInstance] queryData:@"testmodel" PrimaryValue:@"" block:^(NSObject* result){
        JxbQueryResult* list = [[JxbQueryResult alloc] initWithClassDictionary:[TestModel class] dictionary:(NSDictionary*)result];
        NSLog(@"%@",list);
    }];
    
    //[[JxbDataMgr sharedInstance] deleteData:@"testmodel" PrimaryValue:@"7"];
}
@end
