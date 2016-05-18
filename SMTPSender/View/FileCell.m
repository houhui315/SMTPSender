//
//  FileCell.m
//  CheckWorkAttendance
//
//  Created by 蓝泰致铭        on 16/4/13.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import "FileCell.h"

@interface FileCell (){
    
}

@property (nonatomic, strong) UILabel *mFileNameLabel;
@property (nonatomic, strong) UILabel *mFileSizeLabel;
@property (nonatomic, strong) UILabel *mCreateTimeLabel;
@property (nonatomic, strong) UIImageView *mUnreadImageView;
@property (nonatomic, strong) UILabel *mCompletedLabel;

@end

@implementation FileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIImageView *unreadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 5, 5)];
    unreadImageView.backgroundColor = [UIColor blueColor];
    unreadImageView.layer.cornerRadius = 2;
    unreadImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:unreadImageView];
    self.mUnreadImageView = unreadImageView;
    unreadImageView.hidden = YES;
    
    UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, screenWidth - 20 - 100, 20)];
    fileNameLabel.font = [UIFont systemFontOfSize:16.f];
    [self.contentView addSubview:fileNameLabel];
    self.mFileNameLabel = fileNameLabel;
    
    UILabel *fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 80, 10, 80, 20)];
    fileSizeLabel.font = [UIFont systemFontOfSize:13.f];
    [self.contentView addSubview:fileSizeLabel];
    self.mFileSizeLabel = fileSizeLabel;
    
    UILabel *createTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 200, 20)];
    createTimeLabel.font = [UIFont systemFontOfSize:13.f];
    createTimeLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:createTimeLabel];
    self.mCreateTimeLabel = createTimeLabel;
    
    UILabel *compeletedLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 120, 40, 80, 20)];
    compeletedLabel.font = [UIFont systemFontOfSize:13.f];
    compeletedLabel.textColor = [UIColor blueColor];
    [self.contentView addSubview:compeletedLabel];
    self.mCompletedLabel = compeletedLabel;
}

- (void)configForCellWithModel:(fileModel*)model{
    
    self.mFileNameLabel.text = model.fileName;
    self.mFileSizeLabel.text = [NSString stringWithFormat:@"%lldKB",model.fileSize/1000];
    self.mCreateTimeLabel.text = model.createTime;
    self.mUnreadImageView.hidden = model.isRead;
    if (!model.isRead) {
        
        self.mCompletedLabel.hidden = YES;
    }else{
        self.mCompletedLabel.hidden = NO;
        if (model.isProcessCompleted) {
         
            self.mCompletedLabel.text = @"发送完成";
        }else{
            self.mCompletedLabel.text = @"发送未完成";
        }
    }
}

@end
