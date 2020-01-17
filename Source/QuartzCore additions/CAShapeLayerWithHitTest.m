#import "CAShapeLayerWithHitTest.h"

/*! Used by the main ShapeElement (and all subclasses) to do perfect "containsPoint" calculations via Apple's API calls
 
 This will only be called if it's the root of an SVG document and the hit was in the parent view on screen,
 OR if it's inside an SVGGElement that contained the hit
 */
@implementation CAShapeLayerWithHitTest

static CGFloat targetInset = 15;

- (BOOL) containsPoint:(CGPoint)p
{
    if (self.expend) {
        return CGRectContainsPoint(self.expandedBounds, p);
    }
    
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
//	BOOL boundsContains = CGRectContainsPoint(self.expandedBounds, p);
//	if( boundsContains )
//	{
//        /// 获取边缘大小
//        CGRect boundingBox = CGPathGetPathBoundingBox(self.path);
//
//        CGFloat targetWidth = CGRectGetWidth(boundingBox) + targetInset * 2;
//        CGFloat targetHeight = CGRectGetHeight(boundingBox) + targetInset * 2;
//
//        /// 缩放比例
//        CGFloat scaleX = targetWidth / CGRectGetWidth(boundingBox);
//        CGFloat scaleY = targetHeight / CGRectGetHeight(boundingBox);
//        /// 放大
//        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleX, scaleY);
//        /// 转换为放大后
//        CGPathRef pathRef = CGPathCreateCopyByTransformingPath(self.path, &scaleTransform);
//
//        CGPoint OCP = CGPointMake(CGRectGetMidX(boundingBox), CGRectGetMidY(boundingBox));
//        CGRect fBoundingBox = CGPathGetPathBoundingBox(pathRef);
//        CGPoint FCP = CGPointMake(CGRectGetMidX(fBoundingBox), CGRectGetMidY(fBoundingBox));
//
//        /// 平移回到原中心点
//        CGFloat x = FCP.x - OCP.x;
//        CGFloat y = FCP.y - OCP.y;
//        CGAffineTransform moveTransform =  CGAffineTransformMakeTranslation(-x, -y);
//        CGPathRef finalPathRef = CGPathCreateCopyByTransformingPath(pathRef, &moveTransform);
//        BOOL pathContains = CGPathContainsPoint(finalPathRef, NULL, p, FALSE);
//        NSLog(@"layerName:%@ \npath:%@ \npathRef:%@ \nfinalPathRef:%@ \npathContains:%d \nscaleX:%f \nscaleY:%f \npointX:%f \npointY:%f \nboundingBoxX:%f \nboundingBoxY:%f \nboundingBoxW:%f \nboundingBoxH:%f \nboundingBoxX:%f \nboundingBoxY:%f \nboundingBoxW:%f \nboundingBoxH:%f \nmx:%f \nmy:%f", self.name, self.path, pathRef, finalPathRef, pathContains, scaleX, scaleY, p.x, p.y, CGRectGetMinX(boundingBox), CGRectGetMinY(boundingBox), CGRectGetWidth(boundingBox), CGRectGetHeight(boundingBox), CGRectGetMinX(fBoundingBox), CGRectGetMinY(fBoundingBox), CGRectGetWidth(fBoundingBox), CGRectGetHeight(fBoundingBox), x, y);
//
//        CGPathRelease(pathRef);
//        CGPathRelease(finalPathRef);
//
//
//		if( pathContains )
//		{
//			for( CALayer* subLayer in self.sublayers )
//			{
//				SVGKitLogVerbose(@"...contains point, Apple will now check sublayer: %@", subLayer);
//			}
//			return TRUE;
//		}
//	}
//	return FALSE;
}

- (CGRect)expandedBounds {
    return CGRectInset(self.bounds, -targetInset, -targetInset);
}
@end
