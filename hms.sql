CREATE DATABASE HMS;

USE HMS;

-- Patients table-- 
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    address VARCHAR(255),
    phone_number VARCHAR(15),
    email VARCHAR(100)
);

-- Doctors table
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialization VARCHAR(100),
    address VARCHAR(255),
    phone_number VARCHAR(15),
    email VARCHAR(100)
);

-- Appointments table
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    appointment_time TIME,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Medical Records table
CREATE TABLE Medical_Records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    date DATE,
    diagnosis VARCHAR(255),
    treatment VARCHAR(255),
    prescription VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Billing table
CREATE TABLE Billing (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    date DATE,
    total_amount DECIMAL(10, 2),
    payment_status ENUM('Pending', 'Paid'),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Rooms table
CREATE TABLE Rooms (
    room_number INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50),
    status ENUM('Occupied', 'Vacant')
);

-- Admissions table
CREATE TABLE Admissions (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    room_number INT,
    admission_date DATE,
    discharge_date DATE,
    reason_for_admission VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (room_number) REFERENCES Rooms(room_number)
);

SHOW TABLES;

-- Insert data into Appointments table
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time)
VALUES (1, 1, '2024-02-21', '10:00:00');

-- Insert data into Billing table
INSERT INTO Billing (patient_id, doctor_id, date, total_amount, payment_status)
VALUES (1, 1, '2024-02-21', 100.00, 'Pending');

-- Insert data into Rooms table
INSERT INTO Rooms (type, status)
VALUES ('Private', 'Vacant');

-- Insert data into Admissions table
INSERT INTO Admissions (patient_id, room_number, admission_date, discharge_date, reason_for_admission)
VALUES (1, 1, '2024-02-21', '2024-02-25', 'High fever');

-- - 1 Write necessary queries to register new user roles and personas

-- Registering a new patient
INSERT INTO Patients (first_name, last_name, date_of_birth, gender, address, phone_number, email)
VALUES ('Deepak', 'Mishra', '2003-09-02', 'Male', 'Mharal, Kalyan', '125-678-9012', 'deepakmishra@gmail.com');

-- Registering a new doctor
INSERT INTO Doctors (first_name, last_name, specialization, address, phone_number, email)
VALUES ('Dr. Satyam', '', 'Mishra', 'Varap, Kalyan', '987-654-3210', 'satyammishra@gmail.com');

SELECT * FROM Doctors;

-- - 2 Write necessary queries to add to the list of diagnosis of the patient tagged by date.

INSERT INTO Medical_Records (patient_id, doctor_id, date, diagnosis, treatment, prescription)
VALUES (1, 1, '2024-02-21', 'Fever', 'Rest and fluids', 'Paracetamol');

SELECT * FROM Medical_Records;

-- - 3 Write necessary queries to fetch required details of a particular patient.

SELECT * FROM Patients WHERE patient_id = 1;

-- - 4 Write necessary queries to prepare bill for the patient at the end of checkout.

SELECT patient_id, SUM(total_amount) AS total_bill FROM Billing WHERE patient_id = 1;

-- - 5 Write necessary queries to fetch and show data from various related tables (Joins)

SELECT p.*, a.appointment_date, a.appointment_time 
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id
WHERE p.patient_id = 1;

-- - 6 Optimize repeated read operations using views/materialized views.

CREATE VIEW Patient_Appointment_Details AS
SELECT p.*, a.appointment_date, a.appointment_time 
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id;

SELECT * FROM Patient_Appointment_Details;

-- - 7 Optimize read operations using indexing wherever required. (Create index on at least 1 table)

CREATE INDEX idx_patient_id ON Patients(patient_id);

SELECT * FROM Patients;

-- - 8 Try optimizing bill generation using stored procedures.

DELIMITER //
CREATE PROCEDURE Generate_Bill(IN patient_id INT)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(total_amount) INTO total FROM Billing WHERE patient_id = patient_id;
    SELECT total;
END //
DELIMITER ;

CALL Generate_Bill(1);

-- - 9 Add necessary triggers to indicate when patients medical insurance limit has expired.

DELIMITER //
CREATE TRIGGER Insurance_Expiration
BEFORE INSERT ON Admissions
FOR EACH ROW
BEGIN
    IF NEW.admission_date < DATE_SUB(NOW(), INTERVAL 1 YEAR) THEN
 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient\'s medical insurance limit has expired';
    END IF;
END //
DELIMITER ;

INSERT INTO Admissions (patient_id, room_number, admission_date, discharge_date, reason_for_admission)
VALUES (2, 2, '2022-01-01', '2022-01-05', 'Routine checkup');


