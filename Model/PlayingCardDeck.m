//
//  PlayingCardDeck.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/16/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

#import "PlayingCardDeck.h"

@implementation PlayingCardDeck
-(instancetype) init
{
    self = [super init];
    if (self) {
        for (NSString *suit in [PlayingCard validSuits]) {
            for (NSUInteger rank=1; rank <= [PlayingCard maxRank]; rank++) {
                PlayingCard* card = [[PlayingCard alloc] init];
                card.rank = rank;
                card.suit = suit;
                [self addCard:card];
            }
        }
    }
    return self;
}

+(NSUInteger)fullDeckCount
{
    return 52;
}
@end
