#!/usr/bin/python
import psycopg2
import config


def connect(params):
    conn = None
    try:
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        
        # open cursor 
        cur = conn.cursor()
        
        # execute your statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')

        # display output
        db_version = cur.fetchone()
        print(db_version)
       
        # Close connection
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')


if __name__ == '__main__':
    print('Testing connection to DataWarehouse...')
    connect(config.dw())

    print('Testing connection to Pegasus...')
    connect(config.prod())
