//
//  PhotoTabViewController.h
//  
//
//  Created by cch on 2020/3/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PhotoTabViewControllerDelegate <NSObject>

- (void)tabbarClick;

@end

@interface PhotoTabViewController : UITabBarController

@property (nonatomic, assign) id<PhotoTabViewControllerDelegate> tabDelegate;

@end

NS_ASSUME_NONNULL_END
