import csv
import datetime
import json
import os
import subprocess


def main():
    # Set the CSV file path (adjust as necessary)
    all_csv_files = []
    # iterate through all csv files in the csv/ directory
    for file in os.listdir('csv/'):
        if file.endswith('.csv'):
            all_csv_files.append(file)
    csv_file_path = '~/Downloads/Shared-Expenses-1MAR2025-to-28MAY2025.csv'  # Replace with your CSV filename if different

    # use 'utf-7' encoding if "+AC0" shows up in the amount field, otherwise UTF-8
    with open(csv_file_path, newline='', encoding='utf-7') as csvfile:
        # Using a tab as the delimiter since your CSV file uses tabs.
        reader = csv.DictReader(csvfile, delimiter=',')

        for row in reader:
            # Skip the row if the Category is blank (empty or just whitespace)
            if not row['Category'].strip():
                continue

            try:
                amount = float(row['Amount'])
            except ValueError:
                # Skip the row if Amount cannot be converted to a float.
                continue

            # Skip rows with a positive amount
            if amount >= 0:
                continue

            dt = datetime.datetime.strptime(row['Date'], '%d/%m/%y')
            dt = dt.replace(hour=0, minute=0, second=0)
            dt = dt.strftime('%Y-%m-%dT%H:%M:%SZ')
            # Build the JSON payload.
            data = {
                "name": row['Payee'] + row['Particulars'] + row['Code'] + row['Reference'],
                "category": row['Category'],
                "amount": abs(amount),
                "date": str(dt)
            }
            json_data = json.dumps(data)

            # Build the curl command.
            command = [
                "curl",
                "-X", "PUT",
                "http://192.168.1.2:5006/expense",
                "-H", "Content-Type: application/json",
                "-d", json_data
            ]

            # (Optional) Print the command for debugging.
            print(json_data)

            # Execute the curl command.
            result = subprocess.run(command, capture_output=True, text=True)
            print("Response:", result.stdout)


if __name__ == '__main__':
    main()