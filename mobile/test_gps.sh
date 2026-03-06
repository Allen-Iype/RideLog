#!/bin/bash
# GPS Location Simulator for RideLog Testing
# Simulates a route through San Francisco

echo "Starting GPS simulation for RideLog testing..."
echo "This will simulate movement along a route."
echo ""

# Array of coordinates (San Francisco area)
coordinates=(
    "37.7749 -122.4194"  # Start: San Francisco
    "37.7739 -122.4189"  # Move slightly northeast
    "37.7729 -122.4184"
    "37.7719 -122.4179"
    "37.7709 -122.4174"
    "37.7699 -122.4169"
    "37.7689 -122.4164"
    "37.7679 -122.4159"
    "37.7669 -122.4154"
    "37.7659 -122.4149"
    "37.7649 -122.4144"  # End point (about 1.1 km from start)
)

# Loop through coordinates and send to emulator
for i in "${!coordinates[@]}"; do
    coord=(${coordinates[$i]})
    lat=${coord[0]}
    lon=${coord[1]}

    echo "[$((i+1))/${#coordinates[@]}] Setting location to: $lat, $lon"
    adb emu geo fix $lon $lat

    # Wait 5 seconds between updates (simulates riding speed)
    if [ $i -lt $((${#coordinates[@]}-1)) ]; then
        sleep 5
    fi
done

echo ""
echo "GPS simulation complete!"
echo "Total points: ${#coordinates[@]}"
echo "Estimated distance: ~1.1 km"
