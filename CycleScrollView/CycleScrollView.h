//
//  CycleScrollView.h
//  CycleScrollView
//
//  Created by YeYiFeng on 2018/3/20.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CycleScrollView;
@protocol CycleScrollViewDelegate <NSObject>
-(void)rebackScrollView:(CycleScrollView*)scrollView didSelectItemIndex:(NSInteger)index;
@end
@interface CycleScrollView : UIView

//*是否无线循环，默认yes
@property (nonatomic,assign) BOOL infiniteLoop;
//*是否自动滑动，默认yes
@property (nonatomic,assign) BOOL autoScroll;
/**是否缩放，默认不缩放*/
@property (nonatomic,assign) BOOL isZoom;
//*自动滚动间隔时间，默认2s
@property (nonatomic,assign) CGFloat autoScrollTimeInterval;
//cell宽度
@property (nonatomic,assign) CGFloat itemWidth;
//cell间距
@property (nonatomic,assign) CGFloat itemSpace;
//imagView圆角，默认为0；
@property (nonatomic,assign) CGFloat imgCornerRadius;
//分页控制器
@property (nonatomic,strong) UIPageControl *pageControl;
/** 占位图，用于网络未加载到图片时 */
@property (nonatomic, strong) UIImage *placeholderImage;
/** cell的占位图，用于网络未加载到图片时*/
@property (nonatomic,strong) UIImage *cellPlaceholderImage;
/** 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill */
@property (nonatomic, assign) UIViewContentMode bannerImageViewContentMode;

@property(nonatomic,weak)id<CycleScrollViewDelegate>delegate;
+(instancetype)cycleScrollViewWithFrame:(CGRect)frame shouldInfiniteLoop:(BOOL)infiniteLoop imageGroups:(NSArray<NSString*>*)imageGroups;
@end
