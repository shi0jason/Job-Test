//
//  JSDataManager.h
//  FlickrPhoto
//
//  Created by cch on 2020/3/13.
//  Copyright © 2020 cch. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSDataManager : NSObject

+ (JSDataManager *)shareInstance;

@property (nonatomic, strong) NSString *searchItemName;
@property (nonatomic, retain) NSMutableArray *photoURLs;
@property (nonatomic, retain) NSMutableArray *photoTitles;
@end

NS_ASSUME_NONNULL_END
