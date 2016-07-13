---
published_on: 2013-01-23
title: MySQL and time zones
excerpt: |
  It turns out that MySQL has support for time zones, but doesn't have the
  necessary information to support named time zones out of the box. Once we
  have that sorted, there are some new and exciting ways we can query local
  times while storing them as UTC in MySQL.

category: Software development
tags:
  - ruby
  - rails
  - mysql
  - timezones
  - utc
  - activerecord
  - timestamp
  - datetime
  - conversion
---
It turns out that MySQL has support for time zones, but doesn't have the
necessary information to support named time zones out of the box. The
instructions on getting time zone support are described in [MySQL Server Time
Zone Support](http://dev.mysql.com/doc/refman/5.5/en/time-zone-support.html)
section of the manual, but the short version is to run this script and then
pass the results into MySQL to create the appropriate tables in the `mysql` db:

```bash
mysql_tzinfo_to_sql /usr/share/zoneinfo |mysql -u root mysql
```

This resets the contents of the `time_zone`, `time_zone_name`,
`time_zone_transition` and `time_zone_transition_type` tables in the system
`mysql` database. It constructs the tables from your operating system's time
zone information database, so if that ever changes, it would be prudent to
re-run this script. (Note to self: I need a puppet manifest for updating it
when the `tzdata` package is updated...!)

Having done this, I now get access to the symbolic names for time zones. Which
is useful for using `CONVERT_TZ`:

```sql
SELECT CONVERT_TZ('2012-06-01 12:00:00', 'America/Los_Angeles', 'Europe/London');
```

which will give us back 8pm London time. Better still, the time zones are then
DST aware. So, I can now do:

```sql
SELECT CONVERT_TZ('2012-06-01 12:00:00', 'Etc/UTC', 'Europe/London');
```

and get back 1pm local time.

There are a couple of situations where this can be useful. From here on, I'm
assuming that you use `DATETIME` columns and that you normalise all these
`DATETIME` columns to UTC because I use Rails and that's what Rails
ActiveRecord does. See the last paragraph where I discover `TIMESTAMP` and
wonder if this is a sensible pattern in the first place.

The first situation is where you're taking inputs in local time (local time in
this example is `Europe/London`, which only gets interesting when DST is in
effect in the summer). If you do:

```sql
SELECT * FROM readings
  WHERE started_at = '2012-06-01 12:00:00';
```

then you are implicitly assuming that the argument your passing is already in
UTC. What if it's in the user's local time? Well:

```sql
SELECT * FROM readings
  WHERE started_at = CONVERT_TZ('2012-06-01 12:00:00', 'Europe/London', 'Etc/UTC');
```

which will convert the time to UTC before performing the query. I think that
since we're converting the input value and leaving the (indexed) column alone
in the `WHERE` clause, this isn't going to have any pejorative impact on index
use. Of course, if ActiveRecord is your hammer, you're already used to the
process of converting to UTC time for SQL queries.

The second situation is in converting the results back to local time. If you
do:

```sql
SELECT started_at FROM readings;
```

then you're going to get back the readings in UTC. However, if you do:

```sql
SELECT CONVERT_TZ(started_at, 'Etc/UTC', 'Europe/London') AS local_started_at
  FROM readings;
```

then you get the time back as a local time. If ActiveRecord is your thing, this
is all handled inside it, so you don't need to worry about it at the DB level.

The third situation is a little more interesting. Say you're doing date based
aggregation in SQL (grouping by `YEARWEEK` or `WEEKDAY` for example). If you do
something along the lines of:

```sql
SELECT YEARWEEK(started_at) AS year_week_started_at, SUM(value) AS value
  FROM readings
  GROUP BY YEARWEEK(started_at);
```

then your results will be subtly wrong because you're grouping into weeks based
on the UTC time. In the case of BST, the hour at the start and end of the week
is being allocated to the wrong week… So, instead we convert:

```sql
SELECT YEARWEEK(CONVERT_TZ(started_at, 'Etc/UTC', 'Europe/London')) AS year_week_started_at, SUM(value) AS value
  FROM readings
  GROUP BY YEARWEEK(CONVERT_TZ(started_at, 'Etc/UTC', 'Europe/London'));
```

Now we're correctly grouping by local time.

From an application perspective, I would imagine setting up these queries to
pass in the "local" time zone based on the user's time zone setting -- perhaps
grabbed from the user's model, or the session.

Of course, MySQL has a built in type called `TIMESTAMP` which does most of this
work for us. It stores timestamps internally as UTC, but converts them on the
fly into the session `time_zone` setting. I'm not sure if that safely covers
the grouping behaviour in the third example. Sadly, being an ActiveRecord
weenie, I think I'm stuck with the convention of using `DATETIME` columns and
the UTC/local time conversion happening inside ActiveRecord. Which means that
when I need to dig down for performant SQL queries with times, I need to be
aware of time zone issues.

Things I still need to figure out (help?):

* Whether somebody has already tweaked ActiveRecord to make use of time zone
  aware `TIMESTAMP` columns natively instead of `DATETIME` columns with
  internal conversion. Or, if not, how hard it would be to implement. I'd
  imagine having something that wraps the request and sets the time zone on the
  AR session(s) to the user's preferred time zone, then carries on its queries
  as usual, but gets back a timestamp which includes the time zone information
  and creates a `TimeWithZone` instance from that...?

* If there is any pejorative impact on index use with any of the changes to
  these queries. Or any other horrible performance implications.

* If using `TIMESTAMP` columns solves the grouping issue covered in the third
  situation.

Chances are I'll be 'refactoring' an application based on this research in the
next couple of days, so there may be an update or two to this post as that
happens. :)
