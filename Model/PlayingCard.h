//
//  PlayingCard.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/9/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;
+(NSArray *)validSuits;
+(NSUInteger)maxRank;
@end
