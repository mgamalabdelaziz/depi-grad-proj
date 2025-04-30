select * from Line_productivity 
select * from Products 
select * from Downtime_factors
select * from Line_downtime_factor 
select * from Line_downtime_factor1


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


--------------------------------------------------------------------
---Q1) How many different products were produced? 

select count(distinct Product) as #Products
from Line_productivity

--------------------------------------------------------------------
---Q2) What is the total number of batches produced?

select count(Batch) as #Batchs
from Line_productivity

---------------------------------------------------------------------
---Q3) How many operators were involved in production? 

select count(distinct Operator) as #Operators
from Line_productivity

---------------------------------------------------------------------
---Q4) Which operators participated in the production process? 

select distinct Operator 
from Line_productivity

---------------------------------------------------------------------
---Q5) What is the total production duration for each operator? 

select lp.Operator , SUM(Duration_min) as Total_Duration_by_Operator
from Line_productivity lp
group by lp.Operator
order by SUM(Duration_min) desc

----------------------------------------------------------------------
---Q6) Which product has the highest average production time? 

select lp.Product , avg(Duration_min) as Average_Production_Duration
from Line_productivity lp
group by lp.Product
order by avg(Duration_min) desc

----------------------------------------------------------------------
---Q7) Which operator is the most efficient in handling batches?

select lp.Operator , sum(ld.Batch_downtime_by_factor) as Total_Downtime
from Line_productivity lp join Line_downtime_factor1 ld
on lp.Batch = ld.Batch
group by lp.Operator 
order by SUM(ld.Batch_downtime_by_factor) asc

----------------------------------------------------------------------
---Q8) What is the production duration for each product? 

select lp.Product , sum(Duration_min) as Total_Production_Duration
from Line_productivity lp
group by lp.Product
order by sum(Duration_min) desc

-----------------------------------------------------------------------
---Q9) What is the minimum batch duration for each product?

select Product , Min_batch_time as Min_Production_Time
from Products

------------------------------------------------------------------------
---Q10) What is the duration of each batch?

select lp.Batch , Duration_min 
from Line_productivity lp


------------------------------------------------------------------------
---Q11) Which Top 10 Batches with Most Batch Duration ?

select top 10 lp.Batch , lp.Duration_min
from Line_productivity lp
order by Duration_min desc

------------------------------------------------------------------------
---Q12) What are the most common downtime factors?

select df.Description  ,count( ld.Factor) as most_common_downtime_factor
from Line_downtime_factor1 ld join Downtime_factors df
on ld.Factor=df.Factor
group by df.Description
order by most_common_downtime_factor desc


--------------------------------------------------------------------
---Q13) How many factors influence downtime?

select count(Description) as Factors_Influence_Downtime
from Downtime_factors

-----------------------------------------------------------------------
---Q14) How many factors influence downtime, and what are they??

select Description
from Downtime_factors

------------------------------------------------------------------
---Q15) How much downtime is caused by operator errors vs. other causes in Minutes ?

select 'Total Downtime' as " " ,sum(Batch_change+Product_spill+Machine_adjustment+Batch_coding_error+
                                             Calibration_error+Label_switch) as Operator
from Line_downtime_factor

select 'Total Downtime' as " " ,sum(Emergency_stop+Labeling_error+Inventory_shortage+Machine_failure+
                                             Conveyo_belt_jam+Other) as Non_operator
from Line_downtime_factor

-----------------------------------------------------------------
---Q16) How much downtime is caused by operator errors vs. other causes in precentage ?

select 'Total Downtime' as " " ,sum(Batch_change+Product_spill+Machine_adjustment+Batch_coding_error+
                                             Calibration_error+Label_switch)*100 /sum(Batch_change+Product_spill+Machine_adjustment+Batch_coding_error+
                                             Calibration_error+Label_switch+Emergency_stop+Labeling_error+Inventory_shortage+Machine_failure+
                                             Conveyo_belt_jam+Other) as Percentage_of_Operator
from Line_downtime_factor

select 'Total Downtime' as " " ,sum(Emergency_stop+Labeling_error+Inventory_shortage+Machine_failure+
                                             Conveyo_belt_jam+Other)*100/sum(Emergency_stop+Labeling_error+Inventory_shortage+Machine_failure+
                                             Conveyo_belt_jam+Other+Batch_change+Product_spill+Machine_adjustment+Batch_coding_error+
                                             Calibration_error+Label_switch) as Percentage_of_Non_operator
from Line_downtime_factor


------------------------------------------------------------------
---Q17) What is the total downtime recorded? 

select sum(Batch_downtime_by_factor) as Total_Downtime
from Line_downtime_factor1

--------------------------------------------------------------------
---Q18) What is the total downtime for each day? 

select lp.Date , sum(ld.Batch_downtime_by_factor) as Total_Downtime
from Line_productivity lp left outer join Line_downtime_factor1 ld
on lp.Batch = ld.Batch
group by lp.Date
order by Total_Downtime desc

----------------------------------------------------------------------
---19) Which Product experienced the most downtime? 

select lp.Product, SUM(Emergency_stop+Batch_change
                       +Labeling_error+Inventory_shortage+Product_spill
					   +Machine_adjustment+Machine_failure+Batch_coding_error+Conveyo_belt_jam
					   +Calibration_error+Label_switch+Other) AS Total_Downtime_Duration
from Line_productivity lp JOIN Line_downtime_factor ldf 
on lp.Batch = ldf.Batch
group by lp.Product
order by Total_Downtime_Duration desc

---------------------------------------------------------------------
---Q20) Which Top 10 Batches with Most Downtime ?

select top 10 Batch , sum(Batch_downtime_by_factor) as Batch_downtime_by_factor
from Line_downtime_factor1
group by Batch
order by Batch_downtime_by_factor desc


------------------------------------------------------------------------
---Q21) Is there a relationship between batch size and downtime?

select lp.Product ,count(Batch) as Batch_count
from Line_productivity lp left join Products p 
on lp.Product=p.Product
group by lp.Product
order by count(Batch) desc 

select lp.Product, SUM(Emergency_stop+Batch_change
                       +Labeling_error+Inventory_shortage+Product_spill
					   +Machine_adjustment+Machine_failure+Batch_coding_error+Conveyo_belt_jam
					   +Calibration_error+Label_switch+Other) AS Total_Downtime_Duration
from Line_productivity lp JOIN Line_downtime_factor ldf 
on lp.Batch = ldf.Batch
group by lp.Product
order by Total_Downtime_Duration desc




