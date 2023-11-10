
CREATE TABLE Orders (
    order_id NUMBER PRIMARY KEY,
    pickup_coordinates VARCHAR2(50),
    order_timestamp TIMESTAMP
);


CREATE TABLE Drivers (
    driver_id NUMBER PRIMARY KEY,
    current_location VARCHAR2(50),
    availability_status VARCHAR2(20),
    created_at TIMESTAMP 
);

------------------------------------------------------

INSERT INTO orders VALUES  (1, '43.238949, 76.889709', TO_TIMESTAMP('2023-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (2, '43.252071, 76.946486', TO_TIMESTAMP('2023-11-02 10:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (3, '43.237195, 76.853650', TO_TIMESTAMP('2023-11-02 14:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (4, '43.221582, 76.837492', TO_TIMESTAMP('2023-11-03 09:20:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (5, '43.229798, 76.906518', TO_TIMESTAMP('2023-11-04 12:10:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (6, '43.238949, 76.889709', TO_TIMESTAMP('2023-11-05 14:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (7, '43.237195, 76.853650', TO_TIMESTAMP('2023-11-06 10:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (8, '43.229798, 76.906518', TO_TIMESTAMP('2023-11-07 08:20:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (9, '43.221582, 76.837492', TO_TIMESTAMP('2023-11-08 16:10:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO orders VALUES  (10, '43.252071, 76.946486', TO_TIMESTAMP('2023-11-09 12:45:00', 'YYYY-MM-DD HH24:MI:SS'));


INSERT INTO drivers VALUES (101, '43.238949, 76.889709', 'Available', TO_TIMESTAMP('2023-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (102, '43.252071, 76.946486', 'Available', TO_TIMESTAMP('2023-11-02 10:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (103, '43.252071, 76.946486', 'Unavailable', TO_TIMESTAMP('2023-11-03 14:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (104, '43.237195, 76.853650', 'Available', TO_TIMESTAMP('2023-11-04 11:20:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (105, '43.221582, 76.837492', 'Available', TO_TIMESTAMP('2023-11-05 09:35:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (106, '43.238949, 76.889709', 'Available', TO_TIMESTAMP('2023-11-06 12:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (107, '43.229798, 76.906518', 'Unavailable', TO_TIMESTAMP('2023-11-07 16:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (108, '43.237195, 76.853650', 'Available', TO_TIMESTAMP('2023-11-08 13:25:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (109, '43.221582, 76.837492', 'Available', TO_TIMESTAMP('2023-11-09 10:10:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO drivers VALUES (110, '43.252071, 76.946486', 'Unavailable', TO_TIMESTAMP('2023-11-10 14:55:00', 'YYYY-MM-DD HH24:MI:SS'));

---------------------------------------------------------------------

SELECT 
    o.order_id, 
    o.pickup_coordinates,
    CASE
        WHEN o.orders_count_daily > d.drivers_count_daily THEN 'Высокая дневная наценка – Водители доступны'
        WHEN o.orders_count_daily < d.drivers_count_daily THEN 
            CASE
                WHEN d.unavailable_drivers_count_daily = 0 THEN 'Высокая дневная наценка – Нужно привлечь недоступных водителей'
                ELSE 'Низкая дневная наценка – Нужно привлечь недоступных водителей'
            END
        ELSE 'Стандартная дневная наценка'
    END AS daily_markup_strategy,
    CASE
        WHEN o.orders_count_weekly > d.drivers_count_weekly THEN 'Высокая еженедельная наценка – Водители доступны'
        WHEN o.orders_count_weekly < d.drivers_count_weekly THEN 
            CASE
                WHEN d.unavailable_drivers_count_weekly = 0 THEN 'Высокая еженедельная наценка - Нужно привлечь недоступных водителей'
                ELSE 'Низкая еженедельная наценка - Нужно привлечь недоступных водителей'
            END
        ELSE 'Стандартная еженедельная наценка'
    END AS weekly_markup_strategy
FROM (
    SELECT 
        order_id,
        pickup_coordinates,
        COUNT(CASE WHEN order_timestamp > SYSDATE - 1 THEN 1 END) AS orders_count_daily,
        COUNT(CASE WHEN order_timestamp > SYSDATE - 7 THEN 1 END) AS orders_count_weekly
    FROM Orders
    GROUP BY order_id, pickup_coordinates
) o
LEFT JOIN (
    SELECT 
        current_location,
        COUNT(CASE WHEN availability_status = 'Available' AND created_at > SYSDATE - 1 THEN 1 END) AS drivers_count_daily,
        COUNT(CASE WHEN availability_status = 'Available' AND created_at > SYSDATE - 7 THEN 1 END) AS drivers_count_weekly,
        COUNT(CASE WHEN availability_status = 'Unavailable' AND created_at > SYSDATE - 1 THEN 1 END) AS unavailable_drivers_count_daily,
        COUNT(CASE WHEN availability_status = 'Unavailable' AND created_at > SYSDATE - 7 THEN 1 END) AS unavailable_drivers_count_weekly
    FROM Drivers
    GROUP BY current_location
) d ON o.pickup_coordinates = d.current_location
ORDER BY 1

