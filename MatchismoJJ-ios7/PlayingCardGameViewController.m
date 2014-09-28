//
//  PlayingCardGameViewController.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 2/25/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"

@interface PlayingCardGameViewController ()

@end

@implementation PlayingCardGameViewController

-(Deck *)createDeck {
    return [[PlayingCardDeck alloc] init];
}

static const CGFloat cardsAspectRatio = 2.0/3.5;
static const NSUInteger minimumNumCards = 6;

@end
