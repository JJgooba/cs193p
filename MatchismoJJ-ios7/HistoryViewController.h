//
//  HistoryViewController.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 3/4/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "ViewController.h"

@interface HistoryViewController : ViewController
@property (weak, nonatomic) IBOutlet UITextView *historyTextView;
@property (strong, nonatomic) NSAttributedString *textToDisplay;
@end
