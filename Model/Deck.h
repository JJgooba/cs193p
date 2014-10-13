//
//  Deck.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/8/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

-(void)addCard:(Card *)card atTop:(BOOL)atTop;
-(void)addCard:(Card *)card;
-(Card *)drawRandomCard;
+(NSUInteger) fullDeckCount;
@end
