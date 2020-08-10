IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='PAYMENT_VOUCHER_CHEQUE')
DROP VIEW PAYMENT_VOUCHER_CHEQUE
GO



create VIEW PAYMENT_VOUCHER_CHEQUE
AS

Select ACT.formatcode As 'ActCode',Case when VPM1.AcctNum is null then ACT.formatcode ELSE VPM1.AcctNum 		
END AS AcctNumber,*
From (select DocNum,AcctNum,U_chequeno 'checknum',checkAct,DueDate As 'duedate',[checksum] CheckAmt,		
		BankCode from vpm1) vpm1 
LEFT join (Select BankCode BankCode1,BankName from odsc) odsc on vpm1.BankCode=odsc.BankCode1		
LEFT Join OACT ACT On VPM1.CheckAct=ACT.AcctCode		
		



GO


