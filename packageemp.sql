create or replace package emp_pkg
is
   procedure pluscomm (prc number);
   function pourcjob(nomjob emp.job%type) return number;
   function  GET_DEPARTEMENT_YRS(numemp emp.empno%type) return number;
end emp_pkg;
/
create or replace package body emp_pkg
is
procedure pluscomm (prc number)
as
begin
     update emp set comm=comm+prc where comm is not null;
     for c1 in (select empno, sal, comm from emp where comm is not null)
     loop
           if c1.comm > c1.sal then
                update emp set sal=sal+0.5*c1.comm, comm=0.5*c1.comm
                where empno = c1.empno;                                
           end if;
     end loop;
end pluscomm;
function pourcjob(nomjob emp.job%type) return number
as
    totByjob number:=0;
    totglobal number:=0;
begin
    select sum(sal+nvl(comm,0)) into totByjob from emp where job=nomjob;
    select sum(sal+nvl(comm,0)) into totglobal from emp;
    if totByjob is  null then
        RAISE_APPLICATION_ERROR(-20001,'pas de nomjob');
    end if;
    return (totByjob/totglobal);
end pourcjob;
function  GET_DEPARTEMENT_YRS(numemp emp.empno%type) 
return number
as
  nbannee number:=0;
begin
      select months_between(sysdate, hiredate)/12 into nbannee 
      from emp where empno=numemp;
      return nbannee;
end  GET_DEPARTEMENT_YRS;
end emp_pkg;
/

begin 
 emp_pkg.pluscomm(&prc);  -- test procedure
 dbms_output.put_line('pourc job est: ' || round(emp_pkg.pourcjob('&job'),2)*100||'%');
 dbms_output.put_line('Nbre anciennete employe: ' ||  trunc(emp_pkg.GET_DEPARTEMENT_YRS(&empno))); 
end;
/