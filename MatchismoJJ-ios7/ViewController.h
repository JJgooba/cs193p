//
//  ViewController.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/7/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

// generic class.  must override createDeck.

#import <UIKit/UIKit.h>
#import "CardMatchingGame.h"

@interface ViewController : UIViewController 
@property (strong, nonatomic) CardMatchingGame *game;
@property (nonatomic) NSUInteger numCardsInPlay;
-(NSAttributedString *)attributedMoveHistory;
@end
