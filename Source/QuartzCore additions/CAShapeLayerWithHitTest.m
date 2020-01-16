#import "CAShapeLayerWithHitTest.h"

/*! Used by the main ShapeElement (and all subclasses) to do perfect "containsPoint" calculations via Apple's API calls
 
 This will only be called if it's the root of an SVG document and the hit was in the parent view on screen,
 OR if it's inside an SVGGElement that contained the hit
 */
@implementation CAShapeLayerWithHitTest

static CGFloat targetInset = 25;

- (BOOL) containsPoint:(CGPoint)p
{
    if (!self.expend) {
        BOOL boundsContains = CGRectContainsPoint(self.bounds, p); // must be BOUNDS because Apple pre-converts the point to local co-ords before running the test
        
        if( boundsContains )
        {
            BOOL pathContains = CGPathContainsPoint(self.path, NULL, p, false);
            
            if( pathContains )
            {
                for( CALayer* subLayer in self.sublayers )
                {
                    SVGKitLogVerbose(@"...contains point, Apple will now check sublayer: %@", subLayer);
                }
                return TRUE;
            }
        }
        return FALSE;
    }
    
	BOOL boundsContains = CGRectContainsPoint(self.expandedBounds, p);
	if( boundsContains )
	{
        /// 获取边缘大小
        CGRect boundingBox = CGPathGetBoundingBox(self.path);
        
        CGFloat targetWidth = CGRectGetWidth(boundingBox) + targetInset * 2;
        CGFloat targetHeight = CGRectGetHeight(boundingBox) + targetInset * 2;
        
        /// 缩放比例
        CGFloat scaleX = targetWidth / boundingBox.size.width;
        CGFloat scaleY = targetHeight / boundingBox.size.height;
        /// 放大
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleX, scaleY);
        /// 转换为放大后
        CGPathRef pathRef = CGPathCreateCopyByTransformingPath(self.path, &scaleTransform);
        
        CGPoint OCP = CGPointMake(CGRectGetMinX(boundingBox) + CGRectGetWidth(boundingBox) / 2, CGRectGetMinY(boundingBox) + CGRectGetHeight(boundingBox));
        CGRect fBoundingBox = CGPathGetBoundingBox(pathRef);
        CGPoint FCP = CGPointMake(CGRectGetMinX(fBoundingBox) + CGRectGetWidth(fBoundingBox) / 2, CGRectGetMinY(fBoundingBox) + CGRectGetHeight(fBoundingBox));
        
        /// 平移回到原中心点
        CGFloat x = FCP.x - OCP.x;
        CGFloat y = FCP.y - OCP.y;
        CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(-x, -y);
        CGPathRef finalPathRef = CGPathCreateCopyByTransformingPath(pathRef, &moveTransform);
        BOOL pathContains = CGPathContainsPoint(finalPathRef, NULL, p, false);
        CGPathRelease(pathRef);
        CGPathRelease(finalPathRef);
		if( pathContains )
		{
			for( CALayer* subLayer in self.sublayers )
			{
				SVGKitLogVerbose(@"...contains point, Apple will now check sublayer: %@", subLayer);
			}
			return TRUE;
		}
	}
	return FALSE;
}

- (CGRect)expandedBounds {
    return CGRectInset(self.bounds, -targetInset, -targetInset);
}
@end
