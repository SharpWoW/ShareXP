#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# Copyright © 2014 by Adam Hellberg <adam.hellberg@sharparam.com>.
#

import io
import os
import re
import sys
import json
import fnmatch
import zipfile
from shutil import copy
from subprocess import call

SCRIPT = sys.argv[0]

TOC_VERSION_PATTERN = re.compile("^## Version: (\d+\.\d+\.\d+(?:-[a-z0-9]+)?)$")

if len(sys.argv) < 3:
    print '{0}: expected args: name, build number'.format(SCRIPT)
    sys.exit(1)

name = None
build = None

try:
    name = str(sys.argv[1]).strip()
    build = int(sys.argv[2].strip())
except ValueError:
    print "{0}: expected build number argument of type integer".format(SCRIPT)
    sys.exit(1)

TOC_FILENAME = "{0}.toc".format(name)

def clean_directory(dst):
    print "{0}: Cleaning directory: {1}".format(SCRIPT, dst)
    if os.path.isdir(dst):
        for f in os.listdir(dst):
            fp = os.path.join(dst, f)
            try:
                if os.path.isfile(fp):
                    os.unlink(fp)
            except Exception, e:
                print "{0}: EXCEPTION: Failed to delete {1}: {2}".format(SCRIPT, fp, e)
    elif os.path.isfile(dst):
        os.unlink(dst)
        os.makedirs(dst)
    else:
        os.makedirs(dst)
    print "{0}: Directory cleanup completed: {1}".format(SCRIPT, dst)

build_dirs = ['build', 'lua', 'misc']

for build_dir in build_dirs:
    clean_directory(build_dir)

additional_files = ["LICENSE", "README.md", TOC_FILENAME]

ignored = ['/.*', SCRIPT]

def is_file_ignored(file):
    for pattern in ignored:
        if os.name == 'nt':
            pattern = pattern.replace('/', '\\')
        if re.search(fnmatch.translate(pattern), file):
            return True
    return False

def compile_addon():
    call(["moonc", "-t", "lua", "*.moon"])
    for filename in additional_files:
        copy(filename, 'misc')

def make_zip(sources, dst):
    ignored.append(dst)
    print "{0}: Building zip file at {1}".format(SCRIPT, dst)
    zf = zipfile.ZipFile(dst, 'w')
    for src in sources:
        print "{0}: Adding {1} to zip".format(SCRIPT, src)
        abs_src = os.path.abspath(src)
        for dirname, subdirs, files in os.walk(src):
            for filename in files:
                absname = os.path.abspath(os.path.join(dirname, filename))
                if not is_file_ignored(absname):
                    arcname = os.path.join(name, 'lua' if src == 'lua' else '', absname[len(abs_src) + 1:])
                    print "{0} -> {1}".format(os.path.join(dirname, filename), arcname)
                    zf.write(absname, arcname)
    zf.close()
    print "{0}: DONE! Zip successfully created: {1}!".format(SCRIPT, dst)

def get_version():
    version = "UNKNOWN"
    for line in open(TOC_FILENAME).read().splitlines():
        match = TOC_VERSION_PATTERN.match(line)
        if match:
            version = match.group(1)
            break
    return version

version = get_version()

zipname = "build/{0}_v{1}_b{2}.zip".format(name, version, build)

compile_addon()

make_zip(['lua', 'misc'], zipname)
