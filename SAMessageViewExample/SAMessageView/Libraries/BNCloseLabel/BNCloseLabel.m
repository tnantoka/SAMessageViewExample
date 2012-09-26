//
//  BNCloseLabel.m
//  BNCloseLabel
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import "BNCloseLabel.h"

#import <QuartzCore/QuartzCore.h>

#define SIZE 23.0f
#define FONT_SIZE 20.0f
#define DURATION 0.2f
#define DISABLED_ALPHA 0.8f

@implementation BNCloseLabel

- (void)dealloc {
    _delegate = nil;
    
#if !__has_feature(objc_arc)
    [_targetView dealloc];
    [super dealloc];
#endif
}

- (id)initWithTargetView:(UIView *)targetView
{
    self = [super initWithFrame:CGRectMake(targetView.frame.origin.x - SIZE / 3, targetView.frame.origin.y - SIZE / 3, SIZE, SIZE)];
    //self = [super initWithFrame:CGRectMake(-SIZE / 3, -SIZE / 3, SIZE, SIZE)];
    if (self) {
        // Initialization code
        
        self.text = @"×";
        //self.textAlignment = UITextAlignmentCenter;
        self.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        
        self.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f];
        
        self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f].CGColor;
        self.layer.cornerRadius = SIZE / 2;
        self.layer.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor;
        self.layer.borderWidth = 1.9f;
        
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        self.layer.shadowRadius = 2.0f;
        self.layer.masksToBounds = NO;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tapRecognizer];
        
        //[targetView addSubview:self];
        [targetView.superview addSubview:self];
        
        self.targetView = targetView;

#if !__has_feature(objc_arc)
        [tapRecognizer release];
#endif
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = UIEdgeInsetsMake(-2.0f, 5.5f, 0, 0);
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

# pragma mark - Actions

- (void)tapAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(closeLabelDidTap:)]) {
        [_delegate closeLabelDidTap:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = DISABLED_ALPHA;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.alpha == DISABLED_ALPHA) {
        self.alpha = 1.0f;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

# pragma mark - Public methods

- (void)closeWithTargetView {
    [UIView animateWithDuration:DURATION animations:^{
        self.alpha = 0;
        _targetView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [_targetView removeFromSuperview];
    }];
}


@end
