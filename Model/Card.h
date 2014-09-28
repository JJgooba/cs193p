//
//  Card.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/8/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject
@property (nonatomic, strong) NSString *contents;
@property (nonatomic, getter = isChosen) BOOL chosen;
@property (nonatomic, getter = isMatched) BOOL matched;
-(int)match: (NSArray *) otherCards;
@end
