//
//  QRCodeOutlineView.m
//  Taodiandian
//
//  Created by workMac on 15/6/26.
//  Copyright (c) 2015年 myself. All rights reserved.
//

#import "QRCodeOutlineView.h"

@implementation QRCodeOutlineView
{
    CAShapeLayer *_outline;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _outline = [CAShapeLayer layer];
        _outline.strokeColor = [UIColor redColor].CGColor;
        _outline.fillColor = [UIColor clearColor].CGColor;
        _outline.lineWidth = 5.0;
        [self.layer addSublayer:_outline];
    }
    return self;
}

- (void)setCorners:(NSArray *)corners
{
    if (_corners != corners) {
        _corners = corners;
        _outline.path = [self creatPathFromPoints:_corners].CGPath;
    }
}

- (UIBezierPath*)creatPathFromPoints:(NSArray*)points
{
    NSUInteger pointsCount;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (!points) {
        return nil;
    }else{
        pointsCount = points.count;
        if (pointsCount == 1) {
            return nil;
        }else{
            CGPoint firstPoint = [[points firstObject]CGPointValue];
            [path moveToPoint:firstPoint];
            for (int i = 1; i < pointsCount; i ++) {
                [path addLineToPoint:[points[i] CGPointValue]];
            }
            [path addLineToPoint:firstPoint];
        }
    }
    
    return path;
}

@end
