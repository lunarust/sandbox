#!/usr/bin/python
from configparser import ConfigParser


def dw(filename='database.ini', section='dw'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    dw = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            dw[param[0]] = param[1]
    else:
        raise Exception(f'Section {section} not found in the {filename} file')

    return dw

def prod(filename='database.ini', section='prod'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    prod = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            prod[param[0]] = param[1]
    else:
        raise Exception(f'Section {section} not found in the {filename} file')

    return prod    
