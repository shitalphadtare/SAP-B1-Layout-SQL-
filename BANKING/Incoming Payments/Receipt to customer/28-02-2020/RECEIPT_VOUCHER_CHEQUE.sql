create VIEW [dbo].[RECEIPT_VOUCHER_CHEQUE]
AS

Select ACT."FormatCode" As "ActCode",									
		Case when "RCT1"."AcctNum" is null then ACT."FormatCode" ELSE "RCT1"."AcctNum" END AS "AcctNumber"
	,"RCT1"."DocNum","RCT1"."CheckAmt","RCT1"."CheckNum","RCT1"."duedate","odsc"."BankName",
	"RCT1"."BankCode",ACT."AcctName", "RCT1"."CheckAct"	,rct1.currency 'currcode'					
From (select "DocNum","AcctNum","CheckNum","CheckAct","DueDate" "duedate","CheckSum" "CheckAmt",									
		"BankCode",currency from RCT1)"RCT1" 							
LEFT join (Select "BankCode" "BankCode1","BankName" from odsc) "odsc" on "RCT1"."BankCode"="odsc"."BankCode1"									
LEFT Join OACT ACT On "RCT1"."CheckAct"=ACT."AcctCode"									
							
									
			



