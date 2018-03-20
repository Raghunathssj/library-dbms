set search_path to step_library;

COPY users from '/users/raghus/Projects/psql/data/users_data.csv' with delimiter ',';
COPY book_group from '/users/raghus/Projects/psql/data/book_group_data.csv' with delimiter ',';
COPY books from '/users/raghus/Projects/psql/data/book_data.csv' with delimiter ',';
