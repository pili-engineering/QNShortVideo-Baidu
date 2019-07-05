//
//  BARCustomAlertView.m
//  ARSDK
//
//  Created by lusnaow on 10/15/15.
//  Copyright © 2015 Baidu. All rights reserved.
//


#import "BARCustomAlertView.h"

#define DEFAULT_ALERT_WIDTH 270
#define DEFAULT_ALERT_HEIGHT 144

@interface BARCustomAlertView ()
{
    CGRect titleLabelFrame;
    CGRect messageLabelFrame;
    CGRect cancelButtonFrame;
    CGRect otherButtonFrame;
    
    CGRect verticalSeperatorFrame;
    CGRect horizontalSeperatorFrame;
    
    BOOL hasModifiedFrame;
    BOOL hasContentView;
}
@property (nonatomic, strong) UIView * alertContentView;

@property (nonatomic, strong) UIView * horizontalSeparator;
@property (nonatomic, strong) UIView * verticalSeparator;

@property (nonatomic, strong) UIView * blackOpaqueView;

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSString * cancelButtonTitle;
@property (nonatomic, strong) NSString * otherButtonTitle;

@property (nonatomic, strong) UIColor *originCancelButtonColor;
@property (nonatomic, strong) UIColor *originOtherButtonColor;

@end

@implementation BARCustomAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)dealloc
{
    if(self.originCancelButtonColor){
        self.originCancelButtonColor = nil;
    }
    if(self.originOtherButtonColor) {
        self.originOtherButtonColor = nil;
    }    
}

// Init method
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id )delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    NSString *firstOtherButtonTitle;
    
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
    {
        //do something with nsstring
        if (!firstOtherButtonTitle) {
            firstOtherButtonTitle = arg;
            break;
        }
    }
    va_end(args);
    
    if ([self initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitles]) {
        self.delegate = delegate;
        
        return self;
    }
    
    return nil;
}

// Init method shorter version
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
    self.width = DEFAULT_ALERT_WIDTH;
    self.height = DEFAULT_ALERT_HEIGHT;
    
    self = [super initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    if (self) {
        // Initialization code
        
        self.clipsToBounds = YES;
        self.title = title;
        self.message = message;
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitle = otherButtonTitle;
        self.appearAnimationType = BARCustomAlertViewAnimationTypeDefault;
        self.disappearAnimationType = BARCustomAlertViewAnimationTypeDefault;
        self.cornerRadius = 3;
        self.buttonClickedHighlight = YES;
        
        self.buttonHeight = 44;
        self.titleTopPadding = 14;
        self.titleHeight = 34;
        self.titleBottomPadding = 2;
        self.messageBottomPadding = 20;
        self.messageLeftRightPadding = 20;
        
        self.shouldDimBackgroundWhenShowInWindow = YES;
        self.shouldDismissOnActionButtonClicked = YES;
        self.dimAlpha = 0.4;
        
        [self setupItems];
        
    }
    return self;
}

#pragma mark - Show the alert view

// Show in specified view
- (void)showInView:(UIView *)view
{
    [self calculateFrame];
    [self setupViews];
    
    if (!hasModifiedFrame) {
        self.frame = CGRectMake((view.frame.size.width - self.frame.size.width )/2, (view.frame.size.height - self.frame.size.height) /2, self.frame.size.width, self.frame.size.height);
    }
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    
    if (self.shouldDimBackgroundWhenShowInView && view != window) {
        UIView *window = [[[UIApplication sharedApplication] delegate] window];
        self.blackOpaqueView = [[UIView alloc] initWithFrame:window.bounds];
        self.blackOpaqueView.backgroundColor = [UIColor colorWithWhite:0 alpha:self.dimAlpha];
        
        UITapGestureRecognizer *outsideTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outsideTap:)];
        [self.blackOpaqueView addGestureRecognizer:outsideTapGesture];
        [view addSubview:self.blackOpaqueView];
    }
    
    [self willAppearAlertView];
    
    [self addThisViewToView:view];
}

// Show in window
- (void)show
{
    //    [self calculateFrame];
    //    [self setupViews];
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    
    if (self.shouldDimBackgroundWhenShowInWindow) {
        self.blackOpaqueView = [[UIView alloc] initWithFrame:window.bounds];
        self.blackOpaqueView.backgroundColor = [UIColor colorWithWhite:0 alpha:self.dimAlpha];
        
        UITapGestureRecognizer *outsideTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outsideTap:)];
        [self.blackOpaqueView addGestureRecognizer:outsideTapGesture];
        [window addSubview:self.blackOpaqueView];
    }
    
    [self showInView:window];
}

- (void)outsideTap:(UITapGestureRecognizer *)recognizer
{
    if (self.shouldDismissOnOutsideTapped) {
        [self dismiss];
    }
}

- (void) addThisViewToView: (UIView *) view
{
    NSTimeInterval timeAppear = ( self.appearTime > 0 ) ? self.appearTime : .2;
    NSTimeInterval timeDelay = 0;
    
    [view addSubview:self];
    
    if (self.appearAnimationType == BARCustomAlertViewAnimationTypeDefault)
    {
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.alpha = .6;
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformIdentity;
            self.alpha = 1;
            
        } completion:^(BOOL finished){
            [self didAppearAlertView];
        }];
    }
    else if (self.appearAnimationType == BARCustomAlertViewAnimationTypeZoomIn)
    {
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished){
            [self didAppearAlertView];
        }];
    }
    else if (self.appearAnimationType == BARCustomAlertViewAnimationTypeFadeIn)
    {
        self.alpha = 0;
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 1;
            
        } completion:^(BOOL finished){
            [self didAppearAlertView];
        }];
    }
    else if (self.appearAnimationType == BARCustomAlertViewAnimationTypeFlyTop)
    {
        CGRect tmpFrame = self.frame;
        self.frame = CGRectMake(self.frame.origin.x, - self.frame.size.height - 10, self.frame.size.width, self.frame.size.height);
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = tmpFrame;
            
        } completion:^(BOOL finished){
            [self didAppearAlertView];
        }];
        
    }
    else if (self.appearAnimationType == BARCustomAlertViewAnimationTypeFlyBottom)
    {
        CGRect tmpFrame = self.frame;
        self.frame = CGRectMake( self.frame.origin.x, view.frame.size.height + 10, self.frame.size.width, self.frame.size.height);
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = tmpFrame;
            
        } completion:^(BOOL finished){
            [self didAppearAlertView];
        }];
        
    }
    else if (self.appearAnimationType == BARCustomAlertViewAnimationTypeFlyLeft)
    {
        CGRect tmpFrame = self.frame;
        self.frame = CGRectMake( - self.frame.size.width - 10, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = tmpFrame;
            
        } completion:^(BOOL finished){
            [self didAppearAlertView];
        }];
        
    }
    else if (self.appearAnimationType == BARCustomAlertViewAnimationTypeFlyRight)
    {
        CGRect tmpFrame = self.frame;
        self.frame = CGRectMake(view.frame.size.width + 10, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = tmpFrame;
            
        } completion:^(BOOL finished){
            [self didAppearAlertView];
        }];
    }
    else if (self.appearAnimationType == BARCustomAlertViewAnimationTypeNone)
    {
        [self didAppearAlertView];
    }
}

- (void)dismissNow
{
    self.alpha = .0;
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [self removeFromSuperview];
    
    
    if (self.blackOpaqueView) {
        self.blackOpaqueView.alpha = 0;
        [self.blackOpaqueView removeFromSuperview];
    }
}

// Hide and dismiss the alert
- (void)dismiss
{
    NSTimeInterval timeDisappear = ( self.disappearTime > 0 ) ? self.disappearTime : .08;
    NSTimeInterval timeDelay = .02;
    
    if (self.disappearAnimationType == BARCustomAlertViewAnimationTypeDefault) {
        //        self.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = .0;
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
    else if (self.disappearAnimationType == BARCustomAlertViewAnimationTypeZoomOut )
    {
        //        self.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformMakeScale(0.01, 0.01);
            
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
    else if (self.disappearAnimationType == BARCustomAlertViewAnimationTypeFaceOut)
    {
        self.alpha = 1;
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0;
            
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
    else if (self.disappearAnimationType == BARCustomAlertViewAnimationTypeFlyTop)
    {
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = CGRectMake(self.frame.origin.x, - self.frame.size.height - 10, self.frame.size.width, self.frame.size.height);
            
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
    else if (self.disappearAnimationType == BARCustomAlertViewAnimationTypeFlyBottom)
    {
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = CGRectMake( self.frame.origin.x, self.superview.frame.size.height + 10, self.frame.size.width, self.frame.size.height);
            
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
    else if (self.disappearAnimationType == BARCustomAlertViewAnimationTypeFlyLeft)
    {
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = CGRectMake( - self.frame.size.width - 10, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
    else if (self.disappearAnimationType == BARCustomAlertViewAnimationTypeFlyRight)
    {
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = CGRectMake(self.superview.frame.size.width + 10, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
    else if (self.disappearAnimationType == BARCustomAlertViewAnimationTypeNone)
    {
        [self removeFromSuperview];
    }
    
    
    if (self.blackOpaqueView) {
        [UIView animateWithDuration:timeDisappear animations:^{
            self.blackOpaqueView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.blackOpaqueView removeFromSuperview];
        }];
    }
}

#pragma mark - Setup the alert view

- (void)setContentView:(UIView *)contentView
{
    if ( ! self.title && ! self.message) {
        self.buttonHeight = 0;
    }
    self.alertContentView = contentView;
    
    hasContentView = YES;
    self.width = contentView.frame.size.width;
    self.height = contentView.frame.size.height + self.buttonHeight;
    
    contentView.frame = contentView.bounds;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.width, self.height);
    [self addSubview:contentView];
}

- (UIView *)contentView
{
    return self.alertContentView;
}

- (void)setCenter:(CGPoint)center
{
    [super setCenter:center];
    
    hasModifiedFrame = YES;
}

- (void)setAlertCustomFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.width = frame.size.width;
    self.height = frame.size.height;
    hasModifiedFrame = YES;
    
    [self calculateFrame];
}

- (void)calculateFrame
{
    BOOL hasButton = (self.cancelButtonTitle || self.otherButtonTitle);
    
    if ( ! hasContentView ) {
        if ( ! hasModifiedFrame )
        {
            UIFont * messageFont = self.messageLabel.font ? self.messageLabel.font : [UIFont systemFontOfSize:14];
            //Calculate label size
            //Calculate the expected size based on the font and linebreak mode of your label
            // FLT_MAX here simply means no constraint in height
            CGSize maximumLabelSize = CGSizeMake(self.width - self.messageLeftRightPadding * 2, FLT_MAX);
            //        CGSize expectedLabelSize = [self.message sizeWithFont:messageFont constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
            
            CGRect textRect;
            if ([self.message respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                textRect = [self.message boundingRectWithSize:maximumLabelSize
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:messageFont ?:  [UIFont systemFontOfSize:14]}
                                                      context:nil];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                CGSize shouldSize = [self.message sizeWithFont:messageFont forWidth:maximumLabelSize.width lineBreakMode:NSLineBreakByWordWrapping];
                textRect = CGRectMake(0, 0, shouldSize.width, shouldSize.height);
#pragma clang diagnostic pop
            }
            
            CGFloat messageHeight = textRect.size.height;
            
            CGFloat newHeight = messageHeight + self.titleHeight + self.buttonHeight + self.titleTopPadding + self.titleBottomPadding + self.messageBottomPadding;
            self.height = newHeight;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.width, self.height);
            
        }
        
        if ( !self.title ) {
            titleLabelFrame = CGRectZero;
        } else {
            titleLabelFrame = CGRectMake(self.messageLeftRightPadding,
                                         self.titleTopPadding,
                                         self.width - self.messageLeftRightPadding * 2,
                                         self.titleHeight);
        }
        if ( ! self.message ) {
            messageLabelFrame = CGRectZero;
        } else if (hasButton) {
            messageLabelFrame = CGRectMake(self.messageLeftRightPadding,
                                           titleLabelFrame.origin.y + titleLabelFrame.size.height + self.titleBottomPadding,
                                           self.width - self.messageLeftRightPadding * 2,
                                           self.height - self.buttonHeight - titleLabelFrame.size.height - self.titleTopPadding - self.titleBottomPadding);
        } else {
            messageLabelFrame = CGRectMake(self.messageLeftRightPadding,
                                           titleLabelFrame.origin.y +  titleLabelFrame.size.height + self.titleBottomPadding,
                                           self.width - self.messageLeftRightPadding * 2,
                                           self.height - titleLabelFrame.size.height - self.titleTopPadding - self.titleBottomPadding);
        }
        
        if ( ! self.title || self.title.length == 0 ) {
            messageLabelFrame = CGRectMake(self.messageLeftRightPadding, 0, self.width - self.messageLeftRightPadding * 2, self.height - self.buttonHeight);
        }
        
    }
    
    
    if ( self.hideSeperator || ! hasButton ) {
        verticalSeperatorFrame = CGRectZero;
        horizontalSeperatorFrame = CGRectZero;
    } else {
        verticalSeperatorFrame = CGRectMake(self.width / 2,
                                            self.height - self.buttonHeight,
                                            0.5,
                                            self.buttonHeight);
        
        horizontalSeperatorFrame = CGRectMake(0,
                                              self.height - self.buttonHeight,
                                              self.width,
                                              0.5);
    }
    
    if ( ! self.cancelButtonTitle ) {
        cancelButtonFrame = CGRectZero;
    } else if ( ! self.otherButtonTitle ) {
        verticalSeperatorFrame = CGRectZero;
        cancelButtonFrame = CGRectMake(0,
                                       self.height - self.buttonHeight,
                                       self.width,
                                       self.buttonHeight);
    } else if ( ! self.cancelButtonPositionRight ) {
        cancelButtonFrame = CGRectMake(0,
                                       self.height - self.buttonHeight,
                                       self.width / 2,
                                       self.buttonHeight);
    } else {
        cancelButtonFrame = CGRectMake(self.width / 2,
                                       self.height - self.buttonHeight,
                                       self.width / 2,
                                       self.buttonHeight);
    }
    
    if ( ! self.otherButtonTitle ) {
        otherButtonFrame = CGRectZero;
    } else if ( ! self.cancelButtonTitle ) {
        verticalSeperatorFrame = CGRectZero;
        otherButtonFrame = CGRectMake(0,
                                      self.height - self.buttonHeight,
                                      self.width,
                                      self.buttonHeight);
    } else if ( ! self.cancelButtonPositionRight ) {
        otherButtonFrame = CGRectMake(self.width / 2,
                                      self.height - self.buttonHeight,
                                      self.width / 2,
                                      self.buttonHeight);
    } else {
        otherButtonFrame = CGRectMake(0,
                                      self.height - self.buttonHeight,
                                      self.width / 2,
                                      self.buttonHeight);
    }
    
    if ( ! self.otherButtonTitle && ! self.cancelButtonTitle) {
        cancelButtonFrame = CGRectZero;
        otherButtonFrame = CGRectZero;
        
        self.height = self.height - self.buttonHeight;
        self.buttonHeight = 0;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.height);
    }
    
}

- (void)setupItems
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Setup Title Label
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24];
    self.titleLabel.text = self.title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [self RGBColorFromHexString:@"#333333" alpha:1.0f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    // Setup Message Label
    self.messageLabel.numberOfLines = 0;
    //self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
    self.messageLabel.font = [UIFont systemFontOfSize:15];
    self.messageLabel.text = self.message;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.textColor = [self RGBColorFromHexString:@"#999999" alpha:1.0f];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    
    //Setup Cancel Button
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setTitleColor:[self RGBColorFromHexString:@"#333333" alpha:1.0f] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    [self.cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //Setup Other Button
    self.otherButton.backgroundColor = [UIColor clearColor];
    [self.otherButton setTitleColor:[self RGBColorFromHexString:@"#333333" alpha:1.0f] forState:UIControlStateNormal];
    self.otherButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    [self.otherButton setTitle:self.otherButtonTitle forState:UIControlStateNormal];
    [self.otherButton addTarget:self action:@selector(otherButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //Set up Seperator
    self.horizontalSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    self.verticalSeparator = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setupViews
{
    // Setup Background
    if (self.backgroundImage) {
        [self setBackgroundColor:[UIColor colorWithPatternImage:self.backgroundImage]];
    } else if (self.backgroundColor) {
        [self setBackgroundColor:self.backgroundColor];
    } else {
        [self setBackgroundColor:[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0]];
    }
    
    if (self.borderWidth) {
        self.layer.borderWidth = self.borderWidth;
    }
    if (self.borderColor) {
        self.layer.borderColor = self.borderColor.CGColor;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    self.layer.cornerRadius = self.cornerRadius;
    
    // Set Frame
    self.titleLabel.frame = titleLabelFrame;
    self.messageLabel.frame = messageLabelFrame;
    self.cancelButton.frame = cancelButtonFrame;
    self.otherButton.frame = otherButtonFrame;
    
    self.horizontalSeparator.frame = horizontalSeperatorFrame;
    self.verticalSeparator.frame = verticalSeperatorFrame;
    
    if (self.separatorColor) {
        self.horizontalSeparator.backgroundColor = self.separatorColor;
        self.verticalSeparator.backgroundColor = self.separatorColor;
    } else {
        self.horizontalSeparator.backgroundColor = [UIColor colorWithRed:196.0/255 green:196.0/255 blue:201.0/255 alpha:1.0];
        self.verticalSeparator.backgroundColor = [UIColor colorWithRed:196.0/255 green:196.0/255 blue:201.0/255 alpha:1.0];
    }
    
    // Make the message fits to it bounds
    if ( self.title ) {
        [self.messageLabel sizeToFit];
        CGRect myFrame = self.messageLabel.frame;
        myFrame = CGRectMake(myFrame.origin.x, myFrame.origin.y, self.width -  2 * self.messageLeftRightPadding, myFrame.size.height);
        self.messageLabel.frame = myFrame;
    }
    
    // Add subviews
    if ( ! hasContentView) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.messageLabel];
    }
    
    [self addSubview:self.cancelButton];
    [self addSubview:self.otherButton];
    [self addSubview:self.horizontalSeparator];
    [self addSubview:self.verticalSeparator];
}


#pragma mark - Touch Event

//- (void)cancelButtonTouchBegan:(id)sender
//{
//    self.originCancelButtonColor = [self.cancelButton.backgroundColor colorWithAlphaComponent:0];
//    self.cancelButton.backgroundColor = [self.cancelButton.backgroundColor colorWithAlphaComponent:.1];
//}

//- (void)cancelButtonTouchEnded:(id)sender
//{
//    self.cancelButton.backgroundColor = self.originCancelButtonColor;
//}

//- (void)otherButtonTouchBegan:(id)sender
//{
//    self.originOtherButtonColor = [self.otherButton.backgroundColor colorWithAlphaComponent:0];
//    self.otherButton.backgroundColor = [self.otherButton.backgroundColor colorWithAlphaComponent:.1];
//}

//- (void)otherButtonTouchEnded:(id)sender
//{
//    self.otherButton.backgroundColor = self.originOtherButtonColor;
//}


#pragma mark - Actions

//- (void)actionWithBlocksCancelButtonHandler:(void (^)(void))cancelHandler otherButtonHandler:(void (^)(void))otherHandler
//{
//    self.cancelButtonAction = cancelHandler;
//    self.otherButtonAction = otherHandler;
//}

- (void)cancelButtonClicked:(id)sender
{
    if (self.buttonClickedHighlight)
    {
        UIColor * originColor = [self.cancelButton.backgroundColor colorWithAlphaComponent:0];
        self.cancelButton.backgroundColor = [self.cancelButton.backgroundColor colorWithAlphaComponent:.1];
        double delayInSeconds = .2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.otherButton.backgroundColor = originColor;
        });
        
    }
    
    [self dismiss];
    
    if (self.cancelButtonAction) {
        self.cancelButtonAction();
        self.cancelButtonAction = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(cancelButtonClickedOnAlertView:)]) {
        [self.delegate cancelButtonClickedOnAlertView:self];
    }
}

- (void)otherButtonClicked:(id)sender
{
    if (self.buttonClickedHighlight)
    {
        UIColor * originColor = [self.otherButton.backgroundColor colorWithAlphaComponent:0];
        self.otherButton.backgroundColor = [self.otherButton.backgroundColor colorWithAlphaComponent:.1];
        double delayInSeconds = .2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.otherButton.backgroundColor = originColor;
        });
    }
    
    if (self.shouldDismissOnActionButtonClicked) {
        [self dismiss];
    }
    
    if (self.otherButtonAction) {
        self.otherButtonAction();
        self.otherButtonAction = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(otherButtonClickedOnAlertView:)]) {
        [self.delegate otherButtonClickedOnAlertView:self];
    }
}

- (void)didAppearAlertView
{
    if ([self.delegate respondsToSelector:@selector(didAppearAlertView:)]) {
        [self.delegate didAppearAlertView:self];
    }
}

- (void)willAppearAlertView
{
    if ([self.delegate respondsToSelector:@selector(willAppearAlertView:)]) {
        [self.delegate willAppearAlertView:self];
    }
}

- (UIColor *)RGBColorFromHexString:(NSString *)aHexStr alpha:(float)aAlpha {
    if ([aHexStr isKindOfClass:[NSString class]] && aHexStr
        && aHexStr.length > 6) // #rrggbb 大小写字母及数字
    {
        int nums[6] = {0};
        for (int i = 1; i < MIN(7, [aHexStr length]); i++) // 第一个字符是“＃”号
        {
            int asc = [aHexStr characterAtIndex:i];
            if (asc >= '0' && asc <= '9') // 数字
                nums[i - 1] = [aHexStr characterAtIndex:i] - '0';
            else if(asc >= 'A' && asc <= 'F') // 大写字母
                nums[i - 1] = [aHexStr characterAtIndex:i] - 'A' + 10;
            else if(asc >= 'a' && asc <= 'f') // 小写字母
                nums[i - 1] = [aHexStr characterAtIndex:i] - 'a' + 10;
            else
                return [UIColor whiteColor];
        }
        float rValue = (nums[0] * 16 + nums[1]) / 255.0f;
        float gValue = (nums[2] * 16 + nums[3]) / 255.0f;
        float bValue = (nums[4] * 16 + nums[5]) / 255.0f;
        UIColor *rgbColor = [UIColor colorWithRed:rValue green:gValue blue:bValue alpha:aAlpha];
        return rgbColor;
    }
    
    return [UIColor blackColor]; // 默认黑色
}
@end
