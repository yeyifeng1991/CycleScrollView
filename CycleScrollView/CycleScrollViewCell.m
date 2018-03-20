//
//  CycleScrollViewCell.m
//  CycleScrollView
//
//  Created by YeYiFeng on 2018/3/20.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import "CycleScrollViewCell.h"
#import <AVFoundation/AVFoundation.h>
@interface CycleScrollViewCell()
@end
@implementation CycleScrollViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
-(void)layoutSubviews{
    
    self.imageView.frame = self.bounds;
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds cornerRadius:self.imgCorneRadious];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    _imageView.layer.mask = maskLayer;
    
    
}
-(UIImageView *)imageView
{
    if(_imageView == nil)
    {
        _imageView = [[UIImageView alloc]init];
    }
    return _imageView;
}
@end
