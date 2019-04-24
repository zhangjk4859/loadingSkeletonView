//
//  JKSkeletonLoader.h
//  loadingSkeletonDemo
//
//  Created by kevin on 2019/4/24.
//  Copyright © 2019 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKSkeletonLoader : NSObject
+(void)addLoaderToTargetView:(UIView *)listView;
+(void)removeLoaderFromTargetView:(UIView *)listView;
@end

NS_ASSUME_NONNULL_END





