CREATE USER NYC IDENTIFIED BY 123; 

GRANT CONNECT TO NYC; 
GRANT RESOURCE TO NYC; 
GRANT UNLIMITED TABLESPACE TO NYC;

CONNECT NYC/123;

CREATE TABLE NYC.Job_NYC_Posting (
  Job_ID NUMBER(6) NOT NULL,
  Agency_Name VARCHAR2(50) NOT NULL,
  Posting_Type VARCHAR2(8) NOT NULL,
  Num_Of_Positions NUMBER(3) NOT NULL,
  Business_Title VARCHAR2(250) NOT NULL,
  Civil_Service_Title VARCHAR2(50) NOT NULL,
  Title_Classification VARCHAR2(50) NOT NULL,
  Title_Code_No VARCHAR2(5) NOT NULL,
  "Level" VARCHAR2(3) NOT NULL,
  Job_Category VARCHAR2(250) NOT NULL,
  Full_Time_Part_Time_indicator CHAR(1) DEFAULT 'F' NOT NULL,
  Career_Level VARCHAR2(50) NOT NULL,
  Salary_Range_From NUMBER(10,2),
  Salary_Range_To NUMBER(10,2),
  Salary_Frequency VARCHAR2(6) NOT NULL,
  Work_Location VARCHAR2(150) NOT NULL,
  Division_Work_Unit VARCHAR2(150) NOT NULL,
  Job_Description CLOB,
  Minimum_Qual_Requirement CLOB,
  Preferred_Skill CLOB,
  Additional_Information VARCHAR2(2200),
  To_Apply VARCHAR2(3000),
  Hour_Shift VARCHAR2(300),
  Work_Location_1 VARCHAR2(400),
  Residency_Requirement CLOB,
  Posting_Date DATE NOT NULL,
  Post_Until DATE,
  Posting_Updated DATE NOT NULL
);

CREATE TABLE NYC.Job_Position (
    Job_ID NUMBER(6),
    To_Apply VARCHAR2(3000),
    Preferred_Skill CLOB,
    Career_Level VARCHAR2(50) NOT NULL,
    Hour_Shift VARCHAR2(300),
    Job_Description CLOB,
    Minimum_Qual_Requirement CLOB,
    Residency_Requirement CLOB,
    Full_Time_Part_Time_indicator CHAR(1) DEFAULT 'F' NOT NULL,
    Work_Location_1 VARCHAR2(400),
    Job_Category VARCHAR2(250) NOT NULL,
    Business_Title VARCHAR2(250) NOT NULL,
    Civil_Service_Title VARCHAR2(50) NOT NULL,
    Title_Classification VARCHAR2(50) NOT NULL,
    Title_Code_No VARCHAR2(5) NOT NULL,
    "Level" VARCHAR2(3) NOT NULL,
    Salary_Range_From NUMBER(10,2),
    Salary_Range_To NUMBER(10,2),
    Salary_Frequency VARCHAR2(6) NOT NULL,
    
    CONSTRAINT job_postion_PK PRIMARY KEY (Job_ID)
);

INSERT INTO NYC.Job_Position (
  Job_ID,
  To_Apply,
  Preferred_Skill,
  Career_Level,
  Hour_Shift,
  Job_Description,
  Minimum_Qual_Requirement,
  Residency_Requirement,
  Full_Time_Part_Time_indicator,
  Work_Location_1,
  Job_Category,
  Business_Title,
  Civil_Service_Title,
  Title_Classification,
  Title_Code_No,
  "Level",
  Salary_Range_From,
  Salary_Range_To,
  Salary_Frequency
)
SELECT 
  j.Job_ID,
  j.To_Apply,
  j.Preferred_Skill,
  j.Career_Level,
  j.Hour_Shift,
  j.Job_Description,
  j.Minimum_Qual_Requirement,
  j.Residency_Requirement,
  j.Full_Time_Part_Time_indicator,
  j.Work_Location_1,
  j.Job_Category,
  j.Business_Title,
  j.Civil_Service_Title,
  j.Title_Classification,
  j.Title_Code_No,
  j."Level",
  j.Salary_Range_From,
  j.Salary_Range_To,
  j.Salary_Frequency
FROM (
  SELECT 
    Job_ID,
    To_Apply,
    Preferred_Skill,
    Career_Level,
    Hour_Shift,
    Job_Description,
    Minimum_Qual_Requirement,
    Residency_Requirement,
    Full_Time_Part_Time_indicator,
    Work_Location_1,
    Job_Category,
    Business_Title,
    Civil_Service_Title,
    Title_Classification,
    Title_Code_No,
    "Level",
    Salary_Range_From,
    Salary_Range_To,
    Salary_Frequency,
    ROW_NUMBER() OVER (PARTITION BY Job_ID ORDER BY CASE WHEN Posting_Type = 'EXTERNAL' THEN 1 ELSE 2 END) AS rn
  FROM NYC.Job_NYC_Posting
) j
WHERE j.rn = 1;

CREATE TABLE NYC.Agency(
    Agency_Name VARCHAR2(50),
    Division_Work_Unit VARCHAR2(150) NOT NULL,
    Work_Location VARCHAR2(150) NOT NULL,
    Additional_Information VARCHAR2(2200),
    
    CONSTRAINT agencey_PK PRIMARY KEY (Agency_Name)
);
    
INSERT INTO NYC.Agency (
    Agency_Name,
    Division_Work_Unit,
    Work_Location,
    Additional_Information
)
SELECT Agency_Name,
       MIN(Division_Work_Unit),
       MIN(Work_Location),
       MIN(Additional_Information)
FROM NYC.Job_NYC_Posting
GROUP BY Agency_Name;


CREATE TABLE NYC.Post (
    j_id NUMBER(6),
    a_name VARCHAR2(50),
    Posting_Type VARCHAR2(8),
    Posting_Date DATE NOT NULL,
    Post_Until DATE,
    Posting_Updated DATE NOT NULL,
    Num_Of_Positions NUMBER(3) NOT NULL,
    
    CONSTRAINT post_PK PRIMARY KEY (j_id, a_name, Posting_Type),
    
    CONSTRAINT post_j_id_FK FOREIGN KEY (j_id)
        REFERENCES NYC.Job_Position(Job_ID),
    
    CONSTRAINT post_a_name_FK FOREIGN KEY (a_name)
        REFERENCES NYC.Agency(Agency_Name)
);

INSERT INTO NYC.Post (
    j_id,
    a_name,
    Posting_Type,
    Posting_Date,
    Post_Until,
    Posting_Updated,
    Num_Of_Positions
)
SELECT DISTINCT
    Job_ID,
    Agency_Name,
    Posting_Type,
    Posting_Date,
    Post_Until,
    Posting_Updated,
    Num_Of_Positions
FROM NYC.Job_NYC_Posting;