//
//  JxbDataMgr.m
//  JxbDataMgr
//
//  Created by Peter on 15/5/28.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "JxbDataMgr.h"

#define dbName      @"JxbDataMgr"
#define USERDEFAULT [NSUserDefaults standardUserDefaults]

static Class rClass;

@implementation JxbDataModel
@end

@implementation JxbQueryResult
- (id)initWithClassDictionary:(Class)c dictionary:(NSDictionary *)dictionary
{
    rClass = c;
    return [super initWithDictionary:dictionary];
}

+(Class)result_class
{
    return rClass;
}
@end


@implementation JxbDataMgr

/**
 *  初始化单例
 *
 *  @return self
 */
+ (instancetype)sharedInstance {
    static JxbDataMgr* mgr = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        mgr = [[JxbDataMgr alloc] init];
    });
    return mgr;
}

/**
 *  查询数据（通过主键）
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return 数据列表
 */
- (NSDictionary*)queryData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue {
    NSMutableDictionary* dicTables = [USERDEFAULT objectForKey:dbName];
    NSString* strDataJson = [dicTables objectForKey:tableName];
    NSError* error = nil;
    NSMutableDictionary* dicData = strDataJson ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        return nil;
    }
    if (PrimaryValue && PrimaryValue.length > 0)
    {
        dicData = [dicData objectForKey:PrimaryValue];
        return @{@"result":dicData};
    }
    return @{@"result":[dicData allValues]};
}

/**
 *  插入或者更新数据
 *
 *  @param tableName  表名
 *  @param primaryKey 主键（model的属性名称）
 *  @param arrItems   数据（model必须继承JxbDataModel）
 *
 *  @return 是否成功
 */
- (BOOL)insertOrUpdateData:(NSString*)tableName PrimaryKey:(NSString*)primaryKey arrItems:(NSArray*)arrItems {
    NSMutableDictionary* dicTables = [USERDEFAULT objectForKey:dbName];
    NSString* strDataJson = [dicTables objectForKey:tableName];
    NSError* error = nil;
    NSMutableDictionary* dicData = strDataJson ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        return NO;
    }
    if(!dicData)
        dicData = [NSMutableDictionary dictionary];
    for (NSObject* obj in arrItems) {
        Jastor* jastor = (Jastor*)obj;
        if(![jastor respondsToSelector:@selector(toDictionary)])
            continue;
        
        NSDictionary* dic = [jastor toDictionary];
        SEL getMethod = NSSelectorFromString(primaryKey);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString* key = [obj performSelector:getMethod];
#pragma clang diagnostic pop
        [dicData setObject:dic forKey:key];
    }
    error = nil;
    NSData* jsonData = [[CJSONSerializer serializer] serializeObject:dicData error:&error];
    if(error)
    {
        NSLog(@"JxbDataMgr serializer error:%@",error);
        return NO;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(!dicTables)
        dicTables = [NSMutableDictionary dictionary];
    [dicTables setObject:jsonString forKey:tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    return YES;
}

/**
 *  删除数据
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return 是否成功
 */
- (BOOL)deleteData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue {
    NSMutableDictionary* dicTables = [USERDEFAULT objectForKey:dbName];
    NSString* strDataJson = [dicTables objectForKey:tableName];
    NSError* error = nil;
    NSMutableDictionary* dicData = strDataJson ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        return NO;
    }
    if (dicData)
        return YES;
    [dicData removeObjectForKey:PrimaryValue];
    error = nil;
    NSData* jsonData = [[CJSONSerializer serializer] serializeObject:dicData error:&error];
    if(error)
    {
        NSLog(@"JxbDataMgr serializer error:%@",error);
        return NO;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(!dicTables)
        dicTables = [NSMutableDictionary dictionary];
    [dicTables setObject:jsonString forKey:tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    return YES;
}

/**
 *  清空数据
 *
 *  @param tableName    表名
 *
 *  @return 是否成功
 */
- (BOOL)dropData:(NSString*)tableName {
    NSMutableDictionary* dicTables = [USERDEFAULT objectForKey:dbName];
    [dicTables setObject:@"" forKey:tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    return YES;
}

@end
