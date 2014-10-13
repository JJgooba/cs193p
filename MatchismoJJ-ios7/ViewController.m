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


@interface ViewController ()
@property (nonatomic) int flipCount;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
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
@property (weak, nonatomic) IBOutlet UIView *cardContainingView;
@property (strong, nonatomic) Grid *grid;
@property (nonatomic) CGFloat cardAspectRatio; // for input to Grid -- override in subclass
@property (nonatomic) NSUInteger minNumCards; // for input to Grid -- override in subclass
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

//this should be overridden

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
    NSLog(@"you tapped the card at index %lu", i);
    if (i < self.cardViews.count) { //if we tapped on a card
        CardView *cardView = self.cardViews[i];
        cardView.chosen = !cardView.isChosen;
        [self.game chooseCardAtIndex:i];
        [self.moveHistory addObject:[self attributedStringFromCardsArray:self.game.lastMatchedCards]];
        [self writeGameInfo];  //update game score info in NSUserDefaults
        [self updateUI];
    }
}
- (IBAction)threeMoreCards:(UIButton *)sender {
    self.numCardsInPlay = self.numCardsInPlay + 3;
    if (self.numCardsInPlay > (self.grid.rowCount * self.grid.columnCount))
        self.refreshView = YES;
    [self updateUI];
}

- (IBAction)touchCardButton:(UIButton *)sender {
    int chosenButtonIndex = (int)[self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:chosenButtonIndex];
    [self.moveHistory addObject:[self attributedStringFromCardsArray:self.game.lastMatchedCards]];
    [self writeGameInfo];  //update game score info in NSUserDefaults
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
    self.game = nil;
    self.gameInfo = nil;
    self.moveHistory = nil;
    [self removeAllCardsFromSuperView];
    self.newGameState = YES;
    self.refreshView = NO;
    [self setup];
    [self updateUI]; //new game will be created in updateUI through lazy instantiation
}
/*
- (IBAction)historySliderChanged:(UISlider *)sender {
    if (self.moveHistory.count > 1) {
        int moveIndex = lroundf(sender.value * (self.moveHistory.count - 1));
        self.moveLabel.alpha = 0.6;
        self.moveLabel.text = [NSString stringWithFormat:@"%@", self.moveHistory[moveIndex]];
    }
}

*/
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
    self.numCardsSelector.enabled = self.newGameState;
    [self updateMoveLabelText];
    self.moveLabel.alpha = 1.0;
    if (self.numCardsInPlay > self.grid.minimumNumberOfCells)  { // if we just added cards then we need to make sure the grid is large enough
        self.grid.minimumNumberOfCells = self.numCardsInPlay;
        self.refreshView = YES;
    }
//    NSLog(@"game is %@", self.game == nil ? @"nil" : @"not nil");
    NSLog(@"num rows = %lu, num cols = %lu",self.grid.rowCount, (unsigned long)self.grid.columnCount);
    for (int i = 0; i < self.numCardsInPlay; i++) {
        Card *card = [self.game cardAtIndex:i];
        if (self.newGameState ) //only place cards if new game
        {
            [self placeCard:card atIndex:i withDelay:i];
            NSLog(@"&&& placing new card at index %i", i);
        }
        if (card.isMatched) {
            [self animateRemovingCard:self.cardViews[i] withDelay:0];
            [self.cardsInPlay removeObjectAtIndex:i];
            NSLog(@"removed card at index %i, %lu (%lu) cards remain in play", i, self.cardsInPlay.count, self.numCardsInPlay);
            self.refreshView = YES; // need to refresh view to remove card gaps
            self.matchedSomeCards = YES;
            i--; // decrement i so we don't skip the next card which just slid into this position
        }
        CardView *cardView = self.cardViews[i];
        cardView.chosen = card.isChosen;
    }
    
    if (self.refreshView) {
        if (self.numCardsInPlay == self.cardsInPlay.count) { //the display rotated
            for (int i = 0; i < self.numCardsInPlay; i++)
                [self moveCardToIndex:i];
        }
        else if (self.matchedSomeCards) {
            self.matchedSomeCards = NO;
            self.grid.minimumNumberOfCells = self.cardsInPlay.count;
            for (int i = 0; i < self.cardViews.count; i++)
                [self moveCardToIndex:i];
            }
        else if (self.numCardsInPlay > self.cardsInPlay.count){         // some cards were added
            self.grid.minimumNumberOfCells = self.cardsInPlay.count;    // resize the grid
            for (int i = self.cardsInPlay.count; i < self.numCardsInPlay; i++) {
                Card *card = [self.game cardAtIndex:i];
                [self placeCard:card atIndex:i];
            }
        }
        else if (self.numCardsInPlay < self.cardsInPlay.count) { // some cards were removed
            
        }
    }
    self.numCardsInPlay = self.cardsInPlay.count;
    self.newGameState = NO;
    self.refreshView = NO;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld",(long)self.game.score];

}

// returns a new SetCardView based on card and rect
-(UIView *)cardViewForCard:(Card *)card withCGRect:(CGRect)rect
{
    return nil; //implement in subclass
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
        NSLog(@"placing card #%lu (%@) at row %lu col %lu", (unsigned long)index, card.contents, (unsigned long)row, (unsigned long)col);
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

        NSLog(@"moving from (%.0f,%.0f)",card.frame.origin.x, card.frame.origin.y);
        [self.cardContainingView addSubview:card];  //add to main GUI (off screen)
        [UIView animateWithDuration:timeInterval
                              delay:delay
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             card.frame = originalFrame;
                             NSLog(@"now moving card to (%.0f,%.0f) in %lux%lu grid", card.frame.origin.x, card.frame.origin.y, self.grid.rowCount, self.grid.columnCount);
                         }
                         completion:NULL];
    }
}

-(void) moveCardToIndex:(NSUInteger)index
{
    
    NSUInteger row = (index  / self.grid.columnCount);
    NSUInteger col = index - (row * self.grid.columnCount);
    if (index <= self.cardViews.count) {
        CardView *cardView = self.cardViews[index];
        if (cardView) {
            [UIView animateWithDuration:timeInterval
                                  delay:0
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
        for (int i = 0; i < cardsToRemove.count; i++) {
            NSTimeInterval del = ((i+1) * timeInterval);
            [self animateRemovingCard:cardsToRemove[i] withDelay:(del/4)];
        }
    }
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
                             [card performSelector:@selector(removeFromSuperview)];
                             NSLog(@"animated removing a card!");
                         }];
        [self.cardViews removeObjectAtIndex:[self.cardViews indexOfObject:card]];
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
    [self updateUI];
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
