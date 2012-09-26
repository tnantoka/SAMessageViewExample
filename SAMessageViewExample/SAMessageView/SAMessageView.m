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

#define WRAPPER_MARGIN 10.0f
#define TABLE_MARGIN 10.0f
#define CELL_MARGIN 5.0f

#define STATUS_BAR_HEIGHT 20.0f
#define DURATION 0.2f

enum {
    SAMessageCellTagTitle = 1,
    SAMessageCellTagBody,
    SAMessageCellTagLink,
    SAMessageCellTagUpdatedAt,
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
        
        self.wrapperView = wrapperView;
        

        // Close label
        BNCloseLabel *closeLabel = [[BNCloseLabel alloc] initWithTargetView:wrapperView];
        closeLabel.delegate = self;
        
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
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;

        [wrapperView addSubview:tableView];

        self.tableView = tableView;

        // Indicator
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.center = tableView.center;
        [indicatorView startAnimating];

        [wrapperView addSubview:indicatorView];
        
        self.indicatorView = indicatorView;

        
        // Self
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
        self.alpha = 0;
        
        _autoClose = YES;
        _forcing = NO;
        _modalType = SAMessageViewModalTypeFade;
        self.apiKey = @"";
        
        self.messages = [NSMutableArray array];
    
        [parentView addSubview:self];        
        
#if !__has_feature(objc_arc)
        [wrapperView release];
        [closeLabel release];
        [gradientView release];
        [tableView release];
        [indicatorView release];
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

# pragma mark - Utifilited

- (void)_updateLoadingStatus:(BOOL)loading {
    
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
        
        // Title
        float y = CELL_MARGIN;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, cell.frame.size.width - CELL_MARGIN * 2, 30)];
        titleLabel.tag = SAMessageCellTagTitle;
        
        [cell.contentView addSubview:titleLabel];

        y += titleLabel.frame.size.height;
        
        // Body
        UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, cell.frame.size.width - CELL_MARGIN * 2, 0)];
        bodyLabel.tag = SAMessageCellTagBody;
        bodyLabel.lineBreakMode = UILineBreakModeWordWrap;
        bodyLabel.numberOfLines = 0;

        [cell.contentView addSubview:bodyLabel];

        y += bodyLabel.frame.size.height;

        
#if !__has_feature(objc_arc)
        [titleLabel autorelease];
#endif

    } else if(indexPath.row == _messages.count) {
    }
}

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row < _messages.count) {
        SAMessage *message = [_messages objectAtIndex:indexPath.row];

        // Title
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:SAMessageCellTagTitle];
        titleLabel.text = message.title;

        // Body
        UILabel *bodyLabel = (UILabel *)[cell.contentView viewWithTag:SAMessageCellTagBody];
        bodyLabel.text = message.body;
        
        float bodyHeight = [message.body sizeWithFont:bodyLabel.font constrainedToSize:CGSizeMake(bodyLabel.frame.size.width, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
        CGRect bodyFrame = bodyLabel.frame;
        bodyFrame.size.height = bodyHeight;
        bodyLabel.frame = bodyFrame;
        
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
