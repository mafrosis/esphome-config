#! /usr/bin/env python

from setuptools import setup, find_packages

with open('README.md') as f:
    long_description = f.read()

with open('requirements.txt') as f:
    install_requires = f.readlines()

setup(
    name='esphome-render',
    version='0.1',
    description='Render composable esphome templates for my devices',
    long_description_content_type='text/markdown',
    long_description=long_description,
    author='Matt Black',
    author_email='dev@mafro.net',
    url='http://github.com/mafrosis/homeassistant-config/esphome',
    packages=find_packages(exclude=['test']),
    package_data={'': ['LICENSE']},
    package_dir={'': '.'},
    include_package_data=True,
    install_requires=install_requires,
    license='MIT License',
    entry_points={
        'console_scripts': [
            'render=esphome_render.render:main'
        ]
    },
    classifiers=[
        'Development Status :: 4 - Beta',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'Intended Audience :: System Administrators',
        'Natural Language :: English',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3.9',
    ],
)
