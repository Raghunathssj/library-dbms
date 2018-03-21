set search_path to step_library;

\set pwd '\'':currentDir'/data/users_data.csv\''
COPY users from :pwd with delimiter ',';



\set pwd '\'':currentDir'/data/book_group_data.csv\''
COPY book_group from :pwd with delimiter ',';



\set pwd '\'':currentDir'/data/book_data.csv\''
COPY books from :pwd with delimiter ',';


\set pwd '\'':currentDir'/data/register_data.csv\''
COPY register from :pwd with delimiter ',';
