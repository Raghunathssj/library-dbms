set search_path to step_library;

\set pwd '\'':currentDir'/data/users_data.csv\''
COPY users from :pwd with delimiter ',';



\set pwd '\'':currentDir'/data/book_group_data.csv\''
COPY books from :pwd with delimiter ',';



\set pwd '\'':currentDir'/data/book_data.csv\''
COPY books_copies from :pwd with delimiter ',';


\set pwd '\'':currentDir'/data/register_data.csv\''
COPY register from :pwd with delimiter ',';

insert into register values
  ('1002-1',20958,'01/01/2018',null),
  ('1002-2',20967,'01/01/2018',null),
  ('1003-1',21003,'01/01/2018',null),
  ('1002-3',20958,'03/01/2018','03/02/2018'),
  ('1002-3',20958,'03/04/2018',null),
  ('1004-1',20967,'03/01/2018',null),
  ('1002-4',20967,'03/01/2018','03/02/2018'),
  ('1002-4',20967,'03/03/2018',null)
