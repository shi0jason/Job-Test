//
//  PhotoDisplayController.m
//  FlickrPhoto
//
//  Created by cch on 2020/3/13.
//  Copyright © 2020 cch. All rights reserved.
//

#import "PhotoDisplayController.h"
#import "JSDataManager.h"
#import <UIScrollView+InfiniteScroll.h>
#import <SDWebImage/UIImageView+WebCache.h>
#define kScreenWidth [UIScreen mainScreen].bounds.size.width / 2
#define kCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
@interface PhotoDisplayController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PhotoDisplayControllerCellDelegate> {
    NSMutableArray<UIImage *> *photoList;
    UIActivityIndicatorView *waitView;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionDisplayView;

@end

@implementation PhotoDisplayController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@%@",@"搜尋結果",[JSDataManager shareInstance].searchItemName.length == 0 ? @"" : [JSDataManager shareInstance].searchItemName];
    [self setupCollectionView];
    
    if (!waitView) {
        if (@available(iOS 13.0, *)) {
            waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
    }
    [waitView setFrame:CGRectMake(self.view.frame.size.width / 2 - waitView.frame.size.width / 2  ,
                                  self.view.frame.size.height / 2 - waitView.frame.size.height / 2, 50,50)];
    [self.view addSubview:waitView];
    [waitView startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData)
                                                 name:@"DataProccessed"
                                               object:nil];
}
- (void) setupCollectionView {
    UICollectionViewFlowLayout *collectLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = (self.view.frame.size.width) / 2 ;
    collectLayout.itemSize = CGSizeMake(width, width);
    
    self.photoCollectionDisplayView.pagingEnabled = true;
    self.photoCollectionDisplayView.scrollEnabled = true;
    self.photoCollectionDisplayView.delegate = self;
    self.photoCollectionDisplayView.dataSource = self;
    self.photoCollectionDisplayView.collectionViewLayout = collectLayout;
    [_photoCollectionDisplayView registerClass:[PhotoDisplayControllerCell class] forCellWithReuseIdentifier:@"Cell"];
}
- (void)processData {
    photoList = [NSMutableArray array];
    for (NSURL *url in [JSDataManager shareInstance].photoURLs) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            [self->photoList addObject:image];
        }] resume];
    }
}
- (void)refreshData {
    [waitView stopAnimating];
    [waitView setHidden:true];
    [self.photoCollectionDisplayView setContentOffset:CGPointMake(0, 0)];
    [self.photoCollectionDisplayView reloadData];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat itemunit = (self.view.frame.size.width) / 2;
    NSInteger page = ceil(self.photoCollectionDisplayView.contentOffset.y / itemunit);
    NSLog(@"y = %.2f",self.photoCollectionDisplayView.contentOffset.y);
    if (page == 0) {
        self.photoCollectionDisplayView.contentOffset = CGPointMake(0 ,itemunit * ([JSDataManager shareInstance].photoURLs.count / 2 - 3));
    } else if (page == [JSDataManager shareInstance].photoURLs.count / 2 - 2){
        self.photoCollectionDisplayView.contentOffset = CGPointMake(0, 0);
    }
}
#pragma mark - Collect Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [JSDataManager shareInstance].photoURLs.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoDisplayControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.cdelegate = self;
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
- (void)cellClick:(PhotoDisplayControllerCell *)cell {
    NSIndexPath *indexPath = [self.photoCollectionDisplayView indexPathForCell:cell];
    
    if ([JSDataManager shareInstance].photoTitles.count > 0 && [JSDataManager shareInstance].photoURLs[indexPath.row] > 0) {
        NSString *title = [JSDataManager shareInstance].photoTitles[indexPath.row];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *titleList = [[userDefaults objectForKey:@"title"] mutableCopy];
        if (titleList == nil) {
            titleList = [NSMutableArray array];
        }
        BOOL isDownloaded = false;
        for (NSString *titleString in titleList) {
            if ([title isEqualToString:titleString]) {
                isDownloaded = true;
            }
        }
        if (!isDownloaded) {
            [titleList addObject:title];
            [self saveImageWith:title Cell:cell];
        }
        [userDefaults setObject:titleList forKey:@"title"];
        [userDefaults synchronize];
    }
}
- (void)saveImageWith:(NSString *)title Cell:(PhotoDisplayControllerCell *)cell {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directryPath = [kCachePath stringByAppendingPathComponent:@"/jpegFile"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpeg",directryPath,title];
    
    NSError *writeError = nil;
    NSData* imageData = [NSData dataWithData:UIImageJPEGRepresentation(cell.displayImage.image, 80)];
    [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    [imageData writeToFile:filePath options:NSDataWritingAtomic error:&writeError];

}
@end
@implementation PhotoDisplayControllerCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.displayImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.itemName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [self.favoriteButton setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
    [self.favoriteButton addTarget:self action:@selector(addFavoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.displayImage];
    [self addSubview:self.itemName];
    [self addSubview:self.favoriteButton];
    
    [self setupConstraint];
    return self;
}
- (void)addFavoriteClick:(UIButton *)sender {
    if(self.cdelegate && [self.cdelegate respondsToSelector:@selector(cellClick:)]){
        [self.cdelegate cellClick:self];
    }
}
- (void)setupConstraint {
    self.displayImage.translatesAutoresizingMaskIntoConstraints = false;
    self.itemName.translatesAutoresizingMaskIntoConstraints = false;
    self.favoriteButton.translatesAutoresizingMaskIntoConstraints = false;
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_displayImage
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:_displayImage
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:_displayImage
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:_displayImage
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_itemName
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0 constant:0.0],
    ]];
    [self addConstraints:@[
        [NSLayoutConstraint constraintWithItem:_favoriteButton
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:_favoriteButton
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:_favoriteButton
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0 constant:40.0],
        [NSLayoutConstraint constraintWithItem:_favoriteButton
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0 constant:40.0],
    ]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_itemName
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0 constant:30.0],
                           [NSLayoutConstraint constraintWithItem:_itemName
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:_itemName
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:_itemName
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0 constant:0.0],
    ]];
}
@end
