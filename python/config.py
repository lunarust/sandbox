#!/usr/bin/python
from configparser import ConfigParser


def dwdb(filename='database.ini', section='dw'):
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
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return dw

def proddb(filename='database.ini', section='prod'):
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
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return prod    