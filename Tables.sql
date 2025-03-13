create database Manufacturing_Downtime 

create table Line_productivity 
       (Date date not null,
	   Product varchar(50) not null,
	   Batch int not null,
	   Operator varchar(50) not null,
	   Start_Time time not null,
	   End_Time time not null)

ALTER TABLE Line_productivity
ADD PRIMARY KEY (Batch)

create table Products
       (Product varchar(50) not null,
	    Flavor varchar(50) not null,
		Size varchar(50) not null,
		Min_batch_time int not null)

ALTER TABLE Products
ADD PRIMARY KEY (Product)

ALTER TABLE Line_productivity
ADD FOREIGN KEY (Product) REFERENCES Products(Product)

create table Downtime_factors
       (Factor int not null,
	    Description varchar(100) not null,
		Operator_Error varchar(50) not null)
		
create table Line_downtime_factor
       (Batch int not null,
	    one int,
		two int,
		three int,
		four int,
		five int,
		six int,
		seven int,
		eight int,
		nine int,
		ten int,
		eleven int,
		twelve int)

ALTER TABLE Line_downtime_factor
ADD FOREIGN KEY (Batch) REFERENCES Line_productivity(Batch)

USE Manufacturing_Downtime;
GO
BULK INSERT Line_productivity
FROM 'D:\Data Analyst\Project DEPI\SQL\Line productivity.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2            
);

BULK INSERT Products
FROM 'D:\Data Analyst\Project DEPI\SQL\Products.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2            
);

BULK INSERT Downtime_factors
FROM 'D:\Data Analyst\Project DEPI\SQL\Downtime factors.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2            
);

BULK INSERT Line_downtime_factor
FROM 'D:\Data Analyst\Project DEPI\SQL\Line downtime.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2            
);


select * from Line_productivity 
select * from Products 
select * from Downtime_factors
select * from Line_downtime_factor 


