
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='PAYMENT_VENDOR')
DROP VIEW PAYMENT_VENDOR
GO

create VIEW PAYMENT_VENDOR
AS

select ovpm.docnum, ovpm.DocEntry, 		
	case when ovpm.series=-1 then 'Manual' Else ser1.seriesname End +'/'+cast(ovpm.docnum as varchar(20)) as DocumentNo,	
	ovpm.docdate as DocDate,OVPM.DocType, 	
	
ovpm.address, vpm1.checknum, vpm1.CheckAct,		
(select BankName from odsc where vpm1.BankCode=odsc.BankCode) as BankName,		
vpm1.duedate as ChqDate,vpm1.[CheckSum] as CheckAmt,		
(select PrjName from OPRJ where PrjCode=ovpm.prjcode) ProjectName,		
(ser2.seriesname+'/'+cast(A.docnum as varchar(30)) )as InvoiceNo,		
A.docdate as InvDate,		
CASE WHEN VPM2.InvType IN (30,46) THEN (Case when OVPM.DocCurr='INR' THEN VPM2.SumApplied ELSE VPM2.AppliedFC END)		
ELSE A.DocTotal END AS InvTotal,		
	
A.wtsum as WTaxAmount, A.Vatsum as Tax, A.TotalExpns as Freight,A.NumAtCard,		
Case When vpm2.InvType=19 then (-1)*(A.DocTotal+A.wtsum) 		
     Else (A.DocTotal+A.wtsum) End as Gross,		
A.wtsum as TDS,		
OVPM.CardCode,OVPM.CardName,		
Case When vpm2.InvType=19 then (-1)*vpm2.SumApplied 		
	 Else vpm2.SumApplied End as Net,vpm2.SumApplied as InvPaidAmt,	
Case WHEN OVPM.DocCurr='INR'THEN OVPM.Doctotal ELSE OVPM.DocTotalFC END AS OVPM_Doctotal,		
		
ovpm.PayNoDoc, CASE WHEN OVPM.DocCurr='INR' THEN ovpm.NoDocSum ELSE ovpm.NoDocSumFC END as NoDocSum  , A.docnum docnum1, orpc.docnum docnum2,		
ojdt.transid, ser2.seriesname, vpm2.DocNum vpm2_DocNum, vpm2.InvoiceID, ojdt.BaseRef, 		
ocrn.CurrCode, ocrn.F100Name 'HUNDRETH NAME', ocrn.CurrName 'CURRENCY NAME', ovpm.Comments		
,VPM4.AcctCode,VPM4.AcctName,VPM4.SumApplied as 'AcctSum',		
CASE WHEN OVPM.DocCurr='INR' THEN OVPM.CashSum ELSE OVPM.CashSumFC END as CashSum,		
CASE WHEN OVPM.DocCurr='INR' THEN OVPM.CheckSum ELSE OVPM.CheckSumFC END as CheckSum,		
CASE WHEN OVPM.DocCurr='INR' THEN OVPM.trsfrsum ELSE OVPM.trsfrsumfc END as Bnksum,		
ACT3.formatcode As 'CashAct',ACT2.formatcode As 'BnkTrsFrAcct',ACT2.AcctName As 'BankNm',ACT3.AcctName As 'CashName'		
,	(CASE WHEN OVPM.DocCurr='INR' THEN OVPM.BcgSum ELSE ovpm.BcgSumFC end) 'Bank Charges'
from ovpm 		
left join vpm2 on ovpm.docentry=vpm2.docnum 		
LEFT JOIN VPM4 ON OVPM.DocEntry=VPM4.DocNum		
left join 		
	(select docnum,DocEntry,CardCode,CardName,docdate,Series,ObjType,Case WHEN DocCur='INR' THEN DocTotal ELSE DoctotalFC End AS DocTotal,wtsum,VatSum,	
	 TotalExpns,NumAtCard from opch	
	 union all	
	 select docnum,DocEntry,CardCode,CardName,docdate,Series,Objtype,CASE WHEN DocCur='INR' THEN (-1)*DocTotal ELSE (-1)*DocTotalFC END AS DocTotal,wtsum,VatSum,	
	 TotalExpns,NumAtCard from orpc	
	 union all	
	 select Number DocNum,transid Docentry,NULL CardCode,NULL CardName,RefDate,Series,transtype,null DocTotal,null wtsum,	
	 null VatSum,null TotalExpns,BaseRef from OJDT where transtype IN (30,46)	
	
	 )A on vpm2.docentry=A.docentry and vpm2.invtype=A.ObjType	
left join orpc on vpm2.docentry=orpc.docentry and vpm2.invtype=orpc.objtype		
left join ojdt on vpm2.docentry=ojdt.transid and vpm2.invtype=ojdt.transtype		
left  join nnm1 ser1 on ovpm.series=ser1.series 		
left join nnm1 ser2 on A.series=ser2.series		
left join (Select * from vpm1 where lineid=0) vpm1 on ovpm.docentry=vpm1.docnum		
Left Join ocrn on ovpm.DocCurr=	ocrn.CurrCode	
left join OACT ACT2 on oVPM.TrsfrAcct=ACT2.AcctCode	
left join OACT ACT3 on oVPM.CashAcct=ACT3.AcctCode
GO


