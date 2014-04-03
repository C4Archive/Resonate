//
//  C4Switch.h
//  C4iOS
//
//  Created by moi on 13-03-05.
//  Copyright (c) 2013 POSTFL. All rights reserved.
//

#import "C4Control.h"
/**You use the C4Switch class to create and manage the On/Off buttons you see, for example, in the preferences (Settings) for such services as Airplane Mode. These objects are known as switches.
 
 The C4Switch class declares a property and a method to control its on/off state. As with C4Slider, when the user manipulates the switch control (“flips” it) a VALUECHANGED event is generated, which results in the control (if properly configured) sending an action message.
 
 You can customize the appearance of the switch by changing the color used to tint the switch when it is in the on position.
 */
@interface C4Switch : C4Control <C4UIElement>

#pragma mark - Creating Switches
///@name Creating Switches
/**Creates and returns a C4Switch object.
 @return A new C4Switch.
 */
+(C4Switch *)switch;

/**Creates and returns a C4Switch object.

 C4Switch overrides the frame and enforces a size appropriate for the control.
 @param frame A rectangle defining the frame of the C4Switch object. The size components of this rectangle are ignored.
 @return a new C4Switch.
 */
+(C4Switch *)switch:(CGRect)frame;

#pragma mark - Initializing the Switch Object
///@name Initializing the Switch Object
/**Returns an initialized switch object.
 
 C4Switch overrides initWithFrame: and enforces a size appropriate for the control.

 @param frame A rectangle defining the frame of the C4Switch object. The size components of this rectangle are ignored.
 @return An initialized UISwitch object or nil if the object could not be initialized.
 */
-(id)initWithFrame:(CGRect)frame;

#pragma mark - Setting the Off/On State
///@name Setting the Off/On State
/**A Boolean value that determines the off/on state of the switch.
 
 This property allows you to retrieve and set (without animation) a value determining whether the C4Switch object is on or off.
*/
@property (readwrite, nonatomic, getter=isOn) BOOL on;

/**Set the state of the switch to On or Off, optionally animating the transition.
 
 Setting the switch to either position does not result in an action message being sent.

 @param on YES if the switch should be turned to the On position; NO if it should be turned to the Off position. If the switch is already in the designated position, nothing happens.
 @param animated YES to animate the “flipping” of the switch; otherwise NO.
 */
-(void)setOn:(BOOL)on animated:(BOOL)animated;

#pragma mark - Customizing the Appearance of the Switch
///@name Customizing the Appearance of the Switch
/**The color used to tint the appearance of the switch when it is turned on.
 */
@property (readwrite, nonatomic, strong) UIColor *onTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
/**The color used to tint the appearance when the switch is disabled.
 
 If you do not specify a color for the thumbTintColor property, this property is also used to tint the thumb of the switch.
 */
@property (readwrite, nonatomic, strong) UIColor *tintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;

/**The color used to tint the appearance of the thumb.
 
 If the value of this property is nil, the tint color is derived from the value in the tintColor property.
 */
@property (readwrite, nonatomic, strong) UIColor *thumbTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;

/**The image displayed when the switch is in the on position.
 
 This image represents the interior contents of the switch. The image you specify is composited with the switch’s rounded bezel and thumb to create the final appearance.
 
 The size of this image must be less than or equal to 77 points wide and 27 points tall. If you specify larger images, the edges may be clipped.
 */
@property (readwrite, nonatomic, strong) C4Image *onImage NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;

/**The image displayed while the switch is in the off position.
 
 This image represents the interior contents of the switch. The image you specify is composited with the switch’s rounded bezel and thumb to create the final appearance.
 
 The size of this image must be less than or equal to 77 points wide and 27 points tall. If you specify larger images, the edges may be clipped.
 */
@property (readwrite, nonatomic, strong) C4Image *offImage NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;

#pragma mark - Accessing The UISwitch
///@name Accessing The UISwitch
/**The UISwitch object which is the primary subview of the receiver.
 */@property (readonly, nonatomic) UISwitch *UISwitch;

#pragma mark - Default Style
///@name Default Style
/**Returns the appearance proxy for the object, cast as a C4Switch rather than the standard (id) cast provided by UIAppearance.
 
 You use this method to grab the appearance object that allows you to change the default style for C4Switch objects.
 
 @return The appearance proxy for the receiver, cast as a C4Switch.
 */
+(C4Switch *)defaultStyle;
@end
