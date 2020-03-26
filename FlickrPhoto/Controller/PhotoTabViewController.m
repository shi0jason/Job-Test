//
//  PhotoTabViewController.m
//  
//
//  Created by cch on 2020/3/26.
//

#import "PhotoTabViewController.h"

@interface PhotoTabViewController () <UITabBarControllerDelegate>

@end

@implementation PhotoTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    self.delegate = self;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if(self.tabDelegate && [self.tabDelegate respondsToSelector:@selector(tabbarClick)]){
        [self.tabDelegate tabbarClick];
    }
}
@end
