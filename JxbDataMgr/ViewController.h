//
//  ViewController.h
//  JxbDataMgr
//
//  Created by Peter on https://github.com/JxbSir 15/5/28.
//  Copyright (c) 2015年 Peter Jin   Mail:i@Jxb.name    All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxbDataMgr.h"

@interface TestModel : JxbDataModel
@property(nonatomic,copy)NSString* name;
@property(nonatomic,copy)NSString* nick;
@property(nonatomic,copy)NSString* qq;
@end

@interface ViewController : UIViewController


@end

