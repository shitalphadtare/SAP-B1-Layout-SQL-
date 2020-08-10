
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:03-12-2017 15:40PM  BY:SHITAL*************/

/******************** AAKASH credit NOTE **********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_CREDIT_NOTE')
DROP VIEW GST_CREDIT_NOTE
GO

CREATE VIEW GST_CREDIT_NOTE
AS

SELECT 

RIN.DocEntry 'Docentry',RIN.DocNum 'Docnum',RIN.DocCur,RIN.DocDate 'Docdate',RIN.NumAtCard 'RefNo'
,NM1.SeriesName 'Docseries'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'') end +RTRIM(LTRIM(CAST(RIN.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) ) as 'Invoice No'
,NM11.seriesname 'ordseries'
,RIN.numatcard  'OrdNo',RIN.U_BPRefDt 'OrdDate'
,T4.SeriesName + '/' + CAST (DLN.Docnum as varchar) 'Challan No',DLN.DocDate 'Challan Date'
,RIN.PayToCode 'BuyerName',RIN.Address 'BuyerAdd',RIN.ShipToCode 'DeilName',RIN.Address2 'DelAdd'
,LCT.Block,LCT.Street,WHS.StreetNo,LCT.Building,LCT.City,LCT.Location,
OCR.NAME 'Country'
,OCS.NAME 'STATE'
,LCT.ZipCode ,LCT.GSTRegnNo 'LocationGSTNO',GTY.GSTType 'LocationGSTType'
,(case when RIN.ExcRefDate is null then RIN.doctime else RIN.ExcRefDate END) 'Supply Time'
,CST.Name 'Supply place',cst.gstCode
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
,CPR.Name 'Salesname',CPR.Cellolar 'Smob',CPR.E_MailL 'Smail'
-------
,(select Name from ocst where Code= RN12.StateS and country=RN12.countrys) 'Delplaceofsupply'
,CPR.E_MailL 'CnctPrsnEmail'
,(select  crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=RIN.cardcode and crd1.AdresType='S' and RIN.ShipToCode=crd1.Address) 'ShipToGSTCode'
,GTY1.GSTType 'ShipToGSTType'
,(select GSTCode from OCST where code=RN12.states and country=RN12.CountryS) 'ShipToStateCode'
,(select Name from ocst where Code= RN12.StateB and country=RN12.countryB) 'BillToState'
,(select GSTCode from OCST where code=RN12.StateB and country=RN12.countryB)  'BillToStateCode'
,(select GTY1.GSTType from  CRD1 CD1 
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry where CD1.CardCode=RIN.CardCode and cd1.Address=RIN.PayToCode and CD1.AdresType='B')'BillToGSTType'
,(select distinct crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=RIN.cardcode and crd1.AdresType='B'and RIN.paytocode=crd1.Address)'BillToGSTCode'
,(SELECT distinct TaxId0 FROM CRD7  WHERE RIN.CardCode = CardCode and RIN.ShipToCode=crd7.Address and addrtype='s')'shipPANNo'
,(SELECT distinct CD7.TaxId0 FROM CRD7 cd7 WHERE RIN.CardCode = CD7.CardCode  and RIN.ShipToCode=cd7.Address and CD7.addrtype='s')'bILLPANNo'
,CPR.Name 'ContactPerson',CPR.Cellolar 'ContactMob',CPR.E_MailL 'ContactMail'
,cpr.Title
---------------------
,RN1.linenum,RN1.ItemCode,RN1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry = (case when RN1.HsnEntry is null then ITM.SACEntry else rn1.hsnentry end))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when RN1.HsnEntry is null then ITM.chapterid else rn1.hsnentry end)) Else '' END) 'HSN Code'
 ,(select  ServCode from OSAC where AbsEntry= RN1.SACEntry) 'Service_SAC_Code'
,RN1.Quantity,RN1.unitMsr,RN1.PriceBefDi,RN1.DiscPrcnt
,(RN1.Quantity*RN1.PriceBefDi) 'TotalAmt'
,((RN1.PriceBefDi-RN1.Price)*RN1.Quantity) 'ItmDiscAmt'
,case when ocrn.CurrCode='INR' then (RN1.LineTotal*(RIN.DiscPrcnt/100)) else (RN1.TotalFrgn*(RIN.DiscPrcnt/100)) end 'DocDiscAmt'
,CASE when RIN.DiscPrcnt=0 then ((RN1.PriceBefDi-RN1.Price)*RN1.Quantity) else ((case when OCRN.CurrCode='INR' then RN1.LineTotal else RN1.TotalFrgn end) *(RIN.DiscPrcnt/100)) end 'DiscAmt'
,RN1.Price
,case when ocrn.CurrCode='INR' then RN1.LineTotal else RN1.TotalFrgn end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when RIN.DiscPrcnt=0 then RN1.LineTotal else (RN1.LineTotal-(RN1.LineTotal*RIN.DiscPrcnt/100)) End)
else (CASE when RIN.DiscPrcnt=0 then RN1.TotalFrgn else (RN1.TotalFrgn-(RN1.TotalFrgn*RIN.DiscPrcnt/100)) End)end 'Total'
,CASE when RN1.AssblValue=0 then 
(CASE when RIN.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then RN1.LineTotal else RN1.TotalFrgn end) 
else ((case when ocrn.CurrCode='INR' then RN1.LineTotal else RN1.TotalFrgn end)-((case when ocrn.CurrCode='INR' then RN1.LineTotal else RN1.TotalFrgn end)*RIN.DiscPrcnt/100))End)
else (RN1.AssblValue*RN1.Quantity) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,RIN.DocTotal
,CASE when OCRN.CurrCode='INR' then RIN.RoundDif else RIN.RoundDiffc end RoundDif
,OCRN.CurrName AS 'Currencyname' ,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,RIN.Comments 'Remark',RIN.Header 'Opening Remark',RIN.Footer 'Closing Remark'
,T5.SeriesName + '/' + CAST (inv.docNum as CHAR(20)) as 'Invoice No1'
,inv.docdate 'invDocdate'
From ORIN RIN
INNER JOIN RIN1 RN1 on RN1.DocEntry=RIN.DocEntry
Inner Join NNM1 NM1 on RIN.Series=NM1.Series 
INNER JOIN OSLP as SLP on RIN.SlpCode = SLP.SlpCode
LEFT OUTER JOIN INV1 AS I1 ON I1.DocEntry = RN1.BaseEntry AND RN1.BaseLine = I1.LineNum
LEFT OUTER JOIN OINV AS inv ON inv.DocEntry = I1.DocEntry
LEFT OUTER JOIN NNM1 T5 ON inv.Series = T5.Series
LEFT OUTER JOIN OWHS WHS ON RN1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on RN1.LocCode=LCT.Code
LEFT OUTER JOIN OCRY OCR ON LCT.COUNTRY = OCR.CODE
LEFT OUTER JOIN OCST OCS ON LCT.STATE = OCS.CODE AND LCT.COUNTRY = OCS.COUNTRY
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
LEFT OUTER JOIN DLN1 AS DN1 ON DN1.DocEntry = I1.BaseEntry AND I1.BaseLine = DN1.LineNum
LEFT OUTER JOIN ODLN AS DLN ON DN1.DocEntry = DLN.DocEntry
LEFT OUTER JOIN NNM1 T4 ON T4.Series = DLN.Series
Left Outer Join RDR1 RR1 On DN1.BaseEntry=RR1.DocEntry and DN1.BaseLine=RR1.LineNum 
left outer Join ORDR RDR On RR1.DocEntry=RDR.DocEntry 
LEFT OUTER JOIN OCRN ON RIN.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON RIN.GroupNum = OCT.GroupNum 
-----------------
left outer join CRD1 CD1 on CD1.CardCode=RIN.CardCode and CD1.AdresType='S' and RIN.ShipToCode=CD1.Address
LEFT OUTER JOIN RIN12 RN12 ON RN12.DocEntry=RIN.DocEntry
left outer join OCST CST1 on CST1.Code=RN12.BpStateCod and  CST1.Country= RN12.CountryS
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry
LEFT OUTER JOIN OCPR AS CPR ON RIN.CardCode = CPR.CardCode AND RIN.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = RN1.ITEMCODE
-----------------------
left outer join NNM1 NM11 On RDR.Series=NM11.Series 
left outer join RIN4 CGST On RN1.DocEntry=CGST.DocEntry and RN1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join RIN4 SGST On RN1.DocEntry=SGST.DocEntry and RN1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join RIN4 IGST On RN1.DocEntry=IGST.DocEntry and RN1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1

go


