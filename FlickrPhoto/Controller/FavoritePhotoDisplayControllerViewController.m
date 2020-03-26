//
//  FavoritePhotoDisplayControllerViewController.m
//  FlickrPhoto
//
//  Created by cch on 2020/3/26.
//  Copyright © 2020 cch. All rights reserved.
//

#import "FavoritePhotoDisplayControllerViewController.h"
#import "PhotoDisplayController.h"
#import "JSDataManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FlickrKit.h"
@interface FavoritePhotoDisplayControllerViewController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *favoriteCollectView;

@end

@implementation FavoritePhotoDisplayControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self setupCollectionView];
}
- (void) setDataSource {
    [[FlickrKit sharedFlickrKit] call:@"flickr.favorites.getList" args:@{@"user_id": @"a", @"per_page": @"15"} maxCacheAge:FKDUMaxAgeOneHour completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response) {

            } else {

            }
        });
    }];
}
- (void) setupCollectionView {
    UICollectionViewFlowLayout *collectLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = (self.view.frame.size.width) / 2 ;
    collectLayout.itemSize = CGSizeMake(width, width);
    
    self.favoriteCollectView.pagingEnabled = true;
    self.favoriteCollectView.scrollEnabled = true;
    self.favoriteCollectView.delegate = self;
    self.favoriteCollectView.dataSource = self;
    self.favoriteCollectView.collectionViewLayout = collectLayout;
    [_favoriteCollectView registerClass:[PhotoDisplayControllerCell class] forCellWithReuseIdentifier:@"aCell"];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat itemunit = (self.view.frame.size.width) / 2;
    NSInteger page = roundf(self.favoriteCollectView.contentOffset.y / itemunit);
    NSLog(@"y = %.2f",self.favoriteCollectView.contentOffset.y);
    if (page == 0) {
        self.favoriteCollectView.contentOffset = CGPointMake(0 ,itemunit * ([JSDataManager shareInstance].photoFavoriteURLs.count / 2 - 3));
    } else if (page == [JSDataManager shareInstance].photoFavoriteURLs.count / 2 - 2){
        self.favoriteCollectView.contentOffset = CGPointMake(0, 0);
    }
}

#pragma mark - Collect Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [JSDataManager shareInstance].photoFavoriteURLs.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoDisplayControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"aCell" forIndexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.displayImage sd_setImageWithURL:[JSDataManager shareInstance].photoURLs[indexPath.row]
                                   placeholderImage:[UIImage imageNamed:@"photo.png"]
                                            options:SDWebImageRetryFailed|SDWebImageLowPriority
                                          completed:nil];
    });

    cell.itemName.text = [JSDataManager shareInstance].photoTitles[indexPath.row];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (self.view.frame.size.width - 10) / 2;
    CGFloat height = collectionView.frame.size.height / 3;
    return CGSizeMake(width, height);
}
@end
