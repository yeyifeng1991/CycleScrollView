//
//  ViewController.m
//  CycleScrollView
//
//  Created by YeYiFeng on 2018/3/20.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import "ViewController.h"
#import "CycleScrollView.h"

@interface ViewController ()<CycleScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSArray *imageArr = @[@"1.jpg",
                          @"2.jpg",
                          @"3.jpg",
                          @"4.jpg",
                          ];
    
    CycleScrollView *banner = [CycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 135) shouldInfiniteLoop:YES imageGroups:imageArr];
    //    banner.placeholderImage = [UIImage imageNamed:@"placeholderImage"];
    //    banner.cellPlaceholderImage = [UIImage imageNamed:@"placeholderImage"];
    banner.autoScrollTimeInterval = 3;
    banner.autoScroll = YES;
    banner.isZoom = YES;
    banner.itemSpace = 0;
    banner.imgCornerRadius = 10;
    banner.itemWidth = self.view.frame.size.width - 100;
    banner.delegate = self;
    [self.view addSubview:banner];
}
-(void)rebackScrollView:(CycleScrollView *)scrollView didSelectItemIndex:(NSInteger)index
{
    NSLog(@"index = %ld",index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
