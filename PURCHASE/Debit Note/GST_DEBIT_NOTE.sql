
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:03-12-2017 15:40PM  BY:SHITAL*************/

/******************** AAKASH GST_DEBIT_NOTE **********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_DEBIT_NOTE')
DROP VIEW GST_DEBIT_NOTE
GO

CREATE VIEW GST_DEBIT_NOTE
AS

SELECT 

RPC.DocEntry 'Docentry',RPC.DocNum 'Docnum',RPC.DocCur,RPC.DocDate 'Docdate',RPC.NumAtCard 'RefNo'
,NM1.SeriesName 'Docseries'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'') end +RTRIM(LTRIM(CAST(RPC.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) ) as 'Invoice No'
,RPC.numatcard  'OrdNo',RPC.U_BPRefDt 'OrdDate'
,RPC.PayToCode 'BuyerName',RPC.Address 'BuyerAdd',RPC.ShipToCode 'DeilName',RPC.Address2 'DelAdd'
,LCT.Block,LCT.Street,WHS.StreetNo,LCT.Building,LCT.City,LCT.Location,
OCR.NAME 'Country'
,OCS.NAME 'STATE'
,LCT.ZipCode ,LCT.GSTRegnNo 'LocationGSTNO',GTY.GSTType 'LocationGSTType'
,(case when RPC.ExcRefDate is null then RPC.doctime else RPC.ExcRefDate END) 'Supply Time'
,CST.Name 'Supply place',cst.gstCode
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
,CPR.Name 'Salesname',CPR.Cellolar 'Smob',CPR.E_MailL 'Smail'
-------
,(select Name from ocst where Code= RC12.StateS and country=RC12.countrys) 'Delplaceofsupply'
,CPR.E_MailL 'CnctPrsnEmail'
,(select  crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=RPC.cardcode and crd1.AdresType='S' and RPC.ShipToCode=crd1.Address) 'ShipToGSTCode'
,GTY1.GSTType 'ShipToGSTType'
,(select GSTCode from OCST where code=RC12.states and country=RC12.CountryS) 'ShipToStateCode'
,(select Name from ocst where Code= RC12.StateB and country=RC12.countryB) 'BillToState'
,(select GSTCode from OCST where code=RC12.StateB and country=RC12.countryB)  'BillToStateCode'
,(select GTY1.GSTType from  CRD1 CD1 
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry where CD1.CardCode=RPC.CardCode and cd1.Address=RPC.PayToCode and CD1.AdresType='B')'BillToGSTType'
,(select distinct crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=RPC.cardcode and crd1.AdresType='B'and RPC.paytocode=crd1.Address)'BillToGSTCode'
,(SELECT distinct TaxId0 FROM CRD7  WHERE RPC.CardCode = CardCode and RPC.ShipToCode=crd7.Address and addrtype='s')'shipPANNo'
,(SELECT distinct CD7.TaxId0 FROM CRD7 cd7 WHERE RPC.CardCode = CD7.CardCode  and RPC.ShipToCode=cd7.Address and CD7.addrtype='s')'bILLPANNo'
,CPR.Name 'ContactPerson',CPR.Cellolar 'ContactMob',CPR.E_MailL 'ContactMail'
,cpr.Title
---------------------
,RN1.linenum,RN1.ItemCode,RN1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry = (case when RN1.HsnEntry is null then ITM.SACEntry else rn1.hsnentry end))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when RN1.HsnEntry is null then ITM.chapterid else rn1.hsnentry end)) Else '' END) 'HSN Code'
 ,(select  ServCode from OSAC where AbsEntry= RN1.SACEntry) 'Service_SAC_Code'
,RN1.Quantity,RN1.unitMsr,RN1.PriceBefDi,RN1.DiscPrcnt
,(RN1.Quantity*isnull(RN1.PriceBefDi,0)) 'TotalAmt'
,((isnull(RN1.PriceBefDi,0)-isnull(RN1.PriceBefDi,0))*RN1.Quantity) 'ItmDiscAmt'
,case when ocrn.CurrCode='INR' then (isnull(RN1.LineTotal,0)*(isnull(RPC.DiscPrcnt,0)/100)) else (isnull(RN1.TotalFrgn,0)*(isnull(RPC.DiscPrcnt,0)/100)) end 'DocDiscAmt'
,CASE when RPC.DiscPrcnt=0 then ((isnull(RN1.PriceBefDi,0)-isnull(RN1.PriceBefDi,0))*RN1.Quantity) else ((case when OCRN.CurrCode='INR' then isnull(RN1.LineTotal,0) else isnull(RN1.TotalFrgn,0) end) *(isnull(RPC.DiscPrcnt,0)/100)) end 'DiscAmt'
,RN1.Price
,case when ocrn.CurrCode='INR' then isnull(RN1.LineTotal,0) else isnull(RN1.TotalFrgn,0) end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when RPC.DiscPrcnt=0 then isnull(RN1.LineTotal,0) else (isnull(RN1.LineTotal,0)-(isnull(RN1.LineTotal,0)*isnull(RPC.DiscPrcnt,0)/100)) End)
else (CASE when RPC.DiscPrcnt=0 then isnull(RN1.TotalFrgn,0) else (isnull(RN1.TotalFrgn,0)-(isnull(RN1.TotalFrgn,0)*isnull(RPC.DiscPrcnt,0)/100)) End)end 'Total'
,CASE when RN1.AssblValue=0 then 
(CASE when RPC.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then isnull(RN1.LineTotal,0) else isnull(RN1.TotalFrgn,0) end) 
else ((case when ocrn.CurrCode='INR' then isnull(RN1.LineTotal,0) else isnull(RN1.TotalFrgn,0) end)-((case when ocrn.CurrCode='INR' then isnull(RN1.LineTotal,0) else isnull(RN1.TotalFrgn,0) end)*isnull(RPC.DiscPrcnt,0)/100))End)
else (RN1.AssblValue*RN1.Quantity) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,CASE when OCRN.CurrCode='INR' then RPC.DocTotal else RPC.DocTotalFC end 'DocTotal'
,CASE when OCRN.CurrCode='INR' then RPC.RoundDif else RPC.RoundDiffc end RoundDif
,OCRN.CurrName AS 'Currencyname' ,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,RPC.Comments 'Remark',RPC.Header 'Opening Remark',RPC.Footer 'Closing Remark'
,T5.SeriesName + '/' + CAST (inv.docNum as CHAR(20)) as 'Invoice No1'
,inv.docdate 'invDocdate'
,RN1.U_ItemDesc2,RN1.U_ItemDesc3
From ORPC RPC
INNER JOIN RPC1 RN1 on RN1.DocEntry=RPC.DocEntry
left Join NNM1 NM1 on RPC.Series=NM1.Series 
left JOIN OSLP as SLP on RPC.SlpCode = SLP.SlpCode
LEFT OUTER JOIN pch1 AS I1 ON I1.DocEntry = RN1.BaseEntry AND RN1.BaseLine = I1.LineNum
LEFT OUTER JOIN opch AS inv ON inv.DocEntry = I1.DocEntry
LEFT OUTER JOIN NNM1 T5 ON inv.Series = T5.Series
LEFT OUTER JOIN OWHS WHS ON RN1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on RN1.LocCode=LCT.Code
LEFT OUTER JOIN OCRY OCR ON LCT.COUNTRY = OCR.CODE
LEFT OUTER JOIN OCST OCS ON LCT.STATE = OCS.CODE AND LCT.COUNTRY = OCS.COUNTRY
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
LEFT OUTER JOIN OCRN ON RPC.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON RPC.GroupNum = OCT.GroupNum 
-----------------
left outer join CRD1 CD1 on CD1.CardCode=RPC.CardCode and CD1.AdresType='S' and RPC.ShipToCode=CD1.Address
LEFT OUTER JOIN RPC12 RC12 ON RC12.DocEntry=RPC.DocEntry
left outer join OCST CST1 on CST1.Code=RC12.states and  CST1.Country= RC12.CountryS
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry
LEFT OUTER JOIN OCPR AS CPR ON RPC.CardCode = CPR.CardCode AND RPC.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = RN1.ITEMCODE
-----------------------
left outer join RPC4 CGST On RN1.DocEntry=CGST.DocEntry and RN1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join RPC4 SGST On RN1.DocEntry=SGST.DocEntry and RN1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join RPC4 IGST On RN1.DocEntry=IGST.DocEntry and RN1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1

go


