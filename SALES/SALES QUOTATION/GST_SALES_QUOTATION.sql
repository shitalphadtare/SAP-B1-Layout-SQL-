
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:09-03-2018 12:36PM  BY:SHITAL*************/

/********************electrocare SALES QUOTATION***********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_SALES_QUOTATION')
DROP VIEW GST_SALES_QUOTATION
GO

CREATE VIEW GST_SALES_QUOTATION
AS

SELECT 

QUT.DocEntry 'Docentry',QUT.DocNum 'Docnum',QUT.DocCur,QUT.DocDate 'Docdate'
,NM1.SeriesName 'Docseries',QUT.Docduedate 'Valid Date'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'')  end +'/'+RTRIM(LTRIM(CAST(QUT.DocNum as CHAR(20)))) +'/' +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else ( ISNULL(NM1.Endstr, N''))  end ) ) as 'Invoice No'
,QUT.NumAtCard 'RefNo'
,NM11.seriesname 'ordseries'
,QUT.NumAtCard  'OrdNo',QUT.U_BPRefDt 'OrdDate'
,QUT.PayToCode 'BuyerName',QUT.Address 'BuyerAdd',QUT.ShipToCode 'DeilName',QUT.Address2 'DelAdd'
,LCT.Block,LCT.Street,WHS.StreetNo,LCT.Building,LCT.City,LCT.Location,LCT.Country,LCT.ZipCode,LCT.GSTRegnNo 'LocationGSTNO',GTY.GSTType 'LocationGSTType'
,(case when QUT.ExcRefDate is null then QUT.doctime else QUT.ExcRefDate END) 'Supply Time'
,CST.Name 'Supply place'
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
,CPR.Name 'ContactPerson',CPR.Cellolar 'ContactMob',CPR.E_MailL 'ContactMail'
-------
,(select Name from ocst where Code= QT12.StateS and country=QT12.countrys) 'Delplaceofsupply'
,CPR.E_MailL 'CnctPrsnEmail'
,(select  crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=QUT.cardcode and crd1.AdresType='S' and QUT.ShipToCode=crd1.Address) 'ShipToGSTCode'
,GTY1.GSTType 'ShipToGSTType'
,(select GSTCode from OCST where code=QT12.states and country=QT12.CountryS) 'ShipToStateCode'
,(select Name from ocst where Code= QT12.StateB and country=QT12.countryB) 'BillToState'
,(select GSTCode from OCST where code=QT12.StateB and country=QT12.countryB)  'BillToStateCode'
,(select GTY1.GSTType from  CRD1 CD1 
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry where CD1.CardCode=QUT.CardCode and cd1.Address=QUT.PayToCode and CD1.AdresType='B')'BillToGSTType'
,(select distinct crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=QUT.cardcode and crd1.AdresType='B'and QUT.paytocode=crd1.Address)'BillToGSTCode'
,(SELECT distinct TaxId0 FROM CRD7  WHERE QUT.CardCode = CardCode and QUT.ShipToCode=crd7.Address and addrtype='s')'shipPANNo'
,(SELECT distinct CD7.TaxId0 FROM CRD7 cd7 WHERE QUT.CardCode = CD7.CardCode  and QUT.ShipToCode=cd7.Address and CD7.addrtype='s')'bILLPANNo'
,cpr.Title,cst.gstCode
---------------------
,RR1.linenum,RR1.ItemCode,RR1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry = (case when  RR1.HsnEntry is null then ITM.SACEntry else rr1.HsnEntry end))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when RR1.HsnEntry is null then ITM.chapterid else rr1.HsnEntry end))
  Else '' END) 'HSN Code'
  ,(select  ServCode from OSAC where AbsEntry= RR1.SACEntry) 'Service_SAC_Code'
,RR1.Quantity,RR1.unitMsr,RR1.PriceBefDi,RR1.DiscPrcnt
,(isnull(RR1.Quantity,0)*isnull(RR1.PriceBefDi,0)) 'TotalAmt'
,((isnull(RR1.PriceBefDi,0)-isnull(RR1.Price,0))*isnull(RR1.Quantity,0)) 'ItmDiscAmt'
,((case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end)*(isnull(QUT.DiscPrcnt,0)/100)) 'DocDiscAmt'
,CASE when QUT.DiscPrcnt=0 then ((isnull(RR1.PriceBefDi,0)-isnull(RR1.Price,0))*isnull(RR1.Quantity,0)) else ((case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end)*(isnull(QUT.DiscPrcnt,0)/100)) end 'DiscAmt'
,RR1.Price
,case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when QUT.DiscPrcnt=0 then isnull(RR1.LineTotal,0) else (isnull(RR1.LineTotal,0)-(isnull(RR1.LineTotal,0)*isnull(QUT.DiscPrcnt,0)/100)) End)
else (CASE when QUT.DiscPrcnt=0 then isnull(RR1.TotalFrgn,0) else (isnull(RR1.TotalFrgn,0)-(isnull(RR1.TotalFrgn,0)*isnull(QUT.DiscPrcnt,0)/100)) End)end 'Total'
,CASE when RR1.AssblValue=0 then 
(CASE when QUT.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end) 
else ((case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end)-((case when ocrn.CurrCode='INR' then isnull(RR1.LineTotal,0) else isnull(RR1.TotalFrgn,0) end)*isnull(QUT.DiscPrcnt,0)/100))End)
else (isnull(RR1.AssblValue,0)*isnull(RR1.Quantity,0)) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,QUT.DocTotal
,CASE when OCRN.CurrCode='INR' then QUT.RoundDif else QUT.RoundDiffc end RoundDif
,OCRN.CurrName AS 'Currencyname' ,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,QUT.Comments 'Remark',QUT.Header 'Opening Remark',QUT.Footer 'Closing Remark'
,shp.TrnspName
,qut.U_Terms_Del 'Delivery'
,rr1.U_itemdesc2 
,RR1.U_ItemDesc3
,qut.DiscPrcnt 'Docleveldisc'
From OQUT QUT
INNER JOIN QUT1 RR1 on RR1.DocEntry=QUT.DocEntry
Inner Join NNM1 NM1 on QUT.Series=NM1.Series 
INNER JOIN OSLP as SLP on QUT.SlpCode = SLP.SlpCode
LEFT OUTER JOIN OWHS WHS ON RR1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on RR1.LocCode=LCT.Code
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
LEFT OUTER JOIN OCRN ON QUT.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON QUT.GroupNum = OCT.GroupNum 
-----------------
left outer join CRD1 CD1 on CD1.CardCode=QUT.CardCode and CD1.AdresType='S' and QUT.ShipToCode=CD1.Address
LEFT OUTER JOIN QUT12 QT12 ON QT12.DocEntry=QUT.DocEntry
left outer join OCST CST1 on CST1.Code=QT12.states and  CST1.Country= QT12.CountryS
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry
LEFT OUTER JOIN OCPR AS CPR ON QUT.CardCode = CPR.CardCode AND QUT.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = RR1.ITEMCODE
-----------------------
left outer join NNM1 NM11 On QUT.Series=NM11.Series 
left outer join QUT4 CGST On RR1.DocEntry=CGST.DocEntry and RR1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join QUT4 SGST On RR1.DocEntry=SGST.DocEntry and RR1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join QUT4 IGST On RR1.DocEntry=IGST.DocEntry and RR1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1
left outer join oshp shp on qut.TrnspCode=shp.TrnspCode
go
