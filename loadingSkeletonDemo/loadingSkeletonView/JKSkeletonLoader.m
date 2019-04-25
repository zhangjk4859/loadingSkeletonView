//
//  JKSkeletonLoader.m
//  loadingSkeletonDemo
//
//  Created by kevin on 2019/4/24.
//  Copyright © 2019 kevin. All rights reserved.
//

#import "JKSkeletonLoader.h"
#import <objc/runtime.h>

@protocol ListLoadable <NSObject>
-(NSArray <UIView *>*)jk_visibleContentViews;
@end

static UInt8   cutoutHandle          = 0;
static UInt8   gradientHandle        = 0;
static CGFloat loaderDuration        = 0.85;
static CGFloat gradientWidth         = 0.17;
static CGFloat gradientFirstStop     = 0.1;


@implementation UITableView (ListLoadable)
-(NSArray<UIView *> *)jk_visibleContentViews{
    NSArray *views = [self.visibleCells valueForKey:@"contentView"];
    return views;
}
@end

@implementation UICollectionView (ListLoadable)
-(NSArray<UIView *> *)jk_visibleContentViews{
    NSArray *views = [self.visibleCells valueForKey:@"contentView"];
    return views;
}
@end



@implementation UIColor (ListLoadable)
+(UIColor *)backgroundFadedGrey{
    return [UIColor colorWithRed:246.0/255.0 green:247.0/255.0 blue:248.0/255.0 alpha:1.0];
}
+(UIColor *)gradientFirstStop{
    return [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
}
+(UIColor *)gradientSecondStop{
    return [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
}
@end


@interface CutoutView : UIView

@end

/***
 如不遵循协议，私有分类只需实现@implementation即可🐭🐂🐅🐇🐉🐍🐴🐑🐒🐔🐩🐖
 */
@implementation UIView (ListLoadable)
-(NSArray<UIView *> *)jk_visibleContentViews{
    NSArray *views = @[self];
    return views;
}
-(void)boundInside:(UIView *)superView{
    //关闭 自适应
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *horizotalCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subview]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"subview":self}];
    [superView addConstraints:horizotalCons];
    
    NSArray *verticalCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[subview]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"subview":self}];
    [superView addConstraints:verticalCons];
}

-(UIView *)ld_getCutoutView{
    return (UIView *)objc_getAssociatedObject(self, &cutoutHandle);
}

-(void)ld_setCutoutView:(UIView *)aView{
    objc_setAssociatedObject(self, &cutoutHandle, aView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CAGradientLayer *)ld_getGradient{
    return (CAGradientLayer *)objc_getAssociatedObject(self, &gradientHandle);
}

-(void)ld_setGradient:(CAGradientLayer *)aLayer{
    objc_setAssociatedObject(self, &gradientHandle, aLayer,OBJC_ASSOCIATION_RETAIN);
}

-(void)ld_addLoader{
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.layer insertSublayer:gradient atIndex:0];
    [self configureAndAddAnimationToGradient:gradient];
    [self addCutoutView];
}

-(void)ld_removeLoader{
    [[self ld_getCutoutView] removeFromSuperview];
    [[self ld_getGradient] removeAllAnimations];
    [[self ld_getGradient] removeFromSuperlayer];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
        subView.alpha = 1.0f;
    }];
}


-(void)configureAndAddAnimationToGradient:(CAGradientLayer *)gradient{
    //-0.83
    gradient.startPoint = CGPointMake(-1.0 + gradientWidth, 0);
    //1.17
    gradient.endPoint = CGPointMake(1.0 + gradientWidth, 0);
    
    //
    gradient.colors = @[
                        (id)[UIColor backgroundFadedGrey].CGColor,
                        (id)[UIColor gradientFirstStop].CGColor,
                        (id)[UIColor gradientSecondStop].CGColor,
                        (id)[UIColor gradientFirstStop].CGColor,
                        (id)[UIColor backgroundFadedGrey].CGColor
                        
                        ];

    NSArray *startLocations = @[
                                @(gradient.startPoint.x),//will be double in 64bit arch
                                @(gradient.startPoint.x),
                                @(0.0),
                                @(gradientWidth),
                                @(1 + gradientWidth)
                                ];
    gradient.locations = startLocations;
    NSString *keyPath = @"locations";
    CABasicAnimation *gradientAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
    
    gradientAnimation.fromValue = startLocations;
    gradientAnimation.toValue = @[@(0.0),@(1.0),@(1.0),@(1 + (gradientWidth - gradientFirstStop)),@( 1.0 + gradientWidth)];
 
    gradientAnimation.repeatCount = MAXFLOAT;
    gradientAnimation.fillMode = kCAFillModeForwards;
    gradientAnimation.removedOnCompletion = NO;
    gradientAnimation.duration = loaderDuration;
    [gradient addAnimation:gradientAnimation forKey:keyPath];
    [self ld_setGradient:gradient];
    
}

-(void)addCutoutView{
    CutoutView *cutout = [[CutoutView alloc] init];
    cutout.frame = self.bounds;
    cutout.backgroundColor = [UIColor clearColor];
    [self addSubview:cutout];
    [cutout setNeedsDisplay];
    [cutout boundInside:self];
    
    for (UIView *subview in self.subviews) {
        if (subview != cutout) {
            subview.alpha = 0;
        }
    }
    [self ld_setCutoutView:cutout];
}
@end




@implementation JKSkeletonLoader
+(void)addLoaderToTargetView:(UIView <ListLoadable>*)listView{
    NSArray *array = [listView jk_visibleContentViews];
    [self addLoaderToViews:array];
}
+(void)removeLoaderFromTargetView:(UIView <ListLoadable>*)listView{
    [self removeLoaderFromViews:[listView jk_visibleContentViews]];
}



+(void)addLoaderToViews:(NSArray <UIView *>*)views{
    [CATransaction begin];
    
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        [subview ld_addLoader];
    }];
    
    [CATransaction commit];
}

+(void)removeLoaderFromViews:(NSArray <UIView *>*)views{
    [CATransaction begin];
    
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        [subview ld_removeLoader];
    }];
    
    [CATransaction commit];
}
@end


@implementation CutoutView
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // C API make backgroungColor white
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, self.bounds);
    
    for (UIView *subView in self.superview.subviews) {
        if (subView == self) {
            continue;
        }
        //make position of subviews clear
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextFillRect(context, subView.frame);
    }
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self setNeedsDisplay];
    CAGradientLayer *layer = [self.superview ld_getGradient];
    layer.frame = self.superview.bounds;
}

@end






