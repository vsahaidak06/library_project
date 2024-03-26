-- SELECT = with non-correlated
-- вибирає книги, які мають таке саме видання, як і книга, рік випуску якої = 1967 
SELECT title
FROM book
WHERE edition = (SELECT edition
                 FROM book
                 WHERE release_year = 1967);


-- SELECT IN with non-correlated
-- вибирає всю інформацію про книги, написані авторами-британцями
SELECT title
FROM book
WHERE author_id IN (SELECT id
                    FROM author
                    WHERE nationality = 'British');


-- SELECT NOT IN with non-correlated
-- вибирає всю інформацію про книги, жанри яких не є трилерами
SELECT isbn
FROM book
WHERE genre_id NOT IN (SELECT id
                       FROM genre
                       WHERE name = 'Thriller' OR name = 'Mystery');


-- SELECT EXISTS with non-correlated
-- вибирає всі жанри, якщо в таблиці існує назва жанру 'Poetry'
SELECT name
FROM genre
WHERE EXISTS (SELECT 1
              FROM genre
              WHERE name = 'Poetry');


-- SELECT NOT EXISTS with non-correlated
-- вибирає імена всіх людей, якщо автора з національністю 'Polish' не існує
SELECT name
FROM author
WHERE NOT EXISTS (SELECT 1
                  FROM author
                  WHERE nationality = 'Polish');


-- SELECT = with correlated
-- вибирає конкретного автора по id книги
SELECT name
FROM author
WHERE id = (SELECT author_id
            FROM book
            WHERE book.id = 3);


-- SELECT IN with correlated
-- вибирає назви книг, які були позичені до конкретної дати
SELECT title
FROM book
WHERE id IN (SELECT book_id
             FROM loan
             WHERE loan_date < '2024-01-10'
             AND book.id = loan.book_id);


-- SELECT NOT IN with correlated
-- вибирає видавництва, в яких середня ціна книг більше 10
SELECT p.name
FROM publisher p
WHERE p.id NOT IN (SELECT b.publisher_id
                   FROM book b
                   WHERE p.id = b.publisher_id
                   GROUP BY b.publisher_id
                   HAVING AVG(price) < 10);


-- SELECT EXISTS with correlated
-- вибирає назви книг, які хоча б раз були взяті читачем
SELECT b.title
FROM book b
WHERE EXISTS (SELECT 1
              FROM book2loan bl
              WHERE bl.book_id = b.id);


-- SELECT NOT EXISTS with correlated
-- вибирає назву жанра, який не належить жодній книзі
SELECT g.name
FROM genre g
WHERE NOT EXISTS (SELECT 1
                  FROM genre2book gb
                  WHERE gb.genre_id = g.id);





-- UPDATE = with non-correlated
-- змінює національність автора, дата народження якого найменша
UPDATE author
SET nationality = 'Ukrainian'
WHERE birth_date = (SELECT birth_date
                    FROM (SELECT MIN(birth_date)
                          FROM author) AS new_author);


-- UPDATE IN with non-correlated
-- змінює адресу клієнта, якщо його номер починається на '380'
UPDATE customer
SET address = 'Ukraine'
WHERE phone IN (SELECT phone
                FROM (SELECT phone
                      FROM customer
                      WHERE phone LIKE'380%') AS new_customer);


-- UPDATE NOT IN with non-correlated
-- змінює фактичну дату повернення на нульове значення, якщо дата, до якої треба було здати не більше зазначеної
UPDATE loan
SET return_date = NULL
WHERE due_date NOT IN (SELECT due_date
                       FROM (SELECT due_date
                             FROM loan
                             WHERE due_date > '2024-02-10') AS new_loan);


-- UPDATE EXISTS with non-correlated
-- змінює фактичну дату повернення на день пізніше, якщо дата, до якої треба було здати дорівнює зазначеній
UPDATE loan
SET return_date = '2024-02-11'
WHERE EXISTS (SELECT 1
              FROM (SELECT 1
                    FROM loan
                    WHERE due_date = '2024-02-10') AS new_loan1);


-- UPDATE NOT EXISTS with non-correlated
-- знижує ціну на всі книги на 1$, якщо в таблиці не існує книг, виданих після 2019 року
UPDATE book
SET price = price - 1
WHERE NOT EXISTS (SELECT 1
                  FROM (SELECT 1
                        FROM book
                        WHERE release_year > 2019) AS new_book);





-- DELETE = with non-correlated
-- видаляє рядок з таблиці авторів, в якому дата народження є найменшою
DELETE
FROM author
WHERE birth_date = (SELECT birth_date
                    FROM (SELECT MIN(birth_date)
                          FROM author) AS delete_author);


-- DELETE IN with non-correlated
-- видаляє рядки з таблиці авторів, де національність автора - японець
DELETE
FROM author
WHERE nationality IN (SELECT nationality
                      FROM (SELECT nationality
                            FROM author
                            WHERE nationality = 'Japanese') AS delete_author);


-- DELETE NOT IN with non-correlated
-- видаляє рядки, адреса яких знаходиться не в Нью-Йорці
DELETE
FROM publisher
WHERE address NOT IN (SELECT address
                      FROM (SELECT address
                            FROM publisher
                            WHERE address LIKE '%NY%') AS delete_publisher);


-- DELETE EXISTS with non-correlated
-- видаляє всі записи, якщо у таблиці існує хоча б один номер, який починається з ‘7’
DELETE
FROM publisher
WHERE EXISTS (SELECT 1
              FROM (SELECT 1
                    FROM publisher
                    WHERE phone LIKE '7%') AS delete_publisher);


-- DELETE NOT EXISTS with non-correlated
-- видаляє всі записи з таблиці клієнтів, якщо в таблиці loan немає жодного запису
DELETE
FROM customer
WHERE NOT EXISTS (SELECT 1
                  FROM (SELECT 1
                        FROM loan) AS delete_customer);


-- DELETE IN with correlated
-- видаляє книги, які не були повернуті до дати, яку призначали
DELETE
FROM book b
WHERE b.id IN (SELECT l.book_id
               FROM loan l
               WHERE l.book_id = b.id
                 AND return_date IS NULL);


-- DELETE NOT IN with correlated
-- видаляє авторів, які не мають жодної книги в таблиці книг
DELETE
FROM author a
WHERE a.id NOT IN (SELECT b.author_id
                   FROM book b
                   WHERE b.author_id = a.id);


-- DELETE  EXISTS with correlated
-- видаляє жанри, якщо ціна книги з цим жанром менше 8
DELETE
FROM genre g
WHERE EXISTS (SELECT 1
              FROM book b
              WHERE g.id = b.genre_id
                AND b.price < 8);


-- DELETE  NOT EXISTS with correlated
-- видаляє тільки той жанр, який не належить жодній книзі
DELETE
FROM genre g
WHERE NOT EXISTS (SELECT 1
                  FROM book b
                  WHERE b.genre_id = g.id);





-- об’єднує таблиці авторів і видавництв, які родом з Англії/ знаходяться в Англії
SELECT name, nationality
FROM author
WHERE nationality = 'British'
UNION
SELECT name, address
FROM publisher
WHERE address LIKE '%GBR%';


-- об'єднує таблиці авторів і клієнтів по іменам і рідним країнам, дозволюючи повтори
SELECT name, nationality
FROM author
UNION ALL
SELECT name, address
FROM customer
ORDER BY nationality;


-- вибирає з таблиць видавництва і клієнтів тільки ту адресу, яка є в обох таблицях
SELECT address
FROM publisher
INTERSECT
SELECT address
FROM customer;


-- вибирає всі імена з таблиці авторів, за виключенням тих, які співпадають з іменами в таблиці клієнтів
SELECT name
FROM author
EXCEPT
SELECT name
FROM customer
ORDER BY name;
