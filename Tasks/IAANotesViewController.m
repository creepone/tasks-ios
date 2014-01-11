//
//  IAANotesViewController.m
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAANotesViewController.h"
#import "IAALog.h"
#import "IAAKeyboard.h"

@interface IAANotesViewController () <UITextViewDelegate> {
    UITextView *_textView;
    NSString *_notes;
}

- (void)setupNavigationBarItems;
- (void)setupTextView;

@end

@implementation IAANotesViewController

- (id)initWithNotes:(NSString *)notes
{
    self = [super init];
    if (self) {
        self.title = @"Notes";
        _notes = notes;
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
    CGRect frame = CGRectMake(0, 0, 320, 416);
    
    if (keyboard.isShown)
        frame.size.height -= keyboard.frame.size.height;

    _textView = [[UITextView alloc] initWithFrame:frame];
    _textView.font = [UIFont systemFontOfSize:18.0];
    _textView.text = _notes;

    [self.view addSubview:_textView];
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
