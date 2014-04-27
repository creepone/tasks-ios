//
//  IAANotesViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAANotesViewController.h"
#import "IAAKeyboard.h"

@interface IAANotesViewController () <UITextViewDelegate, UIGestureRecognizerDelegate> {
    UITextView *_textView;
    NSString *_notes;
    CGFloat _zoomScale;
}

- (void)setupNavigationBarItems;
- (void)setupTextView;

@end

@implementation IAANotesViewController

static const CGFloat kFontSize = 18.f;

- (id)initWithNotes:(NSString *)notes
{
    self = [super init];
    if (self) {
        self.title = @"Notes";
        _notes = notes;
        _zoomScale = 1.f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self setupNavigationBarItems];
    [self setupTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [_textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_textView resignFirstResponder];
    _notes = _textView.text;
    [self.delegate notesViewController:self editedNotes:_notes];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        
    CGRect textViewFrame = _textView.frame;
    textViewFrame.size.height -= keyboardFrame.size.height;

    [_textView setFrame:textViewFrame];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    CGRect textViewFrame = _textView.frame;
    textViewFrame.size.height += keyboardFrame.size.height;
    
    [_textView setFrame:textViewFrame];
}

- (void)setupNavigationBarItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(tappedDelete)];
}

- (void)setupTextView
{
    IAAKeyboard *keyboard = [IAAKeyboard sharedKeyboard];
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    CGRect navFrame = [[self.navigationController navigationBar] frame];
    frame.size.height -= navFrame.origin.y + navFrame.size.height;
    
    if (keyboard.isShown)
        frame.size.height -= keyboard.frame.size.height;

    _textView = [[UITextView alloc] initWithFrame:frame];
    _textView.font = [UIFont systemFontOfSize:kFontSize];
    _textView.text = _notes;
    
    UIPinchGestureRecognizer *pinchGestRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleTextView:)];
    pinchGestRecognizer.delegate = self;
    [_textView addGestureRecognizer:pinchGestRecognizer];
    
    [self.view addSubview:_textView];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        _zoomScale = _textView.font.pointSize / kFontSize;
    }
    return YES;
}

- (void)scaleTextView:(UIPinchGestureRecognizer *)recognizer
{
    CGFloat currentScale = recognizer.scale * _zoomScale;
     currentScale = MIN(3.f, MAX(0.5f, currentScale));
    _textView.font = [UIFont fontWithName:_textView.font.fontName size:18.f * currentScale];
}

- (void)tappedDelete
{
    _textView.text = @"";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
