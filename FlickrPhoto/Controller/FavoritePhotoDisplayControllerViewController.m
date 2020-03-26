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
#import "PhotoTabViewController.h"
#define kCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
@interface FavoritePhotoDisplayControllerViewController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PhotoTabViewControllerDelegate>{
    NSMutableArray *result;
}
@property (weak, nonatomic) IBOutlet UICollectionView *favoriteCollectView;

@end

@implementation FavoritePhotoDisplayControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.tabBarController && [self.tabBarController isKindOfClass:[PhotoTabViewController class]]) {
        PhotoTabViewController *ptabVC = (PhotoTabViewController *)self.tabBarController;
        ptabVC.tabDelegate = self;
    }

    [self setupCollectionView];
    [self setDataSource];
}
- (void) setDataSource {
    if (!result) {
        result = [NSMutableArray array];
    } else {
        [result removeAllObjects];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *titleList = [[userDefaults objectForKey:@"title"] mutableCopy];
    result = titleList;
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
#pragma mark - UITabbarDelegate
- (void) tabbarClick {
    [self setDataSource];
    [self.favoriteCollectView reloadData];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat itemunit = (self.view.frame.size.width) / 2;
    NSInteger page = roundf(self.favoriteCollectView.contentOffset.y / itemunit);
    NSLog(@"y = %.2f",self.favoriteCollectView.contentOffset.y);
    if (page == 0) {
        self.favoriteCollectView.contentOffset = CGPointMake(0 ,itemunit * (result.count / 2 - 3));
    } else if (page == result.count / 2 - 2){
        self.favoriteCollectView.contentOffset = CGPointMake(0, 0);
    }
}

#pragma mark - Collect Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return result.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoDisplayControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"aCell" forIndexPath:indexPath];
    NSString *title = result[indexPath.row];
    NSString *directryPath = [kCachePath stringByAppendingPathComponent:@"/jpegFile"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpeg",directryPath,title];

    [cell.displayImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]]];
    cell.itemName.text = title;
    [cell.favoriteButton setHidden:YES];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (self.view.frame.size.width - 10) / 2;
    CGFloat height = collectionView.frame.size.height / 3;
    return CGSizeMake(width, height);
}
@end
