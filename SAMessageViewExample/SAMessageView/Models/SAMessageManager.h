//
//  SAMessageManager.h
//  SAMessageViewExample
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *SAMessageManagerDidFinishFetch;
extern NSString *SAMessageManagerDidFailFetch;

@interface SAMessageManager : NSObject

+ (SAMessageManager *)shared;

- (void)fetch:(NSString *)apiKey;

@end
