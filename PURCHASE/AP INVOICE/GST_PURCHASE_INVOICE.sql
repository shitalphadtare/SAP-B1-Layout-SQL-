
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:21-11-2017 13:33 PM  BY:SHITAL*************/

/********************SHREE PURCHASE INVOICE***********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_PURCHASE_INVOICE')
DROP VIEW GST_PURCHASE_INVOICE
GO
									
CREATE VIEW GST_PURCHASE_INVOICE
AS

SELECT 
PCH.DocEntry 'Docentry'
,PCH.DocNum 'Docnum'
,PCH.DocCur
,NM1.SeriesName 'Docseries'
,PCH.DocDate 'Docdate'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'')  end +RTRIM(LTRIM(CAST(PCH.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) ) as 'Purchase No'
,PCH.CardName 'VName'
,PCH.Address 'VendorAdd'
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
,VShipFrom1.GSTRegnNo 'VShipGSTNo'
,GTY2.GSTType 'VShipGSTType'
,PCH.NumAtCard 'SupRefNo'
,'' 'SupDate'
,(select  SUBSTRING((SELECT  distinct ( Cast(OPRQ.DocNum AS CHAR(7))) + ', ' AS 'data()' 
FROM  OPRQ inner join PCH1  on  OPRQ.Docentry=PCH1.baseentry  and PCH1.docentry=PCH.docentry 
  left outer join  NNM1 on NNM1.Series=OPRQ.Series        
FOR XML PATH('')) ,1,len((SELECT distinct  ( Cast(OPRQ.DocNum AS CHAR(7)) )+ ', ' AS 'data()'  
FROM  OPRQ inner join PCH1  on   OPRQ.Docentry=PCH1.baseentry  and PCH1.docentry=PCH.docentry 
left outer join  NNM1 on NNM1.Series=OPRQ.Series
FOR XML PATH('') ))-1)) 'PR No'
,(select  SUBSTRING((SELECT  Distinct Cast(CONVERT(VARCHAR,OPRQ.DocDate,105) as char(10)) + ', ' AS 'data()' 
FROM  OPRQ inner join PCH1  on   OPRQ.Docentry=PCH1.baseentry where PCH1.docentry=PCH.docentry
FOR XML PATH('')) ,1,len((SELECT  Distinct Cast(CONVERT(VARCHAR,OPRQ.DocDate,105) as char(10)) + ', ' AS 'data()'  
FROM  OPRQ inner join PCH1  on   OPRQ.Docentry=PCH1.baseentry where PCH1.docentry=PCH.docentry
FOR XML PATH('') ))-1))'PR Date'
,PCH.DocDueDate 'DeliDate'
,SHP.TrnspName 'Deli_Mode'
,PCH.Address2 'Deli_Addr'
,LCT.GSTRegnNo 'Deli_GST'
,GTY.GSTType 'Deli_GSTType'
-----------------------------------------------------------------------------------------------------------
,PCH.PayToCode 'BuyerName'
,PCH.ShipToCode 'DeilName'
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
-------------------------------------------------------------------------
,CPR.E_MailL 'CnctPrsnEmail'
-------------------------------------------------------------------------
,PH1.linenum
,PH1.ItemCode
,PH1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when PH1.HsnEntry is null then ITM.SACEntry else PH1.HsnEntry end))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when PH1.HsnEntry is null then ITM.chapterid else PH1.HsnEntry end))
  Else '' END) 'HSN Code'
,(select  ServCode from OSAC where AbsEntry= PH1.SACEntry) 'Service_SAC_Code'
,PH1.Quantity
,PH1.unitMsr
,PH1.PriceBefDi
,PH1.DiscPrcnt
,(PH1.Quantity*isnull(PH1.PriceBefDi,0)) 'TotalAmt'
,((isnull(PH1.PriceBefDi,0)-PH1.Price)*PH1.Quantity) 'ItmDiscAmt'
,((case when ocrn.CurrCode='INR' then isnull(PH1.LineTotal,0) else isnull(PH1.TotalFrgn,0) end)*(isnull(PCH.DiscPrcnt,0)/100)) 'DocDiscAmt'
,CASE when PCH.DiscPrcnt=0 then ((isnull(PH1.PriceBefDi,0)-PH1.Price)*PH1.Quantity) else ((case when ocrn.CurrCode='INR' then isnull(PH1.LineTotal,0) else isnull(PH1.TotalFrgn,0) end)*(isnull(PCH.DiscPrcnt,0)/100)) end 'DiscAmt'
,PH1.Price
,case when ocrn.CurrCode='INR' then isnull(PH1.LineTotal,0) else isnull(PH1.TotalFrgn,0) end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when PCH.DiscPrcnt=0 then isnull(PH1.LineTotal,0) else (isnull(PH1.LineTotal,0)-(isnull(PH1.LineTotal,0)*isnull(PCH.DiscPrcnt,0)/100)) End)
else (CASE when PCH.DiscPrcnt=0 then isnull(PH1.TotalFrgn,0) else (isnull(PH1.TotalFrgn,0)-(isnull(PH1.TotalFrgn,0)*isnull(PCH.DiscPrcnt,0)/100)) End)end 'Total'
,CASE when PH1.AssblValue=0 
then 
(CASE when PCH.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then isnull(PH1.LineTotal,0) else isnull(PH1.TotalFrgn,0) end)
 else ((case when ocrn.CurrCode='INR' then isnull(PH1.LineTotal,0) else isnull(PH1.TotalFrgn,0) end)-((case when ocrn.CurrCode='INR' then isnull(PH1.LineTotal,0) else isnull(PH1.TotalFrgn,0) end)*isnull(PCH.DiscPrcnt,0)/100))End)
else (PH1.AssblValue*PH1.Quantity) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,CASE when OCRN.CurrCode='INR' then PCH.DocTotal else PCH.DocTotalFC end DocTotal
,CASE when OCRN.CurrCode='INR' then PCH.RoundDif else PCH.RoundDiffc end RoundDif
,OCRN.CurrName AS 'Currencyname' 
,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,PCH.Comments 'Remark'
,PCH.Header 'Opening Remark'
,PCH.Footer 'Closing Remark'
,PRJ.PrjName 'PrjName'
,PH1.ShipDate 'ShipDate'
,PCH.U_OCNo 'U_OC_No'
,CPR.Cellolar
,case when PCH."U_Terms_Del"  is null or PCH."U_Terms_Del" = '' then '' else   PCH."U_Terms_Del" end "Delivery",
case when PCH."U_Terms_Pay"   is null or PCH."U_Terms_Pay"  = '' then '' else   PCH."U_Terms_Pay"  end "Payment",
case when PCH."U_Terms_Insp"  is null or PCH."U_Terms_Insp" = '' then '' else  PCH."U_Terms_Insp"  end "Ispection",
case when PCH."U_Terms_Price"  is null or PCH."U_Terms_Price" = '' then '' else  PCH."U_Terms_Price"  end "Terms_Price",
case when PCH."U_Terms_PackInst"  is null or PCH."U_Terms_PackInst"  = '' then '' else  PCH."U_Terms_PackInst"  end "Packing Instruction",
case when PCH."U_Terms_Insu"  is null or PCH."U_Terms_Insu" = '' then '' else  PCH."U_Terms_Insu"   end "Insurance",
case when PCH."U_Terms_Frt" is null or PCH."U_Terms_Frt" = '' then '' else  PCH."U_Terms_Frt"  end "Freight",
case when PCH."U_Terms_PNF"  is null or PCH."U_Terms_PNF"  = '' then '' else  PCH."U_Terms_PNF"  end "P & N",
PCH.U_BPRefDt 
,PH1.ShipDate 'DueOn'
,PCH.U_Terms_Del
From OPCH PCH
INNER JOIN PCH1 PH1 on PH1.DocEntry=PCH.DocEntry
left Join NNM1 NM1 on PCH.Series=NM1.Series 
left outer join ocrd CRD on PCH.cardcode=crd.CardCode
left outer join (select * from CRD1 )VShipFrom on VShipFrom.Address=PCH.ShipToCode and  VShipFrom.Cardcode=PCH.Cardcode and VShipFrom.AdresType='S'
left outer join (select * from CRD1 )VShipFrom1 on VShipFrom1.Address=CRD.ShipToDef and  VShipFrom1.Cardcode=PCH.Cardcode and VShipFrom1.AdresType='S'
left outer join OGTY GTY2 on VShipFrom1.GSTType=GTY2.AbsEntry
left JOIN OSLP as SLP on PCH.SlpCode = SLP.SlpCode
LEFT OUTER JOIN OSHP SHP ON SHP.Trnspcode = PCH.Trnspcode
LEFT OUTER JOIN OLCT LCT on PH1.LocCode=LCT.Code
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
LEFT OUTER JOIN OCRN ON PCH.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON PCH.GroupNum = OCT.GroupNum 
LEFT OUTER JOIN PCH12 PH12 ON PH12.DocEntry=PCH.DocEntry
left outer join OCST CST1 on CST1.Code=PH12.states and  CST1.Country= PH12.CountryS
LEFT OUTER JOIN OCPR AS CPR ON PCH.CardCode = CPR.CardCode AND PCH.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = PH1.ITEMCODE
left outer join PCH4 CGST On PH1.DocEntry=CGST.DocEntry and PH1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join PCH4 SGST On PH1.DocEntry=SGST.DocEntry and PH1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join PCH4 IGST On PH1.DocEntry=IGST.DocEntry and PH1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1
LEFT OUTER JOIN OPRJ AS PRJ ON PRJ.PrjCode = PCH.Project
go
