import pandas as pd
import openpyxl
file_path = 'Manufacturing_Line_Productivity.xlsx'

sheets_dict = pd.read_excel(file_path, sheet_name=None)

print(sheets_dict.keys())

cleaned_sheets = {}

for sheet_name, df in sheets_dict.items():
    print(f'Cleaning {sheet_name}')

#Drop empty rows & columns
df.dropna(how='all', inplace=True)
df.dropna(axis=1, how='all', inplace=True)

#Fill missing values with 0
df.fillna(0, inplace=True)

#Remove duplicate rows
df.drop_duplicates(inplace=True)

#Store cleaned DataFrame
cleaned_sheets[sheet_name] = df

cleaned_file_path = 'cleaned_Manufacturing_Line_Productivity.xlsx'

#Save all cleaned sheets to a new excel file
with pd.ExcelWriter(cleaned_file_path, engine='openpyxl') as writer:
    for sheet_name, df in cleaned_sheets.items():
        df.to_excel(writer, sheet_name=sheet_name, index=False)

print('Data cleaning complete! Cleaned file saved as:', cleaned_file_path)

