//
//  GameInfo.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 3/8/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import "GameInfo.h"

@interface GameInfo()
@property (readwrite) NSTimeInterval duration;
@end

@implementation GameInfo

-(void)setDuration:(NSTimeInterval)duration
{
    self.duration = duration;
}


-(NSTimeInterval)duration
{
    return [self.endTime timeIntervalSinceDate:self.startTime];
}

-(instancetype) init
{
    self = [super init];
    self.gameName = @"??";
    self.startTime = [NSDate date];
    self.score = 0;
    self.endTime = [NSDate date];
    return self;
}

-(instancetype) initWithGameName:(NSString *)gameName
{
    self = [self init];
    self.gameName = gameName;
    return self;
}

-(void) updateEndTime  //sets the game end time to the current time
{
    _endTime = [NSDate date];
}

-(NSDictionary *)dictionaryRepresentation
{
    return @{@"game name":self.gameName,
//             @"game name":game,
             @"start time":self.startTime,
             @"score":@(self.score),
             @"end time":self.endTime};
}

-(void)setSelfFromDictionary:(NSDictionary *)gameInfoDict
{
    if ([gameInfoDict isKindOfClass:[NSDictionary class]]) {
        self.gameName = gameInfoDict[@"game name"];
        self.startTime = gameInfoDict[@"start time"];
        self.score = (NSInteger)gameInfoDict[@"score"];
        self.endTime = gameInfoDict[@"end time"];
    }
}

-(void)setSelfFromArray:(NSArray *)gameInfoArray
{
    if (gameInfoArray.count == 4) // error checking
    {
        if ([gameInfoArray[1] isKindOfClass:[NSDate class]])
            self.startTime = gameInfoArray[0];
        if ([gameInfoArray[2] isKindOfClass:[NSNumber class]])
            self.score = [(NSNumber *)gameInfoArray[1] integerValue];
        if ([gameInfoArray[3] isKindOfClass:[NSDate class]])
            self.endTime = gameInfoArray[3];
    }
}

-(NSComparisonResult)compareStartTimes:(GameInfo *)otherObject
{
    return [self.startTime compare:otherObject.startTime];
}

-(NSComparisonResult)compareScores:(GameInfo *)otherObject
{
    return [[NSNumber numberWithInteger:self.score] compare:[NSNumber numberWithInteger:otherObject.score]];
}

-(NSComparisonResult)compareDurations:(GameInfo *)otherObject
{
    return [[NSNumber numberWithDouble:self.duration] compare:[NSNumber numberWithDouble:otherObject.duration]];
}
-(NSComparisonResult)compareGameNames:(GameInfo *)otherObject
{
    return [self.gameName compare:otherObject.gameName];
}

+(NSString *)stringFromDate:(NSDate *)date //returns short date and time format from NSDate
{
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // create start time string from self.gameInfo.startTime
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        return [dateFormatter stringFromDate:date];
    }
    else
        return nil;
}

+(NSArray *)arrayOfGameInfoObjectsFromNSUserDefaultsDictionary:(NSDictionary *)defaultsDict forGame:(NSString *)game
{
    id obj = [defaultsDict objectForKey:game];
    return [obj isKindOfClass:[NSArray class]] ? obj : nil;
}

+(GameInfo *)gameInfoFromDict:(NSDictionary *)dict
{
    GameInfo *gameInfo = [[GameInfo alloc] init];
    if (dict) {
        gameInfo.gameName =[dict objectForKey:@"game name"];
        gameInfo.startTime = [dict objectForKey:@"start time"];
        gameInfo.score = [[dict objectForKey:@"score"] integerValue];
        gameInfo.endTime = [dict objectForKey:@"end time"];
    }
    return gameInfo;
}

 +(NSDictionary *)dictOfGameInfoObjectsFromNSUserDefaultsDictionary:(NSDictionary *)defaultsDict forGame:(NSString *)game
{
    id obj = [defaultsDict objectForKey:game];
    return [obj isKindOfClass:[NSDictionary class]] ? obj : nil;
}

+(NSString *)stringFromDictionary:(NSDictionary *)dict
{
    NSString *string;
    if (dict) {
        NSString *gameName =[dict objectForKey:@"game name"];
        NSDate *startTime = [dict objectForKey:@"start time"];
        NSInteger score = [[dict objectForKey:@"score"] integerValue];
        NSDate *endTime = [dict objectForKey:@"end time"];
        NSTimeInterval duration = [endTime timeIntervalSinceDate:startTime];
        string = [NSString stringWithFormat:@"%@\t%@\t%ld\t%.0f seconds", gameName, [self stringFromDate:startTime], score, duration];
    }
    return string;
}
@end
