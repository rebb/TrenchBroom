//
//  VertexRenderer.m
//  TrenchBroom
//
//  Created by Kristian Duske on 23.03.11.
//  Copyright 2011 TU Berlin. All rights reserved.
//

#import "VertexRenderer.h"
#import "Vertex.h"
#import "RenderFilter.h"
#import "VBOBuffer.h"
#import "VBOMemBlock.h"
#import "Vector3f.h"
#import "MathCache.h"

static int VerticesPerBlock = 2000;

@interface VertexRenderer (private)

- (int)writeVertex:(Vertex *)theVertex block:(VBOMemBlock *)theBlock offset:(int)offset;
- (void)validate;

@end

@implementation VertexRenderer (private)

- (int)writeVertex:(Vertex *)theVertex block:(VBOMemBlock *)theBlock offset:(int)offset {
    MathCache* cache = [MathCache sharedCache];
    Vector3f* esb = [cache vector3f];
    Vector3f* est = [cache vector3f];
    Vector3f* enb = [cache vector3f];
    Vector3f* ent = [cache vector3f];
    Vector3f* wsb = [cache vector3f];
    Vector3f* wst = [cache vector3f];
    Vector3f* wnb = [cache vector3f];
    Vector3f* wnt = [cache vector3f];

    [esb setFloat:[theVertex vector]];
    [esb subX:-2 y:-2 z:-2];
    
    [est setFloat:[theVertex vector]];
    [est subX:-2 y:-2 z:2];

    [enb setFloat:[theVertex vector]];
    [enb subX:-2 y:2 z:-2];

    [ent setFloat:[theVertex vector]];
    [ent subX:-2 y:2 z:2];
    
    [wsb setFloat:[theVertex vector]];
    [wsb subX:2 y:-2 z:-2];
    
    [wst setFloat:[theVertex vector]];
    [wst subX:2 y:-2 z:2];
    
    [wnb setFloat:[theVertex vector]];
    [wnb subX:2 y:2 z:-2];
    
    [wnt setFloat:[theVertex vector]];
    [wnt subX:2 y:2 z:2];

    // south face
    offset = [theBlock writeVector3f:esb offset:offset];
    offset = [theBlock writeVector3f:est offset:offset];
    offset = [theBlock writeVector3f:wst offset:offset];
    offset = [theBlock writeVector3f:wsb offset:offset];

    // north face
    offset = [theBlock writeVector3f:enb offset:offset];
    offset = [theBlock writeVector3f:wnb offset:offset];
    offset = [theBlock writeVector3f:wnt offset:offset];
    offset = [theBlock writeVector3f:ent offset:offset];
    
    // east face
    offset = [theBlock writeVector3f:enb offset:offset];
    offset = [theBlock writeVector3f:ent offset:offset];
    offset = [theBlock writeVector3f:est offset:offset];
    offset = [theBlock writeVector3f:esb offset:offset];

    // west face
    offset = [theBlock writeVector3f:wsb offset:offset];
    offset = [theBlock writeVector3f:wst offset:offset];
    offset = [theBlock writeVector3f:wnt offset:offset];
    offset = [theBlock writeVector3f:wnb offset:offset];

    // top face
    offset = [theBlock writeVector3f:est offset:offset];
    offset = [theBlock writeVector3f:ent offset:offset];
    offset = [theBlock writeVector3f:wnt offset:offset];
    offset = [theBlock writeVector3f:wst offset:offset];
    
    // bottom face
    offset = [theBlock writeVector3f:enb offset:offset];
    offset = [theBlock writeVector3f:esb offset:offset];
    offset = [theBlock writeVector3f:wsb offset:offset];
    offset = [theBlock writeVector3f:wnb offset:offset];
    
    [cache returnVector3f:esb];
    [cache returnVector3f:est];
    [cache returnVector3f:enb];
    [cache returnVector3f:ent];
    [cache returnVector3f:wsb];
    [cache returnVector3f:wst];
    [cache returnVector3f:wnb];
    [cache returnVector3f:wnt];

    return offset;
}

- (void)validate {
    if (!valid) {
        [vbo deactivate];
        [vbo freeAllBlocks];
        
        [vbo activate];
        [vbo mapBuffer];
        
        VBOMemBlock* block = nil;
        int offset;
        vertexCount = 0;
        
        NSEnumerator* vertexEn = [vertices objectEnumerator];
        Vertex* vertex;
        while ((vertex = [vertexEn nextObject])) {
            if (filter == nil || [filter vertexPasses:vertex]) {
                if ((vertexCount % VerticesPerBlock) == 0) {
                    [block setState:BS_USED_VALID];
                    block = [vbo allocMemBlock:VerticesPerBlock * 3 * sizeof(float)];
                    offset = 0;
                }
                
                offset = [self writeVertex:vertex block:block offset:offset];
                vertexCount += 24;
            }
        }
        
        if (block != nil)
            [block setState:BS_USED_VALID];
        // [vbo pack]; // probably unnecessary
        [vbo unmapBuffer];
        
        valid = YES;
    }
}

@end

@implementation VertexRenderer

- (id)init {
    if (self = [super init]) {
        vbo = [[VBOBuffer alloc] initWithTotalCapacity:0xFFFF];
        vertices = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)addVertex:(Vertex *)theVertex {
    NSAssert(theVertex != nil, @"vertex must not be nil");
    if (![vertices containsObject:theVertex]) {
        [vertices addObject:theVertex];
        [self invalidate];
    }
}

- (void)removeVertex:(Vertex *)theVertex {
    NSAssert(theVertex != nil, @"vertex must not be nil");
    if ([vertices containsObject:theVertex]) {
        [vertices removeObject:theVertex];
        [self invalidate];
    }
}

- (void)setFilter:(id <RenderFilter>)theFilter {
    if (filter == theFilter)
        return;
    
    [filter release];
    filter = [theFilter retain];
    [self invalidate];
}

- (void)render {
    [vbo activate];
    [self validate];
    
    glVertexPointer(3, GL_FLOAT, 0, NULL);
    glDrawArrays(GL_QUADS, 0, vertexCount);
    
    [vbo deactivate];
}

- (void)invalidate {
    valid = NO;
}

- (void)dealloc {
    [filter release];
    [vertices release];
    [vbo release];
    [super dealloc];
}

@end