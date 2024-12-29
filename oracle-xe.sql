-- muestra que usuario esta logeado
show user;
-- me creo un usuario
alter session set "_ORACLE_SCRIPT"=true;
CREATE USER hospital IDENTIFIED BY hospital;
GRANT DBA TO hospital;