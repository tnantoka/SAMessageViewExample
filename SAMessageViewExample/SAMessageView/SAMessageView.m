//
//  SAMessageView.m
//  SAClientExample
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import "SAMessageView.h"

#import <QuartzCore/QuartzCore.h>
#import "BNCloseLabel.h"

#define WRAPPER_MARGIN 10.0f
#define TABLE_MARGIN 10.0f

#define STATUS_BAR_HEIGHT 20.0f
#define DURATION 0.2f

@interface SAMessageView ()

@property (nonatomic, retain) BNCloseLabel *closeLabel;

@end

@implementation SAMessageView

- (void)dealloc {
    _delegate = nil;

#if !__has_feature(objc_arc)
    [_wrapperView release];
    [_closeLabel release];
#endif
    
    [super dealloc];
}

- (id)initWithParentView:(UIView *)parentView;
{
    CGRect frame = parentView.frame;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
                
        // Wrapper
        UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(WRAPPER_MARGIN, WRAPPER_MARGIN + STATUS_BAR_HEIGHT, frame.size.width - WRAPPER_MARGIN * 2, frame.size.height - WRAPPER_MARGIN * 2 - STATUS_BAR_HEIGHT)];
        wrapperView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0f];
        [self addSubview:wrapperView];

        wrapperView.layer.cornerRadius = 10.0f;
        wrapperView.layer.borderWidth = 0.9f;
        wrapperView.layer.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor;

        wrapperView.layer.shadowOpacity = 0.7f;
        wrapperView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        
        /*
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = wrapperView.bounds;
        gradient.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor darkGrayColor].CGColor];
        [wrapperView.layer insertSublayer:gradient atIndex:0];
         */
        //wrapperView.layer.masksToBounds = YES;
        
        self.wrapperView = wrapperView;
        
        
        // Close label
        BNCloseLabel *closeLabel = [[BNCloseLabel alloc] initWithTargetView:wrapperView];
        closeLabel.delegate = self;
        [self addSubview:closeLabel];
        
        self.closeLabel = closeLabel;
        
        
        // Gradient bg
        UIView *gradientView = [[UIView alloc] initWithFrame:wrapperView.bounds];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = gradientView.bounds;
        gradient.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor darkGrayColor].CGColor];
        [gradientView.layer insertSublayer:gradient atIndex:0];
    
        gradientView.layer.cornerRadius = wrapperView.layer.cornerRadius;
        gradientView.layer.masksToBounds = YES;
    
        [wrapperView addSubview:gradientView];

        // Table view
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(TABLE_MARGIN, TABLE_MARGIN, wrapperView.frame.size.width - TABLE_MARGIN * 2, wrapperView.frame.size.height - TABLE_MARGIN * 2) style:UITableViewStylePlain];
        //tableView.backgroundColor = [UIColor clearColor];

        [wrapperView addSubview:tableView];
        
        // Self
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
        self.alpha = 0;
        
        _autoClose = YES;
        _forcing = NO;
        _modalType = SAMessageViewModalTypeFade;
        
        [parentView addSubview:self];
        
        
#if !__has_feature(objc_arc)
        [wrapperView release];
        [closeLabel release];
        [tableView release];
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

# pragma mark - BNCloseLabelDelegate

- (void)closeLabelDidTap:(BNCloseLabel *)label {
    if (_autoClose) {
        [self hide];
    }
}

# pragma mark - Pulic methods

- (void)show {
    
    switch (_modalType) {
        case SAMessageViewModalTypeFade: {
            self.alpha = 1.0f;
            _wrapperView.alpha = 0;
            _closeLabel.alpha = 0;
            [UIView animateWithDuration:DURATION animations:^{
                _wrapperView.alpha = 1.0f;
                _closeLabel.alpha = 1.0f;
            } completion:^(BOOL finished) {
            }];
            break;
        }
        case SAMessageViewModalTypeSlide: {
            self.alpha = 1.0f;
            
            CGRect wrapperFrame = _wrapperView.frame;
            float wrapperOriginY = wrapperFrame.origin.y;
            wrapperFrame.origin.y = self.frame.size.height;
            _wrapperView.frame = wrapperFrame;
            wrapperFrame.origin.y = wrapperOriginY;
            
            CGRect closeFrame = _closeLabel.frame;
            float closeOriginY = closeFrame.origin.y;
            closeFrame.origin.y = self.frame.size.height;
            _closeLabel.frame = closeFrame;
            closeFrame.origin.y = closeOriginY;
            
            [UIView animateWithDuration:DURATION animations:^{
                _wrapperView.frame = wrapperFrame;
                _closeLabel.frame = closeFrame;
            } completion:^(BOOL finished) {
            }];
            
            break;
        }
    }
}

- (void)hide {
    
    switch (_modalType) {
        case SAMessageViewModalTypeFade: {
            [UIView animateWithDuration:DURATION animations:^{
                _wrapperView.alpha = 0;
                _closeLabel.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
            break;
        }
        case SAMessageViewModalTypeSlide: {
            
            CGRect wrapperFrame = _wrapperView.frame;
            wrapperFrame.origin.y = self.frame.size.height;
            
            CGRect closeFrame = _closeLabel.frame;
            closeFrame.origin.y = self.frame.size.height;
            
            [UIView animateWithDuration:DURATION animations:^{
                _wrapperView.frame = wrapperFrame;
                _closeLabel.frame = closeFrame;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];

            break;
        }
    }

}

@end
