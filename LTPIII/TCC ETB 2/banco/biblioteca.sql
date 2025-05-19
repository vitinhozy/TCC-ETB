CREATE DATABASE biblioteca;
USE biblioteca;

CREATE TABLE livros (
    id INT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    autor VARCHAR(100),
    ano INT
);
