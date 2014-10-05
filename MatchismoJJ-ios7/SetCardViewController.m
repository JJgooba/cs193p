//
//  SetCardViewController.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 3/1/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "SetCardViewController.h"
#import "SetCardDeck.h"
#import "SetCardView.h"

@interface SetCardViewController ()

@end

@implementation SetCardViewController

#pragma mark - Define CONSTs

static const CGFloat cardsAspectRatio = 3.0/2.0;
static const NSUInteger minimumNumCards = 12;
//static const int FONT_SIZE = 12;

-(Deck *)createDeck {
    return [[SetCardDeck alloc] init];
}

-(CGFloat) cardAspectRatio
{
    return cardsAspectRatio;
}

-(NSUInteger) minNumCards
{
    return minimumNumCards;
}

-(NSInteger)numCardsInGame // returns number of cards to match in new game
{
    return 3;  //overriding selector as set game always matches 3
}

-(NSUInteger)numCardsInPlay {
    return 12;
}

/*-(void) setCardButtonStateForCardButton:(UIButton *)cardButton usingCard:(Card *)card {
    [cardButton setAttributedTitle:[self attributedStringFromSetCard:(SetCard *)card] forState:UIControlStateNormal];
    if (card.isMatched) {
        [cardButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    }
    else {
    [cardButton setBackgroundColor:card.isChosen ? [UIColor lightGrayColor] : [UIColor whiteColor]];
    }
}
*/

-(UIView *)cardViewForCard:(Card *)card withCGRect:(CGRect)rect //overriding from parent class
{
    SetCardView *cardView = [[SetCardView alloc] initWithFrame:rect];
    NSLog(@"the rect origin is (%f, %f) and size is %f x %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    SetCard * setCard = (SetCard *)card;
    cardView.number = setCard.number;
    cardView.symbol = setCard.symbol;
    cardView.shading = setCard.shading;
    cardView.color = setCard.color;
    cardView.chosen = setCard.chosen;
    return cardView;
}

/*
-(NSAttributedString *)attributedStringFromCard:(Card *)card
{
    return [self attributedStringFromSetCard:(SetCard *)card];
}


-(NSAttributedString *)attributedStringFromSetCard:(SetCard *)card
{
    NSString *symbol = @"";
    if (card) {
        // choose the right symbol to be displayed
        int s = (int)[[SetCard validSymbols] indexOfObject:card.symbol];
        switch (s) {
            case 0:
                symbol = @"▲";
                break;
            case 1:
                symbol = @"●";
                break;
            case 2:
                symbol = @"■";
                break;
            default:
                break;
        }
        //choose the right color to be displayed
        int c = (int)[[SetCard validColors] indexOfObject:card.color];
        UIColor *color = [[UIColor alloc] init];
        switch (c) {
            case 0:
                color = [UIColor redColor];
                break;
            case 1:
                color = [UIColor greenColor];
                break;
            case 2:
                color = [UIColor purpleColor];
                break;
            default:
                break;
        }
        //choose the right alpha to match our fill
        int a = (int)[[SetCard validShadings] indexOfObject:card.shading];
        float alpha = 1;
        NSNumber *stroke;
        switch (a) {
            case 0:
                alpha = 1; //solid
                stroke = @-5;
                break;
            case 1:
                alpha = 0.2; //striped
                stroke = @-5;
                break;
            case 2:
                alpha = 1.0; //open
                stroke = @5;
                break;
            default:
                break;
        }
        color = [color colorWithAlphaComponent:alpha];
        // create the right number of symbols
        NSString *symbols = [NSString stringWithString:symbol];
        for (int i = 1; i < [card.number integerValue]; i++) {
            symbols = [symbols stringByAppendingString:symbol];
        }
        //select font
        UIFont *font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:FONT_SIZE];
        // create attributed string frmo symbols string
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:symbols];
        //add correct attributes to string
        [string addAttributes:@{NSFontAttributeName:font,
                                NSForegroundColorAttributeName:color,
                                NSStrokeColorAttributeName:color,
                                NSStrokeWidthAttributeName:stroke} range:NSMakeRange(0, string.length)];
        return [[NSAttributedString alloc] initWithAttributedString:string];
    }   else return nil;
}
*/

@end
