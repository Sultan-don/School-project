-- Update Period 1
UPDATE schedules SET time = '08:15 - 09:00' WHERE period = 1;

-- Update Period 2 (Break 10m -> 09:10 start)
UPDATE schedules SET time = '09:10 - 09:55' WHERE period = 2;

-- Update Period 3 (Break 10m -> 10:05 start)
UPDATE schedules SET time = '10:05 - 10:50' WHERE period = 3;

-- Update Period 4 (Big Break 20m -> 11:10 start)
UPDATE schedules SET time = '11:10 - 11:55' WHERE period = 4;

-- Update Period 5 (Break 10m -> 12:05 start)
UPDATE schedules SET time = '12:05 - 12:50' WHERE period = 5;

-- Update Period 6 (Break 10m -> 13:00 start)
UPDATE schedules SET time = '13:00 - 13:45' WHERE period = 6;

-- Update Period 7 (Break 10m -> 13:55 start)
UPDATE schedules SET time = '13:55 - 14:40' WHERE period = 7;

-- Update Period 8 (Break 10m -> 14:50 start)
UPDATE schedules SET time = '14:50 - 15:35' WHERE period = 8;
