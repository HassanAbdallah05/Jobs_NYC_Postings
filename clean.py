import csv
import oracledb
import sys
import re

# --- Enhanced Cleaning Function ---
def clean_text(value):
    if not value:
        return None
    # Remove BOM, quotes, and trim spaces
    value = value.replace('\ufeff', '').replace('"', '').strip()
    # Remove tabs and newlines
    value = value.replace('\t', ' ').replace('\n', ' ')
    # Replace multiple spaces with a single space
    value = re.sub(r'\s+', ' ', value)
    return value

def truncate(value, max_len):
    if value and len(value) > max_len:
        return value[:max_len]
    return value

try:
    conn = oracledb.connect(user="NYC", password="123", dsn="localhost:1521/XEPDB1")
    cur = conn.cursor()

    file_path = r"C:\Users\khale\OneDrive\Desktop\CS\470\project\Jobs_NYC_Postings.csv"

    with open(file_path, encoding="utf-8-sig") as f:
        reader = csv.reader(f)
        headers = next(reader)

        # Skip unwanted columns
        skip_cols = []
        for i, h in enumerate(headers):
            if h.strip().lower() in ["process date", "recruitment contact"]:
                skip_cols.append(i)

        for i, row in enumerate(reader, start=2):
            if not row or not row[0].strip():
                raise ValueError(f"Row {i}: Missing Job_ID")

            filtered_row = [clean_text(v) for j, v in enumerate(row) if j not in skip_cols]

            # Truncate oversized values
            if len(filtered_row) >= 25:
                filtered_row[24] = truncate(filtered_row[24], 250)   # WORK_LOCATION_1
            if len(filtered_row) >= 21:
                filtered_row[20] = truncate(filtered_row[20], 1800)  # ADDITIONAL_INFORMATION

            cur.execute("""
                INSERT INTO JOB_NYC_POSTING (
                    Job_ID, Agency_Name, Posting_Type, Num_Of_Positions,
                    Business_Title, Civil_Service_Title, Title_Classification,
                    Title_Code_No, "Level", Job_Category,
                    Full_Time_Part_Time_indicator, Career_Level,
                    Salary_Range_From, Salary_Range_To, Salary_Frequency,
                    Work_Location, Division_Work_Unit, Job_Description,
                    Minimum_Qual_Requirement, Preferred_Skill,
                    Additional_Information, To_Apply, Hour_Shift,
                    Work_Location_1, Residency_Requirement,
                    Posting_Date, Post_Until, Posting_Updated
                ) VALUES (
                    :1, :2, :3, :4, :5, :6, :7, :8, :9, :10,
                    :11, :12, :13, :14, :15, :16, :17, :18, :19, :20,
                    :21, :22, :23, :24, :25,
                    TO_DATE(:26,'MM/DD/YYYY'), TO_DATE(:27,'DD-MON-YY'), TO_DATE(:28,'MM/DD/YYYY')
                )
            """, filtered_row)

    conn.commit()
    print("✅ Data cleaned and imported successfully!")

except Exception as e:
    print(f"❌ Program stopped due to error:\n{e}")
    sys.exit(1)

finally:
    try:
        cur.close()
        conn.close()
    except:
        pass
