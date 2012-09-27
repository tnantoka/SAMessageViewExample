//
//  SAMessageManager.m
//  SAMessageViewExample
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import "SAMessageManager.h"

#import "SAMessage.h"


#define API_DOMAIN @"http://localhost:3000"
//#define API_DOMAIN @"http://sorryapp.net"
#define FETCH_URI [NSString stringWithFormat:@"%@/api/%%@/messages.xml?l=%%@&p=%%d&n=%d", API_DOMAIN, 3]

#define kSASettingKeyCheckedAt @"kSAKeyCheckedAt"

NSString *SAMessageManagerDidFinishFetch = @"SAMessageManagerDidFinishFetch";
NSString *SAMessageManagerDidFailFetch = @"SAMessageManagerDidFailFetch";


@implementation SAMessageManager

static SAMessageManager *_sharedInstance = nil;

+ (SAMessageManager *)shared {
    if (!_sharedInstance) {
        _sharedInstance = [[SAMessageManager alloc] init];
    }
    return _sharedInstance;
}

# pragma mark - SorryApp API

- (void)fetch:(NSString *)apiKey {

    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString *urlString = [NSString stringWithFormat:FETCH_URI, apiKey, locale, 0];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    
    NSLog(@"url %@", url);
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        
        // Download error
        if (error) {
            [self _notifyFail:SAMessageManagerDidFailFetch message:[error localizedDescription]];
            return;
        }

        NSPropertyListFormat format;
        error = nil;
        NSDictionary *result = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:&error];
        
        
        // Parse error
        if (error) {
            NSLog(@"parset %@", [error localizedDescription]);
            [self _notifyFail:SAMessageManagerDidFailFetch message:[error localizedDescription]];
            return;
        }
        
        // API Error
        if ([[result objectForKey:@"error"] boolValue]) {
            [self _notifyFail:SAMessageManagerDidFailFetch message:[result objectForKey:@"message"]];
            return;
        }
        
        // Succeeded
        NSMutableArray *messages = [NSMutableArray array];
        for (NSDictionary *m in [NSMutableArray arrayWithArray:[result objectForKey:@"messages"]]) {
            SAMessage *message = [[SAMessage alloc] init];
            
            message.title = [m objectForKey:@"title"];
            message.body = [m objectForKey:@"body"];
            message.link = [m objectForKey:@"link"];
            message.link_label = [m objectForKey:@"link_label"];
            message.updated_at = [NSDate dateWithTimeIntervalSince1970:[[m objectForKey:@"updated_at"] intValue]];
            
            [messages addObject:message];
#if !__has_feature(objc_arc)
            [message release];
#endif
        }
        BOOL hasNext = [[result objectForKey:@"has_next"] boolValue];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:messages forKey:@"messages"];
        [userInfo setObject:@(hasNext) forKey:@"hasNext"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SAMessageManagerDidFinishFetch object:self userInfo:userInfo];
        });

    });
}

# pragma mark - Private methods

- (void)_notifyFail:(NSString *)name message:(NSString *)message {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:message forKey:@"message"];    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:userInfo];
    });
}

@end
