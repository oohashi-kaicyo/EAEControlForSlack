//
//  Observer.m
//  Hackason
//
//  Created by oohashi on 2015/07/08.
//  Copyright (c) 2015年 Yasuhiro.Hashimoto. All rights reserved.
//

#import "Observer.h"
#import "ApiManager.h"

@implementation Observer
{
    
}

static Observer* sharedAppData = nil;

+ (Observer *)SharedManager
{
    FUNC();
    @synchronized(self) {
        if(sharedAppData == nil) {
            sharedAppData = [[self alloc] init];
        }
    }
    return sharedAppData;
}

- (Observer *)init
{
    FUNC();
    return [self initWith:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"00000000-48A4-1001-B000-001C4D175E4E"] identifier:@"observeDisplayRegion"]];
}

- (id)initWith: (CLBeaconRegion *)searchBeaconRegion
{
    FUNC();
    if(self = [super init]) {
        self.observer           = [CLLocationManager new];
        self.observer.delegate  = self;
        self.searchBeaconRegion = searchBeaconRegion;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    FUNC();
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"kCLAuthorizationStatusNotDetermined");
    } else if(status == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startMonitoringForRegion:  self.searchBeaconRegion];
        NSLog(@"startMonitoringForRegion");
    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
        [manager startMonitoringForRegion:  self.searchBeaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager
didStartMonitoringForRegion:(CLRegion *)region
{
    FUNC();
    [manager requestAlwaysAuthorization];
    [manager requestWhenInUseAuthorization];
    [manager requestStateForRegion:region];
}

-(void)locationManager:(CLLocationManager *)manager
     didDetermineState:(CLRegionState)state
             forRegion:(CLRegion *)region
{
    FUNC();
    switch (state) {
        case CLRegionStateInside: {
            [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
            {
                LOG(@"CLRegionStateInside");
                NSString *message = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                NSString *beforeState = [[NSUserDefaults standardUserDefaults] objectForKey:@"beforeState"];
                if (message && ([beforeState isEqual:@"exit"])) {
                    message = [message stringByAppendingString:@"は研究室にいます"];
                    [self postSlackAPIWithMessage:message];
                    [[NSUserDefaults standardUserDefaults] setObject:@"enter" forKey:@"beforeState"];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"enterDate"];
                }
            }
        } break;
        case CLRegionStateOutside: {
            LOG(@"CLRegionStateOutside");
            NSString *message     = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
            NSString *beforeState = [[NSUserDefaults standardUserDefaults] objectForKey:@"beforeState"];
            LOG(@"CLRegionStateOutside: %@", beforeState);
            if (message && ([beforeState isEqual:@"enter"])) {
                message = [message stringByAppendingString:@"は研究室にいません"];
                message = [message stringByAppendingString:[self occupancyTimeCalculation]];
                [self postSlackAPIWithMessage:message];
                [[NSUserDefaults standardUserDefaults] setObject:@"exit" forKey:@"beforeState"];
                [self occupancyTimeCalculation];
            }
        } break;
        case CLRegionStateUnknown: {
            LOG(@"CLRegionStateUnknown");
            NSString *message     = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
            NSString *beforeState = [[NSUserDefaults standardUserDefaults] objectForKey:@"beforeState"];
            if (message && ([beforeState isEqual:@"enter"])) {
                message = [message stringByAppendingString:@"は研究室にいません"];
                message = [message stringByAppendingString:[self occupancyTimeCalculation]];
                [self postSlackAPIWithMessage:message];
                [[NSUserDefaults standardUserDefaults] setObject:@"exit" forKey:@"beforeState"];
                [self occupancyTimeCalculation];
            }
        } break;
        default: {
            LOG(@"break");
        } break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    FUNC();
    [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    NSString *message = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *beforeState = [[NSUserDefaults standardUserDefaults] objectForKey:@"beforeState"];
    if (message && ([beforeState isEqual:@"exit"])) {
        message = [message stringByAppendingString:@"が研究室に入室しました"];
        [self postSlackAPIWithMessage:message];
        [[NSUserDefaults standardUserDefaults] setObject:@"enter" forKey:@"beforeState"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"enterDate"];
    }
}

-(NSString *)occupancyTimeCalculation
{
    FUNC();
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [now timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"enterDate"]];
    LOG(@"在室時間: %@",  [self convertFloatToTimeStringWith:delta]);
    return  [self convertFloatToTimeStringWith:delta];
}

-(NSString *)convertFloatToTimeStringWith: (float)delta
{
    FUNC();
    int time       = (int)delta;
    int secondTime = time % 60;
    int minutTime  = (time / 60) % 60;
    int hourTime   = (time / 60 / 60);
    NSString *occupancyTimeText = [NSString stringWithFormat:@"[在室時間: %.2d時間%.2d分%.2d秒]", hourTime, minutTime, secondTime];
    return occupancyTimeText;
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    FUNC();
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    LOG(@"didExitRegion");
    NSString *message     = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *beforeState = [[NSUserDefaults standardUserDefaults] objectForKey:@"beforeState"];
    if (message && ([beforeState isEqual:@"enter"])) {
        message = [message stringByAppendingString:@"が研究室から退室しました"];
        // message = [message stringByAppendingString:[self occupancyTimeCalculation]];
        [self postSlackAPIWithMessage:message];
        [[NSUserDefaults standardUserDefaults] setObject:@"exit" forKey:@"beforeState"];
        [self occupancyTimeCalculation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    FUNC();
    CLBeaconRegion *nearestBeacon = beacons.firstObject;
    LOG(@"nearestBeacon:major=%d, minor=%d", [nearestBeacon.major intValue], [nearestBeacon.minor intValue]);
}

- (void)startMonitoringRegion
{
    FUNC();
    [self.observer startMonitoringForRegion:self.searchBeaconRegion];
}

- (void)stopMonitoringRegion
{
    FUNC();
    [self.observer stopMonitoringForRegion:self.searchBeaconRegion];
}

-(void)postSlackAPIWithMessage:(NSString *)message
{
    FUNC();
    // please your slack api token here...
    NSString *slackApiKey = @"xoxp-XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXXX-XXXXXXXXXX";
    NSDateFormatter *outputFormatter = [NSDateFormatter new];
    [outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *strNow = [outputFormatter stringFromDate:[NSDate date]];
    message = [message stringByAppendingFormat:@"(%@)", strNow];
    
    NSString *text = message;
    LOG(@"%@", text);
    text = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)text,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8
                                                                                 )
                                         );
    NSString *url;
    // please your channel id here...
    url = [NSString stringWithFormat:@"https://slack.com/api/chat.postMessage?token=%@&channel=XXXXXXXX&text=%@&as_user=true", slackApiKey, text];
    LOG(@"%@", url);
    [self httpGetSessionWithURL:url];
}

-(void)httpGetSessionWithURL:(NSString *)url
{
    FUNC();
    NSString *identifier = @"backgroundTask";
    NSURLSessionConfiguration* configuration
    = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURL* requestURL = [NSURL URLWithString:url];
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:requestURL];
    [task resume];
    
    [session getTasksWithCompletionHandler:^(NSArray* dataTasks, NSArray* uploadTasks, NSArray* downloadTasks){
        NSLog(@"Currently suspended tasks");
        for (NSURLSessionDownloadTask* task in downloadTasks) {
            NSLog(@"Task: %@", [task description]);
        }
    }];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    FUNC();
    NSData* data = [NSData dataWithContentsOfURL:location];
    if (data.length == 0) {
        return;
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    LOG(@"dataString: %@", dataString);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    FUNC();
    if (error == nil) {
        LOG(@"Downloading is succeeded");
    } else {
        LOG(@"Downloading is failed: %@", error);
    }
}

@end
