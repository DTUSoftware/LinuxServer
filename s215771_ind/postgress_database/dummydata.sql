CREATE TABLE linux_distros (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL,
    release_date DATE NOT NULL
);

INSERT INTO linux_distros (name, version, release_date)
VALUES ('Ubuntu', '20.04', '2020-04-23'),
       ('Fedora', '34', '2021-04-27'),
       ('Debian', '10.9', '2021-04-24'),
       ('CentOS', '8.4.2105', '2021-05-27'),
       ('Arch', '2021.06.01', '2021-06-01'),
       ('OpenSUSE', '15.3', '2021-06-02'),
       ('Gentoo', '2021.05.23', '2021-05-23');

SELECT * FROM linux_distros;