/*
 File: GLGravityView.m
 Abstract: This class wraps the CAEAGLLayer from CoreAnimation into a convenient
 UIView subclass. The view content is basically an EAGL surface you render your
 OpenGL scene into.  Note that setting the view non-opaque will only work if the
 EAGL surface has an alpha channel.
 Version: 2.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "GLGravityView.h"
#import "teapot.h"

// CONSTANTS
#define kTeapotScale 4
#define R2D (57.2957795131) //conversion parameter for radian to degree

// MACROS
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define mEULAR_ANGLE_Z_FROM_QUAT_YXZ_CONVNETION(q)  (atan2(-2 * (q[1] * q[2] - q[0] * q[3]), 1 - 2 * (q[1] * q[1] + q[3] * q[3])))

@implementation GLGravityView

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!context || ![EAGLContext setCurrentContext:context])
        {
            return nil;
        }
        
        animating = FALSE;
        displayLink = nil;
        
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    const GLfloat lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
    const GLfloat lightDiffuse[] = {1.0, 0.6, 0.0, 1.0};
    const GLfloat matAmbient[] = {0.6, 0.6, 0.6, 1.0};
    const GLfloat matDiffuse[] = {1.0, 1.0, 1.0, 1.0};
    const GLfloat matSpecular[] = {1.0, 1.0, 1.0, 1.0};
    const GLfloat lightPosition[] = {0.0, 0.0, 1.0, 0.0};
    const GLfloat lightShininess = 100.0, zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
    
    // Configure OpenGL lighting
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matSpecular);
    glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, lightShininess);
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_DEPTH_TEST);
    
    // Configure OpenGL arrays
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glVertexPointer(3 ,GL_FLOAT, 0, teapot_vertices);
    glNormalPointer(GL_FLOAT, 0, teapot_normals);
    glEnable(GL_NORMALIZE);
    
    // Set the OpenGL projection matrix
    glMatrixMode(GL_PROJECTION);
    GLfloat size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
    
    // Make the OpenGL modelview matrix the default
    glMatrixMode(GL_MODELVIEW);
}


- (void)updateQuat0:(float)quat0 quat1:(float)quat1 quat2:(float)quat2 quat3:(float)quat3
{
    quat[0] = quat0;
    quat[1] = quat1;
    quat[2] = quat2;
    quat[3] = quat3;
}

- (void)gluPerspective:(double)fovy :(double)aspect :(double)zNear :(double)zFar
{
    // Start in projection mode.
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    double xmin, xmax, ymin, ymax;
    ymax = zNear * tan(fovy * M_PI / 360.0);
    ymin = -ymax;
    xmin = ymin * aspect;
    xmax = ymax * aspect;
    glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
}

// Updates the OpenGL view
- (void)drawView
{
    GLfloat flt;
    
    // Make sure that you are drawing to the current context
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Setup model view matrix
    glLoadIdentity();
    glTranslatef(0.0, -0.1, -2.0);
    glScalef(kTeapotScale, kTeapotScale, kTeapotScale);
    
    // The quaternion have four elements
    // The first element, quat[0], represents a rotation angle after using acos()
    // The remaining elememts quat[1], quat[2], quat[3] represent the rotation axis of X-Y-Z coordinate system
    
    // Rotate teapot along Y axis
    glRotatef(R2D + self.rotAngle, 0, 1, 0);
    
    // Compute the rotation angle from quat[0]
    flt = (GLfloat) acos(quat[0]);
    
    // void glRotatef(GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
    // Rotate object "angle" degrees along (x, y, z)
    // Should transfer the Invensense coordinate system to OpenGL coordinate system for the rotation axis (x,y,z)
    // OpenGL X = Invensense X <=> quat[1]
    // OpenGL Y = Invensense Z <=> quat[3]
    // OpenGL Z = Invensense -Y <=> -quat[2]
    glRotatef((GLfloat)(2* flt * 180 / 3.1415), (GLfloat)quat[1], (GLfloat) quat[3], (GLfloat) - quat[2]);
    
    // Rotate teapot 90 degree along Y axis, let the direction of spout equal the front of the motion device
    glRotatef(90, 0, 1, 0);
    
    // Draw teapot. The new_teapot_indicies array is an RLE (run-length encoded) version of the teapot_indices array in teapot.h
    for (int i = 0; i < num_teapot_indices; i += new_teapot_indicies[i] + 1)
    {
        glDrawElements(GL_TRIANGLE_STRIP, new_teapot_indicies[i], GL_UNSIGNED_SHORT, &new_teapot_indicies[i+1]);
    }
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    glViewport(0, 0, rect.size.width, rect.size.height);
    
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (BOOL)createFramebuffer
{
    // Generate IDs for a framebuffer object and a color renderbuffer
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    // This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
    // allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    // For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
    glGenRenderbuffersOES(1, &depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if (depthRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
        [displayLink setPreferredFramesPerSecond:30];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        [displayLink invalidate];
        displayLink = nil;
        animating = FALSE;
    }
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
}

@end
