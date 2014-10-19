//
//  PlayingCardGameViewController.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 2/25/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCardView.h"

@interface PlayingCardGameViewController ()

@end

@implementation PlayingCardGameViewController

-(Deck *)createDeck {
    return [[PlayingCardDeck alloc] init];
}

static const CGFloat cardsAspectRatio = 2.0/3.0;
static const NSUInteger minimumNumCards = 12;

-(CGFloat) cardAspectRatio
{
    return cardsAspectRatio;
}

-(NSUInteger) minNumCards
{
    return minimumNumCards;
}

-(NSUInteger)numCardsinDeck
{
    return [PlayingCardDeck fullDeckCount];
}

-(UIView *)cardViewForCard:(Card *)card withCGRect:(CGRect)rect //overriding from parent class
{
    PlayingCardView *playingCardView = [[PlayingCardView alloc] initWithFrame:rect];
    PlayingCard *playingCard = (PlayingCard *)card;
    playingCardView.rank = playingCard.rank;
    playingCardView.suit = playingCard.suit;
    playingCardView.faceUp = playingCard.isChosen;
    return playingCardView;
}
@end
