//
//  ViewController.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/7/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

#import "ViewController.h"
#import "HistoryViewController.h"
#import "HighScoreViewController.h"
#import "Card.h"
#import "GameInfo.h"
#import "Grid.h"
#import "CardView.h"
#import "PlayingCardView.h"
#import "CardHoldingView.h"


@interface ViewController () <UIDynamicAnimatorDelegate>
@property (nonatomic) int flipCount;
@property (strong, nonatomic) NSMutableArray *cardViews;
@property (strong, nonatomic) NSMutableArray *cardsInPlay;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numCardsSelector;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) BOOL newGameState;
@property (nonatomic) BOOL refreshView;
@property (nonatomic) BOOL matchedSomeCards;
@property (weak, nonatomic) IBOutlet UILabel *moveLabel;
@property (strong, nonatomic) NSMutableArray *moveHistory;
@property (strong, nonatomic) GameInfo *gameInfo;
@property (weak, nonatomic) IBOutlet CardHoldingView *cardContainingView;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinch;
@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@property (strong, nonatomic) Grid *grid;
@property (nonatomic) CGFloat cardAspectRatio; // for input to Grid -- override in subclass
@property (nonatomic) NSUInteger minNumCards; // for input to Grid -- override in subclass
@property (nonatomic) NSTimeInterval waitThisLongBeforeAddingCards;
@end

@implementation ViewController

static const double timeInterval = 0.3;

//array containing all of the card subviews
-(NSMutableArray *) cardViews {
    if (!_cardViews) {
        _cardViews = [[NSMutableArray alloc] init];
    }
    return _cardViews;
}

// array containing all cards currently in play (not matched)
-(NSMutableArray *)cardsInPlay
{
    if (!_cardsInPlay) {
        _cardsInPlay = [[NSMutableArray alloc] init];
    }
    return _cardsInPlay;
}

// the professor's class which gives approximate dimensions to use for the card views
-(Grid *) grid
{
    if (!_grid) {
        _grid = [[Grid alloc] init];
        _grid.size = self.cardContainingView.bounds.size;
        _grid.cellAspectRatio = self.cardAspectRatio;
        _grid.minimumNumberOfCells = self.numCardsInPlay;
    }
    return _grid;
}

-(NSMutableArray *)moveHistory
{
    if (!_moveHistory) {
        _moveHistory = [[NSMutableArray alloc] init];
    }
    return _moveHistory;
}

// Depends on game in subclass.  To be overridden in subclass.
-(NSUInteger)numCardsinDeck
{
    return 6; //bogus number to make sure it's being overridden in subclass
}

-(CardMatchingGame *)game {  //lazy instantiation of game
    if (!_game) {
        _game = [[CardMatchingGame alloc ]initWithCardCount:[self numCardsinDeck]
                                                  usingDeck:[self createDeck] matchingNumCards:[self numCardsInGame]] ;
    }
    return _game;
}

-(GameInfo *)gameInfo //lazy instantiation and auto-updater for gameInfo
{
    if (!_gameInfo)
        _gameInfo = [[GameInfo alloc] initWithGameName:self.game.description];
    if (self.game) {  // if exists, updates score and end time
        _gameInfo.score = self.game.score;
        [_gameInfo updateEndTime];
    }
    return _gameInfo;
}

-(UIPinchGestureRecognizer *)pinch // gesture to gather up cards
{
    if (!_pinch)
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self.cardContainingView
                                                           action:@selector(gatherCards:)];
    return _pinch;
}

-(UIPanGestureRecognizer *)pan // gesture to flip a card or move gathered stack around
{
    if (!_pan)
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.cardContainingView
                                                       action:@selector(moveCards:)];
    return _pan;
}

-(Deck *)createDeck
{
    return nil; //abstract
}

//the action for when a card (or the stack of cards) is tapped on the screen
- (IBAction)cardTap:(UITapGestureRecognizer *)sender {
    if (!self.cardContainingView.gathered) {
        UIView *tappedView = [self.cardContainingView hitTest:[sender locationInView:self.cardContainingView] withEvent:NULL];
        NSUInteger i = [self.cardViews indexOfObject:tappedView];
        //    NSLog(@"you tapped the card at index %lu", i);
        if (i < self.cardViews.count) { //if we tapped on a card
            CardView *cardView = self.cardViews[i];
            cardView.chosen = !cardView.isChosen;
            if ([cardView isKindOfClass:[PlayingCardView class]]) {
                PlayingCardView *pcView = (PlayingCardView *)cardView;
                pcView.faceUp = !pcView.faceUp;
            }
            
            [self.game chooseCardAtIndex:i];
            [self.moveHistory addObject:[self attributedStringFromCardsArray:self.game.lastMatchedCards]];
            [self writeGameInfo];  //update game score info in NSUserDefaults
            [self updateUI];
        }
    }
    else { // cards are gathered, must disperse
        [self.cardContainingView ungatherCards];
    }
}
- (IBAction)threeMoreCards:(UIButton *)sender {
    self.numCardsInPlay = self.numCardsInPlay + 3;
    self.refreshView = YES;
    if ([self.game numCardsRemainingInDeck] <= 0) {
        sender.alpha = 0.3;
        [sender setTitle: [NSString stringWithFormat:@"No More Cards"] forState:UIControlStateDisabled];
        sender.enabled = NO;
    }
        
    [self updateUI];
}

-(void)writeGameInfo  //writes current game stats to NSUserDefaults
{
    [self.gameInfo updateEndTime]; // set end time
    // retrieve previous results for game type from user defaults
    NSDictionary *userDefaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]; //get user defaults
    NSDictionary *previousGameInfo = [userDefaults objectForKey:@"matchismo"]; //get all previous matchismo results
    NSMutableDictionary *resultsDict = [[NSMutableDictionary alloc] initWithDictionary:previousGameInfo]; //make previous results mutable so I can update
    [resultsDict setObject:[self.gameInfo dictionaryRepresentation] forKey:[GameInfo stringFromDate:self.gameInfo.startTime]];
// add results dictionary back to userdefaults for game type
    [[NSUserDefaults standardUserDefaults] setObject:resultsDict forKey:@"matchismo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)newGame:(id)sender {
    [self removeAllCardsFromSuperView];
    self.cardsInPlay = nil;
    self.game = nil;
    self.gameInfo = nil;
    self.moveHistory = nil;
    self.refreshView = NO;
    [self setup];
    [self updateUI];
}

-(NSInteger)numCardsInGame // returns number of cards to match in new game
{                           // overridden in Set subclass
    return self.numCardsSelector.selectedSegmentIndex + 2;
}

-(NSAttributedString *)attributedStringFromCardsArray:(NSArray *)cards {  //returns a string from an array of cards.
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    if (self.game.lastMatchedCards) {
        if (self.game.fullSet) {
            for (Card *card in cards) {
                [string appendAttributedString:[self attributedStringFromCard:card]];
            }
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.game.lastScore > 0 ? @"match!" : @"don't match!"]];
        } else {
            string = [[NSMutableAttributedString alloc] initWithString:@"you flipped over "];
            [string appendAttributedString:[self attributedStringFromCard:[cards lastObject]]];
        }
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\tScore change: %ld", (long)self.game.lastScore]]];
    }
    return (NSAttributedString *)string;
}

-(NSAttributedString *)attributedStringFromCard:(Card *)card
{
    return [[NSAttributedString alloc] initWithString:card.contents];
}
    // creates attributed string of game history, returns empty string if no history

-(void) updateMoveLabelText
{
    self.moveLabel.attributedText = [self attributedStringFromCardsArray:self.game.lastMatchedCards];
}

-(void)updateUI  // updates the GUI
{
    self.numCardsSelector.enabled = self.newGameState; //can only change the selector if your haven't started a game
    [self updateMoveLabelText];
    self.moveLabel.alpha = 1.0;
    
 // if we just added cards then we need to make sure the grid is large enough
    if (self.numCardsInPlay > self.grid.minimumNumberOfCells)  {
        self.grid.minimumNumberOfCells = self.numCardsInPlay;
        self.refreshView = YES;
    }
    NSUInteger currentCardCount = self.cardsInPlay.count; //used to time the delay for animating 3 more cards below
    for (int i = 0; i < self.numCardsInPlay; i++) {
        if (self.cardsInPlay.count == self.numCardsInPlay){ // this indicates no new or removed cards
            CardView *cardView = self.cardViews[i];
            Card *card = self.cardsInPlay[i];
            cardView.chosen = card.isChosen;
            if ([cardView isKindOfClass:[PlayingCardView class]]) { //animate the flip if it's a playingcard
                PlayingCardView *pcView = (PlayingCardView *)cardView;
                pcView.faceUp = card.isChosen;
                self.waitThisLongBeforeAddingCards = 0.7; // allows time to flip the card over before removing it if it's a match
            }
            else
                self.waitThisLongBeforeAddingCards = 0;
            if (card.isMatched) {
                [self animateRemovingCard:self.cardViews[i] withDelay:self.waitThisLongBeforeAddingCards];
                [self.cardViews removeObjectAtIndex:i];
                [self.cardsInPlay removeObjectAtIndex:i];
                [self.game removeCardAtIndex:i];
                self.numCardsInPlay--;
                self.refreshView = YES; // need to refresh view to remove card gaps
                self.matchedSomeCards = YES;
                i--; // decrement i so we don't skip the next card which just slid into this position
                card.chosen = NO; // reset card to unselected state
            }
        }
        if (self.newGameState || (i+1 > self.cardsInPlay.count)) //only place cards if new game or added three
        {
            Card *newCard = [self.game cardAtIndex:i];
            NSTimeInterval delay = self.newGameState ? i : i+1-currentCardCount;
            [self placeCard:newCard atIndex:i withDelay:delay];
        }
    }    
    if (self.refreshView) {
        self.refreshView = NO;
        if ((self.numCardsInPlay == self.cardsInPlay.count) && (!self.matchedSomeCards)) { //the display rotated
            for (int i = 0; i < self.numCardsInPlay; i++)
                [self moveCardToIndex:i withDelay:0.0];
        }
        else if (self.matchedSomeCards) {
            self.matchedSomeCards = NO;
            self.grid.minimumNumberOfCells = self.cardsInPlay.count;
            for (int i = 0; i < self.cardViews.count; i++)
                [self moveCardToIndex:i withDelay:self.waitThisLongBeforeAddingCards];
            }
        else if (self.numCardsInPlay < self.cardsInPlay.count) { // some cards were removed
            
        }
    }
    self.numCardsInPlay = self.cardsInPlay.count;
    if (self.newGameState) {
        self.newGameState = NO;
        self.grid = nil;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld",(long)self.game.score];
    self.newGameState = NO;
}

// returns a new SetCardView based on card and rect
-(UIView *)cardViewForCard:(Card *)card withCGRect:(CGRect)rect
{
    return nil; // abstract -- implement in subclass
}

//moves an existing card to new location (which it uses grid to find)
-(void) placeCard:(Card *)card atIndex:(NSUInteger) index
{
    [self placeCard:card atIndex:index withDelay:0];
}

// places card in the GUI at (row, col) as derived from index
-(void) placeCard:(Card *)card atIndex:(NSUInteger) index withDelay:(NSUInteger)delay
{
    if (card) {
        NSUInteger row = (index  / self.grid.columnCount);
        NSUInteger col = index - (row * self.grid.columnCount);
        UIView *cardView = [self cardViewForCard:card withCGRect:[self.grid frameOfCellAtRow:row inColumn:col]];
        [self.cardViews addObject:cardView];
        [self.cardsInPlay addObject:card];
        [self animateAddingCardView:cardView withDelay:(delay * timeInterval)/3.0 atIndex:index];
    }
}

-(void)animateAddingCardView:(UIView *)card atIndex:(NSUInteger)index
{
    [self animateAddingCardView:card withDelay:0 atIndex:index];
}

-(void)animateAddingCardView:(UIView *)card withDelay:(NSTimeInterval)delay atIndex:(NSUInteger)index
{
    if (card) {
        CGRect originalFrame = card.frame;
        card.center = CGPointMake(self.cardContainingView.bounds.size.width * 3.0, self.cardContainingView.bounds.size.height * 3.0);

        [self.cardContainingView addSubview:card];  //add to main GUI (off screen)
        [UIView animateWithDuration:timeInterval
                              delay:delay + self.waitThisLongBeforeAddingCards
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             card.frame = originalFrame;
                         }
                         completion:NULL];
    }
}

-(void) moveCardToIndex:(NSUInteger)index withDelay:(NSTimeInterval) delay
{
    
    NSUInteger row = (index  / self.grid.columnCount);
    NSUInteger col = index - (row * self.grid.columnCount);
    if (index <= self.cardViews.count) {
        CardView *cardView = self.cardViews[index];
        if (cardView) {
            [UIView animateWithDuration:timeInterval
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cardView.frame = [self.grid frameOfCellAtRow:row inColumn:col];
                             }
                             completion:NULL];
        }
    }
}

-(void) removeAllCardsFromSuperView
{
    [self animateRemovingCards:self.cardViews];
    self.cardViews = nil;
}

- (void)animateRemovingCards:(NSArray *)cardsToRemove
{
    if (cardsToRemove) {
        int i = 0;
        for (CardView * card in cardsToRemove) {
            NSTimeInterval del = ((i+1) * timeInterval)/4;
            [self animateRemovingCard:card withDelay:(del)];
            i++;
        }
    }
    cardsToRemove = nil;
}

-(void)animateRemovingCard:(UIView *)card withDelay:(NSTimeInterval) delay
{
    if (card) {
        [UIView animateWithDuration:timeInterval
                              delay:delay
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             card.center = CGPointMake(0, -100);
                         }
                         completion:^(BOOL finished) {
                             [card removeFromSuperview];
                             self.waitThisLongBeforeAddingCards = 0;
                         }];
        self.waitThisLongBeforeAddingCards = delay;
    }
}

-(void)animateRemovingCard:(UIView *)card
{
    [self animateRemovingCard:card withDelay:0];
}

-(void) setCardButtonStateForCardButton:(UIButton *)cardButton usingCard:(Card *)card {
    [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
    [cardButton setBackgroundImage:[self backgroundImageForCard:card] forState:UIControlStateNormal];
}

-(NSString *)titleForCard:(Card *)card
{
    return card.isChosen ? card.contents : @"";
}

-(UIImage *)backgroundImageForCard:(Card *)card
{
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}

-(void) setup
{
    self.newGameState = YES;
    self.matchedSomeCards = NO;
    self.numCardsInPlay = self.minNumCards;
    self.cardsInPlay = nil;
    self.cardViews = nil;
    self.grid = nil;
    [self.cardContainingView setup];
    [self.cardContainingView addGestureRecognizer:self.pinch];
    [self.cardContainingView addGestureRecognizer:self.pan];
    NSLog(@"setup: %.0fx%.0f", self.cardContainingView.bounds.size.width, self.cardContainingView.bounds.size.height);
}

-(NSAttributedString *)attributedMoveHistory
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:@""];
    for (NSAttributedString *cards in self.moveHistory) {
        [result appendAttributedString:cards];
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    return result;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"ViewWillAppear: %.0fx%.0f", self.cardContainingView.bounds.size.width, self.cardContainingView.bounds.size.height);
}

-(void)viewDidAppear:(BOOL)animated  // call updateUI here as view sizes are finally stable
{
    [super viewDidAppear:animated];
    [self updateUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowHistory"]) {
        if ([segue.destinationViewController isKindOfClass:[HistoryViewController class]]) {
            HistoryViewController *hvc = (HistoryViewController *)segue.destinationViewController;
            hvc.textToDisplay = [self attributedMoveHistory];
        }
    }
    if ([segue.description isEqualToString:@"HighScores"])
        if ([segue.destinationViewController isKindOfClass:[HighScoreViewController class]]) {
        
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"viewWillLayoutSubviews");
    self.grid = nil;
    self.refreshView = YES;
    [self updateUI];
}

@end
