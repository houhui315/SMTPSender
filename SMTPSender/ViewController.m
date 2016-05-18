//
//  ViewController.m
//  SMTPSender
//
//  Created by 蓝泰致铭        on 16/4/21.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import "ViewController.h"
#import "SettingViewController.h"
#import "FileCell.h"
#import "fileModelTool.h"
#import "SendEmailTableViewController.h"

static NSString *sourceCellIdentifier = @"sourceCellIdentifier";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>{
    
}

@property (nonatomic, strong) UITableView *myTableView;

@property (nonatomic, strong) NSMutableArray *dataSource;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"邮件群发";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(showSettingVC)];
    
    [self initData];
    [self initUI];
    [self initNotificationServer];
    
    [self refershPage];
    
//    [self testData];
}

- (void)testData{
    
    fileModel *model = [fileModel new];
    model.fileName = @"helele";
    model.createTime = @"2016-09-09 12:00:27";
    model.fileSize = 10003;
    model.isRead = NO;
    model.isProcessCompleted = NO;
    
    [self.dataSource addObject:model];
    [self.myTableView reloadData];
}

- (void)showSettingVC {
    
    SettingViewController *viewController = [SettingViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)initNotificationServer{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refershPage) name:ADDEDFILENOTIFICATION object:nil];
}

- (void)refershPage{
    
    fileModelTool *tool = [fileModelTool new];
    self.dataSource = [NSMutableArray arrayWithArray:[tool loadFileListFromLocal]];
    [self.myTableView reloadData];
}


- (void)initUI{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tableView registerClass:[FileCell class] forCellReuseIdentifier:sourceCellIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableView];
    self.myTableView = tableView;
}

- (void)initData{
    
    NSMutableArray *dataAry = [NSMutableArray array];
    self.dataSource = dataAry;
}

- (void)removeDataWithIndex:(NSUInteger)index{
    
    //同步删除文件和记录
    fileModel *model = self.dataSource[index];
    fileModelTool *tool = [fileModelTool new];
    [tool deleteFileModel:model];
    
    [self.dataSource removeObjectAtIndex:index];
    [self.myTableView reloadData];
}


#pragma mark UITableViewDataSource && UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:sourceCellIdentifier forIndexPath:indexPath];
    fileModel *model = self.dataSource[indexPath.row];
    [cell configForCellWithModel:model];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //更新当前页状态
    fileModel *model = self.dataSource[indexPath.row];
    
    //如果状态为未读，则置为已读状态
    if (!model.isRead) {
        model.isRead = YES;
        [tableView reloadData];
        
        //保存状态
        fileModelTool *tool = [fileModelTool new];
        [tool changeFileModelStatusWithModel:model];
    }
    
    SendEmailTableViewController *viewController = [[SendEmailTableViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.model = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self removeDataWithIndex:indexPath.row];
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"删除";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
