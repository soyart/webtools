#!/usr/bin/env python3

import os
import sys
import htmlmin

prog_name = os.path.basename(__file__)

def loop_dir(dir_name, start_path):
    # Change cwd to dir_name
    os.chdir(dir_name)
    dir_files = os.listdir(".")

    for current_file in dir_files:
        if os.path.isdir(current_file):
            loop_dir(current_file, start_path)

        if ".html" in current_file:
            read_and_minify(current_file)

    os.chdir("..")


def read_and_minify(html_filename):
    full_path = os.path.abspath(html_filename)

    fp_r = open(html_filename, "r")
    document = fp_r.read()
    fp_r.close()

    minified = htmlmin.minify(document)
    print(f"[{prog_name}] Minify: {full_path}")

    fp_w = open(html_filename, "w")
    fp_w.write(minified)
    fp_w.close()

def main():
    if len(sys.argv) < 2:
        print("[{prog_name}] Missing HTML root directory")
        print("Usage: {prog_name} <HTML_DIR>")
        exit()
    
    root_dir = sys.argv[1]
    print(f'[{prog_name}] HTML directory: {root_dir}')
    
    path_len = len(root_dir)
    trailing = root_dir[path_len-1]
    if trailing == "/":
      root_dir = root_dir[:path_len-1]
    
    root_full_path = os.path.abspath(root_dir)
    root_parent = os.path.abspath("..")
    
    # call loop_dir (recursive)
    loop_dir(root_full_path, root_parent)

if __name__ == "__main__":
    sys.exit(main())
