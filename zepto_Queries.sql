##################
# data exploration 
##################
-- count of rows
select count(*) from zepto; #Also checking whether we loaded the dataset properly or not.

-- sample data
select * from zepto limit 10; 

-- null values
select * from zepto where 
category is null or 
name is null or 
mrp is null or 
discountPercent is null or 
availableQuantity is null or 
discountedSellingPrice is null or 
weightInGms is null or 
outOfStock is null or 
quantity is null;

-- different product category
select distinct category from zepto order by category;

-- product in stock vs out of stock
select outOfStock, count(outOfStock) from zepto group by outOfStock; #'0' False '1' True i.e., 453 are out of stock and remaining are in.


############################
# Data Cleaning
############################
-- products having price=0
select * from zepto where mrp=0 or discountedSellingPrice=0;

delete from zepto where mrp=0; -- deleted the row that has mrp=0 #NOTE: safe update should be off

-- convert paise to rupee
update zepto set mrp=mrp/100.0, discountedSellingPrice=discountedSellingPrice/100.0; # mrp & discountedSellingPrice column had prices in paise
##############################################################################################################################################################
-- Q1. Find the top 10 best-value products based on the discount percentage.
select distinct name, mrp, discountPercent from zepto order by discountPercent desc limit 10;
-- Q2. What are the products with High MRP but out of stock?
select distinct name, mrp from zepto where outOfStock = 1 and mrp>300 order by mrp desc;
-- Q3. Calculate estimated revenue for each category.
select category, sum(discountedSellingPrice * availableQuantity) as Total_revenue from zepto group by category order by Total_revenue;
-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
select distinct name, mrp, discountPercent from zepto where mrp>500 and discountPercent<10 order by mrp desc, discountPercent desc;
-- Q5. Identify the top 5 categories offering the highest average discount percentage.
select category,round(avg(discountPercent),2) as Avg_discount from zepto group by category order by Avg_discount desc limit 5;
-- Q6. Find the price per gram for products above 100g and sort by best value.
select distinct name, weightInGms, discountedSellingPrice, round(discountedSellingPrice/weightInGms,2) as price_per_grm from zepto where weightInGms>=100 order by price_per_grm;
-- Q7.Group the products into categories like Low, Medium, Bulk.
select distinct name, weightInGms, 
case when weightInGms<1000 then 'Low'
	 when weightInGms<5000 then 'Medium'
     else 'Bulk'
end as weight_category
from zepto;
-- Q8.What is the Total Inventory Weight Per Category 
select category, sum(weightInGms*availableQuantity) as total_weight from zepto group by category order by total_weight;
##########################################################################################################################################################

###########################################################################
-- issues that we faced after loading the dataset & how we tackled them.
###########################################################################
alter table zepto change ï»¿Category category varchar(120); #changing the column heading(category) with datatype.

ALTER TABLE zepto #changing just the datatypes of the mentioned columns.
	modify column name varchar(150) not null,
	modify column mrp numeric(8,2),
	modify column discountPercent numeric(5,2),
	modify column availableQuantity integer,
	modify column discountedSellingPrice numeric(8,2),
	modify column weightInGms integer,
	modify column outOfStock boolean, #MySql doesn't have a "real" boolean type, to bypass that we did the below step of temporary bypass of SAFE mode.
	modify column quantity integer;

/* MySQL Workbench has a safety feature enabled that prevents UPDATE or DELETE commands that don't include a WHERE clause using a Primary Key. This is to stop you from accidentally wiping or changing an entire table. 
You can bypass this easily using either a temporary command or by changing your settings.*/
#(
SET SQL_SAFE_UPDATES = 0; #Temporary Session Bypass.

UPDATE zepto #the outOfStock column had TRUE & FALSE data, so we converted that into numeric to convert the column datatype into boolean, bcz MySql doesn't have a "real" boolean type. it used TINYINT(1)
SET outOfStock = CASE 
    WHEN outOfStock = 'TRUE' THEN 1 
    WHEN outOfStock = 'FALSE' THEN 0 
    ELSE NULL -- Handles unexpected values
END;

SET SQL_SAFE_UPDATES = 1; #Turn it back on after
#)
##########################################################################

describe zepto;