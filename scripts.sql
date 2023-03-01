--Create Athena Table for homedetailsin
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
LOCATION 's3://homedetailsin/'
TBLPROPERTIES ( 'skip.header.line.count'='1' )


--Create Athena Table for homedetailsall
CREATE TABLE homedetailsall
(
    home_id bigint,
    home_name string,
    value bigint,
    tour_date date,
    status string
)
PARTITIONED BY (day(tour_date))
LOCATION 's3://homedetailsall/'
TBLPROPERTIES ( 'table_type' = 'ICEBERG' )


--MERGE
--MERGE
MERGE INTO homedetailsall hda USING homedetailsin hdi
    ON (hda.home_id = hdi.home_id)
    WHEN MATCHED
        THEN UPDATE SET home_name = hdi.home_name, value = hdi.value, tour_date = hdi.tour_date, status = hdi.status
    WHEN NOT MATCHED
        THEN INSERT (home_id,home_name,value,tour_date,status)
                VALUES(hdi.home_id,hdi.home_name,hdi.value,hdi.tour_date,hdi.status)
