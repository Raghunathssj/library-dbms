create schema step_library;

set search_path to step_library;

create table users (
  user_id integer primary key,
  name varchar(100),
  email varchar(100)
);

create table books_copies (
  group_id integer,
  book_id varchar(11) primary key,
  added_on date,
  status varchar(10)
);

create table books (
  group_id integer primary key,
  book_name varchar(100), author varchar(200),
  pages integer, ISBN varchar(20), publisher varchar(200),
  description varchar(1000)
);

create table register (
  book_id varchar(11), borrower_id integer,
  borrowed_date date,
  returned_date date
);

alter table books_copies
add constraint fk_group_id
FOREIGN KEY (group_id)
REFERENCES books(group_id);

alter table register
add constraint fk_borrower_id
FOREIGN KEY (borrower_id)
REFERENCES users(user_id);

alter table register
add constraint fk_book_id
FOREIGN KEY (book_id)
REFERENCES books_copies(book_id);

CREATE OR REPLACE FUNCTION make_status_borrowed() RETURNS TRIGGER AS $$
  BEGIN
    update books_copies bc set status='borrowed' where bc.book_id=new.book_id;
    if new.returned_date is not null then
      update books_copies bc set status='available' where bc.book_id=new.book_id;
    end if;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

create trigger borrow_trigger after insert ON register for each row execute procedure make_status_borrowed();

CREATE OR REPLACE FUNCTION make_status_available() RETURNS TRIGGER AS $$
  BEGIN
    update books_copies bc set status='available' where bc.book_id=new.book_id;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

create trigger return_trigger after update of returned_date ON register for each row execute procedure make_status_available();
