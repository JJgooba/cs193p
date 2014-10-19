//
//  CardMatchingGame.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 2/6/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Deck.h"

@interface CardMatchingGame : NSObject
//designated initializer
-(instancetype) initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck matchingNumCards:(NSInteger)numCards;
-(void)chooseCardAtIndex:(NSUInteger)index;
-(void)removeCardAtIndex:(NSUInteger)index;  // for removing a card after it is matched
-(Card *)cardAtIndex:(NSUInteger)index;
-(NSUInteger)numCardsRemainingInDeck;
-(BOOL) allCardsSelected;
@property (nonatomic) NSInteger numCardsToMatch;
@property (nonatomic, readonly) NSInteger score;
@property (strong, nonatomic) NSMutableArray *lastMatchedCards;
@property (nonatomic) BOOL fullSet;
@property (nonatomic) NSInteger lastScore;
@end

