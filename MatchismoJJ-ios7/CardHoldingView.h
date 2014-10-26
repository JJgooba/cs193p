//
//  CardHoldingView.h
//  MatchismoJJ-ios7
//
//  Created by JJ on 10/23/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardHoldingView : UIView
@property (nonatomic) BOOL gathered;
-(void)gatherCards:(UIPinchGestureRecognizer *)gesture;
-(void)ungatherCards;
-(void)removeSnapAnimations;
-(void)setup;
@end
