#!/bin/bash

# Function to print usage
print_usage() {
  echo "Usage: $0 <path to test> [-s <size_in_mb>]"
  echo "  <path to test>   Path of the disk to test (e.g., /Volumes/YourDiskName)"
  echo "  -s <size_in_mb>  Optional size of the test file in MB (default: 2000)"
  exit 1
}

# Default test file size in MB
TEST_FILE_SIZE_MB=2000

# Check if a path has been provided
if [ $# -eq 0 ]; then
    print_usage
fi

# Parse command-line arguments
MOUNT_PATH="$1"
shift
while getopts ":s:" opt; do
  case ${opt} in
    s )
      TEST_FILE_SIZE_MB=$OPTARG
      ;;
    \? )
      print_usage
      ;;
  esac
done

# Check if the mount path exists
if [ ! -d "$MOUNT_PATH" ]; then
  echo "Error: Disk path '$MOUNT_PATH' does not exist."
  exit 1
fi

TEST_FILE="$MOUNT_PATH/speed_test_file"
BLOCK_SIZE=1m # Use lowercase 'm' for macOS dd command

echo "Testing write and read speed for $MOUNT_PATH with file size ${TEST_FILE_SIZE_MB}MB..."

# Clear the system cache (macOS specific, requires sudo)
echo "Clearing system cache..."
sudo purge

# Measure write speed
WRITE_START=$(date +%s.%N)
dd if=/dev/urandom of="$TEST_FILE" bs=$BLOCK_SIZE count=$TEST_FILE_SIZE_MB &> /dev/null
WRITE_END=$(date +%s.%N)
WRITE_DIFF=$(echo "$WRITE_END - $WRITE_START" | bc)
WRITE_SPEED=$(echo "scale=2; $TEST_FILE_SIZE_MB / $WRITE_DIFF" | bc)
echo "Write Speed: $WRITE_SPEED MB/s"

# Clear the system cache again to ensure accurate read speed measurement
echo "Clearing system cache..."
sudo purge

# Measure read speed
READ_START=$(date +%s.%N)
dd if="$TEST_FILE" of=/dev/null bs=$BLOCK_SIZE &> /dev/null
READ_END=$(date +%s.%N)
READ_DIFF=$(echo "$READ_END - $READ_START" | bc)
READ_SPEED=$(echo "scale=2; $TEST_FILE_SIZE_MB / $READ_DIFF" | bc)
echo "Read Speed: $READ_SPEED MB/s"

# Cleanup
rm -f "$TEST_FILE"
echo "Cleaned up test file."

echo "Speed test completed for $MOUNT_PATH"
