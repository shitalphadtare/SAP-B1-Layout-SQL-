IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='PAYMENT_VOUCHER')
DROP VIEW PAYMENT_VOUCHER
GO


Create VIEW PAYMENT_VOUCHER
AS

select		
	ovpm.docnum,	
	ovpm.DocEntry, 	
	Case When ovpm.Series=-1 then 'Manual' Else nnm1.SeriesName End +'/'+cast(ovpm.DocNum as varchar(20)) as VoucherNo,	
	ovpm.DocDate,/*vpm4.AcctCode,*/	
	ovpm.Address,	
		
	CASE WHEN OVPM.DocCurr='INR' THEN OVPM.CashSum ELSE OVPM.CashSumFC END as CashSum,	
	CASE WHEN OVPM.DocCurr='INR' THEN OVPM.CheckSum ELSE OVPM.CheckSumFC END as CheckSum,	
	CASE WHEN OVPM.DocCurr='INR' THEN OVPM.trsfrsum ELSE OVPM.trsfrsumfc END as Bnksum,	
	--OVPM.CheckSum,	
	OVPM.TrsfrRef As 'BnkTrsFrRef',	
	OVPM.TrsfrDate As 'BnkTrsFrDt',	
	ACT2.formatcode As 'BnkTrsFrAcct',	
	ACT2.AcctName As 'BankNm',	
	ACT3.Formatcode As 'CashAct',	
	ACT3.formatcode As 'CashActCode',	
	ACT3.AcctName As 'CashName',	
	oact.formatcode as Account,	
	vpm4.AcctName,	
	vpm4.Project,	
	(select PrjName from OPRJ where PrjCode=vpm4.Project) ProjectName,	
----ovpm.U_Emp,vpm4.U_Emp,		
----Emp1.[Name],Emp2.[Name],		
----(select case 		
----when Emp2.[Name] is null or Emp2.[Name]='' then 		
----Emp1.[Name] 		
----Else [Emp2].[Name] end) as EmpName,		
	null as EmpName,	
	ovpm.CardName,	
	vpm4.Descrip,	
	CASE WHEN OVPM.DocCurr='INR' THEN VPM4.SumApplied ELSE VPM4.AppliedFC END SumApplied,	
	vpm1.checknum,	
	(select BankName from odsc where vpm1.BankCode=odsc.BankCode) as BankName,	
	vpm1.duedate as ChqDate,	
	vpm1.CheckAct,	
	vpm1.[CheckSum] as CheckAmt,	
	OACT.formatcode As 'ActCode',	
	ocrn.CurrCode, 	
	ocrn.F100Name 'HUNDRETH NAME', 	
	ocrn.CurrName 'CURRENCY NAME',	
	OVPM.Comments,
		(CASE WHEN OVPM.DocCurr='INR' THEN OVPM.BcgSum ELSE ovpm.BcgSumFC end) 'Bank Charges'
	from ovpm 	
left join (select DocNum,checknum,checkAct,duedate,[checksum],BankCode from vpm1 where lineid=0) vpm1 		
on ovpm.docentry=vpm1.docnum		
left join vpm4 on ovpm.docentry=vpm4.docnum		
left join oact on vpm4.AcctCode=oact.AcctCode		
----left join [@Emp] Emp1 on ovpm.U_Emp=Emp1.Code		
----left join [@Emp] Emp2 on vpm4.U_emp=Emp2.Code		
left join nnm1 on ovpm.series=nnm1.series		
left outer join OACT ACT2 on oVPM.TrsfrAcct=ACT2.AcctCode	--For Bank Trsfr A/c (OACT)Accounts Detail	
left outer join OACT ACT3 on oVPM.CashAcct=ACT3.AcctCode	--For Cash A/c (OACT)Accounts Detail	
Left Join ocrn on ovpm.DocCurr=ocrn.CurrCode		
		


GO


