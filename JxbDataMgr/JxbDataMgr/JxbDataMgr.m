//
//  JxbDataMgr.m
//  JxbDataMgr
//
//  Created by Peter on https://github.com/JxbSir 15/5/28.
//  Copyright (c) 2015年 Peter Jin   Mail:i@Jxb.name    All rights reserved.
//


#import "JxbDataMgr.h"

#define dbName      @"JxbDataMgr"
#define USERDEFAULT [NSUserDefaults standardUserDefaults]

typedef enum {
    JxbDataOpType_InsertUpdate,
    JxbDataOpType_Query,
    JxbDataOpType_QueryExt,
    JxbDataOpType_Delete,
    JxbDataOpType_Drop
}JxbDataOpType;

static Class rClass;

#pragma mark - JxbDataModel
@implementation JxbDataModel
@end

#pragma mark - JxbQueryResult
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

#pragma mark - JxbQueryCondition
@implementation JxbQueryCondition

@end


#pragma mark - JxbDataMgrOperation
@interface JxbDataMgrOperation : NSOperation
@property(nonatomic,assign)JxbDataOpType   opType;
@property(nonatomic,strong)JxbDataOpBlock  block;
@property(nonatomic,copy)NSArray*   arrUpdateData;
@property(nonatomic,copy)NSArray*   arrConditions;
@property(nonatomic,copy)NSString*  tableName;
@property(nonatomic,copy)NSString*  primaryKey;
@property(nonatomic,copy)NSString*  primaryValue;
@end

@implementation JxbDataMgrOperation

/**
 *  queue main执行函数
 */
- (void)main {
    switch (_opType) {
        case JxbDataOpType_Query:
            [self _queryData];
            break;
        case JxbDataOpType_QueryExt:
            [self _queryDataExt];
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
    if(!strDataJson || strDataJson.length == 0)
    {
        [self useBlock:nil];
        return;
    }
    NSError* error = nil;
    NSMutableDictionary* dicData = (strDataJson && strDataJson.length > 0)  ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        [self useBlock:nil];
        return;
    }
    if (!dicData || dicData.count == 0)
    {
        [self useBlock:nil];
        return;
    }
    if (_primaryValue && _primaryValue.length > 0)
    {
        dicData = [dicData objectForKey:_primaryValue];
        if(!dicData)
        {
            [self useBlock:nil];
            return;
        }
        [self useBlock:@{@"result":dicData}];
        return;
    }
    [self useBlock:@{@"result":[dicData allValues]}];
}

/**
 *  自定义查询线程
 */
- (void)_queryDataExt {
    NSMutableDictionary* dicTables = [[USERDEFAULT objectForKey:dbName] mutableCopy];
    NSString* strDataJson = [dicTables objectForKey:_tableName];
    if(!strDataJson || strDataJson.length == 0)
    {
        [self useBlock:nil];
        return;
    }
    NSError* error = nil;
    NSMutableDictionary* dicData = (strDataJson && strDataJson.length > 0)  ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        [self useBlock:nil];
        return;
    }
    if (!dicData)
    {
        [self useBlock:nil];
        return;
    }
    
    NSMutableArray* arrResult = [NSMutableArray array];
    for (NSDictionary* item in [dicData allValues]) {
        BOOL bBelong = YES;
        for (JxbQueryCondition* condition in _arrConditions) {
            switch (condition.queryType) {
                case JxbDataQueryType_Equal:
                    if(![[item objectForKey:condition.fieldName] isEqualToString:condition.valueEqual])
                        bBelong = NO;
                    break;
                case JxbDataQueryType_MoreThan:
                    if(![[item objectForKey:condition.fieldName] doubleValue] > [condition.valueMorethan doubleValue])
                        bBelong = NO;
                    break;
                case JxbDataQueryType_LessThan:
                    if(![[item objectForKey:condition.fieldName] doubleValue] < [condition.valueLessthan doubleValue])
                        bBelong = NO;
                    break;
                case JxbDataQueryType_Section:
                    if([[item objectForKey:condition.fieldName] doubleValue] < [condition.valueLessthan doubleValue] || [[item objectForKey:condition.fieldName] doubleValue] > [condition.valueMorethan doubleValue])
                        bBelong = NO;
                    break;
                default:
                    break;
            }
            if(!bBelong)
                break;
        }
        if(bBelong)
            [arrResult addObject:item];
    }
    [self useBlock:@{@"result":arrResult}];
}

/**
 *  更新线程
 */
- (void)_updateData {
    NSMutableDictionary* dicTables = [[USERDEFAULT objectForKey:dbName] mutableCopy];
    NSString* strDataJson = [dicTables objectForKey:_tableName];
    NSError* error = nil;
    NSMutableDictionary* dicData = (strDataJson && strDataJson.length > 0) ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        [self useBlock:[NSNumber numberWithBool:NO]];
        return;
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
        [self useBlock:[NSNumber numberWithBool:NO]];
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(!dicTables)
        dicTables = [NSMutableDictionary dictionary];
    [dicTables setObject:jsonString forKey:_tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    [self useBlock:[NSNumber numberWithBool:YES]];
}

- (void)_deleteData {
    NSMutableDictionary* dicTables = [[USERDEFAULT objectForKey:dbName] mutableCopy];
    NSString* strDataJson = [dicTables objectForKey:_tableName];
    NSError* error = nil;
    NSMutableDictionary* dicData = (strDataJson && strDataJson.length > 0)  ? [NSMutableDictionary dictionaryWithDictionary:[[CJSONDeserializer deserializer] deserialize:[strDataJson dataUsingEncoding:NSUTF8StringEncoding] error:&error]] : nil;
    if(error)
    {
        NSLog(@"JxbDataMgr deserializer error:%@",error);
        [self useBlock:[NSNumber numberWithBool:NO]];
        return;
    }
    if (!dicData)
    {
        [self useBlock:[NSNumber numberWithBool:YES]];
        return;
    }
    [dicData removeObjectForKey:_primaryValue];
    error = nil;
    NSData* jsonData = [[CJSONSerializer serializer] serializeObject:dicData error:&error];
    if(error)
    {
        NSLog(@"JxbDataMgr serializer error:%@",error);
        [self useBlock:[NSNumber numberWithBool:NO]];
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(!dicTables)
        dicTables = [NSMutableDictionary dictionary];
    [dicTables setObject:jsonString forKey:_tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    [self useBlock:[NSNumber numberWithBool:YES]];
}

/**
 *  清空数据
 */
- (void)_dropData {
    NSMutableDictionary* dicTables = [[USERDEFAULT objectForKey:dbName] mutableCopy];
    [dicTables setObject:@"" forKey:_tableName];
    [USERDEFAULT setObject:dicTables forKey:dbName];
    [USERDEFAULT synchronize];
    [self useBlock:[NSNumber numberWithBool:YES]];
}


- (void)useBlock:(NSObject*)obj {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_block != NULL)
            _block(obj);
    });
}
@end

#pragma mark - JxbDataMgr
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

#pragma mark - db operation
/**
 *  查询数据（通过主键）
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *
 *  @return
 */
- (void)queryData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(JxbDataOpBlock)block {
    JxbDataMgrOperation* op = [[JxbDataMgrOperation alloc] init];
    op.opType = JxbDataOpType_Query;
    op.tableName = tableName;
    op.primaryValue = PrimaryValue;
    op.block = block;
    [opQueue addOperation:op];
}

/**
 *  查询数据（自定义字段）
 *
 *  @param tableName  表名
 *  @param conditions 条件（JxbQueryCondition的数组）
 *  @param block      回调
 */
- (void)queryDataExt:(NSString*)tableName conditions:(NSArray*)conditions block:(JxbDataOpBlock)block {
    JxbDataMgrOperation* op = [[JxbDataMgrOperation alloc] init];
    op.opType = JxbDataOpType_QueryExt;
    op.tableName = tableName;
    op.arrConditions = conditions;
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
 *  @return
 */
- (void)insertOrUpdateData:(NSString*)tableName PrimaryKey:(NSString*)primaryKey arrItems:(NSArray*)arrItems block:(JxbDataOpBlock)block {
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
 *  @return
 */
- (void)deleteData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(JxbDataOpBlock)block {
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
 *  @return
 */
- (void)dropData:(NSString*)tableName block:(JxbDataOpBlock)block {
    JxbDataMgrOperation* op = [[JxbDataMgrOperation alloc] init];
    op.opType = JxbDataOpType_Drop;
    op.tableName = tableName;
    op.block = block;
    [opQueue addOperation:op];
}


@end
