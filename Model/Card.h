//
//  Card.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 12/8/13.
//  Copyright (c) 2013 iSmokeHog. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CardProtocol
@interface Card : NSObject
@property (nonatomic, getter = isMatched) BOOL matched;
@property (nonatomic, getter = isChosen) BOOL chosen;
@end
@property (nonatomic, strong) NSString *contents;
-(int)match: (NSArray *) otherCards;
@end
