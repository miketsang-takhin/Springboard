/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS */
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(membercost) AS free_facilities
FROM Facilities
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0
AND membercost < monthlymaintenance*0.2;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	CASE
		WHEN monthlymaintenance < 100 THEN 'cheap'
		ELSE 'expensive' 
	END AS monthly_cost
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate IN (SELECT MAX(joindate) FROM Members);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/* Due to observed server behavior in PHPMyAdmin where standard string concatenation (||)
and (CONCAT()) do not produce expected results, two versions of the query are provided below.*/

/* Version 1: Using standard SQL concatenation (||), which is expected for SQLite.
This version aims to meet the 'formatted as a single column' requirement but may not display correctly on PHPMyAdmin. */
SELECT DISTINCT m.firstname || ' ' || m.surname AS member_name, f.name AS facility
FROM Members AS m
INNER JOIN Bookings AS b
ON m.memid = b.memid
INNER JOIN Facilities AS f
ON b.facid = f.facid
WHERE f.name = 'Tennis Court 1' OR f.name = 'Tennis Court 2'
ORDER BY member_name;

/* Version 2: Selecting first name and surname in separate columns as a workaround for concatenation issues.
This version ensures all data is displayed correctly on PHPMyAdmin, while acknowledging the formatting constraint. */
SELECT DISTINCT m.firstname, m.surname, f.name AS facility
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE f.name IN ('Tennis Court 1', 'Tennis Court 2')
ORDER BY m.surname, m.firstname;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

/* Due to observed server behavior in PHPMyAdmin where standard string concatenation (||)
and (CONCAT()) do not produce expected results, two versions of the query are provided below.*/

/* Version 1: Using standard SQL concatenation (||), which is expected for SQLite.
This version aims to meet the 'formatted as a single column' requirement but may not display correctly on PHPMyAdmin. */
SELECT 
  f.name AS facility,
  m.firstname || ' ' || m.surname AS member_name,
  b.slots * 
    CASE
      WHEN m.memid = 0 THEN f.guestcost
      ELSE f.membercost
    END AS total_cost
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE DATE(b.starttime) = '2012-09-14'
  AND b.slots *
      CASE
        WHEN m.memid = 0 THEN f.guestcost
        ELSE f.membercost
      END > 30
ORDER BY total_cost DESC;

/* Version 2: Selecting first name and surname in separate columns as a workaround for concatenation issues.
This version ensures all data is displayed correctly on PHPMyAdmin, while acknowledging the formatting constraint. */
SELECT 
  f.name AS facility,
  m.firstname, 
  m.surname,
  b.slots * 
    CASE
      WHEN m.memid = 0 THEN f.guestcost
      ELSE f.membercost
    END AS total_cost
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE DATE(b.starttime) = '2012-09-14'
  AND b.slots *
      CASE
        WHEN m.memid = 0 THEN f.guestcost
        ELSE f.membercost
      END > 30
ORDER BY total_cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

/* Due to observed server behavior in PHPMyAdmin where standard string concatenation (||)
and (CONCAT()) do not produce expected results, two versions of the query are provided below.*/

/* Version 1: Using standard SQL concatenation (||), which is expected for SQLite.
This version aims to meet the 'formatted as a single column' requirement but may not display correctly on PHPMyAdmin. */
SELECT 
  facility,
  firstname || ' ' || surname AS member_name,
  total_cost
FROM (
  SELECT 
    m.firstname AS firstname,
	m.surname AS surname,
    f.name AS facility,
    b.slots,
    b.starttime,
    CASE 
      WHEN m.memid = 0 THEN 'Guest'
      ELSE 'Member'
    END AS user_type,
    b.slots * 
    CASE
      WHEN m.memid = 0 THEN f.guestcost
      ELSE f.membercost
    END AS total_cost
  FROM Members AS m
  INNER JOIN Bookings AS b ON m.memid = b.memid
  INNER JOIN Facilities AS f ON b.facid = f.facid
) AS cost_data
WHERE DATE(starttime) = '2012-09-14'
  AND total_cost > 30
ORDER BY total_cost DESC;

/* Version 2: Selecting first name and surname in separate columns as a workaround for concatenation issues.
This version ensures all data is displayed correctly on PHPMyAdmin, while acknowledging the formatting constraint. */
SELECT 
  facility,
  firstname,
  surname,
  total_cost
FROM (
  SELECT 
    m.firstname AS firstname,
	m.surname AS surname,
    f.name AS facility,
    b.slots,
    b.starttime,
    CASE 
      WHEN m.memid = 0 THEN 'Guest'
      ELSE 'Member'
    END AS user_type,
    b.slots * 
    CASE
      WHEN m.memid = 0 THEN f.guestcost
      ELSE f.membercost
    END AS total_cost
  FROM Members AS m
  INNER JOIN Bookings AS b ON m.memid = b.memid
  INNER JOIN Facilities AS f ON b.facid = f.facid
) AS cost_data
WHERE DATE(starttime) = '2012-09-14'
  AND total_cost > 30
ORDER BY total_cost DESC;

/* PART 2: SQLite */
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output. */
 
/* QUESTIONS: */
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT 
f.name AS facility,
SUM(
b.slots * 
	CASE
    	WHEN m.memid = 0 THEN f.guestcost
    	ELSE f.membercost
	END 
)AS total_revenue
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
GROUP BY facility
HAVING total_revenue < 1000
ORDER BY total_revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT
m1.firstname || ' ' || m1.surname AS member_name,
m2.firstname || ' ' || m2.surname AS recommender_name
FROM Members AS m1
LEFT JOIN Members AS m2 
ON m1.recommendedby = m2.memid
ORDER BY m1.surname, m1.firstname;

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT
f.name AS facility,
SUM(B.slots) AS member_usage
FROM Members AS m
JOIN Bookings AS b ON m.memid = b.memid
JOIN Facilities AS f ON b.facid = f.facid
WHERE m.memid > 0
GROUP BY facility;

/* Q13: Find the facilities usage by month, but not guests */

SELECT
STRFTIME('%Y-%m', b.starttime) AS month,
f.name AS facility,
SUM(B.slots) AS monthly_usage
FROM Members AS m
JOIN Bookings AS b ON m.memid = b.memid
JOIN Facilities AS f ON b.facid = f.facid
WHERE m.memid > 0
GROUP BY month, facility;
