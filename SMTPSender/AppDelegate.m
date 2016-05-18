//
//  AppDelegate.m
//  SMTPSender
//
//  Created by 蓝泰致铭        on 16/4/21.
//  Copyright © 2016年 zhixueyun. All rights reserved.
//

#import "AppDelegate.h"
#import "fileModelTool.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation{
    
    return [self handelURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    
    return [self handelURL:url];
}

- (BOOL)handelURL:(NSURL*)url{
    
    if (![url.absoluteString.pathExtension isEqualToString:@"csv"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"仅支持导入csv格式文件" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:url error:nil];
        return NO;
    }
    
    fileModelTool *tool = [fileModelTool new];
    [tool addNewFileWithPath:url.relativePath];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDEDFILENOTIFICATION object:nil];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
