psql -f setup_tables.sql $1
psql -f initialize_data.sql $1
