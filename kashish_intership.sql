CREATE DATABASE event_booking_system;

USE event_booking_system;
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    
    full_name VARCHAR(100) NOT NULL,
    
    email VARCHAR(100) NOT NULL UNIQUE,
    
    phone VARCHAR(15) UNIQUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    
    event_name VARCHAR(150) NOT NULL,
    
    description TEXT,
    
    location VARCHAR(150),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event_instances (

    instance_id INT AUTO_INCREMENT PRIMARY KEY,
    
    event_id INT NOT NULL,
    
    event_date DATE NOT NULL,
    
    event_time TIME NOT NULL,
    
    capacity INT NOT NULL CHECK (capacity > 0),
    
    price DECIMAL(10,2) NOT NULL,
    
    FOREIGN KEY (event_id)
    REFERENCES events(event_id)
    
    ON DELETE CASCADE
);

CREATE TABLE orders (

    order_id INT AUTO_INCREMENT PRIMARY KEY,
    
    user_id INT NOT NULL,
    
    instance_id INT NOT NULL,
    
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    status VARCHAR(20) DEFAULT 'CONFIRMED',
    
    FOREIGN KEY (user_id)
    REFERENCES users(user_id),
    
    FOREIGN KEY (instance_id)
    REFERENCES event_instances(instance_id)
);

CREATE TABLE tickets (

    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    
    order_id INT NOT NULL,
    
    quantity INT NOT NULL CHECK(quantity > 0),
    
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    
    ON DELETE CASCADE
);

CREATE TABLE payments (

    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    
    order_id INT NOT NULL UNIQUE,
    
    amount DECIMAL(10,2) NOT NULL,
    
    payment_method VARCHAR(50),
    
    payment_status VARCHAR(20) CHECK(payment_status IN ('PAID','PENDING','FAILED')),
    
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
);

CREATE INDEX idx_user_email ON users(email);

CREATE INDEX idx_event_id ON event_instances(event_id);

CREATE INDEX idx_order_user ON orders(user_id);

CREATE INDEX idx_payment_status ON payments(payment_status);

DELIMITER $$

CREATE TRIGGER prevent_overbooking

BEFORE INSERT ON tickets

FOR EACH ROW

BEGIN

DECLARE total_booked INT;

DECLARE max_capacity INT;

DECLARE instance INT;


SELECT instance_id INTO instance
FROM orders
WHERE order_id = NEW.order_id;


SELECT IFNULL(SUM(quantity),0)
INTO total_booked
FROM tickets t
JOIN orders o ON t.order_id = o.order_id
WHERE o.instance_id = instance;


SELECT capacity
INTO max_capacity
FROM event_instances
WHERE instance_id = instance;


IF total_booked + NEW.quantity > max_capacity THEN

SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Booking exceeds capacity';

END IF;

END$$

DELIMITER ;

INSERT INTO users (full_name, email, phone) VALUES

('Aarav Sharma', 'aarav.sharma@gmail.com', '9876543210'),

('Diya Patel', 'diya.patel@gmail.com', '9876543211'),

('Vivaan Reddy', 'vivaan.reddy@gmail.com', '9876543212'),

('Ananya Singh', 'ananya.singh@gmail.com', '9876543213'),

('Arjun Mehta', 'arjun.mehta@gmail.com', '9876543214'),

('Ishita Gupta', 'ishita.gupta@gmail.com', '9876543215'),

('Kabir Khan', 'kabir.khan@gmail.com', '9876543216'),

('Meera Iyer', 'meera.iyer@gmail.com', '9876543217'),

('Rohan Das', 'rohan.das@gmail.com', '9876543218'),

('Sneha Nair', 'sneha.nair@gmail.com', '9876543219');

INSERT INTO events (event_name, description, location) VALUES

('Sunburn Live', 'Music Festival', 'Hyderabad'),

('Standup Comedy Night', 'Comedy Show', 'Mumbai'),

('Tech Conference 2026', 'Technology Event', 'Bangalore'),

('Startup Pitch Fest', 'Entrepreneurship Event', 'Delhi'),

('Food Carnival', 'Food Festival', 'Pune'),

('College Cultural Fest', 'Dance and Music', 'Chennai'),

('IPL Fan Park', 'Cricket Screening', 'Ahmedabad'),

('Fashion Show', 'Fashion Event', 'Mumbai'),

('Gaming Tournament', 'Esports Competition', 'Hyderabad'),

('Business Seminar', 'Corporate Event', 'Gurgaon');

INSERT INTO event_instances (event_id, event_date, event_time, capacity, price) VALUES

(1, '2026-03-10', '18:00:00', 100, 1500),

(2, '2026-03-12', '19:00:00', 80, 800),

(3, '2026-03-15', '10:00:00', 200, 2000),

(4, '2026-03-18', '11:00:00', 150, 1000),

(5, '2026-03-20', '17:00:00', 120, 500),

(6, '2026-03-22', '16:00:00', 300, 300),

(7, '2026-03-25', '19:30:00', 500, 200),

(8, '2026-03-27', '18:30:00', 100, 1200),

(9, '2026-03-29', '20:00:00', 250, 700),

(10, '2026-04-02', '09:00:00', 180, 2500);

INSERT INTO orders (user_id, instance_id) VALUES

(1,1),

(2,2),

(3,3),

(4,4),

(5,5),

(6,6),

(7,7),

(8,8),

(9,9),

(10,10);

INSERT INTO tickets (order_id, quantity) VALUES

(1,2),

(2,3),

(3,1),

(4,4),

(5,2),

(6,5),

(7,3),

(8,2),

(9,6),

(10,1);

INSERT INTO payments (order_id, amount, payment_method, payment_status) VALUES

(1,3000,'UPI','PAID'),

(2,2400,'Credit Card','PAID'),

(3,2000,'Debit Card','PAID'),

(4,4000,'UPI','PAID'),

(5,1000,'UPI','PAID'),

(6,1500,'Net Banking','PAID'),

(7,600,'UPI','PAID'),

(8,2400,'Credit Card','PAID'),

(9,4200,'Debit Card','PENDING'),

(10,2500,'UPI','PAID');

select * from users;

SELECT 

ei.instance_id,

e.event_name,

ei.event_date,

ei.capacity,

IFNULL(SUM(t.quantity),0) AS booked,

(ei.capacity - IFNULL(SUM(t.quantity),0)) AS available_seats

FROM event_instances ei

JOIN events e ON ei.event_id = e.event_id

LEFT JOIN orders o ON ei.instance_id = o.instance_id

LEFT JOIN tickets t ON o.order_id = t.order_id

GROUP BY ei.instance_id;



SELECT 

u.full_name,

e.event_name,

ei.event_date,

t.quantity,

p.payment_status

FROM users u

JOIN orders o ON u.user_id = o.user_id

JOIN tickets t ON o.order_id = t.order_id

JOIN event_instances ei ON o.instance_id = ei.instance_id

JOIN events e ON ei.event_id = e.event_id

JOIN payments p ON o.order_id = p.order_id;




SELECT 

e.event_name,

SUM(p.amount) AS total_revenue

FROM payments p

JOIN orders o ON p.order_id = o.order_id

JOIN event_instances ei ON o.instance_id = ei.instance_id

JOIN events e ON ei.event_id = e.event_id

WHERE payment_status='PAID'

GROUP BY e.event_name;

INSERT INTO users (full_name, email, phone) VALUES

('Rahul Verma','rahul.verma@gmail.com','9000000001'),
('Pooja Agarwal','pooja.agarwal@gmail.com','9000000002'),
('Karan Malhotra','karan.m@gmail.com','9000000003'),
('Neha Kapoor','neha.k@gmail.com','9000000004'),
('Aditya Joshi','aditya.j@gmail.com','9000000005'),
('Simran Kaur','simran.k@gmail.com','9000000006'),
('Manish Pandey','manish.p@gmail.com','9000000007'),
('Nisha Sharma','nisha.s@gmail.com','9000000008'),
('Varun Chatterjee','varun.c@gmail.com','9000000009'),
('Priya Nair','priya.n@gmail.com','9000000010'),

('Siddharth Jain','sid.j@gmail.com','9000000011'),
('Aditi Rao','aditi.r@gmail.com','9000000012'),
('Harsh Vardhan','harsh.v@gmail.com','9000000013'),
('Tanya Bansal','tanya.b@gmail.com','9000000014'),
('Ritika Sen','ritika.s@gmail.com','9000000015'),
('Yash Thakur','yash.t@gmail.com','9000000016'),
('Snehal Patil','snehal.p@gmail.com','9000000017'),
('Aman Gupta','aman.g@gmail.com','9000000018'),
('Deepak Yadav','deepak.y@gmail.com','9000000019'),
('Kritika Mehra','kritika.m@gmail.com','9000000020'),

('Rajat Mishra','rajat.m@gmail.com','9000000021'),
('Payal Saxena','payal.s@gmail.com','9000000022'),
('Mohit Arora','mohit.a@gmail.com','9000000023'),
('Shreya Ghosh','shreya.g@gmail.com','9000000024'),
('Nikhil Bansal','nikhil.b@gmail.com','9000000025'),
('Komal Shah','komal.s@gmail.com','9000000026'),
('Ankit Tiwari','ankit.t@gmail.com','9000000027'),
('Divya Pillai','divya.p@gmail.com','9000000028'),
('Rohit Kulkarni','rohit.k@gmail.com','9000000029'),
('Bhavna Desai','bhavna.d@gmail.com','9000000030'),

('Gaurav Sinha','gaurav.s@gmail.com','9000000031'),
('Swati Dubey','swati.d@gmail.com','9000000032'),
('Vikas Rawat','vikas.r@gmail.com','9000000033'),
('Preeti Chauhan','preeti.c@gmail.com','9000000034'),
('Akash Tripathi','akash.t@gmail.com','9000000035'),
('Isha Talwar','isha.t@gmail.com','9000000036'),
('Ramesh Iyer','ramesh.i@gmail.com','9000000037'),
('Kavya Menon','kavya.m@gmail.com','9000000038'),
('Sahil Arjun','sahil.a@gmail.com','9000000039'),
('Tanvi Saxena','tanvi.s@gmail.com','9000000040');

INSERT INTO orders (user_id, instance_id) VALUES

(11,1),(12,2),(13,3),(14,4),(15,5),
(16,6),(17,7),(18,8),(19,9),(20,10),

(21,1),(22,2),(23,3),(24,4),(25,5),
(26,6),(27,7),(28,8),(29,9),(30,10),

(31,1),(32,2),(33,3),(34,4),(35,5),
(36,6),(37,7),(38,8),(39,9),(40,10),

(41,1),(42,2),(43,3),(44,4),(45,5),
(46,6),(47,7),(48,8),(49,9),(50,10);

INSERT INTO tickets (order_id, quantity) VALUES

(11,2),(12,1),(13,4),(14,3),(15,2),
(16,6),(17,2),(18,3),(19,5),(20,1),

(21,2),(22,3),(23,2),(24,1),(25,4),
(26,3),(27,2),(28,1),(29,3),(30,2),

(31,4),(32,2),(33,1),(34,5),(35,3),
(36,2),(37,6),(38,1),(39,4),(40,2),

(41,3),(42,2),(43,1),(44,4),(45,2),
(46,3),(47,5),(48,2),(49,1),(50,4);

INSERT INTO payments (order_id, amount, payment_method, payment_status) VALUES

(11,3000,'UPI','PAID'),
(12,800,'Card','FAILED'),
(13,8000,'UPI','PAID'),
(14,3000,'Net Banking','PAID'),
(15,1000,'UPI','PENDING'),

(16,1800,'UPI','PAID'),
(17,400,'UPI','PAID'),
(18,3600,'Card','PAID'),
(19,3500,'UPI','FAILED'),
(20,2500,'UPI','PAID'),

(21,3000,'Card','PAID'),
(22,2400,'UPI','PENDING'),
(23,4000,'Card','PAID'),
(24,1000,'UPI','PAID'),
(25,2000,'UPI','PAID'),

(26,900,'UPI','FAILED'),
(27,600,'Card','PAID'),
(28,1200,'UPI','PAID'),
(29,4200,'Net Banking','PAID'),
(30,2500,'UPI','PENDING'),

(31,6000,'Card','PAID'),
(32,1600,'UPI','PAID'),
(33,2000,'Card','FAILED'),
(34,5000,'UPI','PAID'),
(35,1500,'UPI','PAID'),

(36,600,'Card','PAID'),
(37,1000,'UPI','PAID'),
(38,1200,'UPI','FAILED'),
(39,2800,'UPI','PAID'),
(40,5000,'Card','PAID'),

(41,4500,'UPI','PAID'),
(42,1600,'Card','PENDING'),
(43,2000,'UPI','PAID'),
(44,4000,'UPI','PAID'),
(45,1000,'Card','FAILED'),

(46,900,'UPI','PAID'),
(47,1000,'Card','PAID'),
(48,2400,'UPI','PAID'),
(49,700,'UPI','FAILED'),
(50,10000,'Net Banking','PAID');

INSERT INTO events (event_name, description, location) VALUES

('Bollywood Night','Dance Event','Mumbai'),
('AI Summit','Tech Conference','Bangalore'),
('Rock Concert','Music Event','Delhi'),
('Photography Workshop','Workshop','Pune'),
('Yoga Retreat','Health Event','Rishikesh'),

('Startup Meetup','Business Networking','Hyderabad'),
('Art Exhibition','Art Event','Delhi'),
('Dance Workshop','Dance Training','Chennai'),
('Coding Bootcamp','Programming Event','Bangalore'),
('Motivational Seminar','Seminar','Mumbai'),

('Fitness Expo','Health Event','Pune'),
('Music Jam','Music Event','Goa'),
('Literature Fest','Book Event','Jaipur'),
('Film Festival','Film Event','Mumbai'),
('Hackathon','Coding Competition','Hyderabad'),

('Gaming Expo','Gaming Event','Bangalore'),
('Career Fair','Job Event','Delhi'),
('Investment Summit','Finance Event','Mumbai'),
('DJ Night','Music Event','Goa'),
('Theatre Play','Drama Event','Chennai'),

('Poetry Slam','Poetry Event','Pune'),
('Business Workshop','Business Event','Gurgaon'),
('Startup Workshop','Startup Event','Hyderabad'),
('Tech Meetup','Tech Event','Bangalore'),
('Food Workshop','Cooking Event','Delhi'),

('Fashion Workshop','Fashion Event','Mumbai'),
('Cricket Meetup','Sports Event','Ahmedabad'),
('Entrepreneurship Summit','Business Event','Hyderabad'),
('Digital Marketing Seminar','Marketing Event','Delhi'),
('Music Workshop','Music Event','Pune'),

('Dance Competition','Dance Event','Mumbai'),
('Film Workshop','Film Event','Chennai'),
('Coding Seminar','Programming Event','Bangalore'),
('Finance Workshop','Finance Event','Delhi'),
('Art Workshop','Art Event','Jaipur'),

('Startup Expo','Startup Event','Hyderabad'),
('Music Festival','Music Event','Goa'),
('Comedy Workshop','Comedy Event','Mumbai'),
('Gaming Tournament 2','Gaming Event','Delhi'),
('Business Expo','Business Event','Bangalore');

INSERT INTO event_instances
(event_id,event_date,event_time,capacity,price) VALUES

(11,'2026-04-05','18:00:00',200,1200),
(12,'2026-04-06','10:00:00',150,2000),
(13,'2026-04-07','19:00:00',300,1500),
(14,'2026-04-08','11:00:00',100,800),
(15,'2026-04-09','06:00:00',80,500),

(16,'2026-04-10','17:00:00',120,700),
(17,'2026-04-11','10:30:00',90,600),
(18,'2026-04-12','16:00:00',110,900),
(19,'2026-04-13','09:00:00',200,2500),
(20,'2026-04-14','14:00:00',180,1000),

(21,'2026-04-15','08:00:00',220,700),
(22,'2026-04-16','19:30:00',350,1500),
(23,'2026-04-17','10:00:00',250,500),
(24,'2026-04-18','18:00:00',300,1800),
(25,'2026-04-19','09:30:00',200,2000),

(26,'2026-04-20','20:00:00',400,2200),
(27,'2026-04-21','11:00:00',150,1000),
(28,'2026-04-22','16:00:00',120,1300),
(29,'2026-04-23','19:00:00',500,900),
(30,'2026-04-24','18:30:00',130,1100),

(31,'2026-04-25','17:00:00',140,600),
(32,'2026-04-26','10:00:00',100,1500),
(33,'2026-04-27','09:00:00',200,2000),
(34,'2026-04-28','11:00:00',170,1700),
(35,'2026-04-29','15:00:00',90,800),

(36,'2026-04-30','19:00:00',180,1600),
(37,'2026-05-01','18:00:00',220,2000),
(38,'2026-05-02','17:30:00',130,900),
(39,'2026-05-03','20:00:00',240,1400),
(40,'2026-05-04','16:00:00',300,3000),

(41,'2026-05-05','18:00:00',150,1200),
(42,'2026-05-06','19:00:00',180,1100),
(43,'2026-05-07','10:00:00',210,2500),
(44,'2026-05-08','11:30:00',190,1800),
(45,'2026-05-09','14:00:00',160,900),

(46,'2026-05-10','09:00:00',130,700),
(47,'2026-05-11','18:00:00',260,2000),
(48,'2026-05-12','17:00:00',280,2200),
(49,'2026-05-13','19:30:00',300,1500),
(50,'2026-05-14','20:00:00',400,3500);


SELECT 

ei.instance_id,

e.event_name,

ei.event_date,

ei.capacity,

IFNULL(SUM(t.quantity),0) AS booked_seats,

(ei.capacity - IFNULL(SUM(t.quantity),0)) AS available_seats

FROM event_instances ei

JOIN events e 
ON ei.event_id = e.event_id

LEFT JOIN orders o 
ON ei.instance_id = o.instance_id

LEFT JOIN tickets t 
ON o.order_id = t.order_id

GROUP BY ei.instance_id, e.event_name, ei.event_date, ei.capacity

ORDER BY available_seats DESC;


SELECT 

ei.instance_id,

e.event_name,

ei.event_date,

ei.event_time,

ei.capacity,

IFNULL(SUM(t.quantity),0) AS booked_seats,

(ei.capacity - IFNULL(SUM(t.quantity),0)) AS available_seats

FROM event_instances ei

JOIN events e
ON ei.event_id = e.event_id

LEFT JOIN orders o
ON ei.instance_id = o.instance_id

LEFT JOIN tickets t
ON o.order_id = t.order_id

GROUP BY 

ei.instance_id,
e.event_name,
ei.event_date,
ei.event_time,
ei.capacity

ORDER BY ei.instance_id;


SELECT 

u.user_id,

u.full_name,

e.event_name,

ei.event_date,

ei.event_time,

t.quantity,

p.amount,

p.payment_status

FROM users u

JOIN orders o
ON u.user_id = o.user_id

JOIN tickets t
ON o.order_id = t.order_id

JOIN event_instances ei
ON o.instance_id = ei.instance_id

JOIN events e
ON ei.event_id = e.event_id

JOIN payments p
ON o.order_id = p.order_id

WHERE u.user_id = 10;


SELECT 

e.event_id,

e.event_name,

SUM(p.amount) AS total_revenue

FROM payments p

JOIN orders o
ON p.order_id = o.order_id

JOIN event_instances ei
ON o.instance_id = ei.instance_id

JOIN events e
ON ei.event_id = e.event_id

WHERE p.payment_status = 'PAID'

GROUP BY 

e.event_id,
e.event_name

ORDER BY total_revenue DESC;

