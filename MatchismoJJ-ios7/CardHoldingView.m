//
//  CardHoldingView.m
//  MatchismoJJ-ios7
//
//  Created by JJ on 10/23/14.
//  Copyright (c) 2014 iSmokeHog. All rights reserved.
//
//  It was necessary to create a custom UIView for this View to enable the animation of the cardViews it contains

#import "CardHoldingView.h"
#import "CardView.h"

@interface CardHoldingView () <UIDynamicAnimatorDelegate>
@property (strong, nonatomic) UIDynamicAnimator *cardAnimator;
@property (strong, nonatomic) NSMutableArray *attachments;  //array of UIAttachmentBehaviors
@property (strong, nonatomic) NSMutableArray *snap;  //array of UISnapBehaviors
@property (strong, nonatomic) NSMutableArray *cardCenters;
@property (nonatomic) BOOL allowAnimation;
@end
@implementation CardHoldingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void) setup
{
    self.gathered = NO;
    self.allowAnimation = YES;
}

-(UIDynamicAnimator *)cardAnimator
{
    if (!_cardAnimator) {
        _cardAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        _cardAnimator.delegate = self; // need implement (conform to) UIDynamicAnimatorDelegate in this class (see above)
    }
    return _cardAnimator;
}

-(NSMutableArray *)attachments
{
    if (!_attachments)
        _attachments = [[NSMutableArray alloc] init];
    return _attachments;
}

-(NSMutableArray *)snap
{
    if (!_snap)
        _snap = [[NSMutableArray alloc] init];
    return _snap;
}

-(NSMutableArray *)cardCenters
{
    if (!_cardCenters)
        _cardCenters = [[NSMutableArray alloc] init];
    return _cardCenters;
}

// Pinch gesture to allow cards to be gathered up and moved around
-(void)gatherCards:(UIPinchGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan && self.allowAnimation) {
        NSLog(@"pinch began");
        CGPoint viewCenter = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height / 2.0);
        for (CardView *cardView in self.subviews) {
            [self.cardCenters addObject:[NSValue valueWithCGPoint:cardView.center]];  //store original centers to restore cards to original location
            [self.snap addObject:[[UISnapBehavior alloc] initWithItem:cardView snapToPoint:viewCenter]];
            [self.cardAnimator addBehavior:[self.snap lastObject]];
            //            [self.attachments addObject:[[UIAttachmentBehavior alloc] initWithItem:cardView attachedToAnchor:self.center]];
            //            [self.cardAnimator addBehavior:[self.attachments lastObject]];
//            NSLog(@"hello %.0f, %.0f : %.0f, %.0f card is %.0f, %.0f", self.center.x, self.center.y, self.bounds.size.width, self.frame.size.height, cardView.frame.origin.x, cardView.frame.origin.y);
        }
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.gathered = YES;
        //        self.snap = nil;
        //        self.cardAnimator = nil;
        self.allowAnimation = NO;
        NSLog(@"pinch ended");
    }
//    [self setNeedsDisplay];
}

-(void)ungatherCards
{
    int i = 0;
    for (CardView *cardView in self.subviews) {
        CGPoint originalCenter = [self.cardCenters[i] CGPointValue];
        [self.snap addObject:[[UISnapBehavior alloc] initWithItem:cardView snapToPoint:originalCenter]];
//        self.snap[i]  = [[UISnapBehavior alloc] initWithItem:cardView snapToPoint:originalCenter];
        [self.cardAnimator addBehavior:[self.snap lastObject]];
        i++;
    }
    self.gathered = NO;
    [self.cardCenters removeAllObjects];
    [self setNeedsDisplay];
}

-(void)removeSnapAnimations
{
    [self.cardAnimator removeAllBehaviors];
    self.snap = nil;
}

-(void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    [self removeSnapAnimations];
    self.allowAnimation = YES;
    NSLog(@"stuff stopped moving");
}

-(void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator
{
    
}
@end
