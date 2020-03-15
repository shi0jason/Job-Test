//
//  XLCycleCollectionView.m
//  XLCycleCollectionViewDemo
//
//  Created by MengXianLiang on 2017/3/6.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import "XLCycleCollectionView.h"
#import "XLCycleCell.h"

//轮播间隔
static CGFloat ScrollInterval = 3.0f;

@interface XLCycleCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *titles;

@end

@implementation XLCycleCollectionView





//循环显示


#pragma mark -
#pragma mark Setter
//设置数据时在第一个之前和最后一个之后分别插入数据
- (void)setData:(NSArray<NSString *> *)data {
    self.titles = [NSMutableArray arrayWithArray:data];
    [self.titles addObject:data.firstObject];
    [self.titles insertObject:data.lastObject atIndex:0];
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width, 0)];
    self.pageControl.numberOfPages = data.count;
}


#pragma mark -
#pragma mark 轮播方法
//自动显示下一个
- (void)showNext {
    //手指拖拽是禁止自动轮播
    if (self.collectionView.isDragging) {return;}
    CGFloat targetX =  self.collectionView.contentOffset.x + self.collectionView.bounds.size.width;
    [self.collectionView setContentOffset:CGPointMake(targetX, 0) animated:true];
}


- (void)dealloc {
    [self.timer invalidate];
}

@end
