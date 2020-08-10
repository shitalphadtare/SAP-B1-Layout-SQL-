
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:09-03-2018 15:40PM  BY:SHITAL*************/

/********************electrocare proforma invoice***********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_PROFORMA_INVOICE')
DROP VIEW GST_PROFORMA_INVOICE
GO

CREATE VIEW GST_PROFORMA_INVOICE
AS

SELECT 

DPI.DocEntry 'Docentry',DPI.DocNum 'Docnum',DPI.DocCur,DPI.DocDate 'Docdate',DPI.NumAtCard 'RefNo'
,NM1.SeriesName 'Docseries'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'') end +RTRIM(LTRIM(CAST(DPI.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) ) as 'Invoice No'
,DPI.numatcard  'OrdNo',DPI.U_BPRefDt 'OrdDate'
,DPI.PayToCode 'BuyerName',DPI.Address 'BuyerAdd',DPI.ShipToCode 'DeilName',DPI.Address2 'DelAdd'
,LCT.Block,LCT.Street,WHS.StreetNo,LCT.Building,LCT.City,LCT.Location,LCT.Country,LCT.ZipCode ,LCT.GSTRegnNo 'LocationGSTNO',GTY.GSTType 'LocationGSTType'
,(case when DPI.ExcRefDate is null then DPI.doctime else DPI.ExcRefDate END) 'Supply Time'
,CST.Name 'Supply place'
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
,CPR.Name 'Salesname',CPR.Cellolar 'Smob',CPR.E_MailL 'Smail'
-------
,(select Name from ocst where Code= IV12.StateS and country=iv12.countrys) 'Delplaceofsupply'
,CPR.E_MailL 'CnctPrsnEmail'
,(select  crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=DPI.cardcode and crd1.AdresType='S' and DPI.ShipToCode=crd1.Address) 'ShipToGSTCode'
,(select GTY1.GSTType from  CRD1 CD1 
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry where CD1.CardCode=DPI.CardCode and cd1.Address=DPI.shiptocode and CD1.AdresType='S') 'ShipToGSTType'
,(select GSTCode from OCST where code=IV12.BPStateCod and country=iv12.CountryS) 'ShipToStateCode'
,(select distinct crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=DPI.cardcode and crd1.AdresType='B'and DPI.paytocode=crd1.Address)'BillToGSTCode'
,(select GTY1.GSTType from  CRD1 CD1 
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry where CD1.CardCode=DPI.CardCode and cd1.Address=DPI.PayToCode and CD1.AdresType='S')'BillToGSTType'

,(select Name from ocst where Code= IV12.StateB and country=iv12.countryB) 'BillToState'
,(select GSTCode from OCST where code=IV12.StateB and country=iv12.countryB)  'BillToStateCode'
,(SELECT distinct  TaxId0 FROM CRD7  WHERE DPI.CardCode = CardCode AND Address =DPI.ShipToCode and AddrType = 'S')'shipPANNo'
,(SELECT distinct CD7.TaxId0 FROM CRD7 cd7 WHERE DPI.CardCode = CD7.CardCode AND CD7.Address =DPI.PayToCode and AddrType = 'S')'bILLPANNo'
---------------------
,IV1.linenum,IV1.ItemCode,IV1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when IV1.HsnEntry is null then ITM.SACEntry else IV1.HsnEntry end))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when IV1.HsnEntry is null then ITM.chapterid else IV1.HsnEntry end)) Else '' END) 'HSN Code'
 ,(select  ServCode from OSAC where AbsEntry= IV1.SACEntry) 'Service_SAC_Code'
,IV1.Quantity,IV1.unitMsr,IV1.PriceBefDi,IV1.DiscPrcnt
,(isnull(IV1.Quantity,0)*isnull(IV1.PriceBefDi,0)) 'TotalAmt'
,((IV1.PriceBefDi-IV1.Price)*IV1.Quantity) 'ItmDiscAmt'
,case when ocrn.CurrCode='INR' then (isnull(IV1.LineTotal,0)*(isnull(DPI.DiscPrcnt,0)/100)) else (isnull(IV1.TotalFrgn,0)*(isnull(DPI.DiscPrcnt,0)/100)) end 'DocDiscAmt'
,CASE when DPI.DiscPrcnt=0 then ((isnull(IV1.PriceBefDi,0)-isnull(IV1.Price,0))*isnull(IV1.Quantity,0)) else ((case when OCRN.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end) *(isnull(DPI.DiscPrcnt,0)/100)) end 'DiscAmt'
,IV1.Price
,case when ocrn.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when DPI.DiscPrcnt=0 then isnull(IV1.LineTotal,0) else (isnull(IV1.LineTotal,0)-(isnull(IV1.LineTotal,0)*isnull(DPI.DiscPrcnt,0)/100)) End)
else (CASE when DPI.DiscPrcnt=0 then isnull(IV1.TotalFrgn,0) else (isnull(IV1.TotalFrgn,0)-(isnull(IV1.TotalFrgn,0)*isnull(DPI.DiscPrcnt,0)/100)) End)end 'Total'
,CASE when IV1.AssblValue=0 then 
(CASE when DPI.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end) 
else ((case when ocrn.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end)-((case when ocrn.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end)*isnull(DPI.DiscPrcnt,0)/100))End)
else (isnull(IV1.AssblValue,0)*isnull(IV1.Quantity,0)) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,CASE when OCRN.CurrCode='INR' then DPI.DocTotal else DPI.DocTotalFC end 'DocTotal'
,CASE when OCRN.CurrCode='INR' then DPI.RoundDif else DPI.RoundDiffc end RoundDif
,OCRN.CurrName AS 'Currencyname' ,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,DPI.Comments 'Remark',DPI.Header 'Opening Remark',DPI.Footer 'Closing Remark'
,iv1.U_ItemDesc2,IV1.U_ItemDesc3
From ODPI DPI
INNER JOIN DPI1 IV1 on IV1.DocEntry=DPI.DocEntry
left Join NNM1 NM1 on DPI.Series=NM1.Series 
left JOIN OSLP as SLP on DPI.SlpCode = SLP.SlpCode
LEFT OUTER JOIN OWHS WHS ON IV1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on IV1.LocCode=LCT.Code
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
LEFT OUTER JOIN OCRN ON DPI.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON DPI.GroupNum = OCT.GroupNum 
LEFT OUTER JOIN OSHP SHP ON SHP.Trnspcode = DPI.Trnspcode
-----------------
left outer join CRD1 CD1 on CD1.CardCode=DPI.CardCode and CD1.AdresType='S' and dpi.shiptocode=cd1.address
LEFT OUTER JOIN DPI12 IV12 ON IV12.DocEntry=DPI.DocEntry
LEFT OUTER JOIN OCPR AS CPR ON DPI.CardCode = CPR.CardCode AND DPI.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = IV1.ITEMCODE
-----------------------
left outer join DPI4 CGST On IV1.DocEntry=CGST.DocEntry and IV1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join DPI4 SGST On IV1.DocEntry=SGST.DocEntry and IV1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join DPI4 IGST On IV1.DocEntry=IGST.DocEntry and IV1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1

go


