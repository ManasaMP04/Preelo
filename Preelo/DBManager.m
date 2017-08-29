#import "DBManager.h"

@implementation DBManager

{
    
    NSString *databasePath;
    
    sqlite3 *database;
    
}
//Initialize DBManager
- (id)initWithFileName:(NSString *)dbFileName

{
    if (self = [super init])
        
    {
        NSString *docsDir;
        
        NSArray *dirPaths;
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = dirPaths[0];
        
        databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:dbFileName]];
        NSLog(@"%@",dirPaths);
    }
    return self;
    
}
//Create DB
- (void)createTableForQuery:(NSString *)query

{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    const char *dbpath = [databasePath UTF8String];
    
    if (![filemgr fileExistsAtPath: databasePath ])
        
    {
        
        if (sqlite3_open(dbpath, &database)== SQLITE_OK)
            
        {
            sqlite3_close(database);
            
        }
    }
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        
    {
        char *errMsg;
        
        const char *sql_stmt = [query UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            
        {
            NSLog(@"Failed to create table");
            
        }
        
         NSLog(@"create table");
        sqlite3_close(database);
        
    }
    else {
        
        NSLog(@"Failed to open/create database");
        
    }
    
}
//Drop Table
- (void)dropTable:(NSString *)tableName

{
    const char *dbPath = [databasePath UTF8String];
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
        
    {
        NSString *deleQry = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
        
        const char *sqlStmt = [deleQry UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sqlStmt, -1, &statement, NULL) == SQLITE_OK)
            
        {
            if (sqlite3_step(statement) == SQLITE_DONE)
                
            {
                NSLog(@"Table %@ is droped", tableName);
                
            }else
                
            {
                NSLog(@"Table %@ is not able to dropped", tableName);
                
            }
            
        }else
            
        {
            NSLog(@"Statement for droping is failed to be prepared");
            
        }
        sqlite3_close(database);
        
    }
    
}
//Delete Row
- (void)deleteRowForQuery:(NSString *)query

{
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
        
    {
        const char *sqlStmt = [query UTF8String];
        
        sqlite3_stmt *statement;
        sqlite3_prepare_v2(database, sqlStmt, -1, & statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
            
        {
            
            NSLog(@"Deleted Sucessfully");
            
        } else
            
        {
            
            NSLog(@"Not Deleted");
            
        }
        
        sqlite3_finalize(statement);
        
        sqlite3_close(database);
        
    }
    
}
//Save Data into DB
- (void)saveDataToDBForQuery:(NSString *)query

{
    const char *dbPath = [databasePath UTF8String];
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
        
    {
        const char *insert_stmt = [query UTF8String];
        
        sqlite3_stmt *statement;
        
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
            
        {
            NSLog(@"saved Sucessfully");
        }
        else
            
        {
            NSLog(@"Not saved ");
            
        }
        sqlite3_finalize(statement);
        
        sqlite3_close(database);
        
    }
    
}
//Get Data from tableView
- (void)getDataForQuery:(NSString *)query

{
    
    const char *dbPath = [databasePath UTF8String];
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
        
    {
        const char *insert_stmt = [query UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL) == SQLITE_OK)
            
        {
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                [self.delegate DBManager:statement];
            }
            
            sqlite3_finalize(statement);
            
        }
        sqlite3_close(database);
        
    }else
        
    {
        NSLog(@"failed");
        
    }
}

- (int) getNumberOfRecord: (NSString *)query
{
    int count = 0;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        const char* sqlStatement = [query UTF8String];
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                count = sqlite3_column_int(statement, 0);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return count;
}
//Get Update column from tableView
- (void)update:(NSString *)query

{
    
    const char *dbPath = [databasePath UTF8String];
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
        
    {
        const char *updateQuery = [query UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, updateQuery, -1, &statement, NULL) == SQLITE_OK)
            
        {
            [self.delegate DBManager:statement];
            sqlite3_finalize(statement);
            
        }
        sqlite3_close(database);
        
    }else
        
    {
        NSLog(@"failed");
        
    }
}

@end
