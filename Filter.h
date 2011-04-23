//
//  Filter.h
//  TrenchBroom
//
//  Created by Kristian Duske on 17.04.11.
//  Copyright 2011 TU Berlin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol Brush;

@protocol Filter <NSObject>

- (BOOL)brushPasses:(id <Brush>)brush;

@end