//
//  UserData.h
//  EAEControl
//
//  Created by oohashi on 2015/08/03.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//

@interface UserData : NSObject

@property(nonatomic)NSUserDefaults *userInfo;

-(void)regiserUserName: (NSString *)userName;
-(void)removeUserName;
-(void)postRegiserUserName;
-(void)postRemoveUserName;

@end
