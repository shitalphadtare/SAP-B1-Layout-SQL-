
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:21-11-2017 13:33 PM  BY:SHITAL*************/

/********************PURCHASE ORDER***********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_PURCHASE_ORDER')
DROP VIEW GST_PURCHASE_ORDER
GO
									
CREATE VIEW GST_PURCHASE_ORDER
AS

SELECT 
POR.DocEntry 'Docentry'
,POR.DocNum 'Docnum'
,POR.DocCur
,NM1.SeriesName 'Docseries'
,POR.DocDate 'Docdate'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'')  end +RTRIM(LTRIM(CAST(POR.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) ) as 'Purchase No'
,case when (crd.cardfname is null or crd.cardfname='') then por.cardcode else crd.cardfname end 'Cardcode'
,POR.CardName 'VName'
,POR.Address 'VendorAdd'
,CPR.Name 'V_CNCTP_N'
,cpr.cellolar 'V_mobileNo'
,CPR.E_MailL 'V_CnctP_E'
,VShipFrom.Block
,VShipFrom.Building
,VShipFrom.Street
,VShipFrom.City
,VShipFrom.ZipCode
,(select distinct Name from OCRY where Code=VShipFrom.Country) 'country'
,VShipFrom.STREETNO 'Street No_Vendor'
,(select distinct name  from ocst where Code=VShipFrom.state and VShipFrom1.country=Ocst.Country) 'STATE_Vendor'
,VShipFrom.GSTRegnNo 'VShipGSTNo'
,GTY2.GSTType 'VShipGSTType'
,POR.NumAtCard 'SupRefNo'
,'' 'SupDate'
,(select  SUBSTRING((SELECT  distinct ( Cast(OPRQ.DocNum AS CHAR(7))) + ', ' AS 'data()' 
FROM  OPRQ inner join POR1  on  OPRQ.Docentry=POR1.baseentry  and POR1.docentry=POR.docentry 
  left outer join  NNM1 on NNM1.Series=OPRQ.Series        
FOR XML PATH('')) ,1,len((SELECT distinct  ( Cast(OPRQ.DocNum AS CHAR(7)) )+ ', ' AS 'data()'  
FROM  OPRQ inner join POR1  on   OPRQ.Docentry=POR1.baseentry  and POR1.docentry=POR.docentry 
left outer join  NNM1 on NNM1.Series=OPRQ.Series
FOR XML PATH('') ))-1)) 'PR No'
,(select  SUBSTRING((SELECT  Distinct Cast(CONVERT(VARCHAR,OPRQ.DocDate,105) as char(10)) + ', ' AS 'data()' 
FROM  OPRQ inner join POR1  on   OPRQ.Docentry=POR1.baseentry where POR1.docentry=POR.docentry
FOR XML PATH('')) ,1,len((SELECT  Distinct Cast(CONVERT(VARCHAR,OPRQ.DocDate,105) as char(10)) + ', ' AS 'data()'  
FROM  OPRQ inner join POR1  on   OPRQ.Docentry=POR1.baseentry where POR1.docentry=POR.docentry
FOR XML PATH('') ))-1))'PR Date'
,POR.DocDueDate 'DeliDate'
,SHP.TrnspName 'Deli_Mode'
,POR.Address2 'Deli_Addr'
,LCT.GSTRegnNo 'Deli_GST'
,GTY.GSTType 'Deli_GSTType'
-----------------------------------------------------------------------------------------------------------
,POR.PayToCode 'BuyerName'
,POR.ShipToCode 'DeilName'
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
-------------------------------------------------------------------------
,CPR.E_MailL 'CnctPrsnEmail'
-------------------------------------------------------------------------
,PR1.linenum
,PR1.ItemCode
,PR1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when PR1.HsnEntry is null then ITM.SACEntry else PR1.HsnEntry end))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when PR1.HsnEntry is null then ITM.chapterid else PR1.HsnEntry end))
  Else '' END) 'HSN Code'
,(select  ServCode from OSAC where AbsEntry= PR1.SACEntry) 'Service_SAC_Code'
,PR1.Quantity
,PR1.unitMsr
,PR1.PriceBefDi
,PR1.DiscPrcnt
,(isnull(PR1.Quantity,0)*isnull(PR1.PriceBefDi,0)) 'TotalAmt'
,((isnull(PR1.PriceBefDi,0)-isnull(PR1.Price,0))*isnull(PR1.Quantity,0)) 'ItmDiscAmt'
,((case when ocrn.CurrCode='INR' then isnull(PR1.LineTotal,0) else isnull(PR1.TotalFrgn,0) end)*(isnull(POR.DiscPrcnt,0)/100)) 'DocDiscAmt'
,CASE when POR.DiscPrcnt=0 then ((isnull(PR1.PriceBefDi,0)-isnull(PR1.Price,0))*isnull(PR1.Quantity,0)) else ((case when ocrn.CurrCode='INR' then isnull(PR1.LineTotal,0) else isnull(PR1.TotalFrgn,0) end)*(isnull(POR.DiscPrcnt,0)/100)) end 'DiscAmt'
,PR1.Price
,case when ocrn.CurrCode='INR' then isnull(PR1.LineTotal,0) else isnull(PR1.TotalFrgn,0) end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when POR.DiscPrcnt=0 then isnull(PR1.LineTotal,0) else (isnull(PR1.LineTotal,0)-(isnull(PR1.LineTotal,0)*isnull(POR.DiscPrcnt,0)/100)) End)
else (CASE when POR.DiscPrcnt=0 then isnull(PR1.TotalFrgn,0) else (isnull(PR1.TotalFrgn,0)-(isnull(PR1.TotalFrgn,0)*isnull(POR.DiscPrcnt,0)/100)) End)end 'Total'
,CASE when PR1.AssblValue=0 
then 
(CASE when POR.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then isnull(PR1.LineTotal,0) else isnull(PR1.TotalFrgn,0) end)
 else ((case when ocrn.CurrCode='INR' then isnull(PR1.LineTotal,0) else isnull(PR1.TotalFrgn,0) end)-((case when ocrn.CurrCode='INR' then isnull(PR1.LineTotal,0) else isnull(PR1.TotalFrgn,0) end)*isnull(POR.DiscPrcnt,0)/100))End)
else (isnull(PR1.AssblValue,0)*isnull(PR1.Quantity,0)) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,POR.DocTotal
,CASE when OCRN.CurrCode='INR' then POR.RoundDif else POR.RoundDiffc end RoundDif
,OCRN.CurrName AS 'Currencyname' 
,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,POR.Comments 'Remark'
,POR.Header 'Opening Remark'
,POR.Footer 'Closing Remark'
,PRJ.PrjName 'PrjName'
,PR1.ShipDate 'ShipDate'
,POR.U_OCNo 'U_OC_No'
,CPR.Cellolar
,POR."U_Terms_Del" "Delivery",
POR."U_Terms_Pay"  "Payment",
POR."U_Terms_Insp"  "Ispection",
POR."U_Terms_Price" "Terms_Price",
POR."U_Terms_PackInst"  "Packing Instruction",
POR."U_Terms_Insu" "Insurance",
POR."U_Terms_Frt" "Freight",
POR."U_Terms_PNF" "P & N",
POR.U_BPRefDt 
,PR1.ShipDate 'DueOn'
,Por.U_Terms_Del
,PR1.U_ItemDesc2
,PR1.U_ItemDesc3
From OPOR POR
INNER JOIN POR1 PR1 on PR1.DocEntry=POR.DocEntry
left Join NNM1 NM1 on POR.Series=NM1.Series 
left outer join ocrd CRD on por.cardcode=crd.CardCode
left outer join (select * from CRD1 )VShipFrom on VShipFrom.Address=por.ShipToCode and  VShipFrom.Cardcode=POR.Cardcode and VShipFrom.AdresType='S'
left outer join (select * from CRD1 )VShipFrom1 on VShipFrom1.Address=CRD.ShipToDef and  VShipFrom1.Cardcode=POR.Cardcode and VShipFrom1.AdresType='S'
left outer join OGTY GTY2 on VShipFrom.GSTType=GTY2.AbsEntry
left JOIN OSLP as SLP on POR.SlpCode = SLP.SlpCode
LEFT OUTER JOIN OSHP SHP ON SHP.Trnspcode = POR.Trnspcode
LEFT OUTER JOIN OLCT LCT on PR1.LocCode=LCT.Code
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
LEFT OUTER JOIN OCRN ON POR.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON POR.GroupNum = OCT.GroupNum 
LEFT OUTER JOIN POR12 PR12 ON PR12.DocEntry=POR.DocEntry
left outer join OCST CST1 on CST1.Code=PR12.states and  CST1.Country= PR12.CountryS
LEFT OUTER JOIN OCPR AS CPR ON POR.CardCode = CPR.CardCode AND POR.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = PR1.ITEMCODE
left outer join POR4 CGST On PR1.DocEntry=CGST.DocEntry and PR1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join POR4 SGST On PR1.DocEntry=SGST.DocEntry and PR1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join POR4 IGST On PR1.DocEntry=IGST.DocEntry and PR1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1
LEFT OUTER JOIN OPRJ AS PRJ ON PRJ.PrjCode = POR.Project
go
