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


@interface ViewController ()
@property (nonatomic) int flipCount;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (strong, nonatomic) NSMutableArray *cardViews;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numCardsSelector;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) BOOL newGameState;
@property (weak, nonatomic) IBOutlet UILabel *moveLabel;
@property (strong, nonatomic) NSMutableArray *moveHistory;
@property (strong, nonatomic) GameInfo *gameInfo;
@property (weak, nonatomic) IBOutlet UIView *cardContainingView;
@property (strong, nonatomic) Grid *grid;
@property (nonatomic) CGFloat cardAspectRatio; // for input to Grid -- override in subclass
@property (nonatomic) NSUInteger minNumCards; // for input to Grid -- override in subclass

@end

@implementation ViewController

-(NSMutableArray *) cardViews {
    if (!_cardViews) {
        _cardViews = [[NSMutableArray alloc] init];
    }
    return _cardViews;
}

- (IBAction)cardTap:(UITapGestureRecognizer *)sender {
    UIView *tappedView = [self.cardContainingView hitTest:[sender locationInView:self.cardContainingView] withEvent:NULL];
    NSUInteger i = [self.cardViews indexOfObject:tappedView];
    NSLog(@"you tapped the card at index %lu", i);
}

-(Grid *) grid
{
    if (!_grid) {
        _grid = [[Grid alloc] init];
        _grid.size = self.cardContainingView.bounds.size;
        NSLog(@"grid size is %.0f x %.0f",_grid.size.width, _grid.size.height);
        _grid.cellAspectRatio = self.cardAspectRatio;
        _grid.minimumNumberOfCells = self.minNumCards;
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

-(CardMatchingGame *)game {  //lazy instantiation of game
    if (!_game) {
//        _game = [[CardMatchingGame alloc ]initWithCardCount:[self.cardButtons count]
        _game = [[CardMatchingGame alloc ]initWithCardCount:self.minNumCards
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
    self.newGameState = YES;
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
    self.newGameState = NO;
    [self updateMoveLabelText];
    self.moveLabel.alpha = 1.0;
    
    NSLog(@"game is %@", self.game == nil ? @"nil" : @"not nil");
    NSLog(@"num rows = %lu, num cols = %lu",self.grid.rowCount, (unsigned long)self.grid.columnCount);
    for (int i = 0; i < (self.grid.rowCount * self.grid.columnCount); i++) {
        Card *card = [self.game cardAtIndex:i];
        [self placeCard:card atIndex:i];
    }
/*    for (UIButton *cardButton in self.cardButtons) {
        int cardButtonIndex = (int)[self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardButtonIndex];
        [self setCardButtonStateForCardButton:cardButton usingCard:card];
        cardButton.enabled = !card.isMatched;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld",(long)self.game.score];
 
    }
 */
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld",(long)self.game.score];

}

-(UIView *)cardViewForCard:(Card *)card withCGRect:(CGRect)rect
{
    return nil; //implement in subclass
}

-(void) placeCard:(Card *)card atIndex:(NSUInteger) index
// places card in the GUI at (row, col) as derived from index
{
    if (card) {
        NSUInteger row = (index  / self.grid.columnCount);
        NSUInteger col = index - (row * self.grid.columnCount);
        NSLog(@"placing card #%lu (%@) at row %lu col %lu", (unsigned long)index, card.contents, (unsigned long)row, (unsigned long)col);
        [self.cardViews addObject:[self cardViewForCard:card withCGRect:[self.grid frameOfCellAtRow:row inColumn:col]]];
        [self.cardContainingView addSubview:self.cardViews[index]];
    }
}

/* -(void) layoutAllCards {
    for (int row = 1; row < self.grid.rowCount; row++)
        for (int col = 1; col < self.grid.columnCount; col++){
            Card *card = [self.game cardAtIndex:(row * col)];
            [self layoutCard:card atIndex:(row * col)];
        }
}
*/

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
    self.newGameState = YES;
    [self updateUI];

	// Do any additional setup after loading the view.
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

@end
