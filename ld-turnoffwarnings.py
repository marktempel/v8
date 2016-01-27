# Copyright (c) 2016 LANDESK Software Inc. All rights reserved.

""" Turn off warnings as errors when building for Visual Studio 2015 """
import sys,glob,os

from xml.dom.minidom import parse, parseString

def main(argv):
    print os.getcwd()

    for file in glob.glob('./v8/tools/gyp/*.vcxproj'):
        doc = parse(file)
        for node in doc.getElementsByTagName('TreatWarningAsError'):
            node.firstChild.replaceWholeText('false')
        doc.writexml(open(file, 'w'))

if __name__ == '__main__':
  main(sys.argv[1:])
