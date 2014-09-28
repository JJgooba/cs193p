//
//  GameInfo.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 3/8/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

// This will keep track of the current game information and will be written to NSUserDefaults

#import <Foundation/Foundation.h>

@interface GameInfo : NSObject
@property (strong, nonatomic) NSString *gameName;
@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) NSInteger score;
@property (strong, nonatomic) NSDate *endTime;
@property (readonly) NSTimeInterval duration;

-(instancetype) initWithGameName:(NSString *)gameName;
-(void) updateEndTime;
-(NSDictionary *)dictionaryRepresentation;
-(void)setSelfFromDictionary:(NSDictionary *)gameInfoDict;
-(void)setSelfFromArray:(NSArray *)gameInfoArray;
-(NSComparisonResult)compareStartTimes:(GameInfo *)otherObject;
-(NSComparisonResult)compareScores:(GameInfo *)otherObject;
-(NSComparisonResult)compareDurations:(GameInfo *)otherObject;
-(NSComparisonResult)compareGameNames:(GameInfo *)otherObject;


+(NSString *)stringFromDate:(NSDate *)date;
+(NSArray *)arrayOfGameInfoObjectsFromNSUserDefaultsDictionary:(NSDictionary *)defaultsDict forGame:(NSString *)game;
+(NSString *)stringFromDictionary:(NSDictionary *)dict;
+(GameInfo *)gameInfoFromDict:(NSDictionary *)dict;

+(NSDictionary *)dictOfGameInfoObjectsFromNSUserDefaultsDictionary:(NSDictionary *)defaultsDict forGame:(NSString *)game;
@end
