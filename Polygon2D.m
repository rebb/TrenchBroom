//
//  Polygon2D.m
//  TrenchBroom
//
//  Created by Kristian Duske on 28.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Polygon2D.h"
#import "Edge2D.h"
#import "Vector2f.h"
#import "Polygon2DIS.h"

@implementation Polygon2D

+ (Polygon2D *)polygonWithVertices:(NSArray *)someVertices {
    return [[[Polygon2D alloc] initWithVertices:someVertices] autorelease];
}

+ (Polygon2D *)polygonWithSortedEdges:(Edge2D *)someEdges {
    return [[[Polygon2D alloc] initWithSortedEdges:someEdges] autorelease];
}

- (id)initWithVertices:(NSArray *)someVertices {
    if (someVertices == nil)
        [NSException raise:NSInvalidArgumentException format:@"vertex array must not be nil"];

    int vertexCount = [someVertices count];
    if (vertexCount < 3)
        [NSException raise:NSInvalidArgumentException format:@"vertex array must contain at least three vertices"];
    
    if (self = [super init]) {
        Vector2f* start = [someVertices objectAtIndex:0];
        Vector2f* end = [someVertices objectAtIndex:1];
        Edge2D* first = [[Edge2D alloc] initWithStart:start end:end];
        Edge2D* current = first;
        
        edges = first;
        Vector2f* smallest = start;
        
        for (int i = 2; i <= vertexCount; i++) {
            start = end;
            end = [someVertices objectAtIndex:i % vertexCount];
            current = [current appendEdgeWithStart:start end:end];
            if ([start isSmallerThan:smallest]) {
                edges = current;
                smallest = start;
            }
        }
        
        [current close:first];
    }
    
    return self;
}

- (id)initWithSortedEdges:(Edge2D *)someEdges {
    if (someEdges == nil)
        [NSException raise:NSInvalidArgumentException format:@"edge list must not be nil"];

    if (self = [super init]) {
        edges = [someEdges retain];
    }
    
    return self;
}

- (NSArray *)vertices {
    NSMutableArray* vertices = [[NSMutableArray alloc] init];
    Edge2D* current = edges;
    do {
        [vertices addObject:[current startVertex]];
        current = [current next];
    } while (current != edges);
    
    return [vertices autorelease];
}

- (Edge2D *)edges {
    return edges;
}

- (Polygon2D *)intersectWith:(Polygon2D *)aPolygon {
    if (aPolygon == nil)
        [NSException raise:NSInvalidArgumentException format:@"polygon must not be nil"];

    Polygon2DIS* polygonIntersection = [[Polygon2DIS alloc] initWithPolygon1:self polygon2:aPolygon];
    Polygon2D* intersection = [polygonIntersection intersection];
    [polygonIntersection release];

    return intersection;
}

- (void)dealloc {
    // open the polygon to avoid reference cycle
    [edges open];
    [edges release];
    [super dealloc];
}
@end