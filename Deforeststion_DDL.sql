--Insert of data into tables

-- forest area
COPY forest_area
FROM '<insert_file_pathway>/forest_area.csv'
DELIMITER ','
CSV HEADER;

-- land area
COPY land_area
FROM '<insert_file_pathway>/land_area.csv'
DELIMITER ','
CSV HEADER;

-- regions
COPY regions
FROM '<insert_file_pathway>/regions.csv'
DELIMITER ','
CSV HEADER;

