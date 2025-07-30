# CalcBox SwiftUI - Setup Instructions

## 🚀 Quick Start Guide

Follow these steps to get your SwiftUI CalcBox app running in Xcode:

## Method 1: Create New Xcode Project (Recommended)

### Step 1: Open Xcode
1. Open **Xcode** from Applications or Spotlight search
2. Select **"Create a new Xcode project"**

### Step 2: Choose Project Template
1. Select **iOS** tab
2. Choose **App** template
3. Click **Next**

### Step 3: Configure Project
- **Product Name**: `CalcBox`
- **Team**: Select your Apple Developer account (or leave default)
- **Organization Identifier**: `com.yourname.calcbox` (replace with your info)
- **Bundle Identifier**: Will auto-populate
- **Language**: **Swift**
- **Interface**: **SwiftUI** ⚠️ (Important!)
- **Use Core Data**: Leave unchecked
- **Include Tests**: Optional (can leave checked)

### Step 4: Save Project
1. Click **Next**
2. Navigate to: `/Users/evanjones/Documents/xcode projects/LifeCalc/`
3. Name the project folder: `CalcBoxXcode`
4. Click **Create**

### Step 5: Replace Generated Files
1. **Delete** the default `ContentView.swift` file in Xcode navigator
2. **Delete** the default `CalcBoxApp.swift` file in Xcode navigator
3. In Finder, navigate to your newly created project folder
4. **Copy all files** from `CalcBoxSwiftUI/` folder to your new Xcode project folder
5. In Xcode, **right-click** on the project in navigator → **Add Files to "CalcBox"**
6. Select all Swift files from the CalcBoxSwiftUI folder and add them

### Step 6: Organize Files in Xcode
1. Create **Groups** (folders) in Xcode navigator:
   - Right-click project → New Group → "Models"
   - Right-click project → New Group → "Views"
   - Right-click project → New Group → "Components" (inside Views)
   - Right-click project → New Group → "Calculators" (inside Views)
2. Drag files into appropriate groups to match the folder structure

## Method 2: Manual Project Creation (Alternative)

If Method 1 doesn't work, here's an alternative approach:

### Step 1: Use Xcode Command Line
```bash
cd "/Users/evanjones/Documents/xcode projects/LifeCalc/"
# Create a new directory for the Xcode project
mkdir CalcBoxXcode
cd CalcBoxXcode
```

### Step 2: Follow Method 1 Steps 1-4
Then copy files as described in Step 5.

## ⚠️ Important Notes

1. **Swift Charts**: The app uses Swift Charts framework, available in iOS 16.0+
2. **Target iOS Version**: Set deployment target to iOS 16.0 or later
3. **SwiftUI**: Make sure Interface is set to SwiftUI (not UIKit)

## 🔧 Build Settings

Once project is set up:
1. Select your project in navigator
2. Go to **Build Settings**
3. Set **iOS Deployment Target** to **16.0** (for Charts support)
4. Ensure **Swift Language Version** is set to **Swift 5**

## 🏃‍♂️ Running the App

1. Select a simulator (iPhone 14 or newer recommended)
2. Press **⌘+R** or click **Play** button
3. The app should build and launch with the calculator list

## 🐛 Troubleshooting

**Build Errors?**
- Check that all Swift files are added to the target
- Verify iOS deployment target is 16.0+
- Make sure SwiftUI is selected as interface

**Missing Files?**
- Ensure all files from CalcBoxSwiftUI folder are copied
- Check that files are added to the Xcode project target

**Charts Not Working?**
- Verify iOS 16.0+ deployment target
- Import statement `import Charts` should be present

## 📱 Testing Different Calculators

Once running, you can test:
- **Compound Interest**: Enter values and see growth charts
- **EV Charging**: Select different electric vehicles
- **BMI Calculator**: Test with different height/weight values
- **Appliance Energy**: Try different appliances from the picker

## 🎯 Next Steps

After getting it running:
- Customize colors and styling
- Add more calculator implementations 
- Implement data persistence
- Add widgets support

Need help? Check the README.md for more technical details!