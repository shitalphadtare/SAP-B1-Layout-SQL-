
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:22-12-2017 12:36PM  BY:SHITAL*************/

/********************SHREE SALES ORDER***********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_SALES_ORDER')
DROP VIEW GST_SALES_ORDER
GO

CREATE VIEW GST_SALES_ORDER
AS

SELECT 

RDR.DocEntry 'Docentry',RDR.DocNum 'Docnum',RDR.DocCur,RDR.DocDate 'Docdate'
,NM1.SeriesName 'Docseries'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'')  end +RTRIM(LTRIM(CAST(RDR.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) ) as 'Invoice No'
,RDR.NumAtCard 'RefNo'
,NM11.seriesname 'ordseries'
,RDR.NumAtCard  'OrdNo',RDR.U_BPRefDt 'OrdDate'
,RDR.PayToCode 'BuyerName',RDR.Address 'BuyerAdd',RDR.ShipToCode 'DeilName',RDR.Address2 'DelAdd'
,LCT.Block,LCT.Street,WHS.StreetNo,LCT.Building,LCT.City,LCT.Location,LCT.Country,LCT.ZipCode,LCT.GSTRegnNo 'LocationGSTNO',GTY.GSTType 'LocationGSTType'
,(case when RDR.ExcRefDate is null then RDR.doctime else RDR.ExcRefDate END) 'Supply Time'
,CST.Name 'Supply place'
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
,CPR.Name 'ContactPerson',CPR.Cellolar 'ContactMob',CPR.E_MailL 'ContactMail'
-------
,(select Name from ocst where Code= RR12.StateS and country=RR12.countrys) 'Delplaceofsupply'
,CPR.E_MailL 'CnctPrsnEmail'
,(select  crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=RDR.cardcode and crd1.AdresType='S' and RDR.ShipToCode=crd1.Address) 'ShipToGSTCode'
,GTY1.GSTType 'ShipToGSTType'
,(select GSTCode from OCST where code=RR12.states and country=RR12.CountryS) 'ShipToStateCode'
,(select Name from ocst where Code= RR12.StateB and country=RR12.countryB) 'BillToState'
,(select GSTCode from OCST where code=RR12.StateB and country=RR12.countryB)  'BillToStateCode'
,(select GTY1.GSTType from  CRD1 CD1 
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry where CD1.CardCode=RDR.CardCode and cd1.Address=RDR.PayToCode and CD1.AdresType='B')'BillToGSTType'
,(select distinct crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=RDR.cardcode and crd1.AdresType='B'and RDR.paytocode=crd1.Address)'BillToGSTCode'
,(SELECT distinct TaxId0 FROM CRD7  WHERE RDR.CardCode = CardCode and RDR.ShipToCode=crd7.Address and addrtype='s')'shipPANNo'
,(SELECT distinct CD7.TaxId0 FROM CRD7 cd7 WHERE RDR.CardCode = CD7.CardCode  and RDR.ShipToCode=cd7.Address and CD7.addrtype='s')'bILLPANNo'
---------------------
,RR1.linenum,RR1.ItemCode,RR1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(CASE WHEN  RR1.HsnEntry IS NULL THEN ITM.SACEntry ELSE RR1.HsnEntry END))
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (CASE WHEN  RR1.HsnEntry IS NULL THEN ITM.chapterid ELSE RR1.HsnEntry END))
  Else '' END) 'HSN Code'
  ,(select  ServCode from OSAC where AbsEntry= RR1.SACEntry) 'Service_SAC_Code'
,RR1.Quantity,RR1.unitMsr,RR1.PriceBefDi,RR1.DiscPrcnt
,(isnull(RR1.Quantity,0)*isnull(RR1.PriceBefDi,0)) 'TotalAmt'
,((isnull(RR1.PriceBefDi,0)-isnull(RR1.Price,0))*isnull(RR1.Quantity,0)) 'ItmDiscAmt'
,((case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end)*(isnull(RDR.DiscPrcnt,0)/100)) 'DocDiscAmt'
,CASE when RDR.DiscPrcnt=0 then ((isnull(RR1.PriceBefDi,0)-isnull(RR1.Price,0))*isnull(RR1.Quantity,0)) else ((case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end)*(isnull(RDR.DiscPrcnt,0)/100)) end 'DiscAmt'
,RR1.Price
,case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when RDR.DiscPrcnt=0 then isnull(RR1.LineTotal,0) else (isnull(RR1.LineTotal,0)-(isnull(RR1.LineTotal,0)*isnull(RDR.DiscPrcnt,0)/100)) End)
else (CASE when RDR.DiscPrcnt=0 then isnull(RR1.TotalFrgn,0) else (isnull(RR1.TotalFrgn,0)-(isnull(RR1.TotalFrgn,0)*isnull(RDR.DiscPrcnt,0)/100)) End)end 'Total'
,CASE when RR1.AssblValue=0 then 
(CASE when RDR.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end) 
else ((case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end)-((case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end)*isnull(RDR.DiscPrcnt,0)/100))End)
else (isnull(RR1.AssblValue,0)*isnull(RR1.Quantity,0)) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,CASE when OCRN.CurrCode='INR' then RDR.DocTotal else RDR.DocTotalFC end 'DocTotal'
,CASE when OCRN.CurrCode='INR' then isnull(RDR.RoundDif,0) else isnull(RDR.RoundDiffc,0) end RoundDif
,OCRN.CurrName AS 'Currencyname' ,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,RDR.Comments 'Remark',RDR.Header 'Opening Remark',RDR.Footer 'Closing Remark'
,RR1.U_ItemDesc2,RR1.U_ItemDesc3
From ORDR RDR
INNER JOIN RDR1 RR1 on RR1.DocEntry=RDR.DocEntry
left Join NNM1 NM1 on RDR.Series=NM1.Series 
left JOIN OSLP as SLP on RDR.SlpCode = SLP.SlpCode
LEFT OUTER JOIN OWHS WHS ON RR1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on RR1.LocCode=LCT.Code
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
LEFT OUTER JOIN OCRN ON RDR.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON RDR.GroupNum = OCT.GroupNum 
-----------------
left outer join CRD1 CD1 on CD1.CardCode=RDR.CardCode and CD1.AdresType='S' and RDR.ShipToCode=CD1.Address
LEFT OUTER JOIN RDR12 RR12 ON RR12.DocEntry=RDR.DocEntry
left outer join OCST CST1 on CST1.Code=RR12.BpStateCod and  CST1.Country= RR12.CountryS
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry
LEFT OUTER JOIN OCPR AS CPR ON RDR.CardCode = CPR.CardCode AND RDR.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = RR1.ITEMCODE
-----------------------
left outer join NNM1 NM11 On RDR.Series=NM11.Series 
left outer join RDR4 CGST On RR1.DocEntry=CGST.DocEntry and RR1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join RDR4 SGST On RR1.DocEntry=SGST.DocEntry and RR1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join RDR4 IGST On RR1.DocEntry=IGST.DocEntry and RR1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1
