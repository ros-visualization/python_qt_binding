#!/usr/bin/env python
try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

setup_opts = dict(
	package_dir={'': 'src'},
    classifiers = [
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'Operating System :: OS Independent'
        'Programming Language :: Python',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'License :: OSI Approved :: BSD License',
        'License :: OSI Approved :: GNU Library or Lesser General Public License (LGPL)',
        'License :: OSI Approved :: GNU General Public License (GPL)',
    ]
)
	
try:
	from catkin_pkg.python_setup import generate_distutils_setup
except ImportError:
	import xml.etree.ElementTree as ET
	tree = ET.parse('package.xml')

	root = tree.getroot()

	setup_opts['name'] = root.find("./name").text
	setup_opts['version'] = root.find("./version").text
	setup_opts['description'] = root.find("./description").text.strip()
	setup_opts['url'] = root.find("./url").text
	setup_opts['author'] = ', '.join([x.text for x in root.findall("./author")])
	setup_opts['packages'] = [setup_opts['name']]
	
	mt = root.find("./maintainer")
	setup_opts['maintainer'] = mt.text
	setup_opts['maintainer_email'] = mt.attrib['email']

	setup(**setup_opts)
else:
	d = generate_distutils_setup(**setup_opts)
	setup(**d)
	

