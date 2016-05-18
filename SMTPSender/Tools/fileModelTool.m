//
//  fileModelTool.m
//  CheckWorkAttendance
//
//  Created by 蓝泰致铭        on 16/4/13.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import "fileModelTool.h"

@implementation fileModelTool

- (instancetype)init{
    
    if (self = [super init]) {
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        self.recordPlistPath = [docPath stringByAppendingPathComponent:@"recordList.plist"];
        self.inBoxDictionaryPath = [docPath stringByAppendingPathComponent:@"Inbox"];
    }
    return self;
}

- (fileModel*)createFileModelFormFilePath:(NSString*)filePath{
    
    fileModel *model = [fileModel new];
    model.fileName = [filePath lastPathComponent];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    model.createTime = currentDateStr;
    model.fileSize = [self fileSizeAtPath:filePath];
    model.isRead = NO;
    
    return model;
}

- (fileModel*)createFileModelWithDictionary:(NSDictionary*)dict{
    
    fileModel *model = [fileModel new];
    model.fileName = dict[@"fileName"];
    model.fileSize = [dict[@"fileSize"] integerValue];
    model.createTime = dict[@"createTime"];
    model.isRead = [dict[@"IsRead"] boolValue];
    model.isProcessCompleted = [dict[@"IsProcessCompleted"] boolValue];
    model.totalNumber = [dict[@"TotalNumber"] unsignedIntegerValue];
    model.alreadySendArray = dict[@"alreadySend"];
    if (!model.alreadySendArray) {
        model.alreadySendArray = @"";
    }
    
    return model;
}

- (NSDictionary*)createDictFromFileModel:(fileModel*)model {
    
    NSDictionary *dict = @{@"fileName": model.fileName,@"createTime":model.createTime,@"fileSize":@(model.fileSize),@"IsRead":@(model.isRead),@"IsProcessCompleted":@(model.isProcessCompleted),@"TotalNumber":@(model.totalNumber),@"alreadySend":model.alreadySendArray};
    return dict;
}

- (long long)fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)addNewFileWithPath:(NSString*)filePath{
    
    fileModel *model = [self createFileModelFormFilePath:filePath];
    [self saveRecordWithModel:model];
}

- (void)notificationServer{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDEDFILENOTIFICATION object:nil];
}

- (NSMutableArray*)loadFileListFromLocal{
    
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:self.recordPlistPath];
    if (!array) {
        array = [NSMutableArray array];
    }
    NSMutableArray *modelArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < [array count]; i++) {
        
        NSDictionary *dic = array[i];
        if (dic) {
            
            fileModel *model = [self createFileModelWithDictionary:dic];
            [modelArray addObject:model];
        }
    }
    return modelArray;
}

- (void)savePlistWithModelArray:(NSMutableArray*)ary{
    
    NSMutableArray *dicArray = [NSMutableArray array];
    
    for (fileModel *model in ary) {
        
        NSDictionary *dict = [self createDictFromFileModel:model];
        [dicArray addObject:dict];
    }
    
    if ([dicArray writeToFile:self.recordPlistPath atomically:YES]) {
        
        NSLog(@"更新状态");
    }
}

- (void)saveRecordWithModel:(fileModel*)model{
    
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:self.recordPlistPath];
    if (!array) {
        array = [NSMutableArray array];
    }
    BOOL isFound = NO;
    NSInteger index = -1;
    for (NSUInteger i = 0; i < [array count]; i++) {
        
        NSDictionary *dict = array[i];
        if ([dict[@"fileName"] isEqualToString:model.fileName]) {
            
            isFound = YES;
            index = i;
            break;
        }
    }
    NSDictionary *dict = @{@"fileName": model.fileName,@"createTime":model.createTime,@"fileSize":@(model.fileSize),@"IsRead":@(model.isRead),@"IsProcessCompleted":@(model.isProcessCompleted),@"TotalNumber":@(model.totalNumber)};
    if (isFound) {
        
        [array replaceObjectAtIndex:index withObject:dict];
    }else{
        [array insertObject:dict atIndex:0];
    }
    [array writeToFile:self.recordPlistPath atomically:YES];
}

- (void)deleteFileWithDictionaryPath:(NSString*)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        [fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
    }
    [fileManager removeItemAtPath:path error:nil];
    
}

- (void)deleteFileModel:(fileModel*)fileModel{
    
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:self.recordPlistPath];
    if (!array) {
        array = [NSMutableArray array];
    }
    BOOL isFound = NO;
    NSInteger index = -1;
    for (NSUInteger i = 0; i < [array count]; i++) {
        
        NSDictionary *dict = array[i];
        if ([dict[@"fileName"] isEqualToString:fileModel.fileName]) {
            
            isFound = YES;
            index = i;
            break;
        }
    }
    if (isFound) {
        
        
        //删除原文件
        NSFileManager *manager = [NSFileManager defaultManager];
        
        NSString *inboxPath = [self.inBoxDictionaryPath stringByAppendingPathComponent:fileModel.fileName];
        [manager removeItemAtPath:inboxPath error:nil];
        
        //保存记录
        [array removeObjectAtIndex:index];
        [array writeToFile:self.recordPlistPath atomically:YES];
    }
}

- (void)changeFileModelStatusWithModel:(fileModel*)model{
    
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[self loadFileListFromLocal]];
    NSInteger index = -1;
    for (NSUInteger i = 0; i < [ary count]; i++) {
        
        fileModel *tModel = ary[i];
        if ([tModel.fileName isEqualToString:model.fileName]) {
            
            index = i;
            
            break;
        }
    }
    
    if (index >= 0) {
        
        [ary replaceObjectAtIndex:index withObject:model];
        
        [self savePlistWithModelArray:ary];
    }
}

@end
