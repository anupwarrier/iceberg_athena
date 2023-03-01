# iceberg_athena

## Purpose

This repo includes examples to demonstrate how you can create an iceberg supported Athena table and interact with data in S3 via Athena ACID Transactions.

## Step -by step flow

1. Create S3 budkets to host the incoming data. 
For the demo, we will be creating 2 buckets, ie "homedetailsin" and "homedetailsall" buckets. The homedetailsin bucket will have transactional data thats coming from a database for example. The homedetailsall bucket will hold all the changes for the incoming data is accumulated. 

2. Create upload the sample csv file to homedetailsin bucket. 

3. Create a database in Glue Data Catalog. 

4. Create tables in Athena. 

```sql
--Create Athena Tables
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
```

```sql
--Create Athena Tables with Iceberg format
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
```

5. Run a SELECT query to retrive the data from S3 via Athena to ensure you can retrive the data

```sql
--query the data in S3 via Athena for homedetailsin
SELECT * FROM homedetailsin
```

6. Insert into homedetailsall table from homedetailsin to populate some data

```sql
--populate data to homedetailsall from homedetailsin
insert into homedetailsall
select * from homedetailsin
```

7. Run a SELECT query to retrive the data from S3 via Athena to ensure you can retrive the data

```sql
--query the data in S3 via Athena for homedetailsall
select * from homedetailsall
```

8. Explore the S3 bucket homedetailsall to see the partitions that were created and the file in parquet format 


9. Update the table homedetailsall

```sql
update homedetailsall
set value=100000 where home_id=1
```

--update the homedatsilsall table

```sql
update homedetailsall
set value=200000 where home_id=1
```

10. Time travel with snapshots 
Helps us see how data has changed over a period

```sql
SELECT * from "homedetailsall$history"
```

The result of the query shows how data has changed over a period of time using Snapshots(snapshot_id for ref)

If we query using a snapshot_id, we can see the data as of that snapshot_id

```sql
SELECT * FROM homedetailsall for version as of <snapshot_id here>
```

11. Update the csv file simulating changes from the upstream databases & upload the file to S3  homedetailsin bucket. 

12. Merge the data to reflect the new updates from homedetailsin under homedetailsall

```sql
--MERGE
MERGE INTO homedetailsall hda USING homedetailsin hdi
    ON (hda.home_id = hdi.home_id)
    WHEN MATCHED
        THEN UPDATE SET home_name = hdi.home_name, value = hdi.value, tour_date = hdi.tour_date, status = hdi.status
    WHEN NOT MATCHED
        THEN INSERT (home_id,home_name,value,tour_date,status)
                VALUES(hdi.home_id,hdi.home_name,hdi.value,hdi.tour_date,hdi.status)
```