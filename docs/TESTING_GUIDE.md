# RideLog - Testing Guide

**Version:** 1.0
**Last Updated:** 2026-03-06
**Phases Covered:** 1-4 (Setup, Map, GPS, Ride Recording)

---

## Prerequisites

- Android emulator running (or iOS Simulator with CocoaPods installed)
- RideLog app installed and running
- Terminal access for GPS simulation

---

## Testing Workflow

### Test 1: Map Display and Interaction
**Feature:** Phase 2 - Map Integration
**Objective:** Verify map renders and is interactive

**Steps:**
1. Launch the app
2. Observe the map loads on screen
3. Try to pan the map (drag with mouse/finger)
4. Try to zoom (pinch gesture or mouse wheel)
5. Click the "My Location" button (compass icon) in top-right

**Expected Results:**
- ✅ Map displays OpenStreetMap tiles
- ✅ Map responds to pan gestures smoothly
- ✅ Zoom works correctly
- ✅ "My Location" button centers map on current location

**Potential Issues:**
- Map tiles fail to load (network issue)
- App shows default location (San Francisco) if no GPS signal

---

### Test 2: Initial Location Acquisition
**Feature:** Phase 2 - Map Integration
**Objective:** Verify app gets initial GPS location

**Steps:**
1. On app launch, observe loading indicator
2. Wait for "Getting your location..." message to complete

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Map centers on current location once acquired
- ✅ Red location pin appears on map

**To Simulate GPS Location:**
```bash
# Set a starting location (San Francisco)
adb emu geo fix -122.4194 37.7749
```

**Potential Issues:**
- Loading indicator stays forever (GPS permissions denied)
- Error message appears (location services disabled)

---

### Test 3: GPS Permission Handling
**Feature:** Phase 3 - GPS Tracking
**Objective:** Verify location permissions are requested

**Steps:**
1. On first launch, app should request location permission
2. If permission dialog appears, click "Allow" or "While using the app"
3. If already granted, check Settings → Apps → RideLog → Permissions

**Expected Results:**
- ✅ Permission dialog shown on first use
- ✅ App functions after granting permission
- ✅ Graceful error if permission denied

**Manual Test:**
- Revoke permissions in Settings
- Relaunch app
- Verify error message appears

---

### Test 4: GPS Tracking Toggle
**Feature:** Phase 3 - GPS Tracking
**Objective:** Verify GPS tracking can be enabled/disabled

**Steps:**
1. Tap the GPS icon in the top-right corner (should be gray/off)
2. Observe the icon turns green
3. Check for "GPS tracking started" snackbar message
4. Tap the GPS icon again to disable
5. Verify "GPS tracking stopped" message appears

**Expected Results:**
- ✅ GPS icon changes color (gray → green)
- ✅ Snackbar messages appear
- ✅ Location marker updates when tracking is ON
- ✅ Location marker stops updating when tracking is OFF

---

### Test 5: Live GPS Data Display
**Feature:** Phase 3 - GPS Tracking
**Objective:** Verify GPS data panel shows live information

**Steps:**
1. Enable GPS tracking (green icon)
2. Look at the bottom panel showing GPS data
3. Simulate location changes:
   ```bash
   # Send new location
   adb emu geo fix -122.4189 37.7739
   ```
4. Observe the panel updates

**Expected Results:**
- ✅ Speed displays in km/h
- ✅ Heading displays in degrees
- ✅ Altitude displays in meters
- ✅ Coordinates display with 6 decimal places
- ✅ GPS accuracy indicator shows quality (Excellent/Good/Fair/Poor)
- ✅ Values update in real-time as location changes

**What to Look For:**
- Speed: Should be 0.0 km/h when stationary
- Heading: Shows direction (0-360°)
- Altitude: Elevation in meters
- Accuracy: Green = Excellent (<10m), Orange = Fair (30-50m), Red = Poor (>50m)

---

### Test 6: Start Ride Recording
**Feature:** Phase 4 - Ride Recording
**Objective:** Verify ride recording starts correctly

**Steps:**
1. Ensure GPS tracking is enabled (green icon)
2. Tap the green "Start Ride" button at the bottom
3. Observe the button changes to red "Stop Ride"
4. Check for "Ride recording started!" snackbar
5. Observe the GPS data panel switches to Ride Stats Panel

**Expected Results:**
- ✅ Button changes: Green "Start Ride" → Red "Stop Ride"
- ✅ Success message appears
- ✅ Ride Stats Panel appears with red "RECORDING" indicator
- ✅ Statistics show: Distance (km), Time, Avg Speed, Max Speed
- ✅ GPS point count starts at 0 and increases

**Initial Values:**
- Distance: 0.00 km
- Time: 0s (then 1s, 2s, 3s...)
- Avg Speed: 0.0 km/h
- Max Speed: 0.0 km/h
- GPS Points: 0

---

### Test 7: Route Polyline Drawing
**Feature:** Phase 4 - Ride Recording
**Objective:** Verify route is drawn on map during ride

**Steps:**
1. Start a ride (see Test 6)
2. Run the GPS simulation script:
   ```bash
   cd /Users/allen/Personal/RideLog/mobile
   ./test_gps.sh
   ```
3. Watch the map as the script runs

**Expected Results:**
- ✅ Blue polyline appears on the map
- ✅ Polyline connects each GPS point in order
- ✅ Polyline has white border for visibility
- ✅ Route updates in real-time as new points are added
- ✅ Location marker moves along the route

**Visual Check:**
- Polyline should be smooth and continuous
- No big jumps or erratic lines (GPS filtering working)
- Route follows the simulated path

---

### Test 8: Live Statistics During Ride
**Feature:** Phase 4 - Ride Recording
**Objective:** Verify statistics calculate correctly during ride

**Steps:**
1. Start a ride
2. Run GPS simulation script
3. Watch the Ride Stats Panel while simulation runs

**Expected Results:**
- ✅ **Distance** increases as route extends (~1.1 km total)
- ✅ **Time** counts up every second (format: 1s, 30s, 1m 30s, etc.)
- ✅ **Avg Speed** calculates correctly (distance / time)
- ✅ **Max Speed** updates when speed increases
- ✅ **GPS Points** increments (should reach 11 points)

**Calculations to Verify:**
- Distance should be approximately 1.1 km after simulation
- Time should be approximately 50 seconds (11 points × 5 seconds)
- Avg Speed = (1.1 km / 50s) × 3600 = ~79 km/h (high because we're teleporting)
- In real riding, speeds would be more realistic (40-80 km/h for motorcycle)

---

### Test 9: Stop Ride and View Summary
**Feature:** Phase 4 - Ride Recording
**Objective:** Verify ride can be stopped and summary displayed

**Steps:**
1. After GPS simulation completes, tap red "Stop Ride" button
2. Wait for ride summary dialog to appear
3. Review all statistics in the dialog

**Expected Results:**
- ✅ Summary dialog appears with title "Ride Complete!"
- ✅ Dialog shows:
  - Distance: ~1.1 km
  - Duration: ~50 seconds (formatted as "50s")
  - Average Speed: ~79 km/h
  - Max Speed: (highest speed during ride)
  - GPS Points: 11
- ✅ "Save Ride" button present
- ✅ "Discard" button present

**Dialog Format:**
```
✓ Ride Complete!
━━━━━━━━━━━━━━━━━━━
📍 Distance:      1.10 km
⏱ Duration:      50s
💨 Average Speed: 79.2 km/h
📈 Max Speed:     85.6 km/h
📌 GPS Points:    11
━━━━━━━━━━━━━━━━━━━
[Save Ride]  [Discard]
```

---

### Test 10: Save/Discard Ride
**Feature:** Phase 4 - Ride Recording (Placeholder)
**Objective:** Verify save/discard buttons work

**Steps:**
1. From ride summary dialog, tap "Save Ride"
2. Observe the result
3. Alternatively, tap "Discard"

**Expected Results (Current Phase 4):**
- ✅ Tapping "Save Ride" shows placeholder: "Ride saved locally (coming in Phase 5)"
- ✅ Tapping "Discard" closes dialog without saving
- ✅ Dialog closes after either action

**Note:** Actual saving to SQLite will be implemented in Phase 5

---

### Test 11: GPS Accuracy Filtering
**Feature:** Phase 4 - Ride Recording
**Objective:** Verify low-accuracy points are filtered out

**Steps:**
1. Start a ride
2. Manually send a low-accuracy location:
   ```bash
   # Note: Emulator doesn't support setting accuracy directly
   # This test requires physical device testing
   ```

**Expected Results:**
- ✅ Points with accuracy > 50 meters are rejected
- ✅ Message in debug console: "Skipping low accuracy point: XXm"
- ✅ Bad points don't appear on the route polyline

**Physical Device Testing:**
- Test indoors (poor GPS) vs outdoors (good GPS)
- Verify indoor points are filtered out

---

### Test 12: Error Handling
**Feature:** All Phases
**Objective:** Verify app handles errors gracefully

**Test Cases:**

**12a. Start ride without GPS:**
1. Disable GPS tracking (gray icon)
2. Tap "Start Ride"
3. **Expected:** Error message: "Failed to start ride recording. Check GPS."

**12b. Location permission denied:**
1. Revoke location permission in Settings
2. Try to enable GPS tracking
3. **Expected:** Permission denied message

**12c. Stop ride without starting:**
1. Fresh app launch
2. Try to tap "Stop Ride" (should not be visible)
3. **Expected:** Button is disabled/not shown

---

## Complete Test Scenario: Full Ride Flow

**Objective:** Test the complete user journey from launch to ride completion

### Step-by-Step:

1. **Launch App**
   - ✅ Map loads
   - ✅ Location acquired
   - ✅ Location marker appears

2. **Enable GPS Tracking**
   - ✅ Tap GPS icon (top-right)
   - ✅ Icon turns green
   - ✅ GPS data panel shows live data

3. **Start Ride**
   - ✅ Tap green "Start Ride" button
   - ✅ Button turns red "Stop Ride"
   - ✅ Ride stats panel appears

4. **Simulate Movement**
   - ✅ Run `./test_gps.sh`
   - ✅ Watch route draw on map
   - ✅ Watch statistics update

5. **Monitor Progress**
   - ✅ Distance increases to ~1.1 km
   - ✅ Time counts up to ~50s
   - ✅ GPS points reach 11
   - ✅ Speeds calculate correctly

6. **Stop Ride**
   - ✅ Tap red "Stop Ride"
   - ✅ Summary dialog appears
   - ✅ All stats displayed correctly

7. **Complete**
   - ✅ Tap "Save Ride" (placeholder message)
   - ✅ Dialog closes

**Total Test Time:** ~3-5 minutes

---

## GPS Simulation Commands

### Set Single Location
```bash
# Format: adb emu geo fix <longitude> <latitude>
adb emu geo fix -122.4194 37.7749  # San Francisco
```

### Run Full Route Simulation
```bash
cd /Users/allen/Personal/RideLog/mobile
./test_gps.sh
```

### Manual Route (for custom testing)
```bash
# Start location
adb emu geo fix -122.4194 37.7749
sleep 5

# Move northeast
adb emu geo fix -122.4189 37.7739
sleep 5

# Continue moving
adb emu geo fix -122.4184 37.7729
sleep 5

# And so on...
```

---

## Known Limitations (Emulator)

1. **No Real Movement**: Emulator teleports between points, not smooth movement
2. **High Speeds**: Teleporting results in unrealistically high speeds
3. **No Heading Data**: Emulator may not provide accurate heading/compass data
4. **Perfect Accuracy**: Emulator always reports high accuracy (no realistic variation)

**For Realistic Testing:**
- Use a physical Android device or iPhone
- Go for an actual ride (motorcycle, car, or even walking)
- Real GPS will provide accurate speed, heading, and accuracy data

---

## Debug Output

While testing, monitor the terminal running `flutter run` for debug messages:

```
I/flutter ( 5416): GPS tracking started (distance filter: 10.0m, time: 5000ms)
I/flutter ( 5416): Ride recording started at 2026-03-06T12:00:00.000
I/flutter ( 5416): Recorded point 1: 37.774900, -122.419400 (distance: 0.00km)
I/flutter ( 5416): Recorded point 2: 37.773900, -122.418900 (distance: 0.11km)
I/flutter ( 5416): Skipping low accuracy point: 75.0m
I/flutter ( 5416): Ride recording stopped at 2026-03-06T12:01:00.000
I/flutter ( 5416): Total distance: 1.10 km
I/flutter ( 5416): Duration: 00:00:50
I/flutter ( 5416): Average speed: 79.2 km/h
```

---

## Test Results Template

Use this checklist to track your testing:

### Phase 2 - Map Integration
- [ ] Map displays correctly
- [ ] Map pan works
- [ ] Map zoom works
- [ ] My location button works

### Phase 3 - GPS Tracking
- [ ] Location permissions requested
- [ ] Initial location acquired
- [ ] GPS tracking toggle works
- [ ] GPS data panel displays
- [ ] Live data updates correctly
- [ ] Accuracy indicator shows correct status

### Phase 4 - Ride Recording
- [ ] Start ride button works
- [ ] GPS tracking auto-starts with ride
- [ ] Ride stats panel appears
- [ ] Polyline draws on map
- [ ] Distance calculates correctly
- [ ] Duration counts up
- [ ] Average speed calculates
- [ ] Max speed tracks
- [ ] GPS point count increases
- [ ] Stop ride button works
- [ ] Summary dialog displays
- [ ] Save button works (placeholder)
- [ ] Discard button works

### Error Handling
- [ ] Handles permission denial
- [ ] Handles no GPS signal
- [ ] Filters low-accuracy points
- [ ] Shows appropriate error messages

---

## Troubleshooting

### Issue: GPS simulation not working
**Solution:**
```bash
# Check if emulator is connected
adb devices

# If multiple devices, specify emulator
adb -s emulator-5554 emu geo fix -122.4194 37.7749
```

### Issue: Polyline not drawing
**Possible causes:**
- GPS tracking not enabled (gray icon)
- Ride not started
- No location updates received
- Points filtered due to low accuracy

### Issue: Statistics not updating
**Check:**
- Timer is running (time should count up)
- GPS points are being recorded (watch debug output)
- Location updates are arriving (check GPS data panel first)

---

## Next Steps

After completing Phase 1-4 testing:

1. Document any bugs found
2. Verify all acceptance criteria met
3. Ready to proceed with **Phase 5 - Local Ride Storage**

---

**End of Testing Guide**
