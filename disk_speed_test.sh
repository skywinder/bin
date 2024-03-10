#!/bin/bash

# Check if a path has been provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <path to test>"
    exit 1
fi

MOUNT_PATH="$1"
TEST_FILE="$MOUNT_PATH/speed_test_file"
TEST_FILE_SIZE_MB=200 # Size of the test file in megabytes
BLOCK_SIZE=1m # Use lowercase 'm' for macOS dd command

echo "Testing write and read speed for $MOUNT_PATH..."

# Create a test file with random data, suppressing progress output
dd if=/dev/urandom of="$TEST_FILE" bs=$BLOCK_SIZE count=$TEST_FILE_SIZE_MB &> /dev/null

# Measure write speed
WRITE_START=$(date +%s.%N)
dd if=/dev/urandom of="$TEST_FILE" bs=$BLOCK_SIZE count=$TEST_FILE_SIZE_MB &> /dev/null
WRITE_END=$(date +%s.%N)
WRITE_DIFF=$(echo "$WRITE_END - $WRITE_START" | bc)

# Calculate write speed in MB/s
WRITE_SPEED=$(echo "scale=2; $TEST_FILE_SIZE_MB / $WRITE_DIFF" | bc)
echo "Write Speed: $WRITE_SPEED MB/s"

# Clear the system cache to ensure accurate read speed measurement. This command might require sudo and not be feasible on all macOS setups.
# Instead of trying to drop caches (which is not straightforward on macOS), advise the user manually or ensure read tests are understood to include cache effects.

# Measure read speed
READ_START=$(date +%s.%N)
dd if="$TEST_FILE" of=/dev/null bs=$BLOCK_SIZE &> /dev/null
READ_END=$(date +%s.%N)
READ_DIFF=$(echo "$READ_END - $READ_START" | bc)

# Calculate read speed in MB/s
READ_SPEED=$(echo "scale=2; $TEST_FILE_SIZE_MB / $READ_DIFF" | bc)
echo "Read Speed: $READ_SPEED MB/s"

# Cleanup
rm -f "$TEST_FILE"

echo "Speed test completed for $MOUNT_PATH"

