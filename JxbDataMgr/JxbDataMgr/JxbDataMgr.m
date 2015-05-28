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

//TODO:通过随意字段查询

typedef enum {
    JxbDataOpType_InsertUpdate,
    JxbDataOpType_Query,
    JxbDataOpType_Delete,
    JxbDataOpType_Drop
}JxbDataOpType;

typedef void (^JxbDataOpBlock) (NSObject* result);
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


@interface JxbDataMgrOperation : NSOperation
@property(nonatomic,assign)JxbDataOpType   opType;
@property(nonatomic,assign)JxbDataOpBlock  block;
@property(nonatomic,copy)NSArray*   arrUpdateData;
@property(nonatomic,copy)NSString*  tableName;
@property(nonatomic,copy)NSString*  primaryKey;
@property(nonatomic,copy)NSString*  primaryValue;
@end

@implementation JxbDataMgrOperation

- (void)main {
    switch (_opType) {
        case JxbDataOpType_Query:
            [self _queryData];
            break;
        case JxbDataOpType_InsertUpdate:
            [self _updateData];
            break;
        case JxbDataOpType_Delete:
            [self _deleteData];
            break;
        case JxbDataOpType_Drop:
            [self _dropData];
            break;
        default:
            break;
    }
    
}

/**
 *  查询线程
 */
- (void)_queryData {
    NSMutableDictionary* dicTables = [USERDEFAULT objectForKey:dbName];
    NSString* strDataJson = [dicTables objectForKey:_tableName];
    NSError* error = nil;
    NSMutableDictionary* dicData = strDataJson ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        if(_block != NULL)
            _block(nil);
    }
    if (!dicData)
        if(_block != NULL)
            _block(nil);
    if (_primaryValue && _primaryValue.length > 0)
    {
        dicData = [dicData objectForKey:_primaryValue];
        if(_block != NULL)
            _block(@{@"result":dicData});
    }
    if(_block != NULL)
        _block(@{@"result":[dicData allValues]});
}

/**
 *  更新线程
 */
- (void)_updateData {
    NSMutableDictionary* dicTables = [USERDEFAULT objectForKey:dbName];
    NSString* strDataJson = [dicTables objectForKey:_tableName];
    NSError* error = nil;
    NSMutableDictionary* dicData = strDataJson ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        if(_block != NULL)
            _block([NSNumber numberWithBool:NO]);
    }
    if(!dicData)
        dicData = [NSMutableDictionary dictionary];
    for (NSObject* obj in _arrUpdateData) {
        Jastor* jastor = (Jastor*)obj;
        if(![jastor respondsToSelector:@selector(toDictionary)])
            continue;
        
        NSDictionary* dic = [jastor toDictionary];
        SEL getMethod = NSSelectorFromString(_primaryKey);
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
        if(_block != NULL)
            _block([NSNumber numberWithBool:NO]);
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(!dicTables)
        dicTables = [NSMutableDictionary dictionary];
    [dicTables setObject:jsonString forKey:_tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    if(_block != NULL)
        _block([NSNumber numberWithBool:YES]);
}

- (void)_deleteData {
    NSMutableDictionary* dicTables = [USERDEFAULT objectForKey:dbName];
    NSString* strDataJson = [dicTables objectForKey:_tableName];
    NSError* error = nil;
    NSMutableDictionary* dicData = strDataJson ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        if(_block != NULL)
            _block([NSNumber numberWithBool:NO]);
    }
    if (!dicData)
        if(_block != NULL)
            _block([NSNumber numberWithBool:YES]);
    [dicData removeObjectForKey:_primaryValue];
    error = nil;
    NSData* jsonData = [[CJSONSerializer serializer] serializeObject:dicData error:&error];
    if(error)
    {
        NSLog(@"JxbDataMgr serializer error:%@",error);
        if(_block != NULL)
            _block([NSNumber numberWithBool:NO]);
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(!dicTables)
        dicTables = [NSMutableDictionary dictionary];
    [dicTables setObject:jsonString forKey:_tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    if(_block != NULL)
        _block([NSNumber numberWithBool:YES]);
}

/**
 *  清空数据
 */
- (void)_dropData {
    NSMutableDictionary* dicTables = [USERDEFAULT objectForKey:dbName];
    [dicTables setObject:@"" forKey:_tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    if(_block != NULL)
        _block([NSNumber numberWithBool:YES]);
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

- (id)init {
    self = [super init];
    if (self)
    {
        opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

/**
 *  查询数据（通过主键）
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return 数据列表
 */
- (void)queryData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(id)block {
    JxbDataMgrOperation* op = [[JxbDataMgrOperation alloc] init];
    op.opType = JxbDataOpType_Query;
    op.tableName = tableName;
    op.primaryValue = PrimaryValue;
    op.block = block;
    [opQueue addOperation:op];
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
- (void)insertOrUpdateData:(NSString*)tableName PrimaryKey:(NSString*)primaryKey arrItems:(NSArray*)arrItems block:(id)block {
    JxbDataMgrOperation* op = [[JxbDataMgrOperation alloc] init];
    op.opType = JxbDataOpType_InsertUpdate;
    op.tableName = tableName;
    op.primaryKey = primaryKey;
    op.arrUpdateData = arrItems;
    op.block = block;
    [opQueue addOperation:op];
}

/**
 *  删除数据
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return 是否成功
 */
- (void)deleteData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(id)block {
    JxbDataMgrOperation* op = [[JxbDataMgrOperation alloc] init];
    op.opType = JxbDataOpType_Delete;
    op.tableName = tableName;
    op.primaryValue = PrimaryValue;
    op.block = block;
    [opQueue addOperation:op];
    
    
    
}

/**
 *  清空数据
 *
 *  @param tableName    表名
 *
 *  @return 是否成功
 */
- (void)dropData:(NSString*)tableName block:(id)block {
    JxbDataMgrOperation* op = [[JxbDataMgrOperation alloc] init];
    op.opType = JxbDataOpType_Drop;
    op.tableName = tableName;
    op.block = block;
    [opQueue addOperation:op];
}


@end
