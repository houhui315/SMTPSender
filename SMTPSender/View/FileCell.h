//
//  FileCell.h
//  CheckWorkAttendance
//
//  Created by 蓝泰致铭        on 16/4/13.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fileModel.h"

@interface FileCell : UITableViewCell

- (void)configForCellWithModel:(fileModel*)model;

@end
