set search_path to step_library;

COPY users from '/users/yogiras/Projects/library-dbms/data/users_data.csv' with delimiter ',';
COPY book_group from '/users/yogiras/Projects/library-dbms/data/book_group_data.csv' with delimiter ',';
COPY books from '/users/yogiras/Projects/library-dbms/data/book_data.csv' with delimiter ',';
