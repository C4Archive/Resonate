//
//  C4View.h
//  C4iOS
//
//  Created by Travis Kirton on 12-02-14.
//  Copyright (c) 2012 POSTFL. All rights reserved.
//

#import <UIKit/UIKit.h>
/** The C4View is a subclass of UIView, which defines a rectangular area on the screen and the interfaces for managing the content in that area. At runtime, a view object handles the rendering of any content in its area and also handles any interactions with that content. The C4View class itself provides basic behavior for filling its rectangular area with a background color.
 
 Because view objects are the main way your application interacts with the user, they have a number of responsibilities. Here are just a few:
 
 You should never have to construct a C4View yourself. Instead, choose the appropriate C4 object and work from there.

 C4Views conform to the C4Notification protocol which means that all views will have the ability to post and receive notifications. Furthermore, C4View defines basic methods that deal with basic animations for the following properties:
 
 @property center
 @property frame
 @property bounds
 @property transform
 @property alpha
 @property backgroundColor
 @property contentStretch
 
 @warning *Note:* For more information on the above properties, consult the UIView class documentation.
 
 C4Views also have a custom animation options property which allows for setting of basic characteristics such as AUTOREVERSE, REPEAT, as well as delays and durations. These properties are:
 
 @property animationDelay
 @property animationDuration
 @property animationOptions

*/
@interface C4View : UIView <C4Notification, C4Gesture, C4MethodDelay, NSCopying, C4AddSubview> {
}

/// @name Convenience Methods

/** A method to call instead of overriding any of the standard initializers.
 
 It is easier and safer to override this method than to override something like -(id)init, or -(id)initWithFrame, etc...
 */
-(void)setup;

/** A method to call when you want to test simple things.
 
 Override this method to test small bits of fuctionality. For example, you could call this method to make sure another call is working by doing the following in the .m file of your subclass:
 
 -(void)test {
 C4Log(@"test was run");
 }
 */
-(void)test;

/** A method to remove another object from its view.
 
 For the object in question, use this method to remove any visible object that was previously added to it as a subview.
 
 @param visualObject the visible object to remove from its parent view
 */
-(void)removeObject:(id)visualObject;

/** A method to remove an array of objects from their view.
 
 This will run the removeObject: method on each object in an array.
 
 @param array the array of visible objects to remove from their parent view
 */
-(void)removeObjects:(NSArray *)array;


/** A convenience method used for handling the rotation of a visual object's view after its z-rotation has changed.
 
 You shouldn't use this method, it will be deprecated in future versions.
 
 @param rotation the value (in radians) to rotate the receiver
 */
-(void)rotationDidFinish:(CGFloat)rotation;

/// @name Setting A Control's Origin Point
/** The origin point of the view.
 
 Takes a CGPoint and animates the view's origin position from its current point to the new point.
 
 This method positions the origin point of the current view by calculating the difference between this point and what the view's new center point will be. It then initiates the animation by setting the displaced new center point.
 */
@property (nonatomic) CGPoint origin;

#pragma mark Animation Properties
/// @name Configuring A Control's Animation Properties

/** The duration of the view's animations, measured in seconds.
 
 All animations that occur will use this value as their duration.
 
 For immediate animations set this property to 0.0f;
 
 Defaults to 0.0f
 
 */
@property (nonatomic) CGFloat animationDuration;

/** The time to wait before the view's animations begin, measured in seconds.
 
 All animations that occur will use this value as their delay.
 
 For immediate animations set this property to 0.0f;
 
 Defaults to 0.0f
 */
@property (atomic) CGFloat animationDelay;

/** The options for which the view should use in its animations.
 
 An integer which can be constructed from bitmasked values
 
 The available animation options are a limited subset of UIViewAnimationOptions and include:
 - ALLOWSINTERACTION
 - BEGINCURRENT (default)
 - REPEAT
 - AUTOREVERSE
 - EASEINOUT
 - EASEIN
 - EASEOUT
 - LINEAR
 
 This value can have a variety of options attached to it by using integer bitmasks. For example, to set an animation which will auto reverse and repeat:
 view.animationOptions = AUTOREVERSE | REPEAT;
 
 @warning *Note:* All animation options should be set at the same time using the | bitmask operator. Animation options should never be set in the following way:
 view.animationOptions = AUTOREVERSE;
 view.animationOptions = REPEAT;
 */
@property (nonatomic) NSUInteger animationOptions;

/** The number of times an animation autorepeats.
 
 @warning *Note:* This parameter is currently unused.
 */
@property (nonatomic) CGFloat repeatCount;

#pragma mark Shadow Properties
///@name Shadow Properties

/**Specifies the blur radius used to render the receiver’s shadow.
 
 This applies to the shadow of the contents of the layer, and not specifically the text.
 */
@property (readwrite, nonatomic) CGFloat shadowRadius;

/**Specifies the opacity of the receiver’s shadow. Animatable.
 
 This applies to the shadow of the contents of the layer, and not specifically the text.
 */
@property (readwrite, nonatomic) CGFloat shadowOpacity;
/**The shadow color of the text.
 
 The default value for this property is nil, which indicates that no shadow is drawn. In addition to this property, you may also want to change the default shadow offset by modifying the shadowOffset property. Text shadows are drawn with the specified offset and color and no blurring.
 */
@property (readwrite, strong, nonatomic) UIColor *shadowColor;

/**The shadow offset (measured in points) for the text.
 
 The shadow color must be non-nil for this property to have any effect. The default offset size is (0, -1), which indicates a shadow one point above the text. Text shadows are drawn with the specified offset and color and no blurring.
 */
@property (readwrite, nonatomic) CGSize shadowOffset;

/**Defines the shape of the shadow. Animatable.
 
 Unlike most animatable properties, shadowPath does not support implicit animation.
 
 If the value in this property is non-nil, the shadow is created using the specified path instead of the layer’s composited alpha channel. The path defines the outline of the shadow. It is filled using the non-zero winding rule and the current shadow color, opacity, and blur radius.
 
 Specifying an explicit path usually improves rendering performance.
 
 The default value of this property is NULL.
 */
@property (readwrite, nonatomic) CGPathRef shadowPath;

#pragma mark Other Properties
///@name Other Properties
/**Determines if the sublayers are clipped to the receiver’s bounds. Animatable.
 
 If YES, an implicit mask matching the layer bounds is applied to the layer, including the effects of the cornerRadius property. If YES and a mask property is specified, the two masks are multiplied to get the actual mask values. Defaults to NO.
 */
@property (readwrite, nonatomic) BOOL masksToBounds;

/**Specifies a transform applied to each sublayer when rendering. Animatable.
 
 This property is typically used as the projection matrix to add perspective and other viewing effects to the receiver. Defaults to the identity transform.
 */
@property (readwrite, nonatomic) CATransform3D layerTransform;

/**An optional layer whose alpha channel is used as a mask to select between the layer's background and the result of compositing the layer's contents with its filtered background.
 
 Defaults to nil.
 */
@property (readwrite, nonatomic, assign) C4Control *mask;

/** The width of the receiver's frame.
 */
@property (readonly, nonatomic) CGFloat width;

/** The height of the receiver's frame.
 */
@property (readonly, nonatomic) CGFloat height;

/**Specifies the width of the receiver’s border. Animatable.
 
 The border is drawn inset from the receiver’s bounds by borderWidth. It is composited above the receiver’s contents and sublayers and includes the effects of the cornerRadius property. The default is 0.0.
 */
@property (readwrite, nonatomic) CGFloat borderWidth;

/**Specifies a radius used to draw the rounded corners of the receiver’s background. Animatable.
 
 If the radius is greater than 0 the background is drawn with rounded corners. The default value is 0.0.
 */
@property (readwrite, nonatomic) CGFloat cornerRadius;

/**Specifies the receiver’s position on the z axis. Animatable.
 
 Defaults to 0.
 */
@property (readwrite, nonatomic) CGFloat zPosition;

/**Specifies the receiver's z-axis rotation value. Animatable.
 
 Setting this value will rotate the receiver around its anchorPoint.
 */
@property (readwrite, nonatomic) CGFloat rotation;

/**Specifies the receiver's x-axis rotation value. Animatable.
 
 Setting this value will rotate the receiver around its anchorPoint.
 */
@property (readwrite, nonatomic) CGFloat rotationX;

/**Specifies the receiver's y-axis rotation value. Animatable.
 
 Setting this value will rotate the receiver around its anchorPoint.
 */
@property (readwrite, nonatomic) CGFloat rotationY;

/**Specifies the perspective distance for x and y axis rotations.
 
 Technically, this will set the perspective transform component of the receiver's transform to 1/value (i.e. the new value that is set). It will perform the following action:
 
 `CATransform3D t = self.transform;
 if(perspectiveDistance != 0.0f) t.m34 = 1/self.perspectiveDistance;
 else t.m34 = 0.0f;
 self.transform = t;`
 
 Defaults to 0.
 */
@property (readwrite, nonatomic) CGFloat perspectiveDistance;

/**Defines the anchor point of the layer's bounds rectangle. Animatable.
 
 Described in the unit coordinate space. The value of this property is specified in points. Defaults to (0.5, 0.5), the center of the bounds rectangle.
 
 See “Layer Geometry and Transforms” in Core Animation Programming Guide for more information on the relationship between the bounds, anchorPoint and position properties.
 */
@property (readwrite, nonatomic) CGPoint anchorPoint;

/**The color of the receiver’s border. Animatable.
 
 Defaults to opaque black.
 
 The value of this property is retained using the Core Foundation retain/release semantics. This behavior occurs despite the fact that the property declaration appears to use the default assign semantics for object retention.
 */
@property (readwrite, nonatomic, weak) UIColor *borderColor;

#pragma mark - Rendering into a Context
/**Renders the receiver and its sublayers into the specified context.
 
 This method renders the contents of a C4View directly from the layer tree, ignoring any animations added to the render tree. It essentially binds to the `renderInContext` method of the underlying C4Layer.
 
 This method is used for rendering objects into a graphics context before either creating an image or saving drawing to external files.
 
 @param context The graphics context to use to render the layer.
 */
-(void)renderInContext:(CGContextRef)context;

#pragma mark - Default Style
///@name Default Style
/**Returns the appearance proxy for the object, cast as a C4View rather than the standard (id) cast provided by UIAppearance.
 
 You use this method to grab the appearance object that allows you to change the default style for C4View objects.
 
 @return The appearance proxy for the receiver, cast as a C4View.
 */
+(C4View *)defaultStyle;
@end
