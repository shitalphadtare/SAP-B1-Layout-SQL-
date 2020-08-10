

CREATE VIEW [dbo].[PAYMENT_VOUCHER_CHEQUE]
AS

Select 
ocrn.CurrCode, 
ACT."FormatCode" As "ActCode",									
		Case when "vpm1"."AcctNum" is null then ACT."FormatCode" ELSE "vpm1"."AcctNum" END AS "AcctNumber"
	,"vpm1"."DocNum","vpm1"."CheckAmt","vpm1"."CheckNum","vpm1"."duedate","odsc"."BankName",
	"vpm1"."BankCode",ACT."AcctName", "vpm1"."CheckAct"						
From (select "DocNum","AcctNum","CheckNum","CheckAct","DueDate" "duedate","CheckSum" "CheckAmt",									
		"BankCode" from vpm1)"vpm1" 							
LEFT join (Select "BankCode" "BankCode1","BankName" from odsc) "odsc" on "vpm1"."BankCode"="odsc"."BankCode1"									
LEFT Join OACT ACT On "vpm1"."CheckAct"=ACT."AcctCode"
left outer join ovpm vpm on vpm.DocEntry=vpm1.DocNum									
Left Join ocrn on vpm.DocCurr=ocrn.CurrCode								









GO


