//
//  RNUnityView.m
//  RNUnityView
//
//  Created by xzper on 2018/2/23.
//  Copyright © 2018年 xzper. All rights reserved.
//

#import "RNUnityView.h"

@implementation RNUnityView

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"UUUUUUUUUUUU In RNUnityView.initWithFrame");
   self = [super initWithFrame:frame];
    NSLog(@"UUUUUUUUUUUU In RNUnityView.initWithFrame called super.initWithFrame");
    return self;
}

- (void)dealloc
{
}

- (void)setUnityView:(UnityView *)view
{
    NSLog(@"UUUUUUUUUUUU In RNUnityView.setUnityView");
    self.uView = view;
    NSLog(@"UUUUUUUUUUUU In RNUnityView.initWithFrame set self.uView");
    [self setNeedsLayout];
    NSLog(@"UUUUUUUUUUUU In RNUnityView.initWithFrame called self.setNeedsLayout");
}

- (void)layoutSubviews
{
    NSLog(@"UUUUUUUUUUUU In RNUnityView.layoutSubviews");
    [super layoutSubviews];
    NSLog(@"UUUUUUUUUUUU In RNUnityView.layoutSubviews, called super.layoutSubviews");
    [(UIView *)self.uView removeFromSuperview];
    NSLog(@"UUUUUUUUUUUU In RNUnityView.layoutSubviews, called removeFromSuperview");
    [self insertSubview:(UIView *)self.uView atIndex:0];
    NSLog(@"UUUUUUUUUUUU In RNUnityView.layoutSubviews, called insertSubview");
    ((UIView *)self.uView).frame = self.bounds;
    NSLog(@"UUUUUUUUUUUU In RNUnityView.layoutSubviews, set frame bounds");
    [(UIView *)self.uView setNeedsLayout];
    NSLog(@"UUUUUUUUUUUU In RNUnityView.layoutSubviews, called setNeedsLayout");
}

@end
