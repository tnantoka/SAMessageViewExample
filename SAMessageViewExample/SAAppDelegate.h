//
//  SAAppDelegate.h
//  SAMessageViewExample
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAViewController;

@interface SAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SAViewController *viewController;

@end
