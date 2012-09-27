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

//#define WRAPPER_MARGIN 10.0f
#define TABLE_MARGIN 10.0f
#define CELL_MARGIN 10.0f
#define NEW_MARGIN 2.5f

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
    
    float WRAPPER_MARGIN = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        WRAPPER_MARGIN = 10.0f;
    } else {
        WRAPPER_MARGIN = 150.0f;
    }
    
    if (self) {
        // Initialization code
                
        // Wrapper (width is fixed)
        //UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(WRAPPER_MARGIN, WRAPPER_MARGIN + STATUS_BAR_HEIGHT, parentView.frame.size.width - WRAPPER_MARGIN * 2, frame.size.height - WRAPPER_MARGIN * 2 - STATUS_BAR_HEIGHT)];
        UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(WRAPPER_MARGIN, WRAPPER_MARGIN + STATUS_BAR_HEIGHT, frame.size.width - WRAPPER_MARGIN * 2, frame.size.height - WRAPPER_MARGIN * 2 - STATUS_BAR_HEIGHT)];
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
        NSLog(@"maxSize %f, %f, %f", maxSize, gradientView.bounds.size.height, gradientView.bounds.size.width);
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

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
        [self _buildContentView:cell atIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if(indexPath.row == _messages.count) {
    }
}

- (void)_buildContentView:(UITableViewCell *)cell atIndexPath:(NSIndexPath*)indexPath {

    
    float tableWitdh = MIN(_tableView.frame.size.width, _tableView.frame.size.height) - CELL_MARGIN * 2;
    //float tableWitdh = _tableView.frame.size.width - CELL_MARGIN * 2;
    
    UIView *contentWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWitdh + CELL_MARGIN * 2, cell.contentView.frame.size.height)];
    //contentWrapper.backgroundColor = [UIColor blueColor];
    contentWrapper.tag = SAMessageCellTagWrapper;
    
    contentWrapper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [cell.contentView addSubview:contentWrapper];
    
    // Title
    float y = CELL_MARGIN * 1.5;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_MARGIN, y, tableWitdh, 30)];
    titleLabel.tag = SAMessageCellTagTitle;
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.shadowColor = [UIColor lightGrayColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1.0f);
    
    //[cell.contentView addSubview:titleLabel];
    [contentWrapper addSubview:titleLabel];
    
    // New
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_MARGIN, y, 30, 20)];
    newLabel.text = @"New";
    newLabel.tag = SAMessageCellTagNew;
    newLabel.textAlignment = UITextAlignmentCenter;
    newLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    newLabel.textColor = [UIColor orangeColor];
    newLabel.backgroundColor = [UIColor clearColor];
    //newLabel.center = CGPointMake(newLabel.center.x, titleLabel.center.y);
    
    //[cell.contentView addSubview:newLabel];
    [contentWrapper addSubview:newLabel];
    
    y += titleLabel.frame.size.height;

    // Body
    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_MARGIN, y, tableWitdh, 0)];
    bodyLabel.tag = SAMessageCellTagBody;
    bodyLabel.lineBreakMode = UILineBreakModeWordWrap;
    bodyLabel.numberOfLines = 0;
    bodyLabel.font = [UIFont systemFontOfSize:15.0f];
    bodyLabel.textColor = [UIColor whiteColor];
    bodyLabel.backgroundColor = [UIColor clearColor];
    
    //[cell.contentView addSubview:bodyLabel];
    [contentWrapper addSubview:bodyLabel];
    
    y += bodyLabel.frame.size.height;
    
    // Updated at
    UILabel *updatedAtLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_MARGIN, y, tableWitdh * 0.49, 30)];
    updatedAtLabel.tag = SAMessageCellTagUpdatedAt;
    updatedAtLabel.font = [UIFont systemFontOfSize:13.0f];
    updatedAtLabel.textColor = [UIColor lightGrayColor];
    updatedAtLabel.backgroundColor = [UIColor clearColor];

    //[cell.contentView addSubview:updatedAtLabel];
    [contentWrapper addSubview:updatedAtLabel];
    
    // Link
    UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    linkButton.tag = SAMessageCellTagLink;
    [linkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    linkButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    linkButton.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.9];
    //[linkButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    float linkWidth = tableWitdh * 0.49;
    //float linkWidth = 130;
    [linkButton setTitle:@"test" forState:UIControlStateNormal];
    linkButton.frame = CGRectMake(tableWitdh - linkWidth + CELL_MARGIN, y, linkWidth, 20);
    [linkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    linkButton.titleLabel.tag = indexPath.row;
    [linkButton addTarget:self action:@selector(linkAction:) forControlEvents:UIControlEventTouchUpInside];
    
    linkButton.layer.cornerRadius = linkButton.frame.size.height / 2.0;
    //linkButton.layer.borderColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f].CGColor;
    //linkButton.layer.borderWidth = 0.9f;
    linkButton.layer.masksToBounds = YES;
    
    //[linkButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //linkButton.titleLabel.shadowOffset = CGSizeMake(0, 1.0f);
    
    //linkButton.reversesTitleShadowWhenHighlighted = YES;
    //linkButton.showsTouchWhenHighlighted = YES;
    
    NSLog(@"link width %f", linkButton.frame.size.width);
    
    UIImage *linkBG = [UIImage imageNamed:@"SAMessageView_link"];
    [linkButton setBackgroundImage:linkBG forState:UIControlStateNormal];

    //linkButton.autoresizingMask = UIViewAutoresizingNone;
    
    //[cell.contentView addSubview:linkButton];
    [contentWrapper addSubview:linkButton];

    cell.autoresizingMask = UIViewAutoresizingNone;
    cell.contentView.autoresizingMask = UIViewAutoresizingNone;
    
    //cell.contentView.backgroundColor = [UIColor whiteColor];
    
#if !__has_feature(objc_arc)
    [titleLabel release];
    [bodyLabel release];
    [updatedAtLabel release];
    [newLabel release];
    [contentWrapper release];
#endif

}

- (void)_updateContentView:(UITableViewCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    
    SAMessage *message = [_messages objectAtIndex:indexPath.row];

    UIView *contentWrapper = [cell.contentView viewWithTag:SAMessageCellTagWrapper];
    
    // Body
    //UILabel *bodyLabel = (UILabel *)[cell.contentView viewWithTag:SAMessageCellTagBody];
    UILabel *bodyLabel = (UILabel *)[contentWrapper viewWithTag:SAMessageCellTagBody];
    bodyLabel.text = message.body;
    
    NSLog(@"body %@",  bodyLabel);

    float bodyHeight = [message.body sizeWithFont:bodyLabel.font constrainedToSize:CGSizeMake(bodyLabel.frame.size.width, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
    CGRect bodyFrame = bodyLabel.frame;
    bodyFrame.size.height = MAX(50, bodyHeight);
    bodyLabel.frame = bodyFrame;

    // New
    //UILabel *newLabel = (UILabel *)[cell.contentView viewWithTag:SAMessageCellTagNew];
    UILabel *newLabel = (UILabel *)[contentWrapper viewWithTag:SAMessageCellTagNew];
    
    // Title
    //UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:SAMessageCellTagTitle];
    UILabel *titleLabel = (UILabel *)[contentWrapper viewWithTag:SAMessageCellTagTitle];
    titleLabel.text = message.title;
    [titleLabel sizeToFit];
    
    float maxWidth = bodyLabel.frame.size.width - newLabel.frame.size.width - NEW_MARGIN;
    CGRect titleFrame = titleLabel.frame;
    titleFrame.size.width = MIN(titleLabel.frame.size.width, maxWidth);
    titleLabel.frame = titleFrame;
    
    CGRect newFrame = newLabel.frame;
    newFrame.origin.x = titleLabel.frame.origin.x + titleLabel.frame.size.width + NEW_MARGIN;
    newLabel.frame = newFrame;
    
    // Updated at
    //UILabel *updatedAtLabel = (UILabel *)[cell.contentView viewWithTag:SAMessageCellTagUpdatedAt];
    UILabel *updatedAtLabel = (UILabel *)[contentWrapper viewWithTag:SAMessageCellTagUpdatedAt];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-mm-dd HH:mm:ss"];
    updatedAtLabel.text = [formatter stringFromDate:message.updated_at];

    CGRect updatedAtFrame = updatedAtLabel.frame;
    updatedAtFrame.origin.y = bodyLabel.frame.origin.y + bodyLabel.frame.size.height;
    updatedAtLabel.frame = updatedAtFrame;

    // Link button
    //UIButton *linkButton = (UIButton *)[cell.contentView viewWithTag:SAMessageCellTagLink];
    UIButton *linkButton = (UIButton *)[contentWrapper viewWithTag:SAMessageCellTagLink];
    if (message.link.length > 0) {
        [linkButton setTitle:[NSString stringWithFormat:@"%@", message.link_label] forState:UIControlStateNormal];
        
        linkButton.center = CGPointMake(linkButton.center.x, updatedAtLabel.center.y);
        linkButton.hidden = NO;
    } else {
        linkButton.hidden = YES;
    }
    
    // Content view height
    float height = updatedAtLabel.frame.origin.y + updatedAtLabel.frame.size.height + CELL_MARGIN;
    
    CGRect contentFrame =  cell.contentView.frame;
    contentFrame.size.height = height;
    cell.contentView.frame = contentFrame;
    
    CGRect wrapperFrame =  contentWrapper.frame;
    wrapperFrame.origin.x =  cell.contentView.frame.size.width / 2 - wrapperFrame.size.width / 2;
    wrapperFrame.size.height = height;
    contentWrapper.frame = wrapperFrame;
    
    NSLog(@"wraper height %f, %f", wrapperFrame.size.height, cell.contentView.frame.size.height);

#if !__has_feature(objc_arc)
    [formatter release];
#endif
    

}

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row < _messages.count) {
        [self _updateContentView:cell atIndexPath:indexPath];
        NSLog(@"height: %f", cell.contentView.frame.size.height);
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
        UITableViewCell *dummyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dummyCell"];
        [self _buildContentView:dummyCell atIndexPath:indexPath];
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
    
    NSLog(@"finish fetch %@", messages);
    
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
