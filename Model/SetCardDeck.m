//
//  SetCardDeck.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 2/26/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "SetCardDeck.h"

@implementation SetCardDeck

-(instancetype) init
{
    self = [super init];
    if (self) {
        for (NSNumber *number in [SetCard validNumbers]) {
            for (NSString *symbol in [SetCard validSymbols]) {
                for (NSString *shading in [SetCard validShadings]) {
                    for (NSString *color in [SetCard validColors]) {
                        SetCard *card = [[SetCard alloc] init];
                        card.number = number;
                        card.symbol = symbol;
                        card.shading = shading;
                        card.color = color;
                        [self addCard:card atTop:YES];
                    }
                }
            }
        }
    }
    return self;
}
@end
