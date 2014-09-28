//
//  HighScoreViewController.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 3/8/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "HighScoreViewController.h"
#import "GameInfo.h"

@interface HighScoreViewController ()
@property (weak, nonatomic) IBOutlet UITextView *highScoreTextView;
@property (nonatomic, weak)  NSAttributedString *highScoreText;
@property (nonatomic) SEL gameInfoSortSelector;
@end

@implementation HighScoreViewController


- (IBAction)setSortSelector:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Date"])
        self.gameInfoSortSelector = @selector(compareStartTimes:);
    if ([sender.currentTitle isEqualToString:@"Game"])
        self.gameInfoSortSelector = @selector(compareGameNames:);
    if ([sender.currentTitle isEqualToString:@"Score"])
        self.gameInfoSortSelector = @selector(compareScores:);
    if ([sender.currentTitle isEqualToString:@"Duration"])
        self.gameInfoSortSelector = @selector(compareDurations:);
    [self updateUI];
}

-(SEL)gameInfoSortSelector {
    if (!_gameInfoSortSelector)
        _gameInfoSortSelector = @selector(compareStartTimes:);
    return _gameInfoSortSelector;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.gameInfoSortSelector = @selector(compareStartTimes:); //initialize sort selector
    [self updateUI];
}

-(void)updateUI
{
    if (self.view) {
        self.highScoreTextView.attributedText = self.highScoreText;
    }
}

static const int FONT_SIZE = 8;

-(NSAttributedString *)highScoreText
{
    NSMutableAttributedString *returnString = [[NSMutableAttributedString alloc] initWithString:[self scoreResultsFromNSUserDefaults]];
    UIFont *font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:FONT_SIZE];
    [returnString addAttributes:@{NSFontAttributeName:font} range:NSMakeRange(0, returnString.length)];
    return returnString;
}

- (NSComparisonResult)compareStartTimes:(id)otherObject {
    if ([self isKindOfClass:[NSDictionary class]] && [otherObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"we are all dictionaries!");
    }
    else {
        NSLog(@"we are not dictionaries");
    }
    return  NSOrderedAscending;
}

-(NSMutableArray *)gameInfoArrayFromDictionary:(NSDictionary *)dict //returns array of gameInfo objects from dictionary
{
    if (dict){ //loop through all dict values and insert into array
        NSMutableArray *gameInfoArray = [[NSMutableArray alloc] init];
        for (NSString *key in dict) {
            GameInfo *gameInfo = [GameInfo gameInfoFromDict:[dict valueForKey:key]];
            [gameInfoArray addObject:gameInfo];
        }
        return gameInfoArray;
    }
    else return nil;
}

-(NSString *)stringFromGameInfo:(GameInfo *)gameInfo
{
    return [NSString stringWithFormat:@"%@\t%@\t%ld\t\t%.0f seconds", gameInfo.gameName, [GameInfo stringFromDate:gameInfo.startTime], gameInfo.score, gameInfo.duration];
}

-(NSString *)scoreResultsFromNSUserDefaults //returns string of old score results from userdefaults
{
    NSMutableString *highScores = [[NSMutableString alloc] init]; //initialize string
    NSDictionary *scoresDict = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"matchismo"]; //get dictionary of results from NSUserDefaults
    
    if (scoresDict) {
        NSMutableArray *scoresArray = [self gameInfoArrayFromDictionary:scoresDict]; // get array representation of all scores from dictionary
        NSArray *sortedScores = [scoresArray sortedArrayUsingSelector:self.gameInfoSortSelector]; //sort the array of GameInfo
        for (GameInfo *gI in sortedScores) { //get all  results into a string
            if (highScores.length > 0)
                [highScores appendString:@"\n"];
            [highScores appendString:[self stringFromGameInfo:gI]];
        }
    }
    return [NSString stringWithString:highScores];
}
@end
