


alter VIEW [dbo].[PAYMENT_VOUCHER]
AS

select ovpm."DocNum", ovpm."DocEntry", 									
Case When ovpm.Series=-1 then 'Manual' Else nnm1.SeriesName End +'/'+cast(ovpm.DocNum as varchar(20))  "VoucherNo",	


ovpm."DocDate",									
ovpm."Address",oact."FormatCode" as "Account",vpm4."AcctName",vpm4."Project",									
(select "PrjName" from OPRJ where "PrjCode"=vpm4."Project") "ProjectName",																	
null as "EmpName",ovpm."CardName",									
vpm4."Descrip",									
CASE WHEN ovpm."DocCurr"='INR' THEN vpm4."SumApplied" ELSE vpm4."AppliedFC" END "SumApplied",									
CASE WHEN ovpm."DocCurr"='INR' THEN ovpm."CashSum" ELSE ovpm."CashSumFC" END as "CashSum",									
CASE WHEN ovpm."DocCurr"='INR' THEN ovpm."CheckSum" ELSE ovpm."CheckSumFC" END as "CheckSum",									
CASE WHEN ovpm."DocCurr"='INR' THEN ovpm."TrsfrSum" ELSE ovpm."TrsfrSumFC" END as "Bnksum",									
"vpm1"."CheckNum",(select "BankName" from odsc where "vpm1"."BankCode"=odsc."BankCode") as "BankName",									
"vpm1"."DueDate" as "ChqDate","vpm1"."CheckAct",									
"vpm1"."CheckSum" as "CheckAmt",
OACT."FormatCode" As "ActCode",									
ocrn."CurrCode", 									
ocrn."F100Name" "HUNDRETH NAME" 
,ocrn."frgnname" " hundredth"
								
,ocrn."CurrName" "CURRENCY NAME",									
ovpm."Comments",									
bkcode."FormatCode" As "BnkTrsFrAcct",									
chAcc."FormatCode" As "CashAct",									
chAcc."AcctName" As "CashName",									
bkcode."AcctName" As "BankNm"		
,(CASE WHEN ovpm."DocCurr"='INR' THEN ovpm."BcgSum" ELSE ovpm."BcgSumFC" end) "Bank Charges"

from ovpm 									
left join (select "DocNum","CheckNum","CheckAct","DueDate","CheckSum","BankCode" from vpm1 where "LineID"=0) "vpm1" 									
on ovpm."DocEntry"="vpm1"."DocNum"									
left join vpm4 on ovpm."DocEntry"=vpm4."DocNum"									
left join oact on vpm4."AcctCode"=oact."AcctCode"									
left join OACT chAcc on ovpm."CashAcct"=chAcc."AcctCode"	--For Bank Trsfr A/c (OACT)Accounts Detail								
left join OACT bkcode on ovpm."TrsfrAcct"=bkcode."AcctCode"	--For Cash A/c (OACT)Accounts Detail								
left join nnm1 on ovpm."Series"=nnm1."Series"									
Left Join ocrn on ovpm."DocCurr"=ocrn."CurrCode"	

