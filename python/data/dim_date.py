import pandas as pd
import sqlalchemy as sa
import config
import datetime as dt

def save_dim_date_to_db():
    conn = sa.create_engine(f'postgresql+psycopg2://{config.dw()["user"]}:{config.dw()["password"]}@{config.dw()["host"]}:{config.dw()["port"]}/{config.dw()["dbname"]}')

    # date dimension table
    # Set start and end dates
    start_date = dt.date(2019, 1, 1)
    end_date = dt.date(2025, 12, 31)

    # Create date range
    date_range = pd.date_range(start_date, end_date)

    # Get today's date
    today = pd.Timestamp.now().normalize()
    # Calculate the start and end dates of the last month
    start_last_month = today - pd.DateOffset(months=1, days=today.day - 1)
    end_last_month = today - pd.DateOffset(days=today.day)

    # Create dataframe
    df_dim_date = pd.DataFrame({
        'tx_date': date_range.strftime('%Y-%m-%d'),
        'day_of_week': date_range.strftime('%a'),
        'part_of_week': pd.cut(date_range.dayofweek, [-1, 4, 6], labels=['weekday', 'weekend']),
        'week': date_range.strftime('%Y wk %U'),
        'month': date_range.strftime('%Y-%m'),
        'month_name': date_range.strftime('%Y %b'),
        'year': date_range.strftime('%Y'),
        'is_last_month': ((date_range >= start_last_month) & (date_range <= today)).astype(int)
    })

    df_dim_date.to_sql('dim_date', con=conn, schema='dev_staging', if_exists='replace', index=False)
    print('saved dim_date table to dw')


if __name__ == '__main__':
    print('Saving dim_date table to DataWarehouse...')
    save_dim_date_to_db()
