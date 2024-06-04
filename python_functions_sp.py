import pandas as pd

def columns_lower_snake_case(dataframes):
    for df in dataframes:
        df.columns = df.columns.str.lower()
        df.columns = df.columns.str.replace(' ', '_')
        df.rename(columns = {'year/study': 'year'}, inplace=True)

        print(df.columns)
        print('-' * 30)
    return dataframes


def columns_lower_snake_case_2(df):
    df.columns = df.columns.str.lower()
    df.columns = df.columns.str.replace(' ', '_')

    return df

