
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:23-03-2018 BY:SHITAL*************/

/********************PANCHSHEEL DELIVERY CHALLAN***********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_DELIVERY_CHALLAN')
DROP VIEW GST_DELIVERY_CHALLAN
GO

CREATE VIEW GST_DELIVERY_CHALLAN
AS

SELECT 

DLN.DocEntry 'Docentry',
DLN.DocNum 'Docnum',
DLN.DocCur,
NM1.SeriesName 'Docseries'
,DLN.DocDate 'Docdate'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'')  end +RTRIM(LTRIM(CAST(DLN.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) ) as 'Invoice No'
,DLN.NumAtCard 'RefNo'
,NM11.seriesname 'ordseries'
,DLN.NumAtCard  'OrdNo'
,DLN.U_BpRefDt 'OrdDate'
,DLN.PayToCode 'BuyerName'
,DLN.Address 'BuyerAdd'
,DLN.ShipToCode 'DeilName'
,DLN.Address2 'DelAdd'
,LCT.Block
,LCT.Street
,WHS.StreetNo
,LCT.Building
,LCT.City
,LCT.Location
,LCT.Country
,LCT.ZipCode 
,LCT.GSTRegnNo 'LocationGSTNO'
,GTY.GSTType 'LocationGSTType'
,(case when DLN.ExcRefDate is null then DLN.doctime else DLN.ExcRefDate END) 'Supply Time'
,CST.Name 'Supply place'
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
,CPR.Name 'CnctName',CPR.Cellolar 'CnctMob'
-------
,(select Name from ocst where Code= DC12.StateS and country=DC12.countrys) 'Delplaceofsupply'
,CPR.E_MailL 'CnctPrsnEmail'
,(select  crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=DLN.cardcode and crd1.AdresType='S' and DLN.ShipToCode=crd1.Address) 'ShipToGSTCode'
,GTY1.GSTType 'ShipToGSTType'
,(select GSTCode from OCST where code=DC12.states and country=DC12.CountryS) 'ShipToStateCode'
,(select Name from ocst where Code= DC12.StateB and country=DC12.countryB) 'BillToState'
,(select GSTCode from OCST where code=DC12.StateB and country=DC12.countryB)  'BillToStateCode'
,(select GTY1.GSTType from  CRD1 CD1 
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry where CD1.CardCode=DLN.CardCode and cd1.Address=DLN.PayToCode and CD1.AdresType='B')'BillToGSTType'
,(select distinct crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=DLN.cardcode and crd1.AdresType='B'and DLN.paytocode=crd1.Address)'BillToGSTCode'
,(SELECT distinct TaxId0 FROM CRD7  WHERE DLN.CardCode = CardCode and DLN.ShipToCode=crd7.Address and addrtype='s')'shipPANNo'
,(SELECT distinct CD7.TaxId0 FROM CRD7 cd7 WHERE DLN.CardCode = CD7.CardCode  and DLN.ShipToCode=cd7.Address and CD7.addrtype='s')'bILLPANNo'
,CPR.Name 'ContactPerson',CPR.Cellolar 'ContactMob',CPR.E_MailL 'ContactMail'
,cpr.Title,cst.gstCode
---------------------
,DN1.linenum
,DN1.ItemCode
,DN1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where  AbsEntry = (case when DN1.SACEntry=null then ITM.SACEntry else DN1.SACEntry end ))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where  Absentry=(case when DN1.HsnEntry=null then ITM.chapterid else DN1.HsnEntry end ))
  Else '' END) 'HSN Code'
  ,(select  ServCode from OSAC where AbsEntry= DN1.SACEntry) 'Service_SAC_Code'
,DN1.Quantity
,DN1.unitMsr
,DN1.PriceBefDi
,DN1.DiscPrcnt
,(isnull(DN1.Quantity,0)*isnull(DN1.PriceBefDi,0)) 'TotalAmt'
,((isnull(DN1.PriceBefDi,0)-isnull(DN1.Price,0))*isnull(DN1.Quantity,0)) 'ItmDiscAmt'
,((case when ocrn.CurrCode='INR' then isnull(DN1.LineTotal,0) else isnull(DN1.TotalFrgn,0) end)*(isnull(DLN.DiscPrcnt,0)/100)) 'DocDiscAmt'
,CASE when DLN.DiscPrcnt=0 then ((isnull(DN1.PriceBefDi,0)-isnull(DN1.Price,0))*isnull(DN1.Quantity,0)) else ((case when ocrn.CurrCode='INR' then isnull(DN1.LineTotal,0) else isnull(DN1.TotalFrgn,0) end)*(isnull(DLN.DiscPrcnt,0)/100)) end 'DiscAmt'
,DN1.Price
,case when ocrn.CurrCode='INR' then isnull(DN1.LineTotal,0) else isnull(DN1.TotalFrgn,0) end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when DLN.DiscPrcnt=0 then isnull(DN1.LineTotal,0) else (isnull(DN1.LineTotal,0)-(isnull(DN1.LineTotal,0)*isnull(DLN.DiscPrcnt,0)/100)) End)
else (CASE when DLN.DiscPrcnt=0 then isnull(DN1.TotalFrgn,0) else (isnull(DN1.TotalFrgn,0)-(isnull(DN1.TotalFrgn,0)*isnull(DLN.DiscPrcnt,0)/100)) End)end 'Total'
,CASE when DN1.AssblValue=0 then 
(CASE when DLN.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then isnull(DN1.LineTotal,0) else isnull(DN1.TotalFrgn,0) end)
 else ((case when ocrn.CurrCode='INR' then isnull(DN1.LineTotal,0) else isnull(DN1.TotalFrgn,0) end)-((case when ocrn.CurrCode='INR' then isnull(DN1.LineTotal,0) else isnull(DN1.TotalFrgn,0) end)*isnull(DLN.DiscPrcnt,0)/100))End)
else (isnull(DN1.AssblValue,0)*isnull(DN1.Quantity,0)) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,CASE when OCRN.CurrCode='INR' then DLN.DocTotal else DLN.DocTotalFC end 'DocTotal'
,CASE when OCRN.CurrCode='INR' then DLN.RoundDif else DLN.RoundDiffc end RoundDif
,OCRN.CurrName AS 'Currencyname' 
,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,DLN.Comments 'Remark'
,DLN.Header 'Opening Remark'
,DLN.Footer 'Closing Remark'
,dln.U_vehNo 'Vehicleno'
,shp.TrnspName
,DN1.U_ItemDesc2
,DN1.U_ItemDesc3

From ODLN DLN
INNER JOIN DLN1 DN1 on DN1.DocEntry=DLN.DocEntry
LEFT OUTER JOIN DLN12 DC12 ON DC12.DocEntry=DLN.DocEntry
LEFT Join NNM1 NM1 on DLN.Series=NM1.Series 
LEFT JOIN OSLP as SLP on DLN.SlpCode = SLP.SlpCode
LEFT OUTER JOIN OWHS WHS ON DN1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on DN1.LocCode=LCT.Code
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
Left Outer Join RDR1 RR1 On DN1.BaseEntry=RR1.DocEntry and DN1.BaseLine=RR1.LineNum 
left outer Join ORDR RDR On RR1.DocEntry=RDR.DocEntry 
LEFT OUTER JOIN OCRN ON DLN.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON DLN.GroupNum = OCT.GroupNum 
-----------------
left outer join CRD1 CD1 on CD1.CardCode=DLN.CardCode and CD1.AdresType='S' and DLN.ShipToCode=CD1.Address
LEFT OUTER JOIN DLN12 DN12 ON DN12.DocEntry=DLN.DocEntry
left outer join OCST CST1 on CST1.Code=DN12.BpStateCod and  CST1.Country= DN12.CountryS
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry
LEFT OUTER JOIN OCPR AS CPR ON DLN.CardCode = CPR.CardCode AND DLN.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = DN1.ITEMCODE
-----------------------
left outer join NNM1 NM11 On RDR.Series=NM11.Series 
left outer join DLN4 CGST On DN1.DocEntry=CGST.DocEntry and DN1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join DLN4 SGST On DN1.DocEntry=SGST.DocEntry and DN1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join DLN4 IGST On DN1.DocEntry=IGST.DocEntry and DN1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1
left outer join OSHP shp on shp.trnspcode=dln.trnspcode
go
