update Line_downtime_factor 
 set            one=coalesce(one , 0 ),
                two=coalesce(two , 0 ),
				three=coalesce(three , 0 ),
				four=coalesce(four , 0 ),
				five=coalesce(five , 0 ),
				six=coalesce(six , 0 ),
				seven=coalesce(seven , 0 ),
				eight=coalesce(eight , 0 ),
				nine=coalesce(nine , 0 ),
				ten=coalesce(ten , 0 ),
				eleven=coalesce(eleven , 0 ),
				twelve=coalesce(twelve , 0 )

 
EXEC sp_rename 'Line_downtime_factor.one', 'Emergency_stop', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.two', 'Batch_change', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.three', 'Labeling_error', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.four', 'Inventory_shortage', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.five', 'Product_spill', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.six', 'Machine_adjustment', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.seven', 'Machine_failure', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.eight', 'Batch_coding_error', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.nine', 'Conveyo_belt_jam', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.ten', 'Calibration_error', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.eleven', 'Label_switch', 'COLUMN';
EXEC sp_rename 'Line_downtime_factor.twelve', 'Other', 'COLUMN';

select * from Line_downtime_factor   


ALTER TABLE Line_productivity
ADD Duration_min AS 
  DATEDIFF(MINUTE,CAST(CONVERT(VARCHAR, Date, 23) + ' ' + CONVERT(VARCHAR, Start_Time, 8) AS DATETIME2),
    CASE
      WHEN End_Time < Start_Time
        THEN CAST(CONVERT(VARCHAR, DATEADD(DAY, 1, Date), 23) + ' ' + CONVERT(VARCHAR, End_Time, 8) AS DATETIME2)
      ELSE CAST(CONVERT(VARCHAR, Date, 23) + ' ' + CONVERT(VARCHAR, End_Time, 8) AS DATETIME2)
    END)


select * from Line_productivity


---------------------------------------------
----count of batch for each product

select lp.Product ,count(Batch) as Batch_count
from Line_productivity lp left join Products p 
on lp.Product=p.Product
group by lp.Product

--------------------------------------------------------------------
---Total Duration by Operator

select lp.Operator , SUM(Duration_min) as Total_Duration_by_Operator
from Line_productivity lp
group by lp.Operator

select lp.Operator , avg(Duration_min) as Average_Duration_by_Operator
from Line_productivity lp
group by lp.Operator

--------------------------------------------------------------
---Total Production Duration for each product

select lp.Product , sum(Duration_min) as Total_Production_Duration
from Line_productivity lp
group by lp.Product

select lp.Product , avg(Duration_min) as Average_Production_Duration
from Line_productivity lp
group by lp.Product

-----------------------------------------------
---Total Downtime Duration for each product

select lp.Product, SUM(Emergency_stop+Batch_change
                       +Labeling_error+Inventory_shortage+Product_spill
					   +Machine_adjustment+Machine_failure+Batch_coding_error+Conveyo_belt_jam
					   +Calibration_error+Label_switch+Other) AS Total_Downtime_Duration
from Line_productivity lp JOIN Line_downtime_factor ldf 
on lp.Batch = ldf.Batch
group by lp.Product


-------------------------------------------------------
---total downtime duration for each factor

select 'Total Downtime Duration for each factor' as " " , sum(Emergency_stop)as Emergency_stop ,sum(Batch_change) as Batch_change ,sum(Labeling_error) as Labeling_error ,
        sum(Inventory_shortage) as Inventory_shortage ,sum(Product_spill) as Product_spill ,sum(Machine_adjustment) as Machine_adjustment ,
		sum(Machine_failure) as Machine_failure ,sum(Batch_coding_error) as Batch_coding_error ,sum(Conveyo_belt_jam) as Conveyo_belt_jam ,
		sum(Calibration_error) as Calibration_error ,sum(Label_switch) as Label_switch ,sum(Other) as Other
from Line_downtime_factor

SELECT 'Emergency_stop' AS Downtime_Factor, sum(Emergency_stop) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Batch_change' AS Downtime_Factor, sum(Batch_change) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Labeling_error' AS Downtime_Factor, sum(Labeling_error) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Inventory_shortage' AS Downtime_Factor, sum(Inventory_shortage) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Product_spill' AS Downtime_Factor, sum(Product_spill) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Machine_adjustment' AS Downtime_Factor, sum(Machine_adjustment) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Machine_failure' AS Downtime_Factor, sum(Machine_failure) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Batch_coding_error' AS Downtime_Factor, sum(Batch_coding_error) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Conveyo_belt_jam' AS Downtime_Factor, sum(Conveyo_belt_jam) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Calibration_error' AS Downtime_Factor, sum(Calibration_error) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Label_switch' AS Downtime_Factor, sum(Label_switch) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Other' AS Downtime_Factor, sum(Other) AS Total_Duration FROM Line_downtime_factor;

-----------------------------------------------------------
---Total Downtime for Operator and non-operator 
	select * from Line_downtime_factor

select 'Total Downtime Duration' as " " ,sum(Batch_change+Product_spill+Machine_adjustment+Batch_coding_error+
                                             Calibration_error+Label_switch) as Operator
from Line_downtime_factor

select 'Total Downtime Duration' as " " ,sum(Emergency_stop+Labeling_error+Inventory_shortage+Machine_failure+
                                             Conveyo_belt_jam+Other) as Non_operator
from Line_downtime_factor


---------------------------------------------------------------
---Downtime Duration for each operator and non-operator factor

select  'Total Downtime Duration' as "Operator factor" ,sum(Batch_change) as Batch_change ,sum(Product_spill) as Product_spill,
         sum(Machine_adjustment) as Machine_adjustment ,sum(Batch_coding_error) as Batch_coding_error, sum(Calibration_error) as Calibration_error ,
		 sum(Label_switch) as Label_switch 
from Line_downtime_factor

select  'Total Downtime Duration' as "Non operator factor" , sum(Emergency_stop)as Emergency_stop ,sum(Labeling_error) as Labeling_error,
         sum(Inventory_shortage) as Inventory_shortage ,sum(Machine_failure) as Machine_failure, sum(Conveyo_belt_jam) as Conveyo_belt_jam,
		 sum(Other) as Other
from Line_downtime_factor

SELECT 'Operator factor' AS Factor_Category, 'Batch_change' AS Downtime_Factor, sum(Batch_change) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Operator factor' AS Factor_Category, 'Product_spill' AS Downtime_Factor, sum(Product_spill) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Operator factor' AS Factor_Category, 'Machine_adjustment' AS Downtime_Factor, sum(Machine_adjustment) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Operator factor' AS Factor_Category, 'Batch_coding_error' AS Downtime_Factor, sum(Batch_coding_error) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Operator factor' AS Factor_Category, 'Calibration_error' AS Downtime_Factor, sum(Calibration_error) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Operator factor' AS Factor_Category, 'Label_switch' AS Downtime_Factor, sum(Label_switch) AS Total_Duration FROM Line_downtime_factor

SELECT 'Non operator factor' AS Factor_Category, 'Emergency_stop' AS Downtime_Factor, sum(Emergency_stop) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Non operator factor' AS Factor_Category, 'Labeling_error' AS Downtime_Factor, sum(Labeling_error) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Non operator factor' AS Factor_Category, 'Inventory_shortage' AS Downtime_Factor, sum(Inventory_shortage) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Non operator factor' AS Factor_Category, 'Machine_failure' AS Downtime_Factor, sum(Machine_failure) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Non operator factor' AS Factor_Category, 'Conveyo_belt_jam' AS Downtime_Factor, sum(Conveyo_belt_jam) AS Total_Duration FROM Line_downtime_factor
UNION ALL
SELECT 'Non operator factor' AS Factor_Category, 'Other' AS Downtime_Factor, sum(Other) AS Total_Duration FROM Line_downtime_factor;



-------------------------------------------------------------------
---Downtime factor per operator 
    select * from Line_productivity
	select * from Line_downtime_factor

select lp.Operator , sum(Batch_change) as Batch_change ,sum(Product_spill) as Product_spill,
                     sum(Machine_adjustment) as Machine_adjustment ,sum(Batch_coding_error) as Batch_coding_error, sum(Calibration_error) as Calibration_error ,
		             sum(Label_switch) as Label_switch 
from Line_productivity lp full outer join Line_downtime_factor ldf
on lp.Batch=ldf.Batch
group by lp.Operator

select lp.Operator, SUM(Batch_change+Product_spill+Machine_adjustment+Batch_coding_error
					   +Calibration_error+Label_switch) AS Total_Downtime_Duration
from Line_productivity lp JOIN Line_downtime_factor ldf 
on lp.Batch = ldf.Batch
group by lp.Operator

-----------------------------------------------------------------------




