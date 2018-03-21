psql -f create_tables.sql $1
psql -f queries.sql $1
psql -v currentDir=$PWD -f initialize_data.sql $1
