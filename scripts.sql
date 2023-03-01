--Create Athena Table
CREATE EXTERNAL TABLE homedetailsin
(
    home_id bigint,
    home_name string,
    value bigint,
    tour_date date,
    status string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'S3://homedetailsin/'
TBLPROPERTIES ( 'skip.header.line.count'='1' )