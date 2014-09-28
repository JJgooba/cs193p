//
//  HistoryViewController.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 3/4/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController


-(void)setTextToDisplay:(NSAttributedString *)textToDisplay
{
    _textToDisplay = textToDisplay;
    if (self.view.window) [self updateUI]; //only updateUI if outlets are set
                                            // if window is not nil then we are on screen
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

-(void)updateUI
{
    self.historyTextView.attributedText = self.textToDisplay;
}
@end
