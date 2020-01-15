#import "CAShapeLayerWithHitTest.h"

/*! Used by the main ShapeElement (and all subclasses) to do perfect "containsPoint" calculations via Apple's API calls
 
 This will only be called if it's the root of an SVG document and the hit was in the parent view on screen,
 OR if it's inside an SVGGElement that contained the hit
 */
@implementation CAShapeLayerWithHitTest

static CGFloat targetInset = 25;

- (BOOL) containsPoint:(CGPoint)p
{
	BOOL boundsContains = CGRectContainsPoint(self.expandedBounds, p);
	
	if( boundsContains )
	{
        /// 获取边缘大小
        CGRect boundingBox = CGPathGetBoundingBox(self.path);
        CGFloat targetWidth = boundingBox.size.width + targetInset * 2;
        CGFloat targetHeight = boundingBox.size.height + targetInset * 2;
        
        /// 缩放比例
        CGFloat scaleX = targetWidth / boundingBox.size.width;
        CGFloat scaleY = targetHeight / boundingBox.size.height;
        /// 放大
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleX, scaleY);
        /// 转换为放大后
        CGPathRef pathRef = CGPathCreateCopyByTransformingPath(self.path, &scaleTransform);
        /// 平移回到原中心点
        CGFloat x = boundingBox.size.width*scaleX - boundingBox.size.width;
        CGFloat y = boundingBox.size.height*scaleY - boundingBox.size.height;
        CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(-x/2, -y/2);
        CGPathRef finalPathRef = CGPathCreateCopyByTransformingPath(pathRef, &moveTransform);
        BOOL pathContains = CGPathContainsPoint(finalPathRef, NULL, p, false);
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
