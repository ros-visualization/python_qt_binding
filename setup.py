#!/usr/bin/env python
from distutils.core import setup

setup(name='Python Qt binding',
      version='0.2.0',
      description='Qt bindings for ROS',
      packages=['python_qt_binding'],
      package_dir={'':'src'}
)
