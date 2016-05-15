//
//  AppDelegate.m
//  EAEControl
//
//  Created by oohashi on 2015/08/03.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    Observer *observer;
}

@end

@implementation AppDelegate

-(id)init
{
    if (self = [super init]) {
        observer = [Observer SharedManager];
        [[NSUserDefaults standardUserDefaults] setObject:@"exit" forKey:@"beforeState"];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    FUNC();
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [observer startMonitoringRegion];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [observer startMonitoringRegion];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [observer startMonitoringRegion];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [observer startMonitoringRegion];
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    FUNC();
    [observer stopMonitoringRegion ];
    [observer startMonitoringRegion];
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
