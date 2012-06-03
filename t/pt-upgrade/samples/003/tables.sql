DROP DATABASE IF EXISTS test;
CREATE DATABASE test;
USE test;
CREATE TABLE t (
  id    INT NOT NULL PRIMARY KEY,
  total DOUBLE NOT NULL
) ENGINE=InnoDB;
INSERT INTO test.t VALUES
  (1, 1.23),
  (2, 4.56),
  (3, 7.89);
