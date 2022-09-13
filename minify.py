#!/usr/bin/env python

import os
import sys
import htmlmin

def loop_dir(dir_name, start_path):
    prev = os.getcwd()
    print(f"> Call loop_dir({dir_name})")
    os.chdir(dir_name)
    print(f"> PWD: {os.getcwd()}")
    basedir = os.path.basename(".")
    dir_files = os.listdir(basedir)

    for current_file in dir_files:
        print(f"> Working on {current_file}")
        if os.path.isdir(current_file):
            prev = f"../{current_file}"
            print(f"> prev is now {prev}")
            loop_dir(current_file, start_path)
        if ".html" in current_file:
            print(f'> {current_file} is html')
            read_and_minify(current_file)

    print(f"> loop_dir DONE for {dir_name}")
    print(f"> Now PWD ${os.getcwd()}")
    try:
        os.chdir(prev)
    except FileNotFoundError:
        dotdot_dir = os.path.abspath("..")
        if dotdot_dir != start_path:
            os.chdir("..")
        else:
            print("> DONE")
            exit()

visited = {}
def read_and_minify(html_filename):
    fullpath = os.path.abspath(html_filename)
    this_visited = visited.get(fullpath)
    if this_visited:
        return

    fp = open(html_filename)
    document = fp.read()
    minified = htmlmin.minify(document)
    print(f"> HTML: {html_filename}")
    print(f"> Minified:")
    print(minified)

    visited[fullpath] = True

if len(sys.argv) < 2:
    print("Missing HTML root directory")
    print("Usage: minify.py <HTML_DIR>")
    exit()

root_dir = sys.argv[1]
root_fullpath = os.path.abspath(root_dir)
print(f'HTML directory: {root_dir}')

loop_dir(root_dir, root_fullpath)
