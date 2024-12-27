-- Manejo de SP

-- EJEMPLO 1
-- Crear una SP que me permita generar todos los valores de una nueva columna.
-- Agregar el campo patients_age en la tabla PATIENTS y generar todos sus valores desde un procedimiento almacenado

SELECT SYSDATE FROM DUAL;
SELECT TO_DATE(SYSDATE, 'YY-MM-DD') FROM DUAL;
SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE('2000-06-10', 'YY-MM-DD')) / 12) FROM DUAL;

ALTER TABLE PATIENTS ADD PATIENTS_AGE INTEGER;

CREATE PROCEDURE generate_age
    AS
        CURSOR cursor_patients IS SELECT * FROM PATIENTS;
        fila cursor_patients%ROWTYPE;
        age_value INTEGER;
    BEGIN

        FOR fila IN cursor_patients
            loop
                SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(fila.PATIENT_DATE_OF_BIRTH)) / 12)
                INTO age_value FROM DUAL;

                UPDATE PATIENTS SET PATIENTS.PATIENTS_AGE = age_value WHERE PATIENT_ID = fila.PATIENT_ID;
            end loop;

    END;
/

-- EXECUTE generate_age;
begin
  generate_age;
end;

-- EJEMPLO 2
-- Crear una SP que me permita insertar nuevos registros.
-- El SP debe ser capaz de insertar nuevos registros a la tabla PATIENTS.

CREATE OR REPLACE PROCEDURE patients_row_create(
    ID IN OUT INTEGER,
    GENDER IN CHAR,
    DATE_OF_BIRTH IN DATE,
    NAME IN VARCHAR2,
    LASTNAME IN VARCHAR2,
    HEIGHT IN NUMBER,
    WEIGHT IN NUMBER,
    CELLPHONE IN VARCHAR2,
    AGE IN NUMBER
    )
    AS
        validate_id NUMBER;
    BEGIN
        SELECT COUNT(pa.PATIENT_ID) INTO validate_id
        FROM PATIENTS pa
        WHERE pa.PATIENT_ID = ID;

        if validate_id > 0 then
            SELECT MAX(pa.PATIENT_ID) INTO ID
            FROM PATIENTS pa;
            ID := ID + 1;
        end if;

        insert into PATIENTS (PATIENT_GENDER, PATIENT_DATE_OF_BIRTH, PATIENT_NAME,
                              PATIENT_LASTNAME, PATIENT_HEIGHT, PATIENT_WEIGHT,
                              PATIENT_CELLPHONE, PATIENTS_AGE) VALUES
            (GENDER, DATE_OF_BIRTH, NAME, LASTNAME, HEIGHT, WEIGHT, CELLPHONE, AGE);
    END;
/

declare
    new_ID NUMBER := 1;
begin
    patients_row_create(new_ID, 'm', DATE '2001-06-10', 'William2', 'Barra2', 160, 200, '76531214', 50);
end;

SELECT * FROM PATIENTS;

-- Crear una SP que me permita insertar nuevos registros.
-- El SP debe ser capaz de insertar nuevos registros a la tabla de auditoría de patients.

SELECT USER FROM DUAL;
SELECT sys_context('USERENV', 'SERVER_HOST') FROM DUAL;
SELECT to_char(SYSDATE) FROM DUAL;

CREATE TABLE audit_patients
(
    USER_NAME VARCHAR2(20),
    HOST_NAME VARCHAR2(20),
    SYS_DATE VARCHAR2(15),
    PATIENT_NAME          VARCHAR2(25),
    PATIENT_LASTNAME      VARCHAR2(25)
);

CREATE OR REPLACE PROCEDURE insert_data_to_audit_table
    AS
        user_name_value VARCHAR2(25);
        host_name_value VARCHAR2(25);
        sys_date_value VARCHAR2(25);
        sql_string VARCHAR2(800);
    BEGIN
        SELECT USER INTO user_name_value FROM DUAL;
        SELECT sys_context('USERENV', 'SERVER_HOST') INTO host_name_value FROM DUAL;
        SELECT to_char(SYSDATE) INTO sys_date_value FROM DUAL;

        sql_string := 'INSERT INTO audit_patients(USER_NAME, HOST_NAME, SYS_DATE, PATIENT_NAME, PATIENT_LASTNAME) ';
        sql_string := sql_string || 'VALUES (:1, :2, :3, :4, :5)';

        EXECUTE IMMEDIATE sql_string USING user_name_value, host_name_value, sys_date_value, 'William2', 'Barra2';

    END;
/

begin
    insert_data_to_audit_table;
end;

SELECT * FROM audit_patients;