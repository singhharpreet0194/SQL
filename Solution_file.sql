use orders

/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

show tables
select * from online_customer

SELECT CUSTOMER_ID,
  CASE 
    WHEN CUSTOMER_GENDER = 'M' THEN CONCAT('Mr ', upper(CUSTOMER_FNAME), ' ', upper(CUSTOMER_LNAME))
    WHEN CUSTOMER_GENDER = 'F' THEN CONCAT('Ms ', upper(CUSTOMER_FNAME), ' ', upper(CUSTOMER_LNAME))
  END AS full_name,
  CUSTOMER_EMAIL,
  Year(CUSTOMER_CREATION_DATE) as CUSTOMER_CREATION_YEAR,
  CASE 
    WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A'
    WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
    WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN 'Category C'
  END AS customer_category
FROM online_customer;

/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/

select * from PRODUCT

SELECT 
  p.product_id, 
  p.product_desc, 
  p.product_quantity_avail, 
  p.product_price, 
  (p.product_quantity_avail * p.product_price) AS inventory_value, 
  CASE 
    WHEN p.product_price > 20000 THEN p.product_price * 0.8
    WHEN p.product_price > 10000 THEN p.product_price * 0.85
    ELSE p.product_price * 0.9
  END AS new_price
FROM 
  PRODUCT p
WHERE 
  p.product_id NOT IN (SELECT product_id FROM ORDER_ITEMS)
ORDER BY 
  inventory_value DESC;
  
  
  
  
 /*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

 
  SELECT 
  pc.product_class_code, 
  pc.product_class_desc, 
  COUNT(DISTINCT p.product_id) AS product_type_count, 
  SUM(p.product_quantity_avail * p.product_price) AS inventory_value
FROM 
  PRODUCT p 
  JOIN PRODUCT_CLASS pc ON p.product_class_code = pc.product_class_code
GROUP BY 
  pc.product_class_code, 
  pc.product_class_desc
HAVING 
  SUM(p.product_quantity_avail * p.product_price) > 100000
ORDER BY 
  inventory_value DESC;
  
/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER (CUSTOMER_ID, CUSTOMER_FNAME, CUSTOMER_LNAME, CUSTOMER_EMAIL, 
CUSTOMER_PHONE, ADDRESS_ID, CUSTOMER_CREATION_DATE, CUSTOMER_USERNAME, CUSTOMER_GENDER),
 ADDRESSS (ADDRESS_ID, ADDRESS_LINE1, ADDRESS_LINE2, 
CITY, STATE, PINCODE, COUNTRY),
 OREDER_HEADER(ORDER_ID, CUSTOMER_ID, ORDER_DATE, ORDER_STATUS, PAYMENT_MODE, PAYMENT_DATE, ORDER_SHIPMENT_DATE, SHIPPER_ID)]
Hint: USE SUBQUERY
*/
show tables
select * from order_header

SELECT 
  oc.customer_id, 
  CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS full_name, 
  oc.customer_email, 
  oc.customer_phone, 
  a.country
FROM 
  ONLINE_CUSTOMER oc 
  JOIN ADDRESS a ON oc.address_id = a.address_id
WHERE 
  oc.customer_id IN (
    SELECT 
      oh.customer_id 
    FROM 
      ORDER_HEADER oh 
    WHERE 
      oh.order_status = 'CANCELLED' 
    GROUP BY 
      oh.customer_id 
    HAVING 
      COUNT(DISTINCT oh.order_id) = (
        SELECT 
          COUNT(*) 
        FROM 
          ORDER_HEADER 
        WHERE 
          customer_id = oh.customer_id
      )
  );

/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER (SHIPPER_ID, SHIPPER_NAME, SHIPPER_PHONE, SHIPPER_ADDRESS), ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */
select* from shipper

SELECT SHIPPER.SHIPPER_NAME, ADDRESS.CITY, COUNT(DISTINCT ONLINE_CUSTOMER.CUSTOMER_ID) AS NUM_CUSTOMERS, 
COUNT(DISTINCT ORDER_HEADER.ORDER_ID) AS NUM_CONSIGNMENTS
FROM SHIPPER
JOIN ORDER_HEADER ON SHIPPER.SHIPPER_ID = ORDER_HEADER.SHIPPER_ID
JOIN ONLINE_CUSTOMER ON ORDER_HEADER.CUSTOMER_ID = ONLINE_CUSTOMER.CUSTOMER_ID
JOIN ADDRESS ON ONLINE_CUSTOMER.ADDRESS_ID = ADDRESS.ADDRESS_ID
WHERE SHIPPER.SHIPPER_NAME = 'DHL'
GROUP BY SHIPPER.SHIPPER_NAME, ADDRESS.CITY

/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT (PRODUCT_ID, PRODUCT_DESC, PRODUCT_CLASS_CODE, PRODUCT_PRICE, 
PRODUCT_QUANTITY_AVAIL, LEN, WIDTH, HEIGHT, WEIGHT), PRODUCT_CLASS (PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESC), ORDER_ITEMS(ORDER_ID, PRODUCT_ID,
 PRODUCT_QUANTITY)]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

select*from ORDER_ITEMS

SELECT p.product_id, p.product_desc, p.product_quantity_avail, SUM(oi.product_quantity) AS quantity_sold,
CASE
    WHEN pc.product_class_desc IN ('Electronics', 'Computers') THEN
        CASE
            WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
            WHEN p.product_quantity_avail < (0.1 * SUM(oi.product_quantity)) THEN 'Low inventory, need to add inventory'
            WHEN p.product_quantity_avail < (0.5 * SUM(oi.product_quantity)) THEN 'Medium inventory, need to add some inventory'
            ELSE 'Sufficient inventory'
        END
    WHEN pc.product_class_desc IN ('Mobiles', 'Watches') THEN
        CASE
            WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
            WHEN p.product_quantity_avail < (0.2 * SUM(oi.product_quantity)) THEN 'Low inventory, need to add inventory'
            WHEN p.product_quantity_avail < (0.6 * SUM(oi.product_quantity)) THEN 'Medium inventory, need to add some inventory'
            ELSE 'Sufficient inventory'
        END
    ELSE
        CASE
            WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
            WHEN p.product_quantity_avail < (0.3 * SUM(oi.product_quantity)) THEN 'Low inventory, need to add inventory'
            WHEN p.product_quantity_avail < (0.7 * SUM(oi.product_quantity)) THEN 'Medium inventory, need to add some inventory'
            ELSE 'Sufficient inventory'
        END
END AS inventory_status
FROM product p
JOIN product_class pc ON p.product_class_code = pc.product_class_code
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_desc, p.product_quantity_avail, pc.product_class_desc
ORDER BY p.product_id;


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON (CARTON_ID, LEN, WIDTH, HEIGHT), ORDER_ITEMS (ORDER_ID, PRODUCT_ID, PRODUCT_QUANTITY), 
PRODUCT(PRODUCT_ID, PRODUCT_DESC, PRODUCT_CLASS_CODE, PRODUCT_PRICE, PRODUCT_QUANTITY_AVAIL, LEN, WIDTH, HEIGHT, WEIGHT)]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */
 SELECT oi.order_id, 
	SUM(oi.product_quantity * p.len * p.width * p.height) AS volume
	FROM order_items oi
	JOIN product p USING(product_id)
	GROUP BY oi.order_id
	HAVING volume < (SELECT c.len * c.width * c.height FROM carton c WHERE c.carton_id = 10)
	ORDER BY volume DESC
    LIMIT 1;
 /*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ER_ITEMS (ORDER_ID, PRODUCT_ID, PRODUCT_QUANTITY), PRODUCT(PRODUCT_ID, PRODUCT_DESC, PRODUCT_CLASS_CODE, PRODUCT_PRICE, PRODUCT_QUANTITY_AVAIL,
 LEN, WIDTH, HEIGHT, WEIGHT), ORDER_HEADER(ORDER_ID, CUSTOMER_ID, ORDER_DATE, ORDERONLINE_CUSTOMER (CUSTOMER_ID, CUSTOMER_FNAME, CUSTOMER_LNAME, CUSTOMER_EMAIL, CUSTOMER_PHONE, ADDRESS_ID, 
CUSTOMER_CREATION_DATE, CUSTOMER_USERNAME, CUSTOMER_GENDER), ORD_STATUS,
 PAYMENT_MODE, PAYMENT_DATE, ORDER_SHIPMENT_DATE, SHIPPER_ID)]*/

select* from ORDER_HEADER
 
SELECT 
    oc.customer_id,
    CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS customer_full_name,
    SUM(oi.product_quantity) AS total_quantity,
    SUM(oi.product_quantity * p.product_price) AS total_value
FROM 
    online_customer oc
    JOIN order_header oh ON oc.customer_id = oh.customer_id
    JOIN order_items oi ON oh.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
WHERE 
    oh.payment_mode = 'Cash'
    AND oc.customer_lname LIKE 'G%'
GROUP BY 
    oc.customer_id

/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS (ORDER_ID, PRODUCT_ID, PRODUCT_QUANTITY), PRODUCT(PRODUCT_ID, PRODUCT_DESC, PRODUCT_CLASS_CODE, PRODUCT_PRICE, PRODUCT_QUANTITY_AVAIL,
 LEN, WIDTH, HEIGHT, WEIGHT), ORDER_HEADER (ORDER_ID, CUSTOMER_ID, ORDER_DATE, ORDER_STATUS, 
 PAYMENT_MODE, PAYMENT_DATE, ORDER_SHIPMENT_DATE, SHIPPER_ID), ONLINE_CUSTOMER (CUSTOMER_ID, CUSTOMER_FNAME, CUSTOMER_LNAME, CUSTOMER_EMAIL, CUSTOMER_PHONE, ADDRESS_ID, 
 CUSTOMER_CREATION_DATE, CUSTOMER_USERNAME, CUSTOMER_GENDER), ADDRESS (ADDRESS_ID, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, PINCODE, COUNTRY)]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */
 
SELECT p.PRODUCT_ID, p.PRODUCT_DESC, SUM(oi.PRODUCT_QUANTITY) AS total_quantity
FROM ORDER_ITEMS oi
JOIN PRODUCT p ON oi.PRODUCT_ID = p.PRODUCT_ID
JOIN ORDER_HEADER oh ON oi.ORDER_ID = oh.ORDER_ID
JOIN ONLINE_CUSTOMER oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE oi.ORDER_ID IN (
  SELECT oi2.ORDER_ID
  FROM ORDER_ITEMS oi2
  WHERE oi2.PRODUCT_ID = 201
)
AND a.CITY NOT IN ('Bangalore', 'New Delhi')
GROUP BY p.PRODUCT_ID, p.PRODUCT_DESC
ORDER BY total_quantity DESC;


/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	

ORDER_ITEMS (ORDER_ID, PRODUCT_ID, PRODUCT_QUANTITY), ORDER_HEADER (ORDER_ID, CUSTOMER_ID, ORDER_DATE, ORDER_STATUS, 
 PAYMENT_MODE, PAYMENT_DATE, ORDER_SHIPMENT_DATE, SHIPPER_ID), ONLINE_CUSTOMER (CUSTOMER_ID, CUSTOMER_FNAME, CUSTOMER_LNAME, CUSTOMER_EMAIL, CUSTOMER_PHONE, ADDRESS_ID, 
 CUSTOMER_CREATION_DATE, CUSTOMER_USERNAME, CUSTOMER_GENDER), ADDRESS (ADDRESS_ID, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, PINCODE, COUNTRY)
 */
SELECT  oi.order_id, 
	oh.customer_id,
	CONCAT(oc.customer_fname,' ',oc.customer_lname) AS customer_full_name,
	SUM(oi.product_quantity) AS total_quantity_of_products, 
	a.pincode 
	FROM order_items oi
	INNER JOIN order_header oh USING(order_id)
	INNER JOIN online_customer oc USING(customer_id)
	INNER JOIN address a USING(address_id)
	WHERE oh.order_status = 'Shipped' AND a.pincode NOT LIKE "5%" AND oi.order_id %2 = 0
	GROUP BY oh.customer_id, oi.order_id
	ORDER BY oi.order_id;

