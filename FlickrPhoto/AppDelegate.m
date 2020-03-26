//
//  AppDelegate.m
//  FlickrPhoto
//
//  Created by cch on 2020/3/13.
//  Copyright © 2020 cch. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrKit.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *apiKey = @"8e089660c705c1448d0b0c6865e3cbf0";
    NSString *secret = @"d70d119518f553d4";

    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:apiKey sharedSecret:secret];
    return YES;
}
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *scheme = [url scheme];
    if([@"flickrkitdemo" isEqualToString:scheme]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserAuthCallbackNotification" object:url userInfo:nil];
    }
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
