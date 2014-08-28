//
//  AMAudioRouterController.m
//  AMAudio
//
//  Created by 王 为 on 8/28/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioRouterController.h"
#import "AMIOButton.h"
#import "AMBackgroundView.h"
#import "AMConnectionsView.h"
#import "AMConnectionLine.h"
#import "math.h"

@interface AMAudioRouterController ()

@end

@implementation AMAudioRouterController

NSMutableDictionary *ioButtonInstances;
NSMutableDictionary *currentLines;
NSMutableArray *selectedIOButtons;
NSMutableArray *lineCoordinates;

NSView *buttonView;
AMBackgroundView *backgroundView;
AMConnectionsView *connectionsView;
AMConnectionLine *connectionLine;

int screenWidth;
int screenHeight;
int buttonSize = 22;
int totalButtons = 72;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) awakeFromNib {
    // Main application
    
    [self setInitialVars];
    
    [self createViews];
    
    [self layoutIOButtons];
    
}

- (void) setInitialVars{
    // Set values for and instantiate initial variables used
    
    NSRect e = self.view.frame;
    screenHeight = (int)e.size.height;
    screenWidth = (int)e.size.width;
    
    ioButtonInstances = [[NSMutableDictionary alloc] init];
    currentLines = [[NSMutableDictionary alloc] init];
    selectedIOButtons = [[NSMutableArray alloc] init];
    lineCoordinates = [[NSMutableArray alloc] init];
}

- (void) createViews {
    // Create Views
    
    buttonView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, screenWidth, screenHeight)];
    backgroundView = [[AMBackgroundView alloc] initWithFrame:NSMakeRect(0, 0, screenWidth, screenHeight)];
    connectionsView = [[AMConnectionsView alloc] initWithFrame: NSMakeRect(0,0, screenWidth, screenHeight)];
    //connectionLine = [[ConnectionLine alloc] initWithFrame: NSMakeRect(0,0,screenWidth,screenHeight)];
    
    
    [self.view addSubview:backgroundView];
    [self.view addSubview:buttonView];
    [self.view addSubview:connectionsView];
}

- (void) layoutIOButtons {
    
    int viewWidth = buttonView.frame.size.width;
    int viewHeight = buttonView.frame.size.height;
    int viewCenterX = buttonView.frame.origin.x + (viewWidth / 2);
    int viewCenterY = buttonView.frame.origin.y + (viewHeight /2);
    int radius = (viewHeight / 2) - buttonSize;
    int s = viewCenterX;
    int t = viewHeight;
    
    float buttonSpacing = (360.0/totalButtons);
    
    NSLog(@"starting button coordinates are: %d, %d", s, t);
    
    for (int i = 1; i < (totalButtons + 1); i++) {
        // Determine position of each button and place it on the buttonView
        
        NSString *buttonName = [NSMutableString stringWithFormat:@"button %d", i];
        float deg = buttonSpacing * i;
        float rad = (deg * M_PI) / 180.0;
        
        float u = (viewCenterX - (buttonSize / 2)) + (radius * sin(rad) );
        float v = (viewCenterY - (buttonSize / 2)) + (radius * cos(rad) );
        
        //Create instance of the IOButton
        AMIOButton *button = [[AMIOButton alloc] initWithFrame:NSMakeRect(u, v, buttonSize, buttonSize) andSize:buttonSize];
        
        //Configure Button Instance
        button.connectedTo = FALSE;
        [button setAction:@selector(ioButtonPressed:)];
        [button setTarget:self];
        
        //Add Buttons to View
        [buttonView addSubview:button];
        
        //Rename button to something unique, for later tracking/use
        button.name = buttonName;
        [ioButtonInstances setObject:button forKey:buttonName];
        
    }
    
}

- (IBAction) ioButtonDoubleClick : (AMIOButton *)selector {
    NSLog(@"io button double clicked..");
}

- (IBAction) ioButtonPressed : (AMIOButton *)selector
{
    //Button pressed
    
    if ( [selector state] == NSOnState && !selector.connectedTo ) {
        [selectedIOButtons addObject:selector];
        
        if ( [selectedIOButtons count] < 2 ) {
            
        } else {
            //2 buttons selected
            
            //Get center coordinates of 2 buttons to be connected
            
            for (int i = 0; i < [selectedIOButtons count]; i++) {
                
                //Get Center Coordinates of selected Button
                AMIOButton *currentButton = [selectedIOButtons objectAtIndex:i];
                
                CGFloat xCenter = (currentButton.frame.origin.x + (currentButton.frame.size.height/2));
                
                CGFloat yCenter = (currentButton.frame.origin.y + (currentButton.frame.size.height / 2));
                
                //Add Center Coordinates of Selected Button to Array for use later
                [lineCoordinates addObject:@(xCenter)];
                [lineCoordinates addObject:@(yCenter)];
                
                //[selectedIOButtons[i] setState:0];
                
                // Set connectedTo property equal to paired button
                switch (i) {
                    case 0:
                        currentButton.connectedTo = selectedIOButtons[1];
                        break;
                    case 1:
                        currentButton.connectedTo = selectedIOButtons[0];
                        break;
                }
                
                // Set button image to reflect a connected button
                [currentButton makeButtonConnected:currentButton];
                
            }
            
            //Draw a line that connects the 2 buttons
            NSString *lineName = selector.name;
            
            AMConnectionLine *connectionLine;
            
            NSRect frame = NSMakeRect(0,0,screenWidth, screenHeight);
            connectionLine = [[AMConnectionLine alloc] initWithFrame:frame andCoords:lineCoordinates];
            
            [currentLines setObject:connectionLine forKey:lineName];
            NSLog(@"Current Lines are %@ with name %@", currentLines, lineName);
            
            //[connectionLine setCoords:lineCoordinates];
            //NSLog(@"test coords = %@",connectionLine);
            
            
            [connectionsView addSubview:connectionLine];
            
            
            
            [lineCoordinates removeAllObjects];
            
            
            
            //Clear out selected arrays
            [selectedIOButtons removeAllObjects];
        }
    } else if ( selector.connectedTo ) {
        // Button already selected and connected to another button
        // Find button's connected counterpart
        AMIOButton *pairedButton;
        pairedButton = [ioButtonInstances objectForKey:selector.connectedTo.name];
        
        AMConnectionLine *lineToRemove;
        // Remove line that connects buttons
        if ( [currentLines objectForKey:selector.name] ) {
            lineToRemove = [currentLines objectForKey:selector.name];
        } else {
            lineToRemove = [currentLines objectForKey:selector.connectedTo.name];
        }
        NSLog(@"Line to remove is %@", lineToRemove);
        lineToRemove.isHidden = 1;
        [lineToRemove removeFromSuperview];
        [connectionsView setNeedsDisplay:YES];
        
        // Reset both buttons
        
        [selector resetButton:selector];
        [pairedButton resetButton:pairedButton];
        
        [selectedIOButtons removeObjectIdenticalTo:selector];
        
    } else {
        // remove ioButton from selected array
        [selectedIOButtons removeObjectIdenticalTo:selector];
        NSLog(@"button removed from array");
    }
    
    
    //Check if any buttons selected
    
}


@end
