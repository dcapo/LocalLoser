//
//  UserInfoViewController.m
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011. All rights reserved.
//

#import "UserInfoViewController.h"


//UserInfoViewController is a simple form used to collect the user's contact information. 

@interface UserInfoViewController()
@property (nonatomic, retain) NSMutableDictionary *userInfoDictionary;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *cellTextField;
@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, retain) UIGestureRecognizer *tap;

@end

@implementation UserInfoViewController

@synthesize delegate;
@synthesize scrollView, currentTextField, tap;
@synthesize nameTextField, emailTextField, cellTextField, userInfoDictionary;

-(NSMutableDictionary *)userInfoDictionary {
    if (!userInfoDictionary) userInfoDictionary = [[NSMutableDictionary alloc] init];
    return userInfoDictionary;
}

-(UIGestureRecognizer *)tap {
    if (!tap) tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(dismissKeyboard)];
    return tap;
}

-(void)setup
{
}

-(void)awakeFromNib {
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length) {
        [textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

#define NAME @"userName"
#define EMAIL @"userEmail"
#define CELL @"userCell"

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self.currentTextField resignFirstResponder];
    if ([self.nameTextField.text isEqualToString:@""] || [self.emailTextField.text isEqualToString:@""]
        || [self.cellTextField.text isEqualToString:@""]) {
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:self];
        [dialog setTitle:@"Uh Oh!"];
        [dialog setMessage:@"Your name, email, and cell number are all required. Please supply them."];
        [dialog addButtonWithTitle:@"Okay"];
        [dialog show];
        [dialog release];
    } else {
        [self.userInfoDictionary setObject:self.nameTextField.text forKey:NAME];
        [self.userInfoDictionary setObject:self.emailTextField.text forKey:EMAIL];
        [self.userInfoDictionary setObject:self.cellTextField.text forKey:CELL];
        [self.delegate userInfoViewController:self gotForm:self.userInfoDictionary];   
    }
}

#pragma mark - View lifecycle

#define USER_INFO @"userInformation"

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    if (userInfo) {
        self.nameTextField.text = [userInfo objectForKey:@"userName"];
        self.emailTextField.text = [userInfo objectForKey:@"userEmail"];
        self.cellTextField.text = [userInfo objectForKey:@"userCell"];
    }
}

//keyboardAppeared and keyboardDisappeared move the scrollView so that the selected textField is visible. 
-(void)theKeyboardAppeared: (NSNotification *)notification
{
    NSValue* keyboardFrameValue = [[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [keyboardFrameValue CGRectValue].size;
    
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height -= keyboardSize.height;
    self.scrollView.frame = viewFrame;
    
    CGRect textFieldRect = [self.currentTextField frame];
    textFieldRect.origin.y += (textFieldRect.size.height);    
    [self.scrollView scrollRectToVisible:textFieldRect animated:YES];
    
    [self.view addGestureRecognizer:self.tap];
}

-(void)theKeyboardDisappeared: (NSNotification *)notification {
    NSValue* keyboardFrameValue = [[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [keyboardFrameValue CGRectValue].size;
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height += keyboardSize.height;
    self.scrollView.frame = viewFrame;
    
    [self.view removeGestureRecognizer:self.tap];
}

//called when user taps outside of keyboard
-(void)dismissKeyboard {
    [self.currentTextField resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.cellTextField.delegate = self;
    
    self.scrollView.contentSize = self.view.frame.size;
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.cellTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.cellTextField.keyboardType = UIKeyboardTypePhonePad;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theKeyboardAppeared:)
                                                 name:UIKeyboardDidShowNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theKeyboardDisappeared:) 
                                                 name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.nameTextField = nil;
    self.emailTextField = nil;
    self.cellTextField = nil;
    self.currentTextField = nil;
    [self.view removeGestureRecognizer:self.tap];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [userInfoDictionary release];
    [nameTextField release];
    [emailTextField release];
    [cellTextField release];
    [currentTextField release];
    if (tap) [tap release];
    [super dealloc];
}
@end

