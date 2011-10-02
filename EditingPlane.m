//
//  EditingPlane.m
//  TrenchBroom
//
//  Created by Kristian Duske on 01.10.11.
//  Copyright 2011 TU Berlin. All rights reserved.
//

#import "EditingPlane.h"
#import "Camera.h"

@implementation EditingPlane

- (id)initWithCamera:(Camera *)theCamera {
    NSAssert(theCamera != nil, @"camera must not be nil");
    
    if ((self = [self init])) {
        backAxis = closestAxisV3f([theCamera direction]);
        
        if (backAxis == &XAxisPos) {
            frontAxis = &XAxisNeg;
            xAxis = &YAxisPos;
            yAxis= &ZAxisPos;
            upAxis = &ZAxisPos;
            rightAxis = &YAxisNeg;
            downAxis = &ZAxisNeg;
            leftAxis = &YAxisPos;
        } else if (backAxis == &XAxisNeg) {
            frontAxis = &XAxisPos;
            xAxis = &YAxisPos;
            yAxis= &ZAxisPos;
            upAxis = &ZAxisPos;
            rightAxis = &YAxisPos;
            downAxis = &ZAxisNeg;
            leftAxis = &YAxisNeg;
        } else if (backAxis == &YAxisPos) {
            frontAxis = &YAxisNeg;
            xAxis = &XAxisPos;
            yAxis= &ZAxisPos;
            upAxis = &ZAxisPos;
            rightAxis = &XAxisPos;
            downAxis = &ZAxisNeg;
            leftAxis = &XAxisNeg;
        } else if (backAxis == &YAxisNeg) {
            frontAxis = &YAxisPos;
            xAxis = &XAxisPos;
            yAxis= &ZAxisPos;
            upAxis = &ZAxisPos;
            rightAxis = &XAxisNeg;
            downAxis = &ZAxisNeg;
            leftAxis = &XAxisPos;
        } else if (backAxis == &ZAxisPos) {
            frontAxis = &ZAxisNeg;
            const TVector3f* right = [theCamera right];
            if (fabsf(right->x) > fabsf(right->y)) {
                xAxis = &XAxisPos;
                yAxis = &YAxisPos;
                
                if (right->x > 0) {
                    upAxis = &YAxisNeg;
                    rightAxis = &XAxisPos;
                    downAxis = &YAxisPos;
                    leftAxis = &XAxisNeg;
                } else {
                    upAxis = &YAxisPos;
                    rightAxis = &XAxisNeg;
                    downAxis = &YAxisNeg;
                    leftAxis = &XAxisPos;
                }
            } else {
                xAxis = &YAxisPos;
                yAxis = &XAxisPos;
                
                if (right->y > 0) {
                    upAxis = &XAxisPos;
                    rightAxis = &YAxisPos;
                    downAxis = &XAxisNeg;
                    leftAxis = &YAxisNeg;
                } else {
                    upAxis = &XAxisNeg;
                    rightAxis = &YAxisNeg;
                    downAxis = &XAxisPos;
                    leftAxis = &YAxisPos;
                }
            }
        } else if (backAxis == &ZAxisNeg) {
            frontAxis = &ZAxisPos;
            const TVector3f* right = [theCamera right];
            if (fabsf(right->x) > fabsf(right->y)) {
                xAxis = &XAxisPos;
                yAxis = &YAxisPos;
                
                if (right->x > 0) {
                    upAxis = &YAxisPos;
                    rightAxis = &XAxisPos;
                    downAxis = &YAxisNeg;
                    leftAxis = &XAxisNeg;
                } else {
                    upAxis = &YAxisNeg;
                    rightAxis = &XAxisNeg;
                    downAxis = &YAxisPos;
                    leftAxis = &XAxisPos;
                }
            } else {
                xAxis = &YAxisPos;
                yAxis = &XAxisPos;
                
                if (right->y > 0) {
                    upAxis = &XAxisNeg;
                    rightAxis = &YAxisPos;
                    downAxis = &XAxisPos;
                    leftAxis = &YAxisNeg;
                } else {
                    upAxis = &XAxisPos;
                    rightAxis = &YAxisNeg;
                    downAxis = &XAxisNeg;
                    leftAxis = &YAxisPos;
                }
            }
        }
    }
    
    return self;
}

- (const TVector3f *)frontAxis {
    return frontAxis;
}

- (const TVector3f *)backAxis {
    return backAxis;
}

- (const TVector3f *)upAxis {
    return upAxis;
}

- (const TVector3f *)rightAxis {
    return rightAxis;
}

- (const TVector3f *)downAxis {
    return downAxis;
}

- (const TVector3f *)leftAxis {
    return leftAxis;
}

- (float)intersectWithRay:(const TRay *)theRay planePosition:(const TVector3f *)thePlanePos {
    TPlane plane;
    plane.point = *thePlanePos;
    plane.norm = *frontAxis;
    
    return intersectPlaneWithRay(&plane, theRay);
}

@end