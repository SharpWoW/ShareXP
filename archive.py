#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# Copyright © 2014 by Adam Hellberg <adam.hellberg@sharparam.com>.
#

import os
import re
import sys
import fnmatch
import zipfile
import glob
from subprocess import call

SCRIPT = sys.argv[0]

TOC_VERSION_PATTERN = re.compile("^## Version: (\d+\.\d+\.\d+(?:-[a-z0-9]+)?)$")

def log(msg, *args):
    print '{0}: {1}'.format(SCRIPT, msg.format(*args))

if len(sys.argv) < 3:
    log('expected args: name, build number')
    sys.exit(1)

name = None
build = None

try:
    name = str(sys.argv[1]).strip()
    build = int(sys.argv[2].strip())
except ValueError:
    log('expected build number argument of type integer')
    sys.exit(1)

TOC_FILENAME = "{0}.toc".format(name)

def clean_directory(dst):
    log('Cleaning directory: {0}', dst)
    if os.path.isdir(dst):
        for f in os.listdir(dst):
            fp = os.path.join(dst, f)
            try:
                if os.path.isfile(fp):
                    os.unlink(fp)
            except Exception, e:
                log('EXCEPTION: Failed to delete {0}: {1}', fp, e)
    elif os.path.isfile(dst):
        os.unlink(dst)
        os.makedirs(dst)
    else:
        os.makedirs(dst)
    log('Directory cleanup completed: {0}', dst)

build_dirs = ['build', 'lua']

for build_dir in build_dirs:
    clean_directory(build_dir)

additional_files = ["LICENSE", "README.md", TOC_FILENAME]

ignored = ['/.*', SCRIPT, '*.moon', '*.zip']

def is_file_ignored(file):
    for pattern in ignored:
        if os.name == 'nt':
            pattern = pattern.replace('/', '\\')
        if re.search(fnmatch.translate(pattern), file):
            return True
    return False

def lint_addon():
    files = glob.glob('*.moon')
    ret = call(["moonc", "-l"] + files)
    if ret != 0:
        log('FAILURE: moonc linter exited with non-zero return code')
        sys.exit(1)

def compile_addon():
    lint_addon()
    moonfiles = glob.glob('*.moon')
    ret = call(["moonc", "-t", "lua"] + moonfiles)
    if ret != 0:
        log('FAILURE: moonc compile exited with non-zero return code')
        sys.exit(1)
    luafiles = glob.glob('lua/*.lua')
    ret = call(["luac", "-p"] + luafiles)
    if ret != 0:
        log('FAILURE: luac parse exited with non-zero return code')
        sys.exit(1)

def zip_file(zf, file):
    absname = os.path.abspath(file)
    if not is_file_ignored(absname):
        arcname = os.path.join(name, file)
        log('{0} -> {1}', file, arcname)
        zf.write(absname, arcname)

def zip_dir(zf, path):
    for dirpath, dirnames, filenames in os.walk(path):
        for filename in filenames:
            zip_file(zf, os.path.join(dirpath, filename))

def make_zip(sources, zf):
    for src in sources:
        if os.path.isdir(src):
            zip_dir(zf, src)
        else:
            zip_file(zf, src)

def get_version():
    version = "UNKNOWN"
    for line in open(TOC_FILENAME).read().splitlines():
        match = TOC_VERSION_PATTERN.match(line)
        if match:
            version = match.group(1)
            break
    return version

version = get_version()

zipname = os.path.join('build', '{0}_v{1}_b{2}.zip'.format(name, version, build))

compile_addon()

ignored.append(zipname)

log('Building zip file at {0}', zipname)

with zipfile.ZipFile(zipname, 'w', zipfile.ZIP_DEFLATED) as zf:
    make_zip(['libs', 'lua', 'LICENSE', 'README.md', 'ShareXP.toc'], zf)
    zf.close()
    log('DONE! Zip successfully created: {0}!', zipname)
