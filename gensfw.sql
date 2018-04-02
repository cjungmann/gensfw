
CREATE DATABASE IF NOT EXISTS TestGenSFW;
USE TestGenSFW;

-- Drop first to simplify updating the table definition.
-- gensfw, at least initially, only consults the table
-- definition, not the table contents, so there is no
-- concern for losing the contents by dropping the table.
DROP TABLE IF EXISTS Person;
CREATE TABLE Person
(
   id     INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
   fname  VARCHAR(20),
   lname  VARCHAR(50),
   dob    DATETIME,
   gender ENUM('male','female','other')
);
