//
//  SAMessageView.h
//  SAClientExample
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SAMessageViewModalTypeFade = 1,
    SAMessageViewModalTypeSlide,
} SAMessageViewModalType;

@interface SAMessageView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIView *wrapperView;
@property (nonatomic) SAMessageViewModalType modalType;
@property (nonatomic, retain) NSString *apiKey;

@property (nonatomic) BOOL autoClose;
@property (nonatomic) BOOL forcing;
@property (nonatomic) BOOL alertWhenError;

- (id)initWithParentView:(UIView *)ParentView;
- (void)show;
- (void)hide;

@end

@interface NSObject (SAMessageViewDelegate)

- (void)messageViewDidTapClose:(SAMessageView *)view;
- (void)messageViewDidHide:(SAMessageView *)view;

@end