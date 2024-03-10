import os
import argparse

def find_and_aggregate_empty_dirs(root_path, target_depth):
    aggregate_counts = {}
    for current_dir, dirs, files in os.walk(root_path):
        current_depth = current_dir[len(root_path):].count(os.path.sep)
        if current_depth >= target_depth:
            continue
        if current_depth == target_depth - 1:
            aggregate_counts[current_dir] = 0
        elif current_depth == target_depth:
            parent_dir = os.path.dirname(current_dir)
            if not dirs and not files and parent_dir in aggregate_counts:
                aggregate_counts[parent_dir] += 1
    return aggregate_counts

def main():
    parser = argparse.ArgumentParser(description='Find and aggregate empty directories at a specified depth.')
    parser.add_argument('path', type=str, help='The root path to search in')
    parser.add_argument('depth', type=int, help='The target depth for aggregation')
    args = parser.parse_args()

    root_path = args.path
    target_depth = args.depth
    aggregate_counts = find_and_aggregate_empty_dirs(root_path, target_depth)

    print(f"Aggregated counts of empty directories at depth {target_depth}:")
    for dir_path, count in aggregate_counts.items():
        print(f"{dir_path}: {count} empty directories")

if __name__ == "__main__":
    main()

