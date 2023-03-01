# iceberg_athena

Purpose - 

This repo includes examples to demonstrate how you can create an iceberg supported Athena table and interact with data in S3 via Athena ACID Transactions.

Step -by step flow - 

1. Create S3 budkets to host the incoming data. 
For the demo, we will be creating 2 buckets, ie "homedetailsin" and "homedetailsall" buckets. The homedetailsin bucket will have transactional data thats coming from a database for example. The homedetailsall bucket will hold all the changes for the incoming data is accumulated. 




