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


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name FROM Facilities WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*)
FROM Facilities 
WHERE membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT name, membercost, guestcost, monthlymaintenance
FROM Facilities 
WHERE membercost < monthlymaintenance *0.2 AND guestcost < monthlymaintenance*0.2

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * FROM Facilities
WHERE facid = 1 OR facid = 6

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name,monthlymaintenance, 
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
WHEN monthlymaintenance < 100 THEN 'cheap' END
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname, joindate
FROM `Members` 
WHERE LAST_DAY(joindate);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT bf.facid, m.surname, m.firstname, bf.name
FROM (

SELECT DISTINCT b.facid, b.memid, f.name
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
WHERE b.facid =0
OR b.facid =1
) AS bf
LEFT JOIN Members AS m ON bf.memid = m.memid
ORDER BY m.surname, m.firstname;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT b.facid, b.starttime, f.membercost, f.guestcost, f.name, m.surname, m.firstname
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
LEFT JOIN Members as m ON b.memid = m.memid 
WHERE b.starttime LIKE '2012-09-14%'
AND (f.membercost >=30 OR f.guestcost >=30)
ORDER BY f.gue

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT bf.facid, bf.memid, bf.starttime, bf.membercost, bf.guestcost, bf.name, m.surname, m.firstname
FROM (

SELECT b.facid, b.memid, b.starttime, f.membercost, f.guestcost, f.name
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%'
AND (
f.membercost >=30
OR f.guestcost >=30
)
) AS bf
LEFT JOIN Members AS m ON bf.memid = m.memid
ORDER BY bf.guestcost DESC;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT sub.name, SUM( sub.revenue ) AS revenue
FROM (
SELECT b.facid, b.memid, f.name, f.guestcost, f.membercost, COUNT( b.facid ) AS facid_count,
CASE
WHEN b.memid =0
THEN COUNT( b.facid ) * f.guestcost
ELSE COUNT( b.facid ) * f.membercost
END AS 'revenue'
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
GROUP BY b.facid, b.memid
) AS sub
GROUP BY sub.facid
HAVING revenue <=1000;
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m.surname, m.firstname, m.recommendedby AS recomender_id, r.surname AS recomender_surname, r.firstname AS recomender_firstname
FROM Members AS m
LEFT JOIN Members AS r ON m.recommendedby = r.memid
WHERE m.recommendedby != 0
ORDER BY r.surname, r.firstname;

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT b.facid, COUNT( b.memid ) AS mem_usage, f.name
FROM (
SELECT facid, memid
FROM Bookings
WHERE memid !=0
) AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
GROUP BY b.facid;
/* Q13: Find the facilities usage by month, but not guests */
SELECT b.months, COUNT( b.memid ) AS mem_usage
FROM (
SELECT MONTH( starttime ) AS months, memid
FROM Bookings
WHERE memid !=0
) AS b
GROUP BY b.months;
