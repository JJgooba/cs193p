//
//  PlayingCard.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/9/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard
@synthesize suit = _suit;

+(NSArray *)validSuits
{
    return @[@"♥",@"♦",@"♠",@"♣"];
}

+(NSArray *)rankStrings
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+(NSUInteger)maxRank
{
    return [[self rankStrings] count] - 1;
}

static const int MATCH_RANK_SCORE = 4;
static const int MATCH_SUIT_SCORE = 1;

-(int) match:(NSArray *)otherCards
{
    NSInteger ranks[[PlayingCard rankStrings].count]; // initialize array for scoring ranks
    for (int i = 0; i < [PlayingCard rankStrings].count; i++) {
        ranks[i] = 0;
    }

    NSInteger suits[[PlayingCard validSuits].count]; // initialize array for scoring suits
    for (int i = 0; i < [PlayingCard validSuits].count; i++) {
        suits[i] = 0;
    }
    NSMutableArray *allCards = [[NSMutableArray alloc] initWithArray:otherCards];
    [allCards addObject:self]; //create new array of ALL selected cards (me plus array of selected cards)
    
    int score = 0;
    
    for (PlayingCard *card in allCards) { //build the arrays for scoring
        ranks[card.rank]++;
        int suitIndex = (int)[[PlayingCard validSuits] indexOfObject:[card suit]];
        suits[suitIndex]++;
    }

    for (int i = 0; i < [PlayingCard rankStrings].count; i++) {
        if (ranks[i] > 1) score += MATCH_RANK_SCORE * (ranks[i] - 1);
    }

    for (int i = 0; i < [PlayingCard validSuits].count; i++) {
        if (suits[i] > 1) score += MATCH_SUIT_SCORE * (suits[i] - 1);
    }
    return score;
}

-(NSString *)contents
{
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

-(NSString *)suit
{
    return _suit ? _suit : @"?";
}

-(void) setSuit:(NSString *)suit
{
    _suit = suit;
}

-(void)setRank:(NSUInteger)rank
{
    if (rank <= [PlayingCard maxRank])
        _rank = rank;
}
-(NSString *)description
{
    return @"Match Card";
}
@end
