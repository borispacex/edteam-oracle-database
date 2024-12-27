SELECT * FROM audit_patients;

-- Manejo de TRIGGERS
-- Ejemplo1
-- Crear un TRIGGER que permita validar si una edad es correcta.
-- Caso contrario generar un EXCEPTION-ERROR.

CREATE OR REPLACE TRIGGER tr_validate_age
    BEFORE INSERT ON PATIENTS
    FOR EACH ROW
    DECLARE
        age_value NUMBER := 0;
    BEGIN
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(:NEW.PATIENT_DATE_OF_BIRTH)) / 12)
        INTO age_value FROM DUAL;

        if age_value != :NEW.PATIENTS_AGE
        then
            RAISE_APPLICATION_ERROR(-20001, 'El valor de la edad es incorrecto!!!');
        end if;
    END;
/

declare
    new_ID NUMBER := 1;
begin
    patients_row_create(new_ID, 'm', DATE '2000-06-10', 'William3', 'Barra3', 160, 200, '76531214', 210);
end;

SELECT * FROM PATIENTS;

-- Ejemplo 2
-- Crear un TRIGGER de auditoria para la tabla DOCTORS
SELECT * FROM DOCTORS;

SELECT USER FROM DUAL;
SELECT sys_context('USERENV', 'SERVER_HOST') FROM DUAL;
SELECT to_char(SYSDATE) FROM DUAL;

CREATE TABLE audit_doctors
(
    USER_NAME       VARCHAR2(25),
    SERVER_HOST     VARCHAR2(25),
    DATE_ACTION     VARCHAR2(25),
    EVENT_NAME      VARCHAR2(25),
    DOCTOR_NAME     VARCHAR2(25),
    DOCTOR_LASTNAME VARCHAR2(25)
);

SELECT USER FROM DUAL;
SELECT sys_context('USERENV', 'SERVER_HOST') FROM DUAL;
SELECT to_char(SYSDATE) FROM DUAL;

CREATE OR REPLACE TRIGGER tr_audit_doctors
    BEFORE UPDATE OR DELETE ON DOCTORS
    FOR EACH ROW
    DECLARE
        user_name_value VARCHAR2(25);
        server_host_value VARCHAR2(25);
        sys_date_value VARCHAR2(25);
        event_name VARCHAR2(25);
    BEGIN
        SELECT USER INTO user_name_value FROM DUAL;
        SELECT sys_context('USERENV', 'SERVER_HOST') INTO server_host_value FROM DUAL;
        SELECT to_char(SYSDATE) INTO sys_date_value FROM DUAL;

        event_name := CASE
            WHEN DELETING THEN 'DELETE'
            WHEN UPDATING THEN 'UPDATE'
        END;

        INSERT INTO audit_doctors (USER_NAME, SERVER_HOST, DATE_ACTION, EVENT_NAME, DOCTOR_NAME, DOCTOR_LASTNAME)
        VALUES (user_name_value, server_host_value, sys_date_value, event_name, :OLD.DOCTOR_NAME, :OLD.DOCTOR_LASTNAME);

    END;
/

SELECT * FROM audit_doctors;
SELECT * FROM DOCTORS;

INSERT INTO DOCTORS (DOCTOR_NAME, DOCTOR_LASTNAME, DOCTOR_DATE_OF_BIRTH, DOCTOR_AGE) VALUES
    ('Juan', 'Misael', DATE '1975-12-10', 38);

UPDATE DOCTORS SET DOCTOR_NAME = 'Yuan' WHERE STAFF_ID = 70;
DELETE doctors WHERE staff_id = 70;

-- EJERCICIO FINAl
-- Crear un TRIGGER que use una función en su lógica.
-- Podría crear una función que valide si la edad es correcta. De ser correcta retorna 1 caso contrario retorna 0.

CREATE FUNCTION fn_validate_correct_age(
        DATE_OF_BIRTH IN VARCHAR2,
        AGE_DATA IN NUMBER
    )
    RETURN NUMBER
    AS
        age_value NUMBER := 0;
        response NUMBER := 0;
    BEGIN
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(DATE_OF_BIRTH)) / 12)
        INTO age_value FROM DUAL;

        if age_value = AGE_DATA then
            response := 1;
        end if;

        RETURN response;
    END;
/

CREATE OR REPLACE TRIGGER tr_validate_age_v2
    BEFORE INSERT ON PATIENTS
    FOR EACH ROW
    BEGIN
        if fn_validate_correct_age(:NEW.PATIENT_DATE_OF_BIRTH, :NEW.PATIENTS_AGE) = 0
        then
            RAISE_APPLICATION_ERROR(-20001, 'El valor de la edad es incorrecto!!!');
        end if;
    END;
/

declare
    new_ID NUMBER := 1;
begin
    patients_row_create(new_ID, 'm', DATE '2000-06-10', 'William5', 'Barra5', 160, 200, '76531214', 21);
end;

SELECT * FROM PATIENTS;





























