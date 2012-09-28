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
#import "SAMessageManager.h"
#import "SAMessage.h"
#import "SAMessageCell.h"

//#define WRAPPER_MARGIN 10.0f
#define TABLE_MARGIN 10.0f

#define STATUS_BAR_HEIGHT 20.0f
#define DURATION 0.2f

enum {
    SAMessageCellTagTitle = 1,
    SAMessageCellTagNew,
    SAMessageCellTagBody,
    SAMessageCellTagLink,
    SAMessageCellTagUpdatedAt,
    SAMessageCellTagWrapper,
};

@interface SAMessageView ()

@property (nonatomic, retain) BNCloseLabel *closeLabel;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) UIActivityIndicatorView *indicatorView;
@property (nonatomic, retain) UITableView *tableView;

@end

@implementation SAMessageView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _delegate = nil;

#if !__has_feature(objc_arc)
    [_wrapperView release];
    [_closeLabel release];
    [_messages release];
    [_indicatorView release];
    [_tableView release];
    [_apiKey release];
#endif
    
    [super dealloc];
}

- (id)initWithParentView:(UIView *)parentView;
{
    CGRect frame = parentView.frame;
    
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            frame.origin.x = parentView.frame.origin.y;
            frame.origin.y = parentView.frame.origin.x;
            frame.size.width = parentView.frame.size.height;
            frame.size.height = parentView.frame.size.width;
            break;
    }
    
    self = [super initWithFrame:frame];
    
    float wrapperMargin = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        wrapperMargin = 10.0f;
    } else {
        wrapperMargin = 150.0f;
    }
    
    if (self) {
        // Initialization code
                
        // Wrapper (width is fixed)
        //UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(WRAPPER_MARGIN, WRAPPER_MARGIN + STATUS_BAR_HEIGHT, parentView.frame.size.width - WRAPPER_MARGIN * 2, frame.size.height - WRAPPER_MARGIN * 2 - STATUS_BAR_HEIGHT)];
        UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(wrapperMargin, wrapperMargin + STATUS_BAR_HEIGHT, frame.size.width - wrapperMargin * 2, frame.size.height - wrapperMargin * 2 - STATUS_BAR_HEIGHT)];
        wrapperView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0f];
        [self addSubview:wrapperView];

        wrapperView.layer.cornerRadius = 10.0f;
        wrapperView.layer.borderWidth = 0.9f;
        wrapperView.layer.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor;

        wrapperView.layer.shadowOpacity = 0.7f;
        wrapperView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);

        wrapperView.center = CGPointMake(self.center.x, wrapperView.center.y);
        
        wrapperView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.wrapperView = wrapperView;


        // Close label
        BNCloseLabel *closeLabel = [[BNCloseLabel alloc] initWithTargetView:wrapperView];
        closeLabel.delegate = self;
        
        self.closeLabel = closeLabel;

        // Gradient bg
        UIView *gradientView = [[UIView alloc] initWithFrame:wrapperView.bounds];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        //gradient.frame = gradientView.bounds;
        float maxSize = MAX(gradientView.bounds.size.width, gradientView.bounds.size.height) + STATUS_BAR_HEIGHT;
        gradient.frame = CGRectMake(0, 0, maxSize, maxSize);
        gradient.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor darkGrayColor].CGColor];
        [gradientView.layer insertSublayer:gradient atIndex:0];
    
        gradientView.layer.cornerRadius = wrapperView.layer.cornerRadius;
        gradientView.layer.masksToBounds = YES;
    
        gradientView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [wrapperView addSubview:gradientView];

        // Table view
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(TABLE_MARGIN, 0, wrapperView.frame.size.width - TABLE_MARGIN * 2, wrapperView.frame.size.height) style:UITableViewStylePlain];
        //UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(TABLE_MARGIN, TABLE_MARGIN, wrapperView.frame.size.width - TABLE_MARGIN * 2, wrapperView.frame.size.height - TABLE_MARGIN * 2) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.showsVerticalScrollIndicator = NO;
        
        tableView.delegate = self;
        tableView.dataSource = self;

        tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        [wrapperView addSubview:tableView];

        self.tableView = tableView;

        
        // Copy right (footer)
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
 
        UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [logoButton setImage:[UIImage imageNamed:@"SAMessageView_logo"] forState:UIControlStateNormal];
        //[logoButton setTitle:@" SorryApp" forState:UIControlStateNormal];
        //[logoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10.0f, 0, 0)];
        [logoButton sizeToFit];
        logoButton.alpha = 0.6;
        
        [logoButton addTarget:self action:@selector(logoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        logoButton.center = footerView.center;
        
        logoButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
        [footerView addSubview:logoButton];
        tableView.tableFooterView = footerView;
        
        // Indicator
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.center = tableView.center;
        [indicatorView startAnimating];
        
        indicatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;

        [wrapperView addSubview:indicatorView];
        
        self.indicatorView = indicatorView;

        // Self
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
        self.alpha = 0;
        
        _autoClose = YES;
        _forcing = NO;
        _modalType = SAMessageViewModalTypeFade;
        self.apiKey = @"";
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        self.messages = [NSMutableArray array];
            
        [parentView addSubview:self];        
        
#if !__has_feature(objc_arc)
        [wrapperView release];
        [closeLabel release];
        [gradientView release];
        [tableView release];
        [indicatorView release];
        [footerView release];
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

# pragma mark - Private methods

- (void)_updateLoadingStatus:(BOOL)loading {
    
}

# pragma mark - Button actions

- (void)logoAction:(id)sender {
    NSString *urlString = @"http://sorryapp.net/";
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)linkAction:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    int row = button.titleLabel.tag;
    
    SAMessage *message = [_messages objectAtIndex:row];
    
    NSString *urlString = message.link;
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

# pragma mark - BNCloseLabelDelegate

- (void)closeLabelDidTap:(BNCloseLabel *)label {
    if (_autoClose) {
        [self hide];
    }
}


# pragma mark - Pulic methods

- (void)show {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(messageManagerDidFinishFetch:) name:SAMessageManagerDidFinishFetch object:nil];
    [center addObserver:self selector:@selector(messageManagerDidFailFetch:) name:SAMessageManagerDidFailFetch object:nil];
    [[SAMessageManager shared] fetch:_apiKey];
    
}

- (void)hide {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    switch (_modalType) {
        case SAMessageViewModalTypeFade: {
            [UIView animateWithDuration:DURATION animations:^{
                _wrapperView.alpha = 0;
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

# pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *CellIdentifier = @"Cell";
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[SAMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        [self _initCell:cell atIndexPath:indexPath];
        
#if !__has_feature(objc_arc)
        [cell autorelease];
#endif
    }
    
    [self _updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)_initCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row < _messages.count) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if(indexPath.row == _messages.count) {
    }
}

- (void)_updateContentView:(SAMessageCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    
    SAMessage *message = [_messages objectAtIndex:indexPath.row];

    // Body
    cell.bodyLabel.text = message.body;
    
    // Title
    cell.titleLabel.text = message.title;
    
    // Updated at
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.updatedAtLabel.text = [formatter stringFromDate:message.updated_at];

    // Link button
    if (message.link.length > 0) {
        [cell.linkButton setTitle:[NSString stringWithFormat:@"%@", message.link_label] forState:UIControlStateNormal];
        
    } else {
        cell.linkButton.hidden = YES;
    }
    
    [cell layoutSubviews];
    
#if !__has_feature(objc_arc)
    [formatter release];
#endif
    
}

- (void)_updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row < _messages.count) {
        [self _updateContentView:(SAMessageCell *)cell atIndexPath:indexPath];
    } else if(indexPath.row == _messages.count) {
        cell.textLabel.text = @"Next";
    }
}

- (void)updateAllCells {
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < _messages.count) {
        SAMessageCell *dummyCell = [[SAMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dummyCell"];
        
        CGRect frame = dummyCell.contentWrapper.frame;
        frame.size.width = _tableView.frame.size.width;
        dummyCell.contentWrapper.frame = frame;
        
        NSLog(@"table width = %f ,wrapper width = %f, content width %f", tableView.frame.size.width, dummyCell.contentWrapper.frame.size.width, dummyCell.contentView.frame.size.width);
        
        [self _updateContentView:dummyCell atIndexPath:indexPath];

#if !__has_feature(objc_arc)
        [dummyCell autorelease];
#endif

        return dummyCell.contentView.frame.size.height;

    } else if(indexPath.row == _messages.count) {
        
    }
    
    return 100.0f;
}

# pragma mark - Notifications

- (void)messageManagerDidFinishFetch:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSMutableArray *messages = [[notification userInfo] objectForKey:@"messages"];
    self.messages = messages;
    [_tableView reloadData];
    
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

- (void)messageManagerDidFailFetch:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSString *message = [[notification userInfo] objectForKey:@"message"];
    
    NSLog(@"fail fetch: %@", message);
}


@end
