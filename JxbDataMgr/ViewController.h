//
//  ViewController.h
//  JxbDataMgr
//
//  Created by Peter on 15/5/28.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxbDataMgr.h"

@interface TestModel : JxbDataModel
@property(nonatomic,copy)NSString* test1;
@property(nonatomic,copy)NSString* test2;
@property(nonatomic,copy)NSString* test3;
@end

@interface ViewController : UIViewController


@end

