set search_path to step_library;

create or replace view copies_of_book (book_name,noOfCopies) as
  select g.book_name,count(*) as noOfCopies
    from books_copies b join books g on g.group_id=b.group_id
    where b.status<>'lost'
      group by g.book_name order by noOfCopies desc;

create or replace view max_copies (book_name,noOfCopies) as
  select book_name,noOfCopies from copies_of_book
    where noOfCopies=(select max(b.noOfCopies) from copies_of_book b);

create or replace view books_with_5_or_less_copies (book_name,noOfCopies) as select *
  from copies_of_book t1 where t1.noOfCopies<=5;

-- first int is for month and second int is for year
create or replace function no_of_times_books_borrowed_in(int,int)
  returns table (group_id int,no_of_times_borrowed bigint) as $$
    select b.group_id,count(*)
      from register r join books_copies b on b.book_id=r.book_id
        where (extract(month from borrowed_date)=$1 and extract(year from borrowed_date)=$2)
          group by b.group_id$$
language sql;

-- first int is for month and second int is for year
create or replace function books_borrowed_in(int,int)
  returns table (group_id int,book_name varchar) as $$
    select distinct g.group_id,g.book_name from
      (select * from no_of_times_books_borrowed_in($1,$2)) t1
      join books g on t1.group_id=g.group_id$$
language sql;

-- first int is for month and second int is for year
create or replace function max_no_of_times_borrowed_in(int,int)
  returns table (group_id int,book_name varchar) as $$
    select g.group_id,g.book_name from (select * from no_of_times_books_borrowed_in($1,$2)) t1
      join books g on t1.group_id=g.group_id
        where t1.no_of_times_borrowed=(select max(no_of_times_borrowed)from no_of_times_books_borrowed_in($1,$2))$$
language sql;

-- int is for number of days
create or replace function books_borrowed_in_last_N_days(int)
  returns table (group_id int) as $$
    select b.group_id from register r left join books_copies b on r.book_id=b.book_id where current_date - r.borrowed_date <= $1 order by r.borrowed_date
$$language sql;

-- int is for number of days
create or replace function books_added_before_N_days(int)
  returns table (group_id int) as $$
  select b.group_id from
    (select group_id,count(group_id) from books_copies
      where added_on + $1 * interval '1 day' > current_date
      group by group_id) rab
    join (select group_id,count(group_id) from books_copies group by group_id) b
    on b.group_id=rab.group_id where b.count=rab.count;
$$ language sql;

-- int is for number of days
create or replace function books_not_borrowed_in_last_N_days(int)
  returns table (book_name varchar,group_id int) as $$
  select g.book_name,g.group_id from books g where g.group_id not in
    (select * from books_borrowed_in_last_N_days($1) union
    select * from books_added_before_N_days($1))
$$language sql;

create or replace view books_not_borrowed_in_last_4_months as
  select * from books_not_borrowed_in_last_N_days(120);

create or replace view more_than_10_copies (book_name,noOfCopies) as
  select * from copies_of_book t1 where t1.noOfCopies>10;

create or replace view books_not_borrowed_in_last_3_months as
  select * from books_not_borrowed_in_last_N_days(90);

create or replace view books_not_borrowed_in_last_3_months_and_has_more_than_10_copies as
  select v1.book_name,v1.group_id from books_not_borrowed_in_last_3_months v1
    join more_than_10_copies v2 on v1.book_name=v2.book_name;


create or replace view num_of_times_borrowed as
  select group_id,count(group_id) as noOfTimes
    from books_copies b join register r on r.book_id=b.book_id group by group_id;

create or replace view borrowers_having_book_for_15_days as
  select distinct user_id,name,email from
    (select borrower_id from register
      where (select now()::date - borrowed_date::date>15 and returned_date is null)
    )t1
    join users on t1.borrower_id=users.user_id;

create or replace view no_of_books_user_holding as
  select distinct borrower_id,count(*) as noOfBooksBorrowed from
    register where returned_date is null group by borrower_id;

create or replace view borrower_having_more_than_2_books as
  select user_id,name,email from no_of_books_user_holding t1
    join users u on t1.borrower_id=u.user_id where t1.noOfBooksBorrowed>2;

create or replace view borrower_having_atleast_2_books_for_15_days as
  with c as (
    select r.borrower_id,count(*) as cnt from register r
    where r.returned_date is null and current_date - r.borrowed_date > 15
    group by r.borrower_id
  ) select * from c where c.cnt >=2;

create or replace view borrower_having_more_than_2_books_and_book_for_15_days as
  select t2.user_id,t2.name,t2.email from
    borrower_having_atleast_2_books_for_15_days t1
    join borrower_having_more_than_2_books t2 on t1.borrower_id=t2.user_id;


create or replace view highest_demand_books as
  select t1.group_id from num_of_times_borrowed t1
    where noOfTimes =(select max(t2.noOfTimes) from num_of_times_borrowed t2)
      group by t1.group_id;

create or replace view group_ids_of_books_that_are_in_highest_demand_and_not_available as
  select * from highest_demand_books h where h.group_id not in (select b.group_id from books_copies b
    join highest_demand_books h on b.group_id = h.group_id where b.status= 'available' group by b.group_id);

create or replace view books_that_are_in_highest_demand_and_not_available as
  select bg.book_name from books bg
    join group_ids_of_books_that_are_in_highest_demand_and_not_available h on h.group_id=bg.group_id;

-- first int is for month and second int is for year
create or replace function books_returned_in(int,int)
  returns table (group_id integer,book_id varchar,borrower_id integer,holding_period integer) as $$
    select b.group_id,r.book_id,r.borrower_id,(r.returned_date - r.borrowed_date) as holding_period
      from register r join books_copies b on b.book_id=r.book_id
        where (extract(month from returned_date)=$1 and extract(year from returned_date)=$2)
$$language sql;

-- first int is for month and second int is for year
create or replace function users_who_returned_book_in_7_days(int,int)
  returns table (user_id integer,name varchar,email varchar) as $$
    select u.* from (select t1.borrower_id from books_returned_in($1,$2) t1
      where t1.holding_period<=7)t2 join users u on u.user_id=t2.borrower_id
$$language sql;

-- first int is for month and second int is for year
create or replace function average_period_of_holding_books_in(int,int)
  returns table (average_period_of_holding_books numeric) as $$
    select avg(t1.holding_period) from books_returned_in($1,$2) t1
$$language sql;

-- first int is for month and second int is for year
create or replace function books_borrowed_by_X_in(int,int)
  returns table (borrower_id int,count bigint) as $$
    select borrower_id,count(borrower_id) from register where (
      extract(month from borrowed_date)=$1 and extract(year from borrowed_date)=$2
    )group by borrower_id
$$language sql;

-- first int is for month and second int is for year
create or replace function maximum_books_borrowed_by_in(int,int)
  returns table (user_id int, user_name varchar,email_id varchar) as $$
    select u.* from users u join
      (
        select * from books_borrowed_by_X_in($1,$2)
      ) t1
    on u.user_id=t1.borrower_id where t1.count=(select max(count) from books_borrowed_by_X_in($1,$2))
$$language sql;
