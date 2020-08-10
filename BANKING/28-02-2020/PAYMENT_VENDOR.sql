

create VIEW PAYMENT_VENDOR
AS

select ovpm.DocNum, ovpm.DocEntry, 		
case when ovpm.Series=-1 then 'Manual' Else ser1.SeriesName End 
+'/'+cast(ovpm.DocNum as varchar(20)) as DocumentNo,	
ovpm.DocDate as DocDate,OVPM.DocType, 		
ovpm.Address, vpm1.CheckNum, vpm1.CheckAct,		
(select BankName from odsc where vpm1.BankCode=odsc.BankCode) as BankName,		
vpm1.DueDate as ChqDate,vpm1.CheckSum as CheckAmt,		
(select PrjName from OPRJ where PrjCode=ovpm.PrjCode) ProjectName,		
(ser2.SeriesName+'/'+cast(A.DocNum as varchar(30)) )as InvoiceNo,		
A.DocDate as InvDate,		
CASE WHEN VPM2.InvType IN (30,46) THEN (Case when OVPM.DocCurr='INR' 
THEN VPM2.SumApplied ELSE VPM2.AppliedFC END)		
ELSE A.DocTotal END AS InvTotal,
	CASE WHEN VPM2.InvType IN (30,46) THEN (Case when OVPM.DocCurr='INR' 
THEN VPM2.SumApplied ELSE VPM2.AppliedFC END)		
ELSE (Case when OVPM.DocCurr='INR' 
THEN VPM2.SumApplied ELSE VPM2.AppliedFC END)	 END 'paidmaount'	,
A.WTSum as WTaxAmount, A.VatSum as Tax, A.TotalExpns as Freight,A.NumAtCard,		
Case When vpm2.InvType=19 then (-1)*(A.DocTotal+A.WTSum) 		
     Else (A.DocTotal+A.WTSum) End as Gross,		
A.WTSum as TDS,
OVPM.CardCode,OVPM.CardName,		
Case When vpm2.InvType=19 then (-1)*vpm2.SumApplied 		
	 Else vpm2.SumApplied End as Net,vpm2.SumApplied as InvPaidAmt,	
Case WHEN OVPM.DocCurr='INR' THEN OVPM.DocTotal ELSE OVPM.DocTotalFC END AS OVPM_Doctotal,				
ovpm.PayNoDoc, CASE WHEN OVPM.DocCurr='INR' THEN ovpm.NoDocSum ELSE ovpm.NoDocSumFC END as NoDocSum
  , A.DocNum docnum1, orpc.DocNum docnum2,		
ojdt.TransId, ser2.SeriesName, vpm2.DocNum vpm2_DocNum, vpm2.InvoiceId, ojdt.BaseRef, 		
ocrn.CurrCode, ocrn.F100Name 'HUNDRETH NAME', ocrn.CurrName 'CURRENCY NAME', ovpm.Comments		
,VPM4.AcctCode,VPM4.AcctName,VPM4.SumApplied as AcctSum,		
CASE WHEN OVPM.DocCurr='INR' THEN OVPM.CashSum ELSE OVPM.CashSumFC END as CashSum,		
CASE WHEN OVPM.DocCurr='INR' THEN OVPM.CheckSum ELSE OVPM.CheckSumFC END as CheckSum,		
CASE WHEN OVPM.DocCurr='INR' THEN OVPM.TrsfrSum ELSE OVPM.TrsfrSumFC END as Bnksum,		
ACT3.FormatCode As CashAct,ACT2.FormatCode As BnkTrsFrAcct,ACT2.AcctName As BankNm
,ACT3.AcctName As CashName		
,	(CASE WHEN OVPM.DocCurr='INR' THEN OVPM.BcgSum ELSE ovpm.BcgSumFC end) 'Bank Charges'
,OCRN.F100Name AS 'Hundredthname'
,OCRN.frgnname 'hundredth'

from ovpm 		
left join vpm2 on ovpm.DocEntry=vpm2.DocNum 		
LEFT JOIN VPM4 ON OVPM.DocEntry=VPM4.DocNum		
left join 		
	(select DocNum,DocEntry,CardCode,CardName,DocDate,Series,ObjType
	,Case WHEN DocCur='INR' THEN DocTotal ELSE DocTotalFC End AS DocTotal
	,case when DocCur='INR' THEN paidtodate else paidfc end 'paidamount'
	,WTSum,VatSum,	
	 TotalExpns,NumAtCard from opch	
	 union all	
	 select DocNum,DocEntry,CardCode,CardName,DocDate,Series,ObjType
	 ,CASE WHEN DocCur='INR' THEN (-1)*DocTotal ELSE (-1)*DocTotalFC END AS DocTotal
	 ,case when DocCur='INR' THEN paidtodate else paidfc end 'paidamount'
	 ,WTSum,VatSum,	
	 TotalExpns,NumAtCard from orpc	
	 union all	
	 select Number DocNum,TransId DocEntry,NULL CardCode,NULL CardName,RefDate,Series,TransType,
	 null DocTotal,0 padiamount,null WTSum,	
	 null VatSum,null TotalExpns,BaseRef from OJDT where TransType IN (30,46)	
	 )A on vpm2.DocEntry=A.DocEntry and vpm2.InvType=A.ObjType	
left join orpc on vpm2.DocEntry=orpc.DocEntry and vpm2.InvType=orpc.ObjType		
left join ojdt on vpm2.DocEntry=ojdt.TransId and vpm2.InvType=ojdt.TransType		
left  join nnm1 ser1 on ovpm.Series=ser1.Series 		
left join nnm1 ser2 on A.Series=ser2.Series		
left join (Select * from vpm1 where LineID=0) vpm1 on ovpm.DocEntry=vpm1.DocNum		
Left Join ocrn on ovpm.DocCurr=	ocrn.CurrCode	
left join OACT ACT2 on oVPM.TrsfrAcct=ACT2.AcctCode	--For Bank Trsfr A/c (OACT)Accounts Detail	
left join OACT ACT3 on oVPM.CashAcct=ACT3.AcctCode	--For Cash A/c (OACT)Accounts Detail	

