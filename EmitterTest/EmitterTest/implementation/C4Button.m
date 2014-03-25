//
//  C4Button.m
//  C4iOS
//
//  Created by moi on 13-02-28.
//  Copyright (c) 2013 POSTFL. All rights reserved.
//

#import "C4Button.h"

@implementation C4Button
@synthesize tintColor = _tintColor;

+(C4Button *)buttonWithType:(C4ButtonType)type {
    C4Button *button = [[C4Button alloc] initWithType:type];
    return button;
}

-(id)initWithType:(C4ButtonType)type {
    UIButton *button = [UIButton buttonWithType:(UIButtonType)type];
    self = [super initWithFrame:button.frame];
    if(self != nil) {
        _UIButton = button;
        _UIButton.frame = self.bounds;
        _UIButton.layer.masksToBounds = YES;
        [self setupFromDefaults];
        [self addSubview:_UIButton];
        [self setup];
    }
    return self;
}

#pragma mark Style 
+(C4Button *)defaultStyle {
    return (C4Button *)[C4Button appearance];
}

-(void)setupFromDefaults {
    self.UIButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:15.0f];
    self.tintColor = [C4Button defaultStyle].tintColor;
    
    if(self.buttonType == ROUNDEDRECT) {
        self.frame = CGRectMake(0,0,96,27);
        [self setTitle:@"BUTTON" forState:NORMAL];
        [self setTitleColor:C4GREY forState:NORMAL];
        [self setTitleColor:C4GREY forState:HIGHLIGHTED];
        [self setTitleColor:C4RED forState:DISABLED];
        [self setTitleShadowColor:[UIColor whiteColor] forState:NORMAL];
        self.reversesTitleShadowWhenHighlighted = YES;
        self.UIButton.titleLabel.shadowOffset = CGSizeMake(1,1);
        
        [self setBackgroundImage:[C4Image imageNamed:@"buttonDisabled"] forState:DISABLED];
        [self setBackgroundImage:[C4Image imageNamed:@"buttonHighlighted"] forState:HIGHLIGHTED];
        [self setBackgroundImage:[C4Image imageNamed:@"buttonNormal"] forState:NORMAL];
        [self setBackgroundImage:[C4Image imageNamed:@"buttonSelected"] forState:SELECTED];
    }
    //NOTE: UIButton only recognizes tintColor for its appearance (check UIButton.h)
}

-(void)setFrame:(CGRect)frame {
    CGPoint origin = frame.origin;
    origin.x = floorf(origin.x);
    origin.y = floorf(origin.y) + 0.5f;
    frame.origin = origin;
    [super setFrame:frame];
    self.UIButton.frame = self.bounds;
}

-(void)setCenter:(CGPoint)center {
    center.x = floorf(center.x);
    center.y = floorf(center.y) + 0.5f;
    [super setCenter:center];
}

-(C4Button *)copyWithZone:(NSZone *)zone {
    C4Button *button = [[C4Button allocWithZone:zone] initWithType:self.buttonType];
    button.style = self.style;
    return button;
}

-(void)setCornerRadius:(CGFloat)cornerRadius {
    [super setCornerRadius:cornerRadius];
    [self.UIButton.layer setCornerRadius:cornerRadius];
}

-(NSDictionary *)style {
    //mutable local styles
    NSMutableDictionary *localStyle = [[NSMutableDictionary alloc] initWithCapacity:0];
    [localStyle addEntriesFromDictionary:@{@"button":self.UIButton}];
    
    NSDictionary *controlStyle = [super style];
    NSMutableDictionary *localAndControlStyle = [NSMutableDictionary dictionaryWithDictionary:localStyle];
    [localAndControlStyle addEntriesFromDictionary:controlStyle];
    
    localStyle = nil;
    controlStyle = nil;
    
    return (NSDictionary *)localAndControlStyle;

}

-(void)setStyle:(NSDictionary *)newStyle {
    self.tintColor = nil;
    [super setStyle:newStyle];
    
    UIButton *b = [newStyle objectForKey:@"button"];
    if(b != nil) {
        
        UIControlState state[4] = {UIControlStateDisabled, UIControlStateHighlighted, UIControlStateNormal, UIControlStateSelected};
        for(int i = 0; i < 4; i++) {
            [self.UIButton setTitle:[b titleForState:state[i]] forState:state[i]];
            [self.UIButton setAttributedTitle:[b attributedTitleForState:state[i]] forState:state[i]];
            [self.UIButton setTitleColor:[b titleColorForState:state[i]] forState:state[i]];
            [self.UIButton setTitleShadowColor:[b titleShadowColorForState:state[i]] forState:state[i]];
            [self.UIButton setImage:[b imageForState:state[i]] forState:state[i]];
            [self.UIButton setBackgroundImage:[b backgroundImageForState:state[i]] forState:state[i]];
        }
                
        self.UIButton.contentEdgeInsets = b.contentEdgeInsets;
        self.UIButton.imageEdgeInsets = b.imageEdgeInsets;
        self.UIButton.titleEdgeInsets = b.titleEdgeInsets;
        
        self.UIButton.reversesTitleShadowWhenHighlighted = b.reversesTitleShadowWhenHighlighted;
        self.UIButton.adjustsImageWhenDisabled = b.adjustsImageWhenDisabled;
        self.UIButton.adjustsImageWhenHighlighted = b.adjustsImageWhenHighlighted;
        self.UIButton.showsTouchWhenHighlighted = b.showsTouchWhenHighlighted;
        
        self.UIButton.titleLabel.font = b.titleLabel.font;
        
        self.UIButton.tintColor = b.tintColor;

        b = nil;
    }
}

-(C4Label *)titleLabel {
    return nil;
}

-(C4Font *)font {
    return [C4Font fontWithName:self.UIButton.titleLabel.font.fontName size:self.UIButton.titleLabel.font.pointSize];
}

-(void)setFont:(C4Font *)font {
    self.UIButton.titleLabel.font = font.UIFont;
}

-(NSString *)titleForState:(C4ControlState)state {
    return [self.UIButton titleForState:(UIControlState)state];
}

-(void)setTitle:(NSString *)title forState:(C4ControlState)state {
    [self.UIButton setTitle:title forState:(UIControlState)state];
    [self.UIButton setAttributedTitle:nil forState:(UIControlState)state];
}

-(UIColor *)titleColorForState:(C4ControlState)state {
    return [self.UIButton titleColorForState:(UIControlState)state];
}

-(void)setTitleColor:(UIColor *)color forState:(C4ControlState)state {
    [self.UIButton setTitleColor:color forState:(UIControlState)state];
}

-(UIColor *)titleShadowColorForState:(C4ControlState)state {
    return [self.UIButton titleShadowColorForState:(UIControlState)state];
}

-(void)setTitleShadowColor:(UIColor *)color forState:(C4ControlState)state {
    [self.UIButton setTitleShadowColor:color forState:(UIControlState)state];
}

-(C4Image *)imageForState:(C4ControlState)state {
    return [C4Image imageWithUIImage:[self.UIButton imageForState:(UIControlState)state]];
}

-(void)setImage:(C4Image *)image forState:(C4ControlState)state {
    [self.UIButton setImage:image.UIImage forState:(UIControlState)state];
}

-(C4Image *)backgroundImageForState:(C4ControlState)state {
    return [C4Image imageWithUIImage:[self.UIButton backgroundImageForState:(UIControlState)state]];
}

-(void)setBackgroundImage:(C4Image *)image forState:(C4ControlState)state {
    [self.UIButton setBackgroundImage:image.UIImage forState:(UIControlState)state];
}

-(NSAttributedString *)attributedTitleForState:(C4ControlState)state {
    return [self.UIButton attributedTitleForState:(UIControlState)state];
}

-(void)setAttributedTitle:(NSAttributedString *)title forState:(C4ControlState)state {
    [self.UIButton setAttributedTitle:title forState:(UIControlState)state];
}

-(UIEdgeInsets)contentEdgeInsets {
    return self.UIButton.contentEdgeInsets;
}

-(void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    self.UIButton.contentEdgeInsets = contentEdgeInsets;
}

-(UIEdgeInsets)titleEdgeInsets {
    return self.UIButton.titleEdgeInsets;
}

-(void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    self.UIButton.titleEdgeInsets = titleEdgeInsets;
}

-(UIEdgeInsets)imageEdgeInsets {
    return self.UIButton.imageEdgeInsets;
}

-(void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    self.UIButton.imageEdgeInsets = imageEdgeInsets;
}

-(BOOL)reversesTitleShadowWhenHighlighted {
    return self.UIButton.reversesTitleShadowWhenHighlighted;
}

-(void)setReversesTitleShadowWhenHighlighted:(BOOL)reversesTitleShadowWhenHighlighted {
    self.UIButton.reversesTitleShadowWhenHighlighted = reversesTitleShadowWhenHighlighted;
}

-(BOOL)adjustsImageWhenDisabled {
    return self.UIButton.adjustsImageWhenDisabled;
}

-(void)setAdjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled {
    self.UIButton.adjustsImageWhenDisabled = adjustsImageWhenDisabled;
}

-(BOOL)adjustsImageWhenHighlighted {
    return self.UIButton.adjustsImageWhenHighlighted;
}

-(void)setAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted {
    self.UIButton.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted;
}

-(BOOL)showsTouchWhenHighlighted {
    return self.UIButton.showsTouchWhenHighlighted;
}

-(void)setShowsTouchWhenHighlighted:(BOOL)showsTouchWhenHighlighted {
    self.UIButton.showsTouchWhenHighlighted = showsTouchWhenHighlighted;
}

-(UIColor *)tintColor {
    return self.UIButton.tintColor;
}

-(void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    self.UIButton.tintColor = tintColor;
}

-(C4ButtonType)buttonType {
    return (C4ButtonType)self.UIButton.buttonType;
}

-(NSString *)currentTitle {
    return self.UIButton.currentTitle;
}

-(NSAttributedString *)currentAttributedTitle {
    return self.UIButton.currentAttributedTitle;
}

-(UIColor *)currentTitleColor {
    return self.UIButton.currentTitleColor;
}

-(UIColor *)currentTitleShadowColor {
    return self.UIButton.currentTitleShadowColor;
}

-(C4Image *)currentImage {
    return [C4Image imageWithUIImage:self.UIButton.currentImage];
}

-(C4Image *)currentBackgroundImage {
    return [C4Image imageWithUIImage:self.UIButton.currentBackgroundImage];
}

#pragma mark C4UIElement
-(void)runMethod:(NSString *)methodName target:(id)object forEvent:(C4ControlEvents)event {
    [self.UIButton addTarget:object action:NSSelectorFromString(methodName) forControlEvents:(UIControlEvents)event];
}

-(void)stopRunningMethod:(NSString *)methodName target:(id)object forEvent:(C4ControlEvents)event {
    [self.UIButton removeTarget:object action:NSSelectorFromString(methodName) forControlEvents:(UIControlEvents)event];
}

#pragma mark Tracking 
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self postNotification:@"trackingBegan"];
    [self beginTracking];
    return [self.UIButton beginTrackingWithTouch:touch withEvent:event];
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self postNotification:@"trackingContinued"];
    [self continueTracking];
    return [self.UIButton continueTrackingWithTouch:touch withEvent:event];
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self postNotification:@"trackingEnded"];
    [self endTracking];
    return [self.UIButton endTrackingWithTouch:touch withEvent:event];
}

-(void)cancelTrackingWithEvent:(UIEvent *)event {
    [self postNotification:@"trackingCancelled"];
    [self cancelTracking];
    [self.UIButton cancelTrackingWithEvent:event];
}

-(void)beginTracking {
}

-(void)continueTracking {
}

-(void)endTracking {
}

-(void)cancelTracking {
}

#pragma mark Control State

-(UIControlState)state {
    return self.UIButton.state;
}

-(void)setEnabled:(BOOL)enabled {
    self.UIButton.enabled = enabled;
}

-(BOOL)enabled {
    return self.UIButton.enabled;
}

-(void)setHighlighted:(BOOL)highlighted {
    self.UIButton.highlighted = highlighted;
}

-(BOOL)highlighted {
    return self.UIButton.highlighted;
}

-(void)setSelected:(BOOL)selected {
    self.UIButton.selected = selected;
}

-(BOOL)selected {
    return self.UIButton.selected;
}

-(void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    self.UIButton.contentVerticalAlignment = contentVerticalAlignment;
}

-(void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    self.UIButton.contentVerticalAlignment = contentHorizontalAlignment;
}

#pragma mark isEqual

-(BOOL)isEqual:(id)object {
    if([object isKindOfClass:[UIButton class]]) return [self.UIButton isEqual:object];
    else if([object isKindOfClass:[self class]]) return [self.UIButton isEqual:((C4Button *)object).UIButton];
    return NO;
}


@end
