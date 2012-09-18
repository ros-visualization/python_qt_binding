#!/usr/bin/env python

from __future__ import print_function
from distutils.core import setup
import sys
from xml.etree.ElementTree import ElementTree

try:
    root = ElementTree(None, 'stack.xml')
    version = root.findtext('version')
except Exception as e:
    print('Could not extract version from your stack.xml:\n%s' % e, file=sys.stderr)
    sys.exit(-1)


setup(name='Python Qt binding',
      version=version,
      description='Qt bindings for ROS',
      packages=['python_qt_binding'],
      package_dir={'':'src'}
)
