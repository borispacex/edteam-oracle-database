-- Crear una funcion que me permita saber el año actual

SELECT SYSDATE
FROM DUAL;
select to_char(sysdate, 'YYYY') from dual;

-- Solucion
CREATE FUNCTION get_current_year
    RETURN DATE IS
        current_year DATE;
    BEGIN
        SELECT SYSDATE INTO current_year
        FROM DUAL;

        return current_year;
    END;
/

SELECT get_current_year FROM DUAL;


-- Crear una funcion que me permita generar un reporte(nombres, apellidos y edad) de los doctores registrados.
-- El nombre y apellido debe ser concatenados en una sola columna.
SELECT CONCAT('William', CONCAT(' ', 'Barra')) FROM DUAL;

-- SOLUCION
CREATE OR REPLACE FUNCTION concat_name_and_lastname(
    par1 IN VARCHAR, par2 IN VARCHAR
)
    RETURN CLOB IS
        response CLOB := '';
    BEGIN
        SELECT CONCAT(par1, CONCAT(' ', par2)) INTO response
        FROM DUAL;
        RETURN response;
    END;

SELECT concat_name_and_lastname(doc.DOCTOR_NAME, doc.DOCTOR_LASTNAME) AS FULL_NAME
FROM DOCTORS doc;



-- Vemos cual es el formato de fecha
SELECT
  value
FROM
  V$NLS_PARAMETERS
WHERE
  parameter = 'NLS_DATE_FORMAT';

-- fmDD-MM-RR

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_DATE_FORMAT = 'fmDD-MM-RR';

SELECT TO_CHAR(TO_DATE('2000-06-10'), 'Day' )
FROM DUAL;

CREATE FUNCTION format_table_patients(fecha varchar)
    RETURN CLOB IS
        response CLOB := '';
        fec_nac DATE;
    BEGIN
        fec_nac := TO_DATE(fecha);
        SELECT TO_CHAR(fec_nac, 'Day' ) INTO response
        FROM DUAL;
        RETURN response;
    END;

CREATE OR REPLACE FUNCTION get_gender(gender varchar)
    return clob is
        response clob := '';
    begin
        case gender
            when 'f' THEN response := 'femenino';
            when 'm' THEN response := 'masculino';
        end case;
        return response;
    end;

SELECT pat.PATIENT_NAME,
       pat.PATIENT_LASTNAME,
       pat.PATIENT_DATE_OF_BIRTH,
       get_gender(pat.PATIENT_GENDER) AS GENDER,
       format_table_patients(pat.PATIENT_DATE_OF_BIRTH) AS DAY
FROM PATIENTS pat;



-- Clase final modulo 2
CREATE TYPE type_row_doctors AS OBJECT
(
  name VARCHAR(15),
  lastname VARCHAR(15),
  age INTEGER
);

CREATE TYPE type_table_doctors AS TABLE OF type_row_doctors;

CREATE FUNCTION get_report_doctors
  RETURN type_table_doctors AS
  BEGIN
    return type_table_doctors(
      type_row_doctors('William', 'Barra', 32),
      type_row_doctors('Micaela', 'mar', 24)
    );
  END;

SELECT get_report_doctors FROM DUAL; 
SELECT * FROM get_report_doctors;
SELECT * FROM TABLE (get_report_doctors);
SELECT info.name, info.lastname
FROM TABLE (get_report_doctors) info; 

CREATE OR REPLACE FUNCTION get_report_doctors_v2
  RETURN type_table_doctors IS
    data_table type_table_doctors := type_table_doctors();
  BEGIN
   data_table.extend;
   data_table(data_table.COUNT) := type_row_doctors('William', 'Barra', 32);

   data_table.extend;
   data_table(data_table.COUNT) := type_row_doctors('Micaela', 'mar', 24);

   RETURN data_table;
  END;

SELECT v2.*
FROM TABLE (get_report_doctors_v2) v2;

SELECT info.name, info.lastname, info.age
FROM TABLE (get_report_doctors_v2) info
WHERE info.age = 32;

