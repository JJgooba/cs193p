//
//  SetCardView.m
//  SuperCard
//
//  Created by JJ on 4/12/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "SetCardView.h"

@implementation SetCardView

#pragma mark - initialization stuff

- (void)setup
{
    NSLog(@"blah");
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw; //invokes setNeedsDisplay when bounds change
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    [self setup];
}

#pragma mark - Set Card Properties

-(void)setNumber:(NSNumber *)number
{
    _number = number;
    [self setNeedsDisplay];
}
-(void)setSymbol:(NSString *)symbol
{
    _symbol = symbol;
    [self setNeedsDisplay];
}
-(void)setShading:(NSString *)shading
{
    _shading = shading;
    [self setNeedsDisplay];
}
-(void)setColor:(NSString *)color
{
    _color = color;
    [self setNeedsDisplay];
}

-(UIColor *)colorType //returns UIColor based on color string property
{
    if ([self.color isEqualToString:@"green"]){
        return [UIColor greenColor];
    } else if ([self.color isEqualToString:@"red"])
        return [UIColor redColor];
    else if ([self.color isEqualToString:@"purple"])
        return [UIColor purpleColor];
    else
        return nil;
}

-(BOOL) isStriped { return ([@"striped" isEqualToString:self.shading]); }
-(BOOL) isSolid { return ([@"solid" isEqualToString:self.shading]); }
-(BOOL) isOpen { return ([@"open" isEqualToString:self.shading]); }

-(BOOL) isOval { return ([@"oval" isEqualToString:self.symbol]); }
-(BOOL) isDiamond { return ([@"diamond" isEqualToString:self.symbol]); }
-(BOOL) isSquiggle { return ([@"squiggle" isEqualToString:self.symbol]); }

#pragma mark - Drawing Properties

static const float shortDimensionScaleFactor = 0.80;
static const float longDimensionScaleFactor = 0.80;
static const float symbolScaleFactor = 0.9;

-(CGFloat)shortDimension //returns the length of the shorter bounds dimension
{ return self.bounds.size.height > self.bounds.size.width ? self.bounds.size.width : self.bounds.size.height; }

-(CGFloat)shortDimensionOffset
{ return [self shortDimension] * ((1.0 - shortDimensionScaleFactor )/2.0); }

-(CGFloat)scaledShortDimension
{ return ([self shortDimension] * shortDimensionScaleFactor); }

-(CGFloat)longDimension //returns the length of the shorter bounds dimension
{ return self.bounds.size.height > self.bounds.size.width ? self.bounds.size.height : self.bounds.size.width; }

-(CGFloat)longDimensionOffset
{ return (([self longDimension] * (1.0 - longDimensionScaleFactor)/2.0) + ((3-[self.number intValue]) * ([self longDimension] * longDimensionScaleFactor / 6.0))); }

-(CGFloat)scaledlongDimension
{ return ([self longDimension] * longDimensionScaleFactor)/3.0; }

-(BOOL) tall { return self.bounds.size.height > self.bounds.size.width; }
-(BOOL) wide {return self.bounds.size.width > self.bounds.size.height;}

-(CGPoint)startPoint
{
    return CGPointMake(self.bounds.size.width * 0.1, self.bounds.size.height * 0.1);
}

#pragma mark - Drawing Actions

static const float lineWidthScaleFactor = 0.015;

-(void)pushContextAndRotate90deg
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.bounds.size.width, 0);
    CGContextRotateCTM(context, M_PI_2);
}

-(void)popContext
{
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

-(CGRect)frame:(int)i //returns frame to draw object #i in
{
    CGPoint startPoint;
    CGRect frameRect;
    startPoint.x = [self longDimensionOffset] + [self scaledlongDimension] * (i-1) + ([self scaledlongDimension] * (1.0 - symbolScaleFactor) * 0.5); //leaves a small border (10%), then indents based on which symbol number we will draw
    startPoint.y = [self shortDimensionOffset];
    frameRect = CGRectMake(startPoint.x, startPoint.y, [self scaledlongDimension] * symbolScaleFactor, [self scaledShortDimension]);
    return frameRect;
}

-(UIBezierPath *)drawOvalnumber:(int)i
{
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:[self frame:i]];
    ovalPath.lineWidth = [self longDimension] * lineWidthScaleFactor; //set line width for symbol
    [ovalPath stroke]; //draw the symbol
    return ovalPath;  // return the path for addition to other paths
}

static const float curveScaleFactor = 1.5;
-(UIBezierPath *)drawSquiggle:(int)i
{
    CGPoint startPoint, endPoint, cp1, cp2;
    CGRect frameRect;
    startPoint.x = [self longDimensionOffset] + [self scaledlongDimension] * (i-1) + ([self scaledlongDimension] / 1.3);
    startPoint.y = [self shortDimensionOffset];
    frameRect = CGRectMake(startPoint.x, startPoint.y, [self scaledlongDimension] * symbolScaleFactor, [self scaledShortDimension]);
    

    endPoint.x = [self longDimensionOffset] + [self scaledlongDimension] * (i-1) + ([self scaledlongDimension] / 2.4);
    endPoint.y = [self shortDimension] - startPoint.y;
    cp1.x = endPoint.x - frameRect.size.width * curveScaleFactor;
    cp1.y = (endPoint.y + startPoint.y) / 2.0;
    cp2.x = endPoint.x + frameRect.size.width / curveScaleFactor;
    cp2.y = (endPoint.y + startPoint.y) / 2.0;
    
    UIBezierPath *squigglePath = [UIBezierPath bezierPath];
    squigglePath.lineWidth = [self longDimension] * lineWidthScaleFactor; //set line width for symbol

    [squigglePath moveToPoint:startPoint];
    [squigglePath addCurveToPoint:endPoint controlPoint1:cp1 controlPoint2:cp2];
    cp1.x = endPoint.x - frameRect.size.width / curveScaleFactor;
    cp2.x = endPoint.x + frameRect.size.width * curveScaleFactor;
    [squigglePath addCurveToPoint:startPoint controlPoint1:cp2 controlPoint2:cp1];
    [squigglePath stroke];
    return squigglePath;
}

-(UIBezierPath *)drawDiamond:(int)i
{
    CGRect diamondRect = [self frame:i];
    UIBezierPath *diamondPath = [[UIBezierPath alloc] init];
    [diamondPath moveToPoint:CGPointMake(diamondRect.origin.x + diamondRect.size.width / 2.0, diamondRect.origin.y)]; //top center
    [diamondPath addLineToPoint:CGPointMake(diamondRect.origin.x, diamondRect.origin.y + diamondRect.size.height / 2.0)]; //middle left
    [diamondPath addLineToPoint:CGPointMake(diamondRect.origin.x + diamondRect.size.width / 2.0, diamondRect.origin.y + diamondRect.size.height)]; //bottom center
    [diamondPath addLineToPoint:CGPointMake(diamondRect.origin.x + diamondRect.size.width, diamondRect.origin.y + diamondRect.size.height / 2.0)]; //middle right
    [diamondPath closePath];
    [diamondPath stroke];
    return diamondPath;
}

-(void)stripePath:(UIBezierPath *)thePath //adds stripes to the path
{
    thePath.lineWidth = [self longDimension]*.002; //set appropriate stripe width
    for (int i = 0; i < 40; i++) {
        [thePath moveToPoint:CGPointMake(0,[self longDimension] * (i/40.0))];
        [thePath addLineToPoint:CGPointMake([self longDimension],[self longDimension] * (i/40.0))];
    }
    [thePath stroke];
}

-(void)fillPath:(UIBezierPath *)thePath
{
    [[self colorType] setFill];
    [thePath fill];
}

#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 12.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self setup];
    UIBezierPath *thePath = [[UIBezierPath alloc] init];
    if ([self tall])
        [self pushContextAndRotate90deg];
    
    [[self colorType] setStroke]; //set color

    for (int i = 1; i <= [self.number integerValue]; i++)
    {
        if ([self isOval])
            [thePath appendPath:[self drawOvalnumber:i]]; //add the oval(s)
        if ([self isSquiggle])
            [thePath appendPath:[self drawSquiggle:i]];
        if ([self isDiamond])
            [thePath appendPath:[self drawDiamond:i]];

    }
    [thePath addClip];

    if ([self isStriped])
        [self stripePath:thePath];
    if ([self isSolid])
        [self fillPath:thePath];
    if ([self tall])
        [self popContext];
    
}


@end
