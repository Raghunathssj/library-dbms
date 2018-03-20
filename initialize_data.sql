set search_path to step_library;

COPY users from "${1}/library-dbms/data/users_data.csv" with delimiter ',';
COPY book_group from '${1}/library-dbms/data/book_group_data.csv' with delimiter ',';
COPY books from '${1}/library-dbms/data/book_data.csv' with delimiter ',';
