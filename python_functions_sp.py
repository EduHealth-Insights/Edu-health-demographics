import pandas as pd

def columns_lower_snake_case(dataframes):
    for df in dataframes:
        df.columns = df.columns.str.lower()
        df.columns = df.columns.str.replace(' ', '_')
        df.rename(columns = {'year/study': 'year'}, inplace=True)

        print(df.columns)
        print('-' * 30)
    return df

def columns_lower_snake_case_2(dataframes):
    for df in dataframes:
        df.columns = df.columns.str.lower()
        df.columns = df.columns.str.replace(' ', '_')
    return df

def columns_lower_snake_case_3(dataframes):
    for df in dataframes:
        df.columns = df.columns.str.lower()
        df.columns = df.columns.str.replace(' ', '_')
        df.columns = df.columns.str.replace('%', 'perc')
        df.columns = df.columns.str.replace('(', '')
        df.columns = df.columns.str.replace(')', '')
        df.columns = df.columns.str.replace(':', '')
    return df

def columns_lower_snake_case_4(df):
    df.columns = df.columns.str.lower()
    df.columns = df.columns.str.replace(' ', '_')
    df.columns = df.columns.str.replace('*', '')
    return df


# Separating the countries into the continents:
# northern america, middle and southern america, europe, africa, asia-pacific

northern_america = ['Canada', 'United States of America', 'United States']

southern_america = ['Antigua and Barbuda', 'Argentina', 'Argentina (2015)', 'Bahamas', 'Barbados', 'Belize',
                    'Bolivia (Plurinational State of)', 'Bolivia (Plurin. State of)', 'Brazil', 'Chile', 'Colombia', 'Costa Rica',
                    'Cuba', 'Dominica', 'Dominican Republic', 'Ecuador', 'El Salvador',
                    'Grenada', 'Guatemala', 'Guyana', 'Haiti', 'Honduras',
                    'Jamaica', 'Mexico', 'Nicaragua', 'Panama', 'Paraguay',
                    'Peru', 'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Saint Vincent & Grenadines', 'Suriname',
                    'Trinidad and Tobago', 'Uruguay', 'Venezuela (Bolivarian Republic of)', 'Venezuela (Boliv. Rep. of)']

northern_europe = ['Denmark', 'Estonia', 'Finland', 'Iceland', 'Latvia',
                   'Lithuania', 'Norway', 'Sweden', 'United Kingdom of Great Britain and Northern Ireland', 'United Kingdom', 'England', 'Scotland', 'Wales', 'Ireland']

eastern_europe = ['Belarus', 'Bulgaria', 'Czechia', 'Czech Republic', 'Hungary', 'Poland',
                  'Republic of Moldova', 'Moldova', 'Romania', 'Russian Federation', 'Russia','Slovakia', 'Slovak Republic', 'Ukraine', 'Ukraine (18 of 27 Regions)']

southern_europe = ['Albania', 'Albania (2015)', 'Andorra', 'Bosnia and Herzegovina', 'Croatia', 'Cyprus',
                   'Greece', 'Italy', 'Malta', 'Monaco', 'Montenegro',
                   'North Macedonia', 'Macedonia', 'Kosovo', 'Portugal', 'San Marino', 'Serbia', 'Slovenia',
                   'Spain']

western_europe = ['Austria', 'Belgium', 'Belgium (French)', 'Belgium (Flemish)', 'France', 'Germany',
                  'Liechtenstein', 'Luxembourg', 'Netherlands (Kingdom of the)', 'Netherlands', 'Switzerland']


africa = ['Algeria', 'Angola', 'Benin', 'Botswana', 'Burkina Faso',
          'Burundi', 'Cabo Verde', 'Cameroon', 'Central African Republic', 'Chad',
          'Comoros', 'Congo', 'Dem. Rep. of the Congo', 'Côte d\'Ivoire', 'Côte d\x92Ivoire', 'Democratic Republic of the Congo', 'Equatorial Guinea',
          'Eritrea', 'Eswatini', 'Ethiopia', 'Gabon', 'Gambia',
          'Ghana', 'Guinea', 'Guinea-Bissau', 'Kenya', 'Lesotho',
          'Liberia', 'Madagascar', 'Malawi', 'Mali', 'Mauritania',
          'Mauritius', 'Mozambique', 'Namibia', 'Niger', 'Nigeria',
          'Rwanda', 'Sao Tome and Principe', 'Senegal', 'Seychelles', 'Sierra Leone', 'Somalia',
          'South Africa', 'South Sudan', 'Sudan [former]', 'Togo', 'Tunisia', 'Uganda',
          'United Republic of Tanzania', 'United Rep. of Tanzania', 'Zambia', 'Zimbabwe', 'Djibouti', 'Egypt',
          'Morocco', 'Sudan']

asia = ['Afghanistan', 'Azerbaijan', 'Baku (Azerbaijan)', 'Iran (Islamic Republic of)','Iraq', 'Jordan',
        'Israel', 'Palestinian Authority', 'State of Palestine', 'Kyrgyzstan', 'Kazakhstan', 'Kazakhstan (2015)', 'Lebanon', 'Libya',
        'Pakistan', 'Syrian Arab Republic', 'Tajikistan', 'Turkmenistan', 'Türkiye', 'Turkey',
        'Uzbekistan', 'Republic of Uzbekistan', 'Yemen', 'Bangladesh', 'Bhutan', 'India',
        'Nepal', 'Sri Lanka', 'Thailand', 'Timor-Leste', 'Lao People\'s Democratic Republic', "Lao People's Dem. Rep.", 
        'Mongolia', 'Armenia', 'Georgia', ]

pacific = ['Australia', 'Australia and New Zealand', 'Indonesia', 'Myanmar', 'Cambodia', 'Fiji', 
           'Micronesia (Federated States of)', 'Micronesia (Fed. States of)', 'New Zealand', 'Papua New Guinea', 'China', 'B-S-J-G (China)',
           'B-S-J-Z (China)', 'Chinese Taipei', 'Hong Kong (China)', 'Macao (China)', 'China, Hong Kong SAR', 'China, Macao SAR', 'Japan', 
           'Malaysia', 'Malaysia (2015)', 'Philippines', 'Republic of Korea', 'Korea', "Dem. People's Rep. Korea", 'Singapore', 'Viet Nam']

middle_east = ['Bahrain', 'Kuwait', 'Oman', 'Qatar', 'Saudi Arabia', 
               'United Arab Emirates', 'Brunei Darussalam']


# define the function to assign the continents to the countries
def assign_continent(country):
    if country in northern_america:
        return 'North America'
    elif country in southern_america:
        return 'South America'
    elif country in northern_europe:
        return 'Europe'
    elif country in eastern_europe:
        return 'Europe'
    elif country in southern_europe:
        return 'Europe'
    elif country in western_europe:
        return 'Europe'
    elif country in africa:
        return 'Africa'
    elif country in asia:
        return 'Asia'
    elif country in pacific:
        return 'Pacific'
    elif country in middle_east:
        return 'Middle East'
    else:
        return 'Other'

# define the function to assign the continents and splitted europe to the countries
def assign_europe_region(country):
    if country in northern_america:
        return 'North America'
    elif country in southern_america:
        return 'South America'
    elif country in northern_europe:
        return 'North Europe'
    elif country in eastern_europe:
        return 'East Europe'
    elif country in southern_europe:
        return 'South Europe'
    elif country in western_europe:
        return 'West Europe'
    elif country in africa:
        return 'Africa'
    elif country in asia:
        return 'Asia'
    elif country in pacific:
        return 'Pacific'
    elif country in middle_east:
        return 'Middle East'
    else:
        return 'Other'
    


# function to check if the values in the new created columns match
def check_values(df):
    # create a new column, True if 'continent' is in 'continent_region'
    df['match'] = df.apply(lambda row: str(row['continent']) in str(row['continent_region']), axis=1)
    
    # check if there are rows where 'match' is False
    if df[df['match'] == False].shape[0] > 0:
        print("There are some rows where the values don't match.")
    else:
        print("All values match.")
    
    # delete the new created but unneeded column
    df.drop('match', axis=1, inplace=True)



# pivoting a DataFrame
def pivot_df(df, columns='indicator', index=['country', 'year'], values='value'):
    """
    Pivots the given DataFrame based on the specified columns, index, and values.

    Parameters:
    - df (pd.DataFrame): The input DataFrame to pivot.
    - columns (str): The column to use to make new frame’s columns.
    - index (list): List of column names to use to make new frame’s index.
    - values (str): The column to use for populating new frame’s values.

    Returns:
    - pd.DataFrame: The pivoted DataFrame with reset index and columns name set to None.
    """
    df_pivoted = pd.pivot(df,
                          columns=columns,
                          index=index,
                          values=values)
    df_pivoted.reset_index(inplace=True)
    df_pivoted.columns.name=None
    return df_pivoted


# change year column into date format
def year_to_int(df):
    df['year'] = pd.to_datetime(df['year'], format='%Y')
    df['year'] = df['year'].dt.year
    return df