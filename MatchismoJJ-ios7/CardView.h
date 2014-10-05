//
//  CardView.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 10/1/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

// Generic Card UIView for distinct card types to inherit from

#import <UIKit/UIKit.h>

@interface CardView : UIView
@property (nonatomic, getter = isMatched) BOOL matched;
@property (nonatomic, getter = isChosen) BOOL chosen;
//-(void)setChosen:(BOOL)chosen;
@end
