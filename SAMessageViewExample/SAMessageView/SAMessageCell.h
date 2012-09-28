//
//  SAMessageCell.h
//  SAMessageViewExample
//
//  Created by Tatsuya Tobioka on 12/09/28.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMessageCell : UITableViewCell

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *bodyLabel;
@property (nonatomic, retain) UILabel *updatedAtLabel;
@property (nonatomic, retain) UIButton *linkButton;
@property (nonatomic, retain) UILabel *newLabel;
@property (nonatomic, retain) UIView *contentWrapper;

@end
