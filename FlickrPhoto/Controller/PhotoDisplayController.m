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
#define kScreenWidth [UIScreen mainScreen].bounds.size.width / 2
@interface PhotoDisplayController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
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
    
    if (@available(iOS 13.0, *)) {
        waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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
    CGFloat width = (self.view.frame.size.width) / 2 ;
    [self.photoCollectionDisplayView setContentOffset:CGPointMake(0, 2000)];
    [self.photoCollectionDisplayView reloadData];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat itemunit = (self.view.frame.size.width) / 2;
    NSInteger page = self.photoCollectionDisplayView.contentOffset.y / itemunit;
    if (page == 0) {
//        self.photoCollectionDisplayView.contentOffset = CGPointMake(0 ,itemunit * ([JSDataManager shareInstance].photoURLs.count - 2));
    } else if (page == [JSDataManager shareInstance].photoURLs.count - 1){
        self.photoCollectionDisplayView.contentOffset = CGPointMake(0, self.photoCollectionDisplayView.bounds.size.height);
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@",[JSDataManager shareInstance].photoURLs[indexPath.row]];
    cell.displayImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
    cell.itemName.text = [JSDataManager shareInstance].photoTitles[indexPath.row];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (self.view.frame.size.width - 10) / 2;
    return CGSizeMake(width, width);
}
@end
@implementation PhotoDisplayControllerCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.displayImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.itemName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    self.displayImage.translatesAutoresizingMaskIntoConstraints = false;
    self.itemName.translatesAutoresizingMaskIntoConstraints = false;
    
    [self addSubview:self.displayImage];
    [self addSubview:self.itemName];
    
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
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_itemName
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutAttributeNotAnAttribute
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
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

    return self;
}
@end
