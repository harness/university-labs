-- CREATE TABLE IF NOT EXISTS `user` (
--   `user_id` int AUTO_INCREMENT  PRIMARY KEY,
--   `name` varchar(100) NOT NULL,
--   `email` varchar(100) NOT NULL,
--   `phone` varchar(20) NOT NULL,
--   `created_at` date NOT NULL,
--   `created_by` varchar(20) NOT NULL,
--   `updated_at` date DEFAULT NULL,
--   `updated_by` varchar(20) DEFAULT NULL
-- );

INSERT INTO USER_ENTITY (name, email, phone, created_at, created_by) VALUES ('Jane Doe', 'jane.doe@example.com', '(919)-345-2121', now(), 'startup');
INSERT INTO USER_ENTITY (name, email, phone, created_at, created_by) VALUES ('Dawson Smith', 'dawson.smith@example.com', '(872)-232-5423', now(), 'startup');
INSERT INTO USER_ENTITY (name, email, phone, created_at, created_by) VALUES ('Robert Sholes', 'robert.sholes@example.com', '(355)-237-6764', now(), 'startup');
INSERT INTO USER_ENTITY (name, email, phone, created_at, created_by) VALUES ('Kate Yang', 'kate.yang@example.com', '(655)-454-1216', now(), 'startup');
INSERT INTO USER_ENTITY (name, email, phone, created_at, created_by) VALUES ('Andrew Nelson', 'andrew.nelson@example.com', '(472)-121-9090', now(), 'startup');