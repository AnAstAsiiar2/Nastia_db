CREATE TABLE `Goods` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `category` varchar(35) NOT NULL,
  `name` varchar(25) NOT NULL,
  `unit_measure` varchar(15) NOT NULL,
  `years_expiration` float NOT NULL,
  `purchase_price` decimal(10, 2) NOT NULL,
  `sale_price` decimal(10, 2) NOT NULL
);

CREATE TABLE `Person` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(20) NOT NULL,
  `address` varchar(35) NOT NULL,
  `category` varchar(20) NOT NULL,
  `discount_percent` decimal(5,2) NOT NULL
);

CREATE TABLE `Operations` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `date` date NOT NULL,
  `product_id` bigint NOT NULL,
  `amount` int NOT NULL,
  FOREIGN KEY (`product_id`) REFERENCES `Goods` (`id`) ON DELETE CASCADE
);

CREATE TABLE `Provider` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `person_id` bigint NOT NULL,
  FOREIGN KEY (`person_id`) REFERENCES `Person` (`id`) ON DELETE CASCADE
);


CREATE TABLE `Customer` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `person_id` bigint NOT NULL,
  `debt` decimal(10,2) NOT NULL,
  FOREIGN KEY (`person_id`) REFERENCES `Person` (`id`) ON DELETE CASCADE
);

CREATE TABLE `Payment_To_Provider` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `operation_id` bigint NOT NULL,
  `provider_id` bigint NOT NULL,
  FOREIGN KEY (`operation_id`) REFERENCES `Operations` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`provider_id`) REFERENCES `Provider` (`id`) ON DELETE CASCADE
);


CREATE TABLE `Payment_From_Customer` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `operation_id` bigint NOT NULL,
  `customer_id` bigint NOT NULL,
  FOREIGN KEY (`operation_id`) REFERENCES `Operations` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`customer_id`) REFERENCES `Customer` (`id`) ON DELETE CASCADE
);

INSERT INTO `Person` (`id`, `name`, `address`, `category`, `discount_percent`) VALUES
(1,	'John Smith',	'123 Main St',	'Regular',	0.00),
(2,	'Jane Doe',	'456 Elm St',	'Regular',	0.00),
(3,	'Bob Johnson',	'789 Oak St',	'VIP',	0.10),
(4,	'Alice Lee',	'101 Maple St',	'VIP',	3.40),
(5,	'Bohdan',	'Levandivka',	'Irregular',	0.30),
(6,	'Yaroslav',	'Chervonograd',	'VIP',	1.05),
(7,	'Nastya',	'Levandivka',	'Regular',	3.67),
(8,	'Khrystyna',	'Main Street, 6',	'VIP',	8.65);

INSERT INTO `Customer` (`id`, `person_id`, `debt`) VALUES
(1,	1,	0.00),
(2,	2,	0.00),
(3,	3,	0.00),
(4,	4,	0.00);

INSERT INTO `Provider` (`id`, `person_id`) VALUES
(1,	5),
(2,	6),
(3,	7),
(4,	8);

INSERT INTO `Goods` (`id`, `category`, `name`, `unit_measure`, `years_expiration`, `purchase_price`, `sale_price`) VALUES
(1,	'Fruits',	'Apple',	'Kg',	0.5,	1.00,	1.50),
(2,	'Fruits',	'Banana',	'Kg',	0.25,	0.50,	1.00),
(3,	'Vegetables',	'Carrot',	'Kg',	0.75,	1.00,	1.50),
(4,	'Vegetables',	'Potato',	'Kg',	1,	0.75,	1.25);

INSERT INTO `Operations` (`id`, `date`, `product_id`, `amount`) VALUES
(1,	'2023-04-16',	1,	2),
(2,	'2023-04-16',	2,	3),
(3,	'2023-04-16',	3,	1),
(4,	'2023-04-16',	4,	2);

INSERT INTO `Payment_From_Customer` (`id`, `operation_id`, `customer_id`) VALUES
(1,	1,	1),
(2,	2,	2),
(3,	3,	3),
(4,	4,	4);

INSERT INTO `Payment_To_Provider` (`id`, `operation_id`, `provider_id`) VALUES
(1,	1,	1),
(2,	2,	2),
(3,	3,	3),
(4,	4,	4);

\\2 lab


SELECT * FROM Goods WHERE unit_measure = "Kg" AND category = "Fruits" 
OR years_expiration < 0.8 
ORDER BY name;

SELECT product_id, SUM(amount) FROM Operations GROUP BY product_id;

SELECT category, name, amount FROM Goods, Operations 
WHERE name <= "Banana" AND category = "Fruits" OR amount > 2
ORDER BY name DESC;

SELECT Customer.id AS customerId, Customer.debt,
Person.id AS personId, Person.name, Person.address
FROM Customer JOIN Person
ON Customer.person_id = Person.id;

SELECT * FROM Goods WHERE category LIKE "F%";
SELECT * FROM Operations WHERE amount BETWEEN 2 AND 5;
SELECT * FROM Person WHERE EXISTS (SELECT person_id FROM Provider);
SELECT * FROM Goods WHERE years_expiration < 
ALL(SELECT amount FROM Operations);
SELECT * FROM Goods WHERE sale_price <= 
ANY(SELECT purchase_price FROM Goods);

SELECT product_id, SUM(amount) AS numberProducts FROM Operations GROUP BY product_id;

SELECT * FROM Goods WHERE sale_price <= 
ANY(SELECT amount FROM Operations);

SELECT * FROM (SELECT name, address, category FROM Person) AS Example
WHERE category = "VIP";

SELECT op.id AS operationId, op.date, op.amount,
c.id AS customerId, p.name, p.address, p.discount_percent
FROM Operations op
JOIN Payment_From_Customer pfc ON op.id = pfc.operation_id
JOIN Customer c ON pfc.customer_id = c.id
JOIN Person p ON p.id = c.person_id;

SELECT provider_id AS providerId, 
COUNT(CASE WHEN operation_id = 1 THEN TRUE END) AS Operation1,
COUNT(CASE WHEN operation_id = 2 THEN TRUE END) AS Operation2,
COUNT(CASE WHEN operation_id = 3 THEN TRUE END) AS Operation3,
COUNT(CASE WHEN operation_id = 4 THEN TRUE END) AS Operation4
FROM Payment_To_Provider
GROUP BY provider_id;

UPDATE Goods
SET purchase_price = 0.75
WHERE id = 2;

UPDATE Customer
JOIN Person ON Customer.person_id = Person.id
SET Customer.debt = 2.85
WHERE Person.name = "Bohdan";

INSERT INTO Operations (date, product_id, amount) VALUES
('2023-04-16',	1,	5);

INSERT INTO Customer (person_id, debt)
VALUES
SELECT id, sale_price * 5 FROM Goods
WHERE name = "Carrot";

DELETE FROM Provider;

DELETE FROM Provider WHERE id = 3;


//3 lab

DELIMITER //
CREATE PROCEDURE calculate_payment_for_customer(IN customer_id INT, IN month DATE)
BEGIN
    DECLARE total_sale DECIMAL(10,2);
    DECLARE payment DECIMAL(10,2);
    DECLARE debt DECIMAL(10,2);
    
    -- отримати загальну вартість операцій з продажу товарів, що були здійснені покупцем у вказаний місяць
    SELECT SUM(o.amount * g.sale_price) INTO total_sale
    FROM Operations o
    JOIN Goods g ON o.product_id = g.id
    JOIN Payment_From_Customer p ON o.id = p.operation_id
    WHERE p.customer_id = customer_id
    AND MONTH(o.date) = MONTH(month)
    AND YEAR(o.date) = YEAR(month);

    -- отримати умови сплати за товари, що встановлені для даного покупця
    SELECT c.debt INTO debt
    FROM Customer c
    WHERE c.id = customer_id;

    -- обчислити нараховану оплату згідно з умовами сплати та оновити баланс покупця
    SET payment = debt + total_sale;
    SELECT payment;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE everybody_calc_payment(IN month DATE)
BEGIN
DECLARE number INT;
SET number = 1;
SELECT COUNT(id) INTO @count FROM Customer;
WHILE number <= @count DO
CALL calculate_payment_for_customer(number, month);
SET number = number + 1;
END WHILE;
END //
DELIMITER ;


//4 lab

ALTER TABLE `Customer`
ADD `UCR` varchar(20) NOT NULL,
ADD `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `UCR`,
ADD `ULC` varchar(20) NOT NULL AFTER `DCR`,
ADD `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ULC`;


ALTER TABLE `Goods`
ADD `UCR` varchar(20) NOT NULL,
ADD `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `UCR`,
ADD `ULC` varchar(20) NOT NULL AFTER `DCR`,
ADD `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ULC`;


ALTER TABLE `Operations`
ADD `UCR` varchar(20) NOT NULL,
ADD `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `UCR`,
ADD `ULC` varchar(20) NOT NULL AFTER `DCR`,
ADD `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ULC`;


ALTER TABLE `Payment_From_Customer`
ADD `UCR` varchar(20) NOT NULL,
ADD `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `UCR`,
ADD `ULC` varchar(20) NOT NULL AFTER `DCR`,
ADD `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ULC`;


ALTER TABLE `Payment_To_Provider`
ADD `UCR` varchar(20) NOT NULL,
ADD `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `UCR`,
ADD `ULC` varchar(20) NOT NULL AFTER `DCR`,
ADD `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ULC`;


ALTER TABLE `Person`
ADD `UCR` varchar(20) NOT NULL,
ADD `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `UCR`,
ADD `ULC` varchar(20) NOT NULL AFTER `DCR`,
ADD `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ULC`;


ALTER TABLE `Provider`
ADD `UCR` varchar(20) NOT NULL,
ADD `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `UCR`,
ADD `ULC` varchar(20) NOT NULL AFTER `DCR`,
ADD `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ULC`;


CREATE TRIGGER customer_before_insert
BEFORE INSERT ON Customer
FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();
CREATE TRIGGER customer_before_update
BEFORE UPDATE ON Customer
FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();

CREATE TRIGGER goods_before_insert
BEFORE INSERT ON Goods
FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();
CREATE TRIGGER goods_before_update
BEFORE UPDATE ON Goods
FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();

CREATE TRIGGER operations_before_insert
BEFORE INSERT ON Operations
FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();
CREATE TRIGGER operations_before_update
BEFORE UPDATE ON Operations
FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();

CREATE TRIGGER payment_customer_before_insert
BEFORE INSERT ON  Payment_From_Customer
FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();
CREATE TRIGGER payment_customer_before_update
BEFORE UPDATE ON  Payment_From_Customer
FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();

CREATE TRIGGER payment_provider_before_insert
BEFORE INSERT ON Payment_To_Provider
FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();
CREATE TRIGGER payment_provider_before_update
BEFORE UPDATE ON Payment_To_Provider
FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();

CREATE TRIGGER person_before_insert
BEFORE INSERT ON Person
FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();
CREATE TRIGGER person_before_update
BEFORE UPDATE ON Person
FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();

CREATE TRIGGER provider_before_insert
BEFORE INSERT ON Provider
FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();
CREATE TRIGGER provider_before_update
BEFORE UPDATE ON Provider
FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();


DELIMITER //
CREATE TRIGGER `surrogate_key` BEFORE INSERT ON Operations FOR EACH ROW
BEGIN
    DECLARE max_id BIGINT;
    SELECT MAX(id) INTO max_id FROM Operations;
    IF NEW.id != max_id+1 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid id value';
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER `check_amount_goods_before_insert` BEFORE INSERT ON Payment_From_Customer
FOR EACH ROW
BEGIN
  DECLARE goods_amount INT;
  DECLARE productId BIGINT;
  DECLARE amountGoodsNew INT;
  SELECT product_id, amount INTO productId, amountGoodsNew FROM Operations
  WHERE id = NEW.operation_id;
  SET goods_amount = (SELECT SUM(o.amount) FROM Operations o
  JOIN Payment_From_Customer pfc ON o.id = pfc.operation_id
  WHERE o.product_id = productId);
  SET goods_amount = goods_amount + amountGoodsNew;
  IF goods_amount > (SELECT SUM(o.amount) FROM Operations o
  JOIN Payment_To_Provider ptp ON o.id = ptp.operation_id
  WHERE o.product_id = productId) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough goods in stock';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER `check_amount_goods_before_update` BEFORE UPDATE ON Payment_From_Customer
FOR EACH ROW
BEGIN
  DECLARE goods_amount INT;
  DECLARE productId BIGINT;
  DECLARE amountGoodsNew INT;
  SELECT product_id, amount INTO productId, amountGoodsNew FROM Operations
  WHERE id = NEW.operation_id;
  SET goods_amount = (SELECT SUM(o.amount) FROM Operations o
  JOIN Payment_From_Customer pfc ON o.id = pfc.operation_id
  WHERE o.product_id = productId);
  SET goods_amount = goods_amount + amountGoodsNew;
  IF goods_amount > (SELECT SUM(o.amount) FROM Operations o
  JOIN Payment_To_Provider ptp ON o.id = ptp.operation_id
  WHERE o.product_id = productId) AND OLD.operation_id != NEW.operation_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough goods in stock';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER `check_amount_goods_operations_before_update` BEFORE UPDATE ON Operations
FOR EACH ROW
BEGIN
  DECLARE goods_amount INT;
  SET goods_amount = (SELECT SUM(o.amount) FROM Operations o
  JOIN Payment_From_Customer pfc ON o.id = pfc.operation_id
  WHERE o.product_id = NEW.product_id);
  SET goods_amount = goods_amount + NEW.amount - OLD.amount;
  IF goods_amount > (SELECT SUM(o.amount) FROM Operations o
  JOIN Payment_To_Provider ptp ON o.id = ptp.operation_id
  WHERE o.product_id = productId) AND EXISTS(SELECT * 
  FROM Payment_From_Customer WHERE operation_id = NEW.id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough goods in stock';
  END IF;
END //
DELIMITER ;

//5 lab

CREATE USER 'AdminDB'@'%' IDENTIFIED BY 'root';
CREATE USER 'Provider'@'%' IDENTIFIED BY 'root';
CREATE USER 'Customer'@'%' IDENTIFIED BY 'root';
CREATE USER 'ShopOwner'@'%' IDENTIFIED BY 'root';

GRANT ALL PRIVILEGES ON sample.* TO 'AdminDB'@'%';
GRANT INSERT, UPDATE, DELETE, SELECT ON Provider TO 'Provider'@'%';
GRANT INSERT, UPDATE, DELETE, SELECT ON Payment_To_Provider TO 'Provider'@'%';
GRANT INSERT, UPDATE, DELETE, SELECT ON Person TO 'Provider'@'%';
GRANT INSERT, UPDATE, DELETE, SELECT ON Customer TO 'Customer'@'%';
GRANT INSERT, UPDATE, DELETE, SELECT ON Payment_From_Customer TO 'Customer'@'%';
GRANT INSERT, UPDATE, DELETE, SELECT ON Person TO 'Customer'@'%';
GRANT SELECT ON sample.* TO 'ShopOwner'@'%';
GRANT INSERT, UPDATE, DELETE ON Operations TO 'ShopOwner'@'%';
GRANT INSERT, UPDATE, DELETE ON Goods TO 'ShopOwner'@'%';


CREATE ROLE admin, user;

GRANT ALL PRIVILEGES ON sample.* TO admin;
GRANT SELECT ON sample.* TO user;

GRANT admin TO 'AdminDB'@'%';
GRANT admin TO 'ShopOwner'@'%';
GRANT user TO 'Provider'@'%';
GRANT user TO 'Customer'@'%';

REVOKE SELECT ON Person FROM 'Customer'@'%';

REVOKE SELECT ON sample.* FROM user;

DROP ROLE 'admin';

DROP USER 'Customer'@'%';