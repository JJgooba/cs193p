//
//  SetCard.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 2/25/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "SetCard.h"

@implementation SetCard
+(NSArray *)validNumbers
{
    return @[@1,@2,@3];
}
+(NSArray *)validSymbols
{
    return @[@"diamond", @"squiggle", @"oval"];
}
+(NSArray *)validShadings
{
    return @[@"solid", @"striped", @"open"];
}
+(NSArray *)validColors{
    return @[@"red", @"green", @"purple"];
}
-(int) match:(NSArray *)otherCards
{
    int numbersCount = (int)[SetCard validNumbers].count;
    NSMutableArray *numbers = [[NSMutableArray alloc] init]; // initialize array for scoring numbers
    for (int i = 0; i < numbersCount; i++) {
        [numbers addObject:[NSNumber numberWithInt:0]];
    }

    int symbolsCount = (int)[SetCard validNumbers].count;
    NSMutableArray *symbols = [[NSMutableArray alloc] init]; // initialize array for scoring symbols
    for (int i = 0; i < symbolsCount; i++) {
        [symbols addObject:@0];
    }
    
    int shadingsCount = (int)[SetCard validShadings].count;
    NSMutableArray *shadings = [[NSMutableArray alloc] init]; // initialize array for scoring shadings
    for (int i = 0; i < shadingsCount; i++) {
        [shadings addObject:@0];
    }
    
    int colorsCount = (int)[SetCard validColors].count;
    NSMutableArray *colors = [[NSMutableArray alloc] init]; // initialize array for scoring colors
    for (int i = 0; i < colorsCount; i++) {
        [colors addObject:@0];
    }

    //create new array of ALL selected cards (me plus array of selected cards)
    NSMutableArray *allCards = [[NSMutableArray alloc] initWithArray:otherCards];
    [allCards addObject:self];

    for (SetCard *card in allCards) {  //count results of selected cards
        int numberIndex = (int)[[SetCard validNumbers] indexOfObject:card.number];
        numbers[numberIndex] = @([numbers[numberIndex] intValue] + 1);
        int symbolIndex = (int)[[SetCard validSymbols] indexOfObject:card.symbol];
        symbols[symbolIndex] = @([symbols[symbolIndex] intValue] + 1);
        int shadingIndex = (int)[[SetCard validShadings] indexOfObject:card.shading];
        shadings[shadingIndex] = @([shadings[shadingIndex] intValue] + 1);
        int colorIndex = (int)[[SetCard validColors] indexOfObject:card.color];
        colors[colorIndex] = @([colors[colorIndex] intValue] + 1);
    }
    static const int MATCH_SCORE = 5;
    int matchScore = 0;
    if (([self allMatch:numbers] || [self noneMatch:numbers]) &&
        ([self allMatch:symbols] || [self noneMatch:symbols]) &&
        ([self allMatch:shadings] || [self noneMatch:shadings]) &&
        ([self allMatch:colors] || [self noneMatch:colors]))
    {
        matchScore += MATCH_SCORE;
    }
    return matchScore;
}

-(BOOL) allMatch:(NSArray *)array //returns TRUE if any one array cell contains all counts
{
    BOOL match = NO;
    for (int i = 0; i < array.count; i++) {
        if ([array[i] isEqualToNumber:[NSNumber numberWithLong:array.count]]) {
            match = YES;
            break;
        }
    }
    return match;
}

-(BOOL) noneMatch:(NSArray *)array  //returns TRUE if each cell has only one count
{
    BOOL match = YES;
    for (int i = 0; i < array.count; i++) {
        if (![array[i] isEqualToNumber:@1]) {
            match = NO;
            break;
        }
    }
    return match;
}

-(NSString *)contents {
    return [NSString stringWithFormat:@"%@ %@ %@ %@", [self.number stringValue], self.symbol, self.shading, self.color];
}

-(NSString *)description
{
    return @"Set Card";
}

@end
