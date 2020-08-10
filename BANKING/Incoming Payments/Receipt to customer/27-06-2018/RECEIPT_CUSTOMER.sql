IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='RECEIPT_CUSTOMER')
DROP VIEW RECEIPT_CUSTOMER
GO

CREATE VIEW RECEIPT_CUSTOMER
AS

select RCT2."InvType",
ORCT."DocCurr",orct."DocNum", 
orct."DocEntry",
case when orct."Series"=-1 then 'Manual' Else ser1."SeriesName" End+'/'+cast(orct."DocNum" as varchar(20)) as "DocumentNo",									
orct."DocDate" as "DocDate",ORCT."DocType", 																		
orct."Address", rct1."CheckNum", rct1."CheckAct",									
(select "BankName" from odsc where rct1."BankCode"=odsc."BankCode") "BankName",									
rct1."DueDate" as "ChqDate",rct1."CheckSum" as "CheckAmt",									
(select "PrjName" from OPRJ where "PrjCode"=orct."PrjCode") "ProjectName",									
ser2."SeriesName"+'/'+cast("A"."DocNum" as varchar(30)) as "InvoiceNo",									
"A"."DocDate" as "InvDate",															
CASE WHEN RCT2."InvType" IN (30,24) THEN (Case when ORCT."DocCurr"='INR' THEN RCT2."SumApplied" ELSE RCT2."AppliedFC" END)									
ELSE "A"."DocTotal" END AS "InvTotal",									
"A"."WTSum" as "WTaxAmount", "A"."VatSum" as "Tax", "A"."TotalExpns" as "Freight","A"."NumAtCard",										
ORCT."CardCode",ORCT."CardName",									
Case When rct2."InvType"=14 then (-1)*("A"."DocTotal"+"A"."WTSum") 									
     Else("A"."DocTotal"+"A"."WTSum") End as "Gross","A"."WTSum" as "TDS",									
Case When rct2."InvType"=14 then (-1)*rct2."SumApplied" Else rct2."SumApplied" End as "Net",									
rct2."SumApplied" as "InvPaidAmt"
,Case WHEN ORCT."DocCurr"='INR' THEN orct."DocTotal" ELSE ORCT."DocTotalFC" END AS "orct_Doctotal",									
orct."PayNoDoc", CASE WHEN ORCT."DocCurr"='INR' THEN orct."NoDocSum" ELSE orct."NoDocSumFC" END As "NoDocSum"  ,
 "A"."DocNum" "docnum1", orin."DocNum" "docnum2",									
ojdt."TransId", ser2."SeriesName", rct2."DocNum" "rct2_DocNum", rct2."InvoiceId", ojdt."BaseRef", 									
ocrn."CurrCode",ocrn."F100Name" "HUNDRETH NAME",ocrn."CurrName" "CURRENCY NAME", orct."Comments"									
,RCT4."AcctCode" ,RCT4."AcctName",RCT4."SumApplied" as "AcctSum",									
CASE WHEN ORCT."DocCurr"='INR' THEN ORCT."CashSum" ELSE ORCT."CashSumFC" END as "CashSum",									
CASE WHEN ORCT."DocCurr"='INR' THEN ORCT."CheckSum" ELSE ORCT."CheckSumFC" END as "CheckSum",									
CASE WHEN ORCT."DocCurr"='INR' THEN ORCT."TrsfrSum" ELSE ORCT."TrsfrSumFC" END as "Bnksum",									
ACT3."FormatCode" As "CashAct",ACT2."FormatCode" As "BnkTrsFrAcct",ACT2."AcctName" As "BankNm",
ACT3."AcctName" As "CashName"									
,(CASE WHEN orct."DocCurr"='INR' THEN orct."BcgSum" ELSE orct."BcgSumFC" end) "Bank Charges"
									
from orct 									
left join rct2 on orct."DocEntry"=rct2."DocNum" 									
LEFT JOIN RCT4 ON ORCT."DocEntry"=RCT4."DocNum"									
left join 									
(									
select "DocNum","DocEntry","DocDate","CardCode","CardName","Series","ObjType",Case when "DocCur"='INR' THEN "DocTotal" else "DocTotalFC" end as "DocTotal"
,"WTSum","VatSum","TotalExpns","NumAtCard" from oinv --where "DocEntry" IN (438,439)									
union all									
select "DocNum","DocEntry","DocDate","CardCode","CardName","Series","ObjType",Case WHEN "DocCur"='INR' THEN (-1)*"DocTotal" ELSE (-1)*"DocTotalFC" end as "DocTotal","WTSum","VatSum",									
"TotalExpns","NumAtCard" from orin									
union all									
select "Number" "DocNum","TransId" "DocEntry","RefDate",NULL "CardCode",NULL "CardName","Series","TransType",null "DocTotal",									
null "WTSum",null "VatSum",null "TotalExpns","BaseRef" from ojdt where "TransType" IN (30,24)									
) "A"									
on rct2."DocEntry"="A"."DocEntry" and rct2."InvType"="A"."ObjType"									
left join orin on rct2."DocEntry"=orin."DocEntry" and rct2."InvType"=orin."ObjType"									
left join ojdt on rct2."DocEntry"=ojdt."TransId" and rct2."InvType"=ojdt."TransType"																		
left  join nnm1 ser1 on orct."Series"=ser1."Series" 									
left join nnm1 ser2 on "A"."Series"=ser2."Series"									
left join (Select * from rct1 where "LineID"=0) rct1 on orct."DocEntry"=rct1."DocNum"									
Left Join ocrn on orct."DocCurr"=ocrn."CurrCode"									
left join OACT ACT2 on orct."TrsfrAcct"=ACT2."AcctCode"	--For Bank Trsfr A/c (OACT)Accounts Detail								
left join OACT ACT3 on orct."CashAcct"=ACT3."AcctCode"	--For Cash A/c (OACT)Accounts Detail