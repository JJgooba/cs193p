//
//  SetCardViewController.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 3/1/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "SetCardViewController.h"
#import "SetCardDeck.h"
#import "SetCardView.h"

@interface SetCardViewController ()

@end

@implementation SetCardViewController

#pragma mark - Define CONSTs

static const CGFloat cardsAspectRatio = 3.0/2.0;
static const NSUInteger minimumNumCards = 12;
//static const int FONT_SIZE = 12;

-(Deck *)createDeck {
    return [[SetCardDeck alloc] init];
}

-(CGFloat) cardAspectRatio
{
    return cardsAspectRatio;
}

-(NSUInteger) minNumCards
{
    return minimumNumCards;
}

-(NSInteger)numCardsInGame // returns number of cards to match in new game
{
    return 3;  //overriding selector as set game always matches 3
}
-(NSUInteger)numCardsinDeck
{
    return 81;
}


// returns a new SetCardView based on card and rect

-(UIView *)cardViewForCard:(Card *)card withCGRect:(CGRect)rect //overriding from parent class
{
    SetCardView *cardView = [[SetCardView alloc] initWithFrame:rect];
    SetCard * setCard = (SetCard *)card;
    cardView.number = setCard.number;
    cardView.symbol = setCard.symbol;
    cardView.shading = setCard.shading;
    cardView.color = setCard.color;
    cardView.chosen = setCard.chosen;
    return cardView;
}

@end
