//
//  SAMessageCell.m
//  SAMessageViewExample
//
//  Created by Tatsuya Tobioka on 12/09/28.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import "SAMessageCell.h"

#import <QuartzCore/QuartzCore.h>

#define CELL_MARGIN 10.0f
#define MAX_HEIGHT 500.0f
#define NEW_MARGIN 2.5f

@implementation SAMessageCell

- (void)dealloc {
#if !__has_feature(objc_arc)
    [_titleLabel release];
    [_bodyLabel release];
    [_updatedAtLabel release];
    [_newLabel release];
    [_contentWrapper release];
    
    [super dealloc];
#endif
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self _buildContentView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self _updateContentView];
}

# pragma mark - Update UI

- (void)_buildContentView {
    
    float contentWidth = self.contentView.frame.size.width - CELL_MARGIN * 2;

    // Wrapper
    UIView *contentWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    //contentWrapper.backgroundColor = [UIColor grayColor];
    
    [self.contentView addSubview:contentWrapper];
    
    // Title
    float y = CELL_MARGIN * 1.5;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_MARGIN, y, contentWidth, 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.shadowColor = [UIColor lightGrayColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1.0f);
    
    //[self.contentView addSubview:titleLabel];
    [contentWrapper addSubview:titleLabel];
    
    // New
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_MARGIN, y, 30, 20)];
    newLabel.text = @"New";
    newLabel.textAlignment = UITextAlignmentCenter;
    newLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    newLabel.textColor = [UIColor orangeColor];
    newLabel.backgroundColor = [UIColor clearColor];
    //newLabel.center = CGPointMake(newLabel.center.x, titleLabel.center.y);
    
    contentWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    //[self.contentView addSubview:newLabel];
    [contentWrapper addSubview:newLabel];


    y += titleLabel.frame.size.height;
    
    // Body
    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_MARGIN, y, contentWidth, 0)];
    bodyLabel.lineBreakMode = UILineBreakModeWordWrap;
    bodyLabel.numberOfLines = 0;
    bodyLabel.font = [UIFont systemFontOfSize:15.0f];
    bodyLabel.textColor = [UIColor whiteColor];
    bodyLabel.backgroundColor = [UIColor clearColor];
    
    //bodyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //[self.contentView addSubview:bodyLabel];
    [contentWrapper addSubview:bodyLabel];
    
    y += bodyLabel.frame.size.height;
    
    // Updated at
    UILabel *updatedAtLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_MARGIN, y, contentWidth * 0.49, 30)];
    updatedAtLabel.font = [UIFont systemFontOfSize:13.0f];
    updatedAtLabel.textColor = [UIColor lightGrayColor];
    updatedAtLabel.backgroundColor = [UIColor clearColor];
    
    //[self.contentView addSubview:updatedAtLabel];
    [contentWrapper addSubview:updatedAtLabel];
    
    // Link
    UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [linkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    linkButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    linkButton.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.9];
    //[linkButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    float linkWidth = contentWidth * 0.49;
    //float linkWidth = 130;
    [linkButton setTitle:@"test" forState:UIControlStateNormal];
    linkButton.frame = CGRectMake(contentWidth - linkWidth + CELL_MARGIN, y, linkWidth, 20);
    [linkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [linkButton addTarget:self action:@selector(linkAction:) forControlEvents:UIControlEventTouchUpInside];
    
    linkButton.layer.cornerRadius = linkButton.frame.size.height / 2.0;
    //linkButton.layer.borderColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f].CGColor;
    //linkButton.layer.borderWidth = 0.9f;
    linkButton.layer.masksToBounds = YES;
    
    //[linkButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //linkButton.titleLabel.shadowOffset = CGSizeMake(0, 1.0f);
    
    //linkButton.reversesTitleShadowWhenHighlighted = YES;
    //linkButton.showsTouchWhenHighlighted = YES;
    
    
    UIImage *linkBG = [UIImage imageNamed:@"SAMessageView_link"];
    [linkButton setBackgroundImage:linkBG forState:UIControlStateNormal];
    
    //linkButton.autoresizingMask = UIViewAutoresizingFleNone;

    //[self.contentView addSubview:linkButton];
    [contentWrapper addSubview:linkButton];
    
    //cell.autoresizingMask = UIViewAutoresizingNone;
    //cell.contentView.autoresizingMask = UIViewAutoresizingNone;
    
    //cell.contentView.backgroundColor = [UIColor whiteColor];

    // Set props
    self.titleLabel = titleLabel;
    self.bodyLabel = bodyLabel;
    self.updatedAtLabel = updatedAtLabel;
    self.linkButton = linkButton;
    self.newLabel = newLabel;
    self.contentWrapper = contentWrapper;
    
#if !__has_feature(objc_arc)
    [titleLabel release];
    [bodyLabel release];
    [updatedAtLabel release];
    [newLabel release];
    
    [contentWrapper release];
#endif
    
}

- (void)_updateContentView {

    // Wrapper
    CGRect wrapperFrame =  _contentWrapper.frame;
    //wrapperFrame.size.width = self.contentView.frame.size.width;
    //self.contentWrapper.frame = wrapperFrame;

    
    // Body    
    CGRect bodyFrame = _bodyLabel.frame;
    //bodyFrame.size.width = self.contentView.frame.size.width - CELL_MARGIN * 2;
    bodyFrame.size.width = _contentWrapper.frame.size.width - CELL_MARGIN * 2;

    float bodyHeight = [_bodyLabel.text sizeWithFont:_bodyLabel.font constrainedToSize:CGSizeMake(bodyFrame.size.width, MAX_HEIGHT) lineBreakMode:UILineBreakModeWordWrap].height;

    bodyFrame.size.height = MAX(50, bodyHeight);
    _bodyLabel.frame = bodyFrame;

    NSLog(@"inner body width %f, inner content %f", _bodyLabel.frame.size.width, self.contentView.frame.size.width);
    
    // Title
    [_titleLabel sizeToFit];
    
    float maxWidth = _bodyLabel.frame.size.width - _newLabel.frame.size.width - NEW_MARGIN;
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.size.width = MIN(_titleLabel.frame.size.width, maxWidth);
    _titleLabel.frame = titleFrame;
    
    CGRect newFrame = _newLabel.frame;
    newFrame.origin.x = _titleLabel.frame.origin.x + _titleLabel.frame.size.width + NEW_MARGIN;
    _newLabel.frame = newFrame;
    
    // Updated at
    CGRect updatedAtFrame = _updatedAtLabel.frame;
    updatedAtFrame.origin.y = _bodyLabel.frame.origin.y + _bodyLabel.frame.size.height;
    _updatedAtLabel.frame = updatedAtFrame;
    
    // Link button
    _linkButton.center = CGPointMake(_linkButton.center.x, _updatedAtLabel.center.y);
    
    float linkWidth = _bodyLabel.frame.size.width * 0.49;
    CGRect linkFrame = _linkButton.frame;
    linkFrame.size.width = linkWidth;
    linkFrame.origin.x = _bodyLabel.frame.size.width - linkWidth + CELL_MARGIN;
    _linkButton.frame = linkFrame;
    
    // Content view height
    float height = _updatedAtLabel.frame.origin.y + _updatedAtLabel.frame.size.height + CELL_MARGIN;
    
    
    CGRect contentFrame =  self.contentView.frame;
    contentFrame.size.height = height;
    self.contentView.frame = contentFrame;

    wrapperFrame.size.height = height;
    self.contentWrapper.frame = wrapperFrame;

}


@end
