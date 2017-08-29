#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class DBManager;
@protocol DBManagerDelegate <NSObject>
-(void)DBManager:(sqlite3_stmt*)statement;
@end
@interface DBManager : NSObject
//Reference of DBManager
@property (weak, nonatomic) id<DBManagerDelegate> delegate;
//Methods
- (instancetype)initWithFileName:(NSString *)dbFileName;
- (void)createTableForQuery:(NSString *)query;

- (void)dropTable:(NSString *)tableName;

- (void)saveDataToDBForQuery:(NSString *)query;

- (void)getDataForQuery:(NSString *)query;

- (void)deleteRowForQuery:(NSString *)query;

- (void)update:(NSString *)query;

- (int) getNumberOfRecord:(NSString *)query;

@end
