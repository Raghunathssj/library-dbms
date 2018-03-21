set search_path to step_library;

create view copies_of_book (book_name,noOfCopies) as select g.book_name,count(*) as noOfCopies from books b join book_group g on g.group_id=b.group_id group by g.book_name order by noOfCopies desc;

create view max_copies (book_name,noOfCopies) as select book_name,noOfCopies from copies_of_book where noOfCopies=(select max(b.noOfCopies) from copies_of_book b);

create view books_with_5_or_less_copies (book_name,noOfCopies) as select * from copies_of_book t1 where t1.noOfCopies<=5;

create or replace function no_of_times_books_borrowed_in(int,int) returns table (group_id int,no_of_times_borrowed bigint) as $$
  select b.group_id,count(*) from register r join books b on b.book_id=r.book_id where (extract(month from borrowed_date)=$1 and extract(year from borrowed_date)=$2) group by b.group_id$$
language sql;

create or replace function books_borrowed_in(int,int) returns table (group_id int,book_name varchar) as $$
  select distinct g.group_id,g.book_name from (select * from no_of_times_books_borrowed_in($1,$2)) t1 join book_group g on t1.group_id=g.group_id$$
language sql;

create or replace function max_no_of_times_borrowed_in(int,int) returns table (group_id int,book_name varchar) as $$
  select g.group_id,g.book_name from (select * from no_of_times_books_borrowed_in($1,$2)) t1 join book_group g on t1.group_id=g.group_id where t1.no_of_times_borrowed=(select max(no_of_times_borrowed) from no_of_times_books_borrowed_in($1,$2))$$
language sql;


create view books_borrowed_in_last_4_months as select book_id from register r where (select now()::date - r.borrowed_date::date) < 120;

create view group_ids_of_books_borrowed_in_last_4_months as select group_id from books b join books_borrowed_in_last_4_months v on b.book_id=v.book_id;

create view books_not_borrowed_in_last_4_months as select bg.book_name,bg.group_id from book_group bg left outer join group_ids_of_books_borrowed_in_last_4_months v on bg.group_id=v.group_id where bg.group_id not in (select * from group_ids_of_books_borrowed_in_last_4_months);


create view more_than_10_copies (book_name,noOfCopies) as select * from copies_of_book t1 where t1.noOfCopies>10;

create view books_borrowed_in_last_3_months as select book_id from register r where (select now()::date - r.borrowed_date::date) < 90;

create view group_ids_of_books_borrowed_in_last_3_months as select group_id from books b join books_borrowed_in_last_3_months v on b.book_id=v.book_id;

create view books_not_borrowed_in_last_3_months as select bg.book_name,bg.group_id from book_group bg left outer join group_ids_of_books_borrowed_in_last_3_months v on bg.group_id=v.group_id where bg.group_id not in (select * from group_ids_of_books_borrowed_in_last_3_months);

create view books_not_borrowed_in_last_3_months_and_has_more_than_10_copies as select v1.book_name,v1.group_id from books_not_borrowed_in_last_3_months v1 join more_than_10_copies v2 on v1.book_name=v2.book_name;




create view num_of_times_borrowed as select group_id,count(group_id) as noOfTimes from books b join register r on r.book_id=b.book_id group by group_id;

create or replace view borrowers_having_book_for_15_days as select emp_id,name,email from (select borrower_id from register where (select now()::date - borrowed_date::date>15 and returned_date is null))t1 join users on t1.borrower_id=users.emp_id;

create or replace view no_of_books_user_holding as select borrower_id,count(*) as noOfBooksBorrowed from register where returned_date is null group by borrower_id;

create or replace view borrower_having_more_than_2_books as select emp_id,name,email from no_of_books_user_holding t1 join users on t1.noOfBooksBorrowed>2;

create or replace view borrower_having_more_than_2_books_and_book_for_15_days as select t1.emp_id,t1.name,t1.email from borrowers_having_book_for_15_days t1 join borrower_having_more_than_2_books t2 on t1.emp_id=t2.emp_id;


create view highest_demand_books as select t1.group_id from num_of_times_borrowed t1 where noOfTimes =(select max(t2.noOfTimes) from num_of_times_borrowed t2) group by t1.group_id;

create view group_ids_of_books_that_are_in_highest_demand_and_not_available as select * from highest_demand_books h where h.group_id not in (select b.group_id from books b join highest_demand_books h on b.group_id = h.group_id where b.status= 'available' group by b.group_id);

create view books_that_are_in_highest_demand_and_not_available as select bg.book_name from book_group bg join group_ids_of_books_that_are_in_highest_demand_and_not_available h on h.group_id=bg.group_id;


create or replace function books_returned_in(int,int) returns table (group_id integer,book_id varchar,borrower_id integer,holding_period integer) as $$
  select b.group_id,r.book_id,r.borrower_id,(r.returned_date - r.borrowed_date) as holding_period from register r join books b on b.book_id=r.book_id where (extract(month from returned_date)=$1 and extract(year from returned_date)=$2)$$
language sql;

create or replace function users_who_returned_book_in_7_days(int,int) returns table (emp_id integer,name varchar,email varchar) as $$
  select u.* from (select t1.borrower_id from books_returned_in($1,$2) t1 where t1.holding_period<=7)t2 join users u on u.emp_id=t2.borrower_id$$
language sql;


create or replace function average_period_of_holding_books_in(int,int) returns table (average_period_of_holding_books numeric) as $$
  select avg(t1.holding_period) from books_returned_in($1,$2) t1 $$
language sql;


create or replace function books_borrowed_by_X_in(int,int) returns table (borrower_id int,count bigint) as $$
  select borrower_id,count(borrower_id) from register where (
    extract(month from borrowed_date)=$1 and extract(year from borrowed_date)=$2
  )group by borrower_id
$$
language sql;

create or replace function maximum_books_borrowed_by_in(int,int) returns table (emp_id int, user_name varchar,email_id varchar) as $$
  select u.* from users u join
    (
      select * from books_borrowed_by_X_in($1,$2)
    ) t1
  on u.emp_id=t1.borrower_id where t1.count=(select max(count) from books_borrowed_by_X_in($1,$2))
$$
language sql;
