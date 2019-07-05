//
//  BARCustomAlertView.h
//  ARSDK
//
//  Created by lusnaow on 10/15/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BARCustomAlertViewDelegate;

typedef enum
{
    BARCustomAlertViewAnimationTypeNone        = 0,
    BARCustomAlertViewAnimationTypeDefault     = 1,
    BARCustomAlertViewAnimationTypeFadeIn      = 2,
    BARCustomAlertViewAnimationTypeFaceOut     = 3,
    BARCustomAlertViewAnimationTypeFlyTop      = 4,
    BARCustomAlertViewAnimationTypeFlyBottom   = 5,
    BARCustomAlertViewAnimationTypeFlyLeft     = 6,
    BARCustomAlertViewAnimationTypeFlyRight    = 7,
    BARCustomAlertViewAnimationTypeZoomIn      = 8,
    BARCustomAlertViewAnimationTypeZoomOut     = 9
    
} BARCustomAlertViewAnimationType;

typedef void (^BARCustomAlertViewBlock)(void);

@interface BARCustomAlertView : UIView

#pragma mark - Public Properties

// Set the custom frame for the Alert View, if this property has not been set the Alert will be shown at center of the view. Don't use the default method [UIView setFrame:]

//@property (nonatomic, assign) CGRect customFrame; // Default is same as UIAlertView

// Set the width and height for the Alert View
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (void)setAlertCustomFrame:(CGRect)frame;
// Set the content view for the Alert View
// The frame of alert view will be resized based on the frame of content view, so you don't have to set the custom frame. If you want the alert view not shown at center, just set the center of the Alert View
@property (nonatomic, strong) UIView *contentView;


// You can get buttons and labels for customizing their appearance
@property (nonatomic, strong) UIButton * cancelButton; // Default is in blue color and system font 16
@property (nonatomic, strong) UIButton * otherButton; // Default is in blue color and system font 16
@property (nonatomic, strong) UILabel * titleLabel; // Default is in black color and system bold font 16
@property (nonatomic, strong) UILabel * messageLabel; // Default is in gray color and system font 14


// Set the height of title and button; and the padding of elements. The message label height is calculated based on its text and font.
@property (nonatomic, assign) CGFloat buttonHeight; // Default is 48
@property (nonatomic, assign) CGFloat titleHeight; // Default is 24

@property (nonatomic, assign) CGFloat titleTopPadding; //Default is 28
@property (nonatomic, assign) CGFloat titleBottomPadding; // Default is 29
@property (nonatomic, assign) CGFloat messageBottomPadding; // Default is 32
@property (nonatomic, assign) CGFloat messageLeftRightPadding; // Default is 20


// Customize the background and border
@property (nonatomic, strong) UIColor * borderColor; // Default is no border
@property (nonatomic, assign) CGFloat borderWidth; // Default is 0
@property (nonatomic, assign) CGFloat cornerRadius; // Default is 8
// inherits from UIView @property (nonatomic, strong) UIColor * backgroundColor; // Default is same as UIAlertView
@property (nonatomic, strong) UIImage * backgroundImage; // Default is nil


// Customize the seperator
@property (nonatomic, assign) BOOL hideSeperator; // Default is NO
@property (nonatomic, strong) UIColor * separatorColor; // Default is same as UIAlertView


// Customize the appearing and disappearing animations
@property (nonatomic, assign) BARCustomAlertViewAnimationType appearAnimationType;
@property (nonatomic, assign) BARCustomAlertViewAnimationType disappearAnimationType;
@property (nonatomic, assign,readonly) NSTimeInterval appearTime; // Default is 0.2
@property (nonatomic, assign,readonly) NSTimeInterval disappearTime; // Default is 0.1


// Make the cancel button appear on the right by setting this to YES
@property (nonatomic, assign,readonly) BOOL cancelButtonPositionRight; // Default is NO

// Disable the button highlight by setting this property to NO
@property (nonatomic, assign) BOOL buttonClickedHighlight; //Default is YES

// By default the alert will not dismiss if clicked to other button, set this property to YES to change the behaviour
@property (nonatomic, assign) BOOL shouldDismissOnActionButtonClicked; //Default is YES

// If this property is YES, the alert will dismiss when you click on outside (only when dim background is enable)
@property (nonatomic, assign,readonly) BOOL shouldDismissOnOutsideTapped; //Default is NO

// When shown in window, the dim background is always enable
@property (nonatomic, assign) BOOL shouldDimBackgroundWhenShowInWindow; //Default is YES

// When shown in view, the dim background is always disable
@property (nonatomic, assign) BOOL shouldDimBackgroundWhenShowInView; //Default is NO

// The default color of dim background is black color with alpha 0.2
@property (nonatomic, assign) CGFloat dimAlpha; //Default is same as UIAlertView

// Delegate
@property (nonatomic, weak) id<BARCustomAlertViewDelegate> delegate;

// Handle the button touching event
@property (readwrite, copy) BARCustomAlertViewBlock cancelButtonAction;
@property (readwrite, copy) BARCustomAlertViewBlock otherButtonAction;


#pragma mark - Public Methods

// Initialize method, same as UIAlertView
// On the current version, the alert does not support more than one other buttons
// If you pass the title by nil, the alert will be no title. If you pass the otherButtonTitle by nil, the alert will only have cancel button. You can remove all buttons by set all buton titles to nil.
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

// Initialize convenience method
// If you pass the title by nil, the alert will be no title. If you pass the otherButtonTitle by nil, the alert will only have cancel button. You can remove all buttons by set all buton titles to nil.
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;


// You can use this methods instead of calling these properties:
// @property (readwrite, copy) BARCustomAlertViewBlock cancelButtonAction;
// @property (readwrite, copy) BARCustomAlertViewBlock otherButtonAction;
//- (void)actionWithBlocksCancelButtonHandler:(void (^)(void))cancelHandler otherButtonHandler:(void (^)(void))otherHandler;


// Show in specified view
// If the custom frame has not been set, the alert will be shown at the center of the view
- (void)showInView:(UIView *)view;


// Show in window
// If the custom frame has not been set, the alert will be shown at the center of the window
- (void)show;


// Dismiss the alert
- (void)dismiss;

- (void)dismissNow;

@end

// BARCustomAlertViewDelegate
@protocol BARCustomAlertViewDelegate <NSObject>

@optional
- (void)willAppearAlertView:(BARCustomAlertView *)alertView;
- (void)didAppearAlertView:(BARCustomAlertView *)alertView;

- (void)cancelButtonClickedOnAlertView:(BARCustomAlertView *)alertView;
- (void)otherButtonClickedOnAlertView:(BARCustomAlertView *)alertView;

@end
