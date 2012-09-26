//
//  SAMessage.m
//  SAMessageViewExample
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import "SAMessage.h"

@implementation SAMessage

- (void)dealloc {
#if !__has_feature(objc_arc)
    [_title release];
    [_body release];
    [_link release];
    [_link_label release];
    [_updated_at release];
    
    [super dealloc];
#endif
}

@end
