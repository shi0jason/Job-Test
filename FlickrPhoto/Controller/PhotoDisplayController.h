//
//  PhotoDisplayController.h
//  FlickrPhoto
//
//  Created by cch on 2020/3/13.
//  Copyright © 2020 cch. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoDisplayController : UIViewController

@end

@protocol PhotoDisplayControllerCellDelegate;

@interface PhotoDisplayControllerCell : UICollectionViewCell

@property (nonatomic, assign) id<PhotoDisplayControllerCellDelegate> cdelegate;
@property (nonatomic, strong) UIImageView *displayImage;
@property (nonatomic, strong) UILabel *itemName;
@property (nonatomic, strong) UIButton *favoriteButton;

@end

@protocol PhotoDisplayControllerCellDelegate <NSObject>

- (void)cellClick:(PhotoDisplayControllerCell *)cell;

@end

NS_ASSUME_NONNULL_END
