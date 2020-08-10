IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_PURCHASE_QUOTATION')
DROP VIEW GST_PURCHASE_QUOTATION
GO
								
CREATE VIEW [dbo].[GST_PURCHASE_QUOTATION]
AS

SELECT 
PQT.DocEntry 'Docentry'
,PQT.DocNum 'Docnum'
,PQT.DocCur
,NM1.SeriesName 'Docseries'
,PQT.DocDate 'Docdate'
,isnull(nm1.BeginStr,'')+RTRIM(LTRIM(CAST(PQT.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) as 'Purchase No'
,PQT.CardCode+ '/' + PQT.CardName 'VName'
,PQT.Address 'VendorAdd'
,CPR.Name 'V_CNCTP_N'
,CPR.E_MailL 'V_CnctP_E'
,VShipFrom.Block
,VShipFrom.Building
,VShipFrom.Street
,VShipFrom.City
,VShipFrom.ZipCode
,(select distinct Name from OCRY where Code=VShipFrom.Country) 'country'
,VShipFrom.STREETNO 'Street No_Vendor'
,(select distinct name  from ocst where Code=VShipFrom.state and VShipFrom.country=Ocst.Country) 'STATE_Vendor'
,VShipFrom.GSTRegnNo 'VShipGSTNo'
,GTY2.GSTType 'VShipGSTType'
,PQT.NumAtCard 'SupRefNo'
,'' 'SupDate'
,(select  SUBSTRING((SELECT  distinct ( Cast(OPRQ.DocNum AS CHAR(7))) + ', ' AS 'data()' 
FROM  OPRQ inner join PQT1  on  OPRQ.Docentry=PQT1.baseentry  and PQT1.docentry=PQT.docentry 
  left outer join  NNM1 on NNM1.Series=OPRQ.Series        
FOR XML PATH('')) ,1,len((SELECT distinct  ( Cast(OPRQ.DocNum AS CHAR(7)) )+ ', ' AS 'data()'  
FROM  OPRQ inner join PQT1  on   OPRQ.Docentry=PQT1.baseentry  and PQT1.docentry=PQT.docentry 
left outer join  NNM1 on NNM1.Series=OPRQ.Series
FOR XML PATH('') ))-1)) 'PR No''PR_No'
,(select  SUBSTRING((SELECT  Distinct Cast(CONVERT(VARCHAR,OPRQ.DocDate,105) as char(10)) + ', ' AS 'data()' 
FROM  OPRQ inner join PQT1  on   OPRQ.Docentry=PQT1.baseentry where PQT1.docentry=PQT.docentry
FOR XML PATH('')) ,1,len((SELECT  Distinct Cast(CONVERT(VARCHAR,OPRQ.DocDate,105) as char(10)) + ', ' AS 'data()'  
FROM  OPRQ inner join PQT1  on   OPRQ.Docentry=PQT1.baseentry where PQT1.docentry=PQT.docentry
FOR XML PATH('') ))-1))'PR Date'
,PQT.DocDueDate 'DeliDate'
,SHP.TrnspName 'Deli_Mode'
,PQT.Address2 'Deli_Addr'
,LCT.GSTRegnNo 'Deli_GST'
,GTY.GSTType 'Deli_GSTType'
-----------------------------------------------------------------------------------------------------------
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
-------------------------------------------------------------------------

,CPR.E_MailL 'CnctPrsnEmail'
-------------------------------------------------------------------------
,PR1.linenum
,PR1.ItemCode
,PR1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when PR1.HsnEntry=null then ITM.SACEntry else PR1.HsnEntry end))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when PR1.HsnEntry=null then ITM.SACEntry else PR1.HsnEntry end))  
  Else '' END) 'HSN Code'
,(select  ServCode from OSAC where AbsEntry= PR1.SACEntry) 'Service_SAC_Code'
,PR1.PQTReqQty 'Req_Qty'
,pr1.PQTReqDate 'Req_Date'
,pr1.Quantity 'Quoted_QTy'
,PR1.unitMsr
,PR1.PriceBefDi 'Quoted_Price'
,pr1.ShipDate 'Quoted_Date'
,PR1.DiscPrcnt
,(PR1.Quantity*PR1.PriceBefDi) 'TotalAmt'
,((PR1.PriceBefDi-PR1.Price)*PR1.Quantity) 'ItmDiscAmt'
,((case when ocrn.CurrCode='INR' then PR1.LineTotal else PR1.TotalFrgn end)*(PQT.DiscPrcnt/100)) 'DocDiscAmt'
,CASE when PQT.DiscPrcnt=0 then ((PR1.PriceBefDi-PR1.Price)*PR1.Quantity) else ((case when ocrn.CurrCode='INR' then PR1.LineTotal else PR1.TotalFrgn end)*(PQT.DiscPrcnt/100)) end 'DiscAmt'
,PR1.Price
,case when ocrn.CurrCode='INR' then PR1.LineTotal else PR1.TotalFrgn end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when PQT.DiscPrcnt=0 then PR1.LineTotal else (PR1.LineTotal-(PR1.LineTotal*PQT.DiscPrcnt/100)) End)
else (CASE when PQT.DiscPrcnt=0 then PR1.TotalFrgn else (PR1.TotalFrgn-(PR1.TotalFrgn*PQT.DiscPrcnt/100)) End)end 'Total'
,CASE when PR1.AssblValue=0 
then 
(CASE when PQT.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then PR1.LineTotal else PR1.TotalFrgn end)
 else ((case when ocrn.CurrCode='INR' then PR1.LineTotal else PR1.TotalFrgn end)-((case when ocrn.CurrCode='INR' then PR1.LineTotal else PR1.TotalFrgn end)*PQT.DiscPrcnt/100))End)
else (PR1.AssblValue*PR1.Quantity) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,PQT.DocTotal
,PQT.RoundDif
,OCRN.CurrName AS 'Currencyname' 
,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,PQT.Comments 'Remark'
,PQT.Header 'Opening Remark'
,PQT.Footer 'Closing Remark'
,PRJ.PrjName 'PrjName'
,PR1.ShipDate 'ShipDate'
,PQT.U_OCNo 'U_OC_No'
,CPR.Cellolar
,case when PQT."U_Terms_Del"  is null or PQT."U_Terms_Del" = '' then '' else   PQT."U_Terms_Del" end "Delivery",
case when PQT."U_Terms_Pay"   is null or PQT."U_Terms_Pay"  = '' then '' else   PQT."U_Terms_Pay"  end "Payment",
case when PQT."U_Terms_Insp"  is null or PQT."U_Terms_Insp" = '' then '' else  PQT."U_Terms_Insp"  end "Ispection",
case when PQT."U_Terms_Price"  is null or PQT."U_Terms_Price" = '' then '' else  PQT."U_Terms_Price"  end "Terms_Price",
case when PQT."U_Terms_PackInst"  is null or PQT."U_Terms_PackInst"  = '' then '' else  PQT."U_Terms_PackInst"  end "Packing Instruction",
case when PQT."U_Terms_Insu"  is null or PQT."U_Terms_Insu" = '' then '' else  PQT."U_Terms_Insu"   end "Insurance",
case when PQT."U_Terms_Frt" is null or PQT."U_Terms_Frt" = '' then '' else  PQT."U_Terms_Frt"  end "Freight",
case when PQT."U_Terms_PNF"  is null or PQT."U_Terms_PNF"  = '' then '' else  PQT."U_Terms_PNF"  end "P & N",
PQT.U_BPRefDt ,
PT10.LineText,
PQT.project
,pr1.U_itemdesc2
,pr1.U_itemdesc3
From OPQT PQT
INNER JOIN PQT1 PR1 on PR1.DocEntry=PQT.DocEntry
Inner Join NNM1 NM1 on PQT.Series=NM1.Series 
left outer join (select * from CRD1 )VShipFrom on VShipFrom.Address=PQT.ShipToCode and  VShipFrom.Cardcode=PQT.Cardcode and VShipFrom.AdresType='S'
left outer join OGTY GTY2 on VShipFrom.GSTType=GTY2.AbsEntry
INNER JOIN OSLP as SLP on PQT.SlpCode = SLP.SlpCode
LEFT OUTER JOIN OSHP SHP ON SHP.Trnspcode = PQT.Trnspcode
LEFT OUTER JOIN OLCT LCT on PR1.LocCode=LCT.Code
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
LEFT OUTER JOIN OCRN ON PQT.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON PQT.GroupNum = OCT.GroupNum 
LEFT OUTER JOIN PQT12 PR12 ON PR12.DocEntry=PQT.DocEntry
left outer join OCST CST1 on CST1.Code=PR12.BpStateCod and  CST1.Country= PR12.CountryS
LEFT OUTER JOIN OCPR AS CPR ON PQT.CardCode = CPR.CardCode AND PQT.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = PR1.ITEMCODE
left outer join PQT4 CGST On PR1.DocEntry=CGST.DocEntry and PR1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join PQT4 SGST On PR1.DocEntry=SGST.DocEntry and PR1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join PQT4 IGST On PR1.DocEntry=IGST.DocEntry and PR1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1
LEFT OUTER JOIN OPRJ AS PRJ ON PRJ.PrjCode = PQT.Project
left outer join PQT10 PT10 on  PT10.AFTLINENUM+1=PR1.VISORDER and PR1.docentry=PT10.docentry
GO


