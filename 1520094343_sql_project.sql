/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

use [Side Project]

select distinct name from [Side Project].[dbo].[Facilities]
where cast(membercost as float)<>0




/* Q2: How many facilities do not charge a fee to members? */

select count(distinct name) from [Side Project].[dbo].[Facilities]
where cast(membercost as float)=0 -- 4



/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */


select distinct facid, name as [facility name], membercost, monthlymaintenance
v
where cast(membercost as float)<>0 and cast(membercost as float)< cast(monthlymaintenance as float) * 0.2



/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

select *  FROM [Side Project].[dbo].[Facilities]
where facid=1 or facid=5



/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */


select name, monthlymaintenance,
case when cast(monthlymaintenance as float)>100 then 'Expensive' else 'Cheap' end as cheap_or_expensive
FROM [Side Project].[dbo].[Facilities]



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

select firstname, surname
from 	[Side Project].[dbo].[Members]
where cast(joindate as date) in 
(
select max(cast(joindate as date)) 
from 	[Side Project].[dbo].[Members]
)



/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select distinct facid, name as tennis_court_name
into #tennis_court_fac_id
from [Side Project].[dbo].[Facilities]
where name like '%tennis%court%'



select distinct x.firstname + ' ' + x.surname as fullname,
y.tennis_court_name
from [Side Project].[dbo].[Members] x
join (
select distinct a.memid , b.tennis_court_name
from [Side Project].[dbo].[Bookings] a 
join #tennis_court_fac_id b 
on a.facid=b.facid
) y
on x.memid=y.memid




/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */



select a.bookid, a.starttime, a.slots * (case when memid=0 then cast(b.guestcost as float) else cast(b.membercost as float) end ) as cost
from 	[Side Project].[dbo].Bookings a 
join  (select distinct facid, membercost, guestcost from [Side Project].[dbo].Facilities)  b 
on a.facid=b.facid
where cast(starttime as date)='2012-09-14'
and a.slots * (case when memid=0 then cast(b.guestcost as float) else cast(b.membercost as float) end )>30



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

select distinct bookid 
into #bookid_list
from (
select bookid, a.starttime, a.slots * (case when memid=0 then cast(b.guestcost as float) else cast(b.membercost as float) end ) as cost
from 	[Side Project].[dbo].Bookings a 
join  (select distinct facid, membercost, guestcost from [Side Project].[dbo].Facilities)  b 
on a.facid=b.facid
where cast(starttime as date)='2012-09-14'
and a.slots * (case when memid=0 then cast(b.guestcost as float) else cast(b.membercost as float) end )>30
) x 


select * from 
[Side Project].[dbo].Bookings
where bookid in (select bookid from  #bookid_list)



/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */



select a.memid, c.joindate, b.facid, name, 
a.slots * (case when a.memid=0 then cast(b.guestcost as float) else cast(b.membercost as float) end ) as cost,
b.initialoutlay, 
b.monthlymaintenance
into #data
from (
select memid, facid, sum(cast(slots as float)) as slots
from 	[Side Project].[dbo].Bookings 
group by memid, facid) a 
left join [Side Project].[dbo].Facilities b 
on a.facid = b.facid
left join [Side Project].[dbo].[Members] c 
on c.memid=a.memid


select name, sum(cost) as revenue
from #data
group by name 



 