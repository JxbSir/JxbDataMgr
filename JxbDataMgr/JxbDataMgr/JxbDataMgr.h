//
//  JxbDataMgr.h
//  JxbDataMgr
//
//  Created by Peter on 15/5/28.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JxbDataModel : Jastor
@end

@interface JxbQueryResult : Jastor
@property(nonatomic,strong)NSArray* result;
- (id)initWithClassDictionary:(Class)c dictionary:(NSDictionary *)dictionary;
@end

@interface JxbDataMgr : NSObject

/**
 *  初始化单例
 *
 *  @return self
 */
+ (instancetype)sharedInstance;

/**
 *  插入或者更新数据
 *
 *  @param tableName  表名
 *  @param primaryKey 主键（model的属性名称）
 *  @param arrItems   数据（model必须继承JxbDataModel）
 *
 *  @return 是否成功
 */
- (BOOL)insertOrUpdateData:(NSString*)tableName PrimaryKey:(NSString*)primaryKey arrItems:(NSArray*)arrItems;

/**
 *  查询数据（通过主键）
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return 数据列表
 */
- (NSDictionary*)queryData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue;

/**
 *  删除数据
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return 是否成功
 */
- (BOOL)deleteData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue;

/**
 *  清空数据
 *
 *  @param tableName    表名
 *
 *  @return 是否成功
 */
- (BOOL)dropData:(NSString*)tableName;
@end
