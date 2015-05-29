# JxbDataMgr
本地小数据存储，使用json字符串保存数据，使用方便简单

#支持CocoaPods引入
`pod 'JxbDataMgr'`

##调用接口
``` object-c
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
- (void)insertOrUpdateData:(NSString*)tableName PrimaryKey:(NSString*)primaryKey arrItems:(NSArray*)arrItems block:(id)block;

/**
 *  查询数据（通过主键）
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *  @param block        结果回调
 *
 *  @return
 */
- (void)queryData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(id)block;

/**
 *  查询数据（自定义字段）
 *
 *  @param tableName  表名
 *  @param conditions 条件（JxbQueryCondition的数组）
 *  @param block      回调
 */
- (void)queryDataExt:(NSString*)tableName conditions:(NSArray*)conditions block:(id)block;

/**
 *  删除数据
 *
 *  @param tableName    表名
 *  @param PrimaryValue 主键value
 *  @param block        结果回调
 *
 *  @return
 */
- (void)deleteData:(NSString*)tableName PrimaryValue:(NSString*)PrimaryValue block:(id)block;

/**
 *  清空数据
 *
 *  @param tableName    表名
 *  @param block        结果回调
 *
 *  @return
 */
- (void)dropData:(NSString*)tableName block:(id)block;
```
