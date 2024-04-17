-- SQL Assignment 4
-- Sebastian, Yoko, Jason, Allison
-- 04-13-2024

-- Step 1
-- A) Create a new Database ‘MajorAssignment2’.
CREATE DATABASE IF NOT EXISTS MajorAssignment2;

-- B) Download the ‘fakenames’ file from the ‘Databases’ folder in ‘Databases’ and create the 
-- ‘customers’ table in your new database.
SELECT *
FROM customers;

-- Step 2:
-- A) Change the column name (number) to (CUSID).
ALTER TABLE customers
RENAME COLUMN number TO CUSID;

-- B) Create a ‘Bonus’ table. You can find the column names and properties in the picture below. 
-- (CustomerID is the foreign key related to CUSID in the customer's table)
CREATE TABLE Bonus (
    ID INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    city VARCHAR(30),
    Bonus DECIMAL(10,2),
    CustomerID INT(11),
    FOREIGN KEY (CustomerID)
REFERENCES customers(CUSID)
);

INSERT INTO Bonus (city, CustomerID)
SELECT city, CUSID
FROM customers;

-- Step 3: 
-- A) Update two columns (bonus and city). Get cities from the ‘customers’ table and set bonus = 
-- 100 for all cities.
UPDATE Bonus
SET Bonus = 100,
    city = (
        SELECT city
        FROM customers
        WHERE customers.CUSID = Bonus.CustomerID
    );

-- B) Add 100 CAD to all customers living in Toronto, Red Deer, and Hamilton.
UPDATE Bonus
SET Bonus = Bonus + 100
WHERE CustomerID IN (
SELECT CUSID
FROM customers
        WHERE city IN('Toronto', 'Red Deer', 'Hamilton')
    );

-- C) Add an additional 23 percent to the bonuses of all customers who are living in the cities 
-- which have the ‘s’ or ‘t’ letters in their city names.
UPDATE Bonus
SET Bonus = Bonus * 1.23
WHERE CustomerID IN (
SELECT CUSID
FROM customers
        WHERE city REGEXP 's' OR city REGEXP 't'
    );

-- Step 4:
-- A) How many customers are living in ‘Barrie’? (Use ‘number of customers in Barrie' for the 
-- result’s title).
SELECT COUNT(*) AS 'number of customers in Barrie'
FROM customers
WHERE city = 'Barrie';

-- B) Add a 33% more bonus to these customers.
UPDATE Bonus
SET Bonus = Bonus * 1.33
WHERE CustomerID IN (
SELECT CUSID
        FROM customers
        WHERE city = 'Barrie'
    );

-- C) We want to see the names and bonuses and the customers who live in ‘Barrie’. (You can use
-- join or subquery) 
SELECT c.givenname, c.surname, B.Bonus
FROM customers AS c
INNER JOIN Bonus AS B ON c.CUSID = B.CustomerID
WHERE c.city = 'Barrie';

-- Step 5:
-- We need to increase the bonus amounts of the customers who get the minimum bonus amount.
-- Find the minimum amount by a query and add 50.5 to all of these customers. 
-- (Tip: write it in one query, you need to search the internet to learn how to do it. Maybe the 
-- below link might help you.)
-- https://stackoverflow.com/questions/45494/mysql-error-1093-cant-specify-target-table-for-
-- update-in-from-clause).
UPDATE Bonus AS B1
JOIN (
    SELECT MIN(Bonus) AS min_bonus
    FROM Bonus
) AS B2 ON B1.Bonus = B2.min_bonus
SET B1.Bonus = B1.Bonus + 50.5;

-- Step 6: 
-- A)- No bonuses for the cities starting with ‘F’. Is it possible to change them to null instead of zero?.
UPDATE Bonus
SET Bonus = NULL
WHERE city LIKE 'F%';

-- B) Calculate the average bonus of the cities not starting with E.
SELECT AVG(Bonus) AS average_bonus
FROM Bonus
WHERE city NOT LIKE 'E%';

-- Step 7:
-- Query all given names and street addresses of the customers who do not get any bonus. (Write 
-- the query with a join. Do not use sub-query).
SELECT c.givenname, c.streetaddress
FROM customers c
LEFT JOIN Bonus B ON c.CUSID = B.CustomerID
WHERE B.Bonus IS NULL;

-- Step 8 & 9: 
-- A) Add a ‘StreetNumber’ column in the customer table after the surname;
ALTER TABLE customers
ADD StreetNumber VARCHAR(10) AFTER surname;

-- B) Copy the Street number from the Street address and add it to the street number.
UPDATE customers
SET StreetNumber = SUBSTRING_INDEX(StreetAddress, ' ', 1);

-- C) delete the street number before the street address.
UPDATE customers
SET StreetAddress = TRIM(SUBSTRING(StreetAddress, LOCATE(' ', StreetAddress) + 1));

-- Step 10:
-- A) Show 2nd top bonuses.
SELECT Bonus
FROM Bonus
WHERE Bonus < (
    SELECT MAX(Bonus)
    FROM Bonus
)
ORDER BY Bonus DESC
LIMIT 1;

-- B) Show the total amount and average bonus in each city.
SELECT city, SUM(Bonus) AS total_amount, AVG(Bonus) AS average_bonus
FROM Bonus
GROUP BY city;

