IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='RECEIPT_VOUCHER')
DROP VIEW RECEIPT_VOUCHER
GO



CREATE VIEW RECEIPT_VOUCHER
AS

select orct."DocNum", orct."DocEntry", 									
case when orct."Series"=-1 then 'Manual' Else nnm1."SeriesName" End+'/'+cast(orct."DocNum" as varchar(20)) as "VoucherNo",									
orct."DocDate",									
orct."Address",oact."FormatCode" as "Account",rct4."AcctName",rct4."Project",									
(select "PrjName" from OPRJ where "PrjCode"=rct4."Project") "ProjectName",																	
null as "EmpName",orct."CardName",									
rct4."Descrip",									
CASE WHEN ORCT."DocCurr"='INR' THEN RCT4."SumApplied" ELSE RCT4."AppliedFC" END "SumApplied",									
CASE WHEN ORCT."DocCurr"='INR' THEN ORCT."CashSum" ELSE ORCT."CashSumFC" END as "CashSum",									
CASE WHEN ORCT."DocCurr"='INR' THEN ORCT."CheckSum" ELSE ORCT."CheckSumFC" END as "CheckSum",									
CASE WHEN ORCT."DocCurr"='INR' THEN ORCT."TrsfrSum" ELSE ORCT."TrsfrSumFC" END as "Bnksum",									
"rct1"."CheckNum",(select "BankName" from odsc where "rct1"."BankCode"=odsc."BankCode") as "BankName",									
"rct1"."DueDate" as "ChqDate","rct1"."CheckAct",									
"rct1"."CheckSum" as "CheckAmt",
OACT."FormatCode" As "ActCode",									
ocrn."CurrCode", 									
ocrn."F100Name" "HUNDRETH NAME", 									
ocrn."CurrName" "CURRENCY NAME",									
ORCT."Comments",									
bkcode."FormatCode" As "BnkTrsFrAcct",									
chAcc."FormatCode" As "CashAct",									
chAcc."AcctName" As "CashName",									
bkcode."AcctName" As "BankNm"		
,(CASE WHEN orct."DocCurr"='INR' THEN orct."BcgSum" ELSE orct."BcgSumFC" end) "Bank Charges"
from orct 									
left join (select "DocNum","CheckNum","CheckAct","DueDate","CheckSum","BankCode" from rct1 where "LineID"=0) "rct1" 									
on orct."DocEntry"="rct1"."DocNum"									
left join rct4 on orct."DocEntry"=rct4."DocNum"									
left join oact on rct4."AcctCode"=oact."AcctCode"									
left join OACT chAcc on ORCT."CashAcct"=chAcc."AcctCode"	--For Bank Trsfr A/c (OACT)Accounts Detail								
left join OACT bkcode on ORCT."TrsfrAcct"=bkcode."AcctCode"	--For Cash A/c (OACT)Accounts Detail								
left join nnm1 on orct."Series"=nnm1."Series"									
Left Join ocrn									
on orct."DocCurr"=ocrn."CurrCode"									



