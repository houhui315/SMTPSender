//
//  fileModelTool.h
//  CheckWorkAttendance
//
//  Created by 蓝泰致铭        on 16/4/13.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fileModel.h"

@interface fileModelTool : NSObject

@property (nonatomic, strong) NSString *recordPlistPath;

@property (nonatomic, strong) NSString *inBoxDictionaryPath;

- (NSMutableArray*)loadFileListFromLocal;

- (void)addNewFileWithPath:(NSString*)filePath;

- (void)deleteFileModel:(fileModel*)fileModel;

- (void)changeFileModelStatusWithModel:(fileModel*)model;

@end
