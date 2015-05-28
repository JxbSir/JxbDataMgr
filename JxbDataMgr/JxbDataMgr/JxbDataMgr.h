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
{
    NSOperationQueue *opQueue;
}
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
- (void)insertOrUpdateData:(NSString*)tableName PrimaryKey:(NSString*)primaryKey arrItems:(NSArray*)arrItems block:(id)block;

/**
 *  查询数据（通过主键）
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return 数据列表
 */
- (void)queryData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(id)block;

/**
 *  删除数据
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return 是否成功
 */
- (void)deleteData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(id)block;

/**
 *  清空数据
 *
 *  @param tableName    表名
 *
 *  @return 是否成功
 */
- (void)dropData:(NSString*)tableName block:(id)block;
@end
