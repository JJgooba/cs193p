 //
//  SetCard.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 2/25/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "Card.h"

@interface SetCard : Card

@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) NSString *symbol;
@property (strong, nonatomic) NSString *shading;
@property (strong, nonatomic) NSString *color;

+(NSArray *)validNumbers;
+(NSArray *)validSymbols;
+(NSArray *)validShadings;
+(NSArray *)validColors;

@end
