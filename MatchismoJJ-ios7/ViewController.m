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
@property (strong, nonatomic) UIDynamicAnimator *cardAnimator;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinch;
@property (nonatomic) BOOL newGameState;
@property (nonatomic) BOOL refreshView;
@property (nonatomic) BOOL matchedSomeCards;
@property (weak, nonatomic) IBOutlet UILabel *moveLabel;
@property (strong, nonatomic) NSMutableArray *moveHistory;
@property (strong, nonatomic) GameInfo *gameInfo;
@property (weak, nonatomic) IBOutlet CardHoldingView *cardContainingView;
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

-(UIDynamicAnimator *)cardAnimator
{
    if (!_cardAnimator) {
        _cardAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.cardContainingView];
        _cardAnimator.delegate = self; // need implement (conform to) UIDynamicAnimatorDelegate in this class (see above)
    }
    return _cardAnimator;
}

-(UIPinchGestureRecognizer *)pinch
{
    if (!_pinch)
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self.cardContainingView action:pinch:];
    return _pinch;
}

// the professor's class which gives approximate dimensions to use for the card views
-(Grid *) grid
{
    if (!_grid) {
        _grid = [[Grid alloc] init];
        _grid.size = self.cardContainingView.bounds.size;
//        NSLog(@"  *** grid size is %.0f x %.0f",_grid.size.width, _grid.size.height);
        _grid.cellAspectRatio = self.cardAspectRatio;
        _grid.minimumNumberOfCells = self.numCardsInPlay;
    }
//    NSLog(@"  *** %lu x %lu grid size is %.0f x %.0f and superview is %.0f x %.0f",_grid.rowCount, _grid.columnCount, _grid.size.width, _grid.size.height, self.cardContainingView.bounds.size.width, self.cardContainingView.bounds.size.height);
    return _grid;
}

-(NSMutableArray *)moveHistory
{
    if (!_moveHistory) {
        _moveHistory = [[NSMutableArray alloc] init];
    }
    return _moveHistory;
}

// to be overridden in subclass
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

-(Deck *)createDeck {
    return nil;
}

//the action for when a card is tapped on the screen
- (IBAction)cardTap:(UITapGestureRecognizer *)sender {
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
- (IBAction)threeMoreCards:(UIButton *)sender {
    self.numCardsInPlay = self.numCardsInPlay + 3;
    self.refreshView = YES;
    [self updateUI];
}

/*- (IBAction)touchCardButton:(UIButton *)sender {
    int chosenButtonIndex = (int)[self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:chosenButtonIndex];
    [self.moveHistory addObject:[self attributedStringFromCardsArray:self.game.lastMatchedCards]];
    [self writeGameInfo];  //update game score info in NSUserDefaults
    [self updateUI];
}
*/
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
}

-(NSInteger)numCardsInGame // returns number of cards to match in new game
{
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
//    NSLog(@"num rows = %lu, num cols = %lu",self.grid.rowCount, (unsigned long)self.grid.columnCount);
    for (int i = 0; i < self.numCardsInPlay; i++) {
        if (self.cardsInPlay.count == self.numCardsInPlay){ // this indicates no new or removed cards
            CardView *cardView = self.cardViews[i];
            Card *card = self.cardsInPlay[i];
            cardView.chosen = card.isChosen;
            if ([cardView isKindOfClass:[PlayingCardView class]]) { //animate the flip if it's a playingcard
                PlayingCardView *pcView = (PlayingCardView *)cardView;
                pcView.faceUp = card.isChosen;
                self.waitThisLongBeforeAddingCards = 0.7;
            }
            else
                self.waitThisLongBeforeAddingCards = 0;
            if (card.isMatched) {
                [self animateRemovingCard:self.cardViews[i] withDelay:self.waitThisLongBeforeAddingCards];
                [self.cardViews removeObjectAtIndex:i];
                [self.cardsInPlay removeObjectAtIndex:i];
                [self.game removeCardAtIndex:i];
                self.numCardsInPlay--;
//                NSLog(@"removed card at index %i, %lu (%lu) cards remain in play", i, self.cardsInPlay.count, self.numCardsInPlay);
                self.refreshView = YES; // need to refresh view to remove card gaps
                self.matchedSomeCards = YES;
                i--; // decrement i so we don't skip the next card which just slid into this position
                card.chosen = NO; // reset card to unselected state
            }
        }
        if (self.newGameState || (i+1 > self.cardsInPlay.count)) //only place cards if new game or added three
        {
            Card *newCard = [self.game cardAtIndex:i];
            NSTimeInterval delay = self.newGameState ? i : i+1-self.cardsInPlay.count;
            [self placeCard:newCard atIndex:i withDelay:delay];
//            NSLog(@"&&& placing new card at index %i", i);
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
//    NSLog(@"within placeCard, self.grid.minimumNumberOfCells=%lu", (unsigned long)self.grid.minimumNumberOfCells);
    if (card) {
        NSUInteger row = (index  / self.grid.columnCount);
        NSUInteger col = index - (row * self.grid.columnCount);
//        NSLog(@"placing card #%lu (%@) at row %lu col %lu", (unsigned long)index, card.contents, (unsigned long)row, (unsigned long)col);
        UIView *cardView = [self cardViewForCard:card withCGRect:[self.grid frameOfCellAtRow:row inColumn:col]];
        [self.cardViews addObject:cardView];
        [self.cardsInPlay addObject:card];
        [self animateAddingCardView:cardView withDelay:(delay * timeInterval)/3.0 atIndex:index];
    }
}
/*-(void)animateFlippingCard
{
    
}
*/
-(void)animateAddingCardView:(UIView *)card atIndex:(NSUInteger)index
{
    [self animateAddingCardView:card withDelay:0 atIndex:index];
}

-(void)animateAddingCardView:(UIView *)card withDelay:(NSTimeInterval)delay atIndex:(NSUInteger)index
{
    if (card) {
        CGRect originalFrame = card.frame;
        card.center = CGPointMake(self.cardContainingView.bounds.size.width * 3.0, self.cardContainingView.bounds.size.height * 3.0);

//        NSLog(@"moving from (%.0f,%.0f)",card.frame.origin.x, card.frame.origin.y);
        [self.cardContainingView addSubview:card];  //add to main GUI (off screen)
        [UIView animateWithDuration:timeInterval
                              delay:delay + self.waitThisLongBeforeAddingCards
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             card.frame = originalFrame;
//                             NSLog(@"now moving card to (%.0f,%.0f) in %lux%lu grid", card.frame.origin.x, card.frame.origin.y, self.grid.rowCount, self.grid.columnCount);
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
//                             NSLog(@"animated removing a card with delay %.3f!", delay);
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
	// Do any additional setup after loading the view.
}

-(void) setup
{
    self.newGameState = YES;
    self.matchedSomeCards = NO;
    self.numCardsInPlay = self.minNumCards;
    self.cardsInPlay = nil;
    self.cardViews = nil;
    self.grid = nil;
//    [self updateUI];
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
