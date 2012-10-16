//
//  SAViewController.m
//  SAMessageViewExample
//
//  Created by Tatsuya Tobioka on 12/09/26.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import "SAViewController.h"

#import "SAMessageView.h"

@interface SAViewController ()

@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"SorryApp Exapmle";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showButton setTitle:@"Show (Fade)" forState:UIControlStateNormal];
    [showButton addTarget:self action:@selector(showAction:) forControlEvents:UIControlEventTouchUpInside];
    showButton.frame = CGRectMake(10, 10, 0, 0);
    [showButton sizeToFit];
    [self.view addSubview:showButton];

    UIButton *forceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [forceButton setTitle:@"Force (Slide)" forState:UIControlStateNormal];
    [forceButton addTarget:self action:@selector(forceAction:) forControlEvents:UIControlEventTouchUpInside];
    forceButton.frame = CGRectMake(10, 60, 0, 0);
    [forceButton sizeToFit];
    [self.view addSubview:forceButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)showAction:(id)sender {
    SAMessageView *messageView = [[SAMessageView alloc] initWithParentView:self.navigationController.view];
    messageView.apiKey = @"923111a2216e0d71216a26f5a116e316206959c9";
    messageView.alertWhenError = YES;
    [messageView show];
    [messageView release];
}

- (void)forceAction:(id)sender {
    SAMessageView *messageView = [[SAMessageView alloc] initWithParentView:self.navigationController.view];
    messageView.modalType = SAMessageViewModalTypeSlide;
    messageView.apiKey = @"923111a2216e0d71216a26f5a116e316206959c9";
    messageView.forcing = YES;
    [messageView show];
    [messageView release];
}

@end
