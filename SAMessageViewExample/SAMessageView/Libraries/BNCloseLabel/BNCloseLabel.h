//
//  BNCloseLabel.h
//  BNCloseLabel
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNCloseLabel : UILabel

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIView *targetView;

- (id)initWithTargetView:(UIView *)targetView;
- (void)closeWithTargetView;

@end


@interface NSObject (BNCloseLabelDelegate)

- (void)closeLabelDidTap:(BNCloseLabel *)label;

@end