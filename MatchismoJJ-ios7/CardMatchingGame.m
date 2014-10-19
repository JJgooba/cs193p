//
//  CardMatchingGame.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 2/6/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame()
@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, strong) NSMutableArray *cards;
@end

@implementation CardMatchingGame

-(NSMutableArray *) cards {
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

-(instancetype) initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck matchingNumCards:(NSInteger)numCards
{
    self = [super init];
    if (numCards > 0 && numCards < count) { //error checking on numCardToMatch
        self.numCardsToMatch = numCards;
        if (self) {
            for (int i = 0; i < count; i++) {
                Card *card = [deck drawRandomCard];
                if (card) {
                    [self.cards addObject:card];
                } else {
                    self = nil;
                    break;
                }
            }
        }
    }
    self.fullSet = NO;
    return self;
}

-(NSString *)description
{
    NSString *description;
    if (self.cards)
        if ([self.cards[0] isKindOfClass:[Card class]]) {
            Card *card = self.cards[0];
            description = [NSString stringWithFormat:@"%@ game",card.description];
        }
    return description;
}

-(Card *)cardAtIndex:(NSUInteger)index
{
    return (index < self.cards.count) ? self.cards[index] : nil;
}

-(BOOL) allCardsSelected //returns YES if the right number of cards is selected
{
    int count = 0;
    for (Card *aCard in self.cards) {
        if (aCard.isChosen && !aCard.isMatched) count++;
    }
    return (count + 1) == self.numCardsToMatch;
}

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

-(void)chooseCardAtIndex:(NSUInteger)index
{
    self.lastMatchedCards = nil; //provides list of matched cards to controller
    int oldScore = (int)self.score;  //for calculating change in score
    Card *card = [self cardAtIndex:index]; //select out the chosen card
    self.lastMatchedCards = [[NSMutableArray alloc] init]; //array of other selected cards
    for (Card *otherCard in self.cards) {  //build array of other selected cards
        if (otherCard.isChosen && !otherCard.isMatched) {
            [self.lastMatchedCards addObject:otherCard];
        }
    }
    if (!card.isMatched) { //we only check unmatched cards
        if (card.isChosen) { //if face up, flip back down
            card.chosen = NO;
            self.fullSet = NO;
        } else if ([self allCardsSelected]) { //is it time to search for matches?
            self.fullSet = YES;
            int matchScore = [card match:self.lastMatchedCards];  //get score for any matches
            if (matchScore > 0) {
                self.score += matchScore * MATCH_BONUS;
                card.matched = YES;
                for (Card *oCard in self.lastMatchedCards) {
                    oCard.matched = YES; //there was a match so these cards are no longer playable
                }
            } else { // if no match
                self.score -= MISMATCH_PENALTY;
                for (Card *oCard in self.lastMatchedCards) {
                    oCard.chosen = NO; //no match, turn back over other cards
                }
            }
            card.chosen = YES;
        } else {
            card.chosen = YES;
            self.fullSet = NO;
        }
        [self.lastMatchedCards addObject:card]; //add chosen card to this array for UI
    }
    self.score -= COST_TO_CHOOSE;
    self.lastScore = self.score - oldScore;
}

-(void) removeCardAtIndex:(NSUInteger)index
{
    if (index < self.cards.count) {
        [self.cards removeObjectAtIndex:index];
    }
}
-(NSUInteger)numCardsRemainingInDeck
{
    return self.cards.count;
}
@end
