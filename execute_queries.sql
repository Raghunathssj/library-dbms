set search_path to step_library;

-- 1.All books available in library
select * from copies_of_book;

-- 2.Books with highest number of copies.
select * from max_copies;

-- 3.Books with five or less copies.
select * from books_with_5_or_less_copies;

-- 4.Books borrowed the most in a given month. (Eg: Sep 2017)
--Specify month and year;
select * from max_no_of_times_borrowed_in(3,2018);

-- 5.Books not borrowed for more than four months as of current date.
select * from books_not_borrowed_in_last_4_months;

-- 6.Books having more than 10 copies and not borrowed for the last 3 months.
select * from books_not_borrowed_in_last_3_months_and_has_more_than_10_copies;

-- 7.Library user who borrowed the maximum books in a given period. (Eg: Jan 2018)
--Specify month and year;
select * from maximum_books_borrowed_by_in(3,2018);

-- 8.Library user(s) who are in possession of a library book for more then 15 days.
select * from borrowers_having_book_for_15_days;

-- 9.Library user(s) who are in possession of more than two library books and holding atleast two of them for more then 15 days.
select * from borrower_having_more_than_2_books_and_book_for_15_days;

-- 10.Books that are in high demand and copies not available.
select * from books_that_are_in_highest_demand_and_not_available;

-- 11.Library users who returned books in 7 days time in a given period.
--Specify month and year in number;
select * from users_who_returned_book_in_7_days(3,2018);

-- 12.Average period of holding the borrowed books that were returned in a certain period. (Eg: Jan 2018).
--Specify month and year in number;
select * from average_period_of_holding_books_in(3,2018);
