//
//  SAMessage.h
//  SAMessageViewExample
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMessage : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *link_label;
@property (nonatomic, retain) NSDate *updated_at;

@end
