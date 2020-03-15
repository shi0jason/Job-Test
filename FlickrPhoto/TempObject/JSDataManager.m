//
//  JSDataManager.m
//  FlickrPhoto
//
//  Created by cch on 2020/3/13.
//  Copyright © 2020 cch. All rights reserved.
//

#import "JSDataManager.h"

@implementation JSDataManager

+ (JSDataManager *)shareInstance {
    static JSDataManager *_jSDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _jSDataManager = [[self alloc] init];
    });
    return _jSDataManager;
}

@end
