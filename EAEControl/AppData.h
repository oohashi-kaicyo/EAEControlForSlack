//
//  AppData.h
//  EAEControl
//
//  Created by oohashi on 2015/08/03.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//
#import "UserData.h"

@interface AppData : NSObject

@property(nonatomic)UserData *userData;

+ (AppData *)SharedManager;

@end
