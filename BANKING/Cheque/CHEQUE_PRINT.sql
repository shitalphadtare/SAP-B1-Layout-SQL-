IF EXISTS(SELECT *
     FROM sys.views
     WHERE name = 'CHEQUE_PRINT' AND
     schema_id = SCHEMA_ID('dbo'))
DROP VIEW [dbo].[CHEQUE_PRINT]
GO



CREATE VIEW CHEQUE_PRINT
AS

select 
T1."DocType",
T1."DocNum"
,T1."DocEntry"
,case when t1.doctype ='s' or t1.DocType='c' then (CASE when T1."U_RTGS" = '' OR T1."U_RTGS" IS null then T1."CardName" else T1."U_RTGS" + '- ' + T1."CardName" end)
else t1.U_printname end "Pay To"
,T1."U_ChequeType" "ChequeType"
,T1."DocDate" "Dt of Issue"
,T2."CheckSum" "Cheque Amt"
,T2."AcctNum" "A/c No"
,(CASE when RIGHT (LEFT (right(T1."DocDate",23),5),1) = '' then '0' else RIGHT (LEFT (right(T1."DocDate",23),5),1) end) "Dt1"
,(CASE when RIGHT (LEFT (right(T1."DocDate",23),6),1) = '' then '0' else RIGHT (LEFT (right(T1."DocDate",23),6),1) end) "Dt2"
,RIGHT (LEFT (right(T1."DocDate",23),8),1) "yr1"
,RIGHT (LEFT (right(T1."DocDate",23),9),1) "yr2"
,RIGHT (LEFT (right(T1."DocDate",23),10),1) "yr3"
,RIGHT (LEFT (right(T1."DocDate",23),11),1) "yr4"
,left( CONVERT(VARCHAR(10),T1."DocDate",101),1) "Mnth1"
,right(left( CONVERT(VARCHAR(10),T1."DocDate",101),2),1) "Mnth2"
from OVPM as T1
left outer join VPM1 as T2 on T1."DocEntry" = T2."DocNum"
where T1."DocType" = 'S' or T1."DocType" = 'C' or t1.doctype='A'

go