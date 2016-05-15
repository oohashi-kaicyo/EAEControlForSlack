//
//  Observer.h
//  Hackason
//
//  Created by oohashi on 2015/07/08.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface Observer : NSObject <CLLocationManagerDelegate, NSURLSessionDelegate>

@property(nonatomic) CLLocationManager *observer;
@property(nonatomic) CLBeaconRegion    *searchBeaconRegion;

- (id)initWith: (CLBeaconRegion *)searchBeaconRegion;
- (void)startMonitoringRegion;
- (void)stopMonitoringRegion;

+ (Observer *)SharedManager;

@end
