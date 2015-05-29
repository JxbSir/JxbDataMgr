//
//  JxbDataMgr.h
//  JxbDataMgr
//
//  Created by Peter on https://github.com/JxbSir 15/5/28.
//  Copyright (c) 2015年 Peter Jin   Mail:i@Jxb.name    All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"
#import "Jastor.h"


typedef void (^JxbDataOpBlock) (NSObject* result);

/**
 查询类别
 */
typedef enum {
    JxbDataQueryType_Equal,
    JxbDataQueryType_MoreThan,
    JxbDataQueryType_LessThan,
    JxbDataQueryType_Section
}JxbDataQueryType;

/**
 *  虚拟表类，insert or update 的model 需继承此类
 */
@interface JxbDataModel : Jastor
@end

/**
 *  查询结果类
 */
@interface JxbQueryResult : Jastor
@property(nonatomic,strong)NSArray* result;
- (id)initWithClassDictionary:(Class)c dictionary:(NSDictionary *)dictionary;
@end

/**
 *  查询条件设置
 */
@interface JxbQueryCondition : NSObject
@property(nonatomic,assign)JxbDataQueryType     queryType;
@property(nonatomic,copy)NSString               *fieldName;
@property(nonatomic,copy)NSString               *valueEqual;
@property(nonatomic,copy)NSString               *valueMorethan;
@property(nonatomic,copy)NSString               *valueLessthan;
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
 *  @param block      结果回调
 *
 *  @return
 */
- (void)insertOrUpdateData:(NSString*)tableName PrimaryKey:(NSString*)primaryKey arrItems:(NSArray*)arrItems block:(JxbDataOpBlock)block;

/**
 *  查询数据（通过主键）
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *  @param block        结果回调
 *
 *  @return
 */
- (void)queryData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(JxbDataOpBlock)block;

/**
 *  查询数据（自定义字段）
 *
 *  @param tableName  表名
 *  @param conditions 条件（JxbQueryCondition的数组）
 *  @param block      回调
 */
- (void)queryDataExt:(NSString*)tableName conditions:(NSArray*)conditions block:(JxbDataOpBlock)block;

/**
 *  删除数据
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *  @param block        结果回调
 *
 *  @return
 */
- (void)deleteData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(JxbDataOpBlock)block;

/**
 *  清空数据
 *
 *  @param tableName    表名
 *  @param block        结果回调
 *
 *  @return
 */
- (void)dropData:(NSString*)tableName block:(JxbDataOpBlock)block;
@end
