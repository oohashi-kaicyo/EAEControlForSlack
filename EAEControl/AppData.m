//
//  AppData.m
//  EAEControl
//
//  Created by oohashi on 2015/08/03.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//

#import "AppData.h"

@implementation AppData
{
    
}

static AppData* sharedAppData = nil;

+ (AppData *)SharedManager
{
    FUNC();
    @synchronized(self) {
        if(sharedAppData == nil) {
            sharedAppData = [[self alloc] init];
        }
    }
    return sharedAppData;
}

- (AppData *)init
{
    FUNC();
    self.userData = [UserData new];
    return self;
}
@end
