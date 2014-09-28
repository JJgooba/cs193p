//
//  Card.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/8/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

#import "Card.h"

@implementation Card
-(int)match: (NSArray *) otherCards
{
    int score = 0;
    for (Card *card in otherCards) {
        if ([card.contents isEqualToString:self.contents]) {
            score = 1;
        }
    }
    return score;
}

-(NSString *)description
{
    return @"Card";
}
@end
