#!/usr/bin/env python
import xml.etree.ElementTree as ET
import os

pmd_xml_file = os.environ.get('PLUGIN_PMD_XML_FILE')

def convert_pmd_to_junit(pmd_xml_file, junit_xml_file):
    # Parse the PMD XML report
    pmd_tree = ET.parse(pmd_xml_file)
    pmd_root = pmd_tree.getroot()

    # Register the namespace
    namespace = {'pmd': 'http://pmd.sourceforge.net/report/2.0.0'}
    
    # Create the root for the JUnit XML report
    junit_root = ET.Element('testsuite', name='PMD Report', tests='0', failures='0', errors='0', skipped='0')

    # Counter for the number of tests and failures
    num_tests = 0
    num_failures = 0

    # Iterate through PMD violations and convert them to JUnit test cases
    for file in pmd_root.findall('pmd:file', namespace):
        filename = file.get('name')
        for violation in file.findall('pmd:violation', namespace):
            num_tests += 1
            # Create a test case for each violation
            testcase = ET.SubElement(junit_root, 'testcase', classname=filename, name=violation.get('rule'))
            
            # Add a failure element for the violation
            failure = ET.SubElement(testcase, 'failure', type='PMD Violation', message=violation.text.strip())
            num_failures += 1

    # Update the attributes of the testsuite
    junit_root.set('tests', str(num_tests))
    junit_root.set('failures', str(num_failures))
    junit_root.set('errors', '0')
    junit_root.set('skipped', '0')

    # Write the JUnit XML report to a file
    junit_tree = ET.ElementTree(junit_root)
    junit_tree.write(junit_xml_file)

    # Read the generated JUnit report and print its contents
    with open(junit_xml_file, 'r') as f:
        junit_report_contents = f.read()
        print(junit_report_contents)

# Example usage
convert_pmd_to_junit(pmd_xml_file, 'pmdjunitreport.xml')
