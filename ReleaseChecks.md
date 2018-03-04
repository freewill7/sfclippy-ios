# Test plan for sfclippy

## iPhone SE
This is the smallest iPhone so we testing using this virtual device.

### Initial
1. Clear out the test account
2. Boot from clean
3. Sign in using test account

### Battle
1. Check main view is ok
2. Select "Alex" via P1
3. Edit "Blanka" to "BlankaChan" via P2
4. Drag to Alex, check reported statistics are correct
5. Drag to Blanka, check reported statistics are correct
6. Drag to Blanka again, check reported statistics are ok

### Results
1. Select "Results" tab, check battles recorded with appropriate winner

### Statistics
1. Select "Statistics" tab, check values look correct

### Settings
1. Select "Settings" tab
2. Select "Regenerate Statistics", check that it goes grey then returns to normal colour
3. Check statistics are still ok

## iPhone 7 (actual hardware)

#### Initial
1. Clear out the test account
2. Boot from clean
3. Sign in using test account

### Battle
1. Check main view is ok
2. Go to P1 and select "Use Sample"
3. Add "Mario" and then select him
4. Go to P2 and select "Ryu"
5. Check no stats in centre
6. Drag centre to "Mario"
 i. Vibration triggered
 ii. Result recorded
7. Drag centre to "Ryu"
 i. Vibration triggered
 ii. Result recorded
8. Drag centre to "Ryu" again
 i. Vibration triggered
 ii. Result recorded

### Results
1. Select "Results" tab, check battles recorded with appropriate winner

### Statistics
1. Select "Statistics" tab, check values look correct

### Settings
1. Select "Settings" tab
2. Select "Regenerate Statistics", check that it goes grey then returns to normal colour
3. Check statistics are still ok
