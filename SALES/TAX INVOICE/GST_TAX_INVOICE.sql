
/****************Created by: SHITAL*****************/
/***********LAST UPDATED:26-06-2018  BY:SHITAL*************/

/********************TAX INVOICE***********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_TAX_INVOICE')
DROP VIEW GST_TAX_INVOICE
GO

CREATE VIEW GST_TAX_INVOICE
AS

SELECT inv.cardcode ,
INV.DocEntry 'Docentry',INV.DocNum 'Docnum',INV.DocCur,INV.DocDate 'Docdate',INV.NumAtCard 'RefNo'
,inv.project,NM1.SeriesName 'Docseries'
,(case when nm1.BeginStr is null then ISNULL(NM1.BeginStr, N'') else ISNULL(NM1.BeginStr, N'') end +RTRIM(LTRIM(CAST(INV.DocNum as CHAR(20))))  +(case when nm1.EndStr is null then ISNULL(NM1.EndStr, N'') else (ISNULL(NM1.Endstr, N''))  end ) ) as 'Invoice No'
--,NM11.seriesname 'ordseries'
--,nm11.seriesname+'/'+cast(rdr.docnum as varchar) 'OrdNo'
--,rdr.DocDate 'OrdDate'
,STUFF((SELECT distinct  ', ' + CAST(nm1.seriesname+'/'+cast(rdr.docnum as varchar) AS VARCHAR(20)) [text()]
         FROM rdr1 rr1
         left outer join ordr rdr on rr1.docentry=rdr.docentry
         left outer join nnm1 nm1 on rdr.series=nm1.series
         left outer join dln1 dn1 On DN1.BaseEntry=RR1.DocEntry and DN1.BaseLine=RR1.LineNum and 
         rr1.objtype=dn1.basetype
         inner join odln dln on dn1.docentry=dln.docentry         
         left join inv1 iv1 on iv1.baseentry=dn1.docentry and iv1.basetype=dn1.objtype
         and iv1.baseline=dn1.linenum
         WHERE  iv1.docentry=inv.docentry 
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ')'OrdNo'
,STUFF((SELECT distinct  ', ' + CAST(convert(varchar,rdr.docdate,105) AS VARCHAR(20)) [text()]
         FROM rdr1 rr1
         left outer join ordr rdr on rr1.docentry=rdr.docentry
         left outer join nnm1 nm1 on rdr.series=nm1.series
         left outer join dln1 dn1 On DN1.BaseEntry=RR1.DocEntry and DN1.BaseLine=RR1.LineNum and 
         rr1.objtype=dn1.basetype
         inner join odln dln on dn1.docentry=dln.docentry         
         left join inv1 iv1 on iv1.baseentry=dn1.docentry and iv1.basetype=dn1.objtype
         and iv1.baseline=dn1.linenum
         WHERE  iv1.docentry=inv.docentry 
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') 'OrdDate'
,inv.numatcard  'suplier ref',INV.U_BPRefDt 'supDate',
--,nm2.seriesname+'/'+cast(DLN.Docnum as varchar)'Challan No',DLN.DocDate 'Challan Date'
STUFF((SELECT distinct  ', ' + CAST(nm1.seriesname+'/'+cast(dln.docnum as varchar)  AS VARCHAR(20)) [text()]
         FROM dln1 dn1
         inner join odln dln on dn1.docentry=dln.docentry
         left outer join nnm1 nm1 on dln.series=nm1.series
         left join inv1 iv1 on iv1.baseentry=dn1.docentry and iv1.basetype=dn1.objtype
         and iv1.baseline=dn1.linenum
         WHERE  iv1.docentry=inv.docentry 
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') 'Challan No'
,STUFF((SELECT distinct  ', ' + CAST(convert(varchar,dln.docdate,105)  AS VARCHAR(10)) [text()]
         FROM dln1 dn1
         inner join odln dln on dn1.docentry=dln.docentry
         left outer join nnm1 nm1 on dln.series=nm1.series
         left join inv1 iv1 on iv1.baseentry=dn1.docentry and iv1.basetype=dn1.objtype
         and iv1.baseline=dn1.linenum
         WHERE  iv1.docentry=inv.docentry 
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') 'Challan Date'
,INV.PayToCode 'BuyerName',INV.Address 'BuyerAdd',INV.ShipToCode 'DeilName',INV.Address2 'DelAdd'
,LCT.Block,LCT.Street,WHS.StreetNo,LCT.Building,LCT.City,LCT.Location,LCT.Country,LCT.ZipCode ,LCT.GSTRegnNo 'LocationGSTNO',GTY.GSTType 'LocationGSTType'
,(select GSTCode from OCST where code=lct.state) as state
,(case when INV.ExcRefDate is null then INV.doctime else INV.ExcRefDate END) 'Supply Time'
,CST.Name 'Supply place'
,CASE WHEN SLP.SlpName = '-No Sales Employee-' THEN '' ELSE SLP.SlpName END 'SalesPrsn'
,SLP.Mobil 'salesmob',SLP.Email 'SalesEmail'
-------
,(select Name from ocst where Code= IV12.StateS and country=iv12.countrys) 'Delplaceofsupply'
,CPR.E_MailL 'CnctPrsnEmail'
,(select  crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=INV.cardcode and crd1.AdresType='S' and INV.ShipToCode=crd1.Address) 'ShipToGSTCode'
,GTY1.GSTType 'ShipToGSTType'
,(select GSTCode from OCST where code=IV12.states and country=iv12.CountryS) 'ShipToStateCode'
,(select Name from ocst where Code= IV12.StateB and country=iv12.countryB) 'BillToState'
,(select GSTCode from OCST where code=IV12.StateB and country=iv12.countryB)  'BillToStateCode'
,(select GTY1.GSTType from  CRD1 CD1 
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry where CD1.CardCode=INV.CardCode and cd1.Address=inv.PayToCode and CD1.AdresType='B')'BillToGSTType'
,(select distinct crd1.gstRegnNo
 from crd1 inner join 
 ocrd on ocrd.cardcode=crd1.cardcode  where  ocrd.cardcode=INV.cardcode and crd1.AdresType='B'and INV.paytocode=crd1.Address)'BillToGSTCode'
,(SELECT distinct TaxId0 FROM CRD7  WHERE INV.CardCode = CardCode and inv.ShipToCode=crd7.Address and addrtype='s')'shipPANNo'
,(SELECT distinct CD7.TaxId0 FROM CRD7 cd7 WHERE INV.CardCode = CD7.CardCode  and inv.ShipToCode=cd7.Address and CD7.addrtype='s')'bILLPANNo'
,CPR.Name 'ContactPerson',CPR.Cellolar 'ContactMob',CPR.E_MailL 'ContactMail'
,cpr.Title,cst.gstCode
---------------------
,IV1.linenum,IV1.ItemCode,IV1.Dscription
,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when  IV1.HsnEntry is  null then  ITM.SACEntry else IV1.HsnEntry end))  
  When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when  IV1.HsnEntry is  null then  ITM.chapterid else IV1.HsnEntry end)) Else '' END) 'HSN Code'
,(select  ServCode from OSAC where AbsEntry= IV1.SACEntry) 'Service_SAC_Code'
,IV1.Quantity,IV1.unitMsr,IV1.PriceBefDi,IV1.DiscPrcnt
,(IV1.Quantity*IV1.PriceBefDi) 'TotalAmt'		
,((isnull(IV1.PriceBefDi,0)-isnull(IV1.Price,0))*isnull(IV1.Quantity,0)) 'ItmDiscAmt'
,case when ocrn.CurrCode='INR' then (isnull(IV1.LineTotal,0)*(isnull(INV.DiscPrcnt,0)/100)) else (isnull(IV1.TotalFrgn,0)*(isnull(INV.DiscPrcnt,0)/100)) end 'DocDiscAmt'
,CASE when INV.DiscPrcnt=0 then ((isnull(IV1.PriceBefDi,0)-isnull(IV1.Price,0))*isnull(IV1.Quantity,0)) else ((case when OCRN.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end) *(isnull(INV.DiscPrcnt,0)/100)) end 'DiscAmt'
,IV1.Price
,case when ocrn.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end 'LineTotal'
,case when OCRN.CurrCode='INR' then (CASE when INV.DiscPrcnt=0 then isnull(IV1.LineTotal,0) else (isnull(IV1.LineTotal,0)-(isnull(IV1.LineTotal,0)*isnull(INV.DiscPrcnt,0)/100)) End)
else (CASE when INV.DiscPrcnt=0 then isnull(IV1.TotalFrgn,0) else (isnull(IV1.TotalFrgn,0)-(isnull(IV1.TotalFrgn,0)*isnull(INV.DiscPrcnt,0)/100)) End)end 'Total'
,CASE when IV1.AssblValue=0 then 
(CASE when INV.DiscPrcnt=0 then (case when ocrn.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end) 
else ((case when ocrn.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end)-((case when ocrn.CurrCode='INR' then isnull(IV1.LineTotal,0) else isnull(IV1.TotalFrgn,0) end)*isnull(INV.DiscPrcnt,0)/100))End)
else (IV1.AssblValue*IV1.Quantity) end 'TotalAsseble'
,CGST.TaxRate CGSTRate
,CASE when OCRN.CurrCode='INR' then CGST.TaxSum else CGST.TaxSumFrgn end CGST
,SGST.TaxRate SGSTRate
,CASE when OCRN.CurrCode='INR' then SGST.TaxSum else SGST.TaxSumFrgn end SGST
,IGST.TaxRate IGSTRate
,CASE when OCRN.CurrCode='INR' then IGST.TaxSum else IGST.TaxSumFrgn end IGST
--------------------------------------------
,CASE when OCRN.CurrCode='INR' then  INV.DocTotal else INV.Doctotalfc end 'DocTotal'
,CASE when OCRN.CurrCode='INR' then INV.RoundDif else INV.RoundDiffc end RoundDif
,OCRN.CurrName AS 'Currencyname' ,OCRN.F100Name AS 'Hundredthname'
,OCT.PymntGroup 'Payment Terms'
,INV.Comments 'Remark',INV.Header 'Opening Remark',INV.Footer 'Closing Remark'
,iv1.U_itemdesc2 'desc'
,shp.TrnspName
,inv.U_terms_del
,inv.shiptocode
,inv.U_Port_Dish 'despatch thr'
,inv.U_otheref 'Despatchdocnum'
,inv.U_Place_Receipt 'Segment'
,iv1.U_itemdesc2
,iv1.U_itemdesc3
,inv.DiscPrcnt 'DocLevelcnt'
--,inv.U_RevChrg
From OINV INV
INNER JOIN INV1 IV1 on IV1.DocEntry=INV.DocEntry
left Join NNM1 NM1 on INV.Series=NM1.Series 
left JOIN OSLP as SLP on INV.SlpCode = SLP.SlpCode
LEFT OUTER JOIN OWHS WHS ON IV1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on IV1.LocCode=LCT.Code
left outer join OGTY GTY On LCT.GSTType=GTY.AbsEntry 
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
--Left Outer Join DLN1 DN1 On IV1.BaseEntry=DN1.DocEntry and IV1.BaseLine=DN1.LineNum and IV1.BaseType=DN1.ObjType
--left outer join ODLN DLN on DLN.DocEntry=DN1.DocEntry
--left Join NNM1 NM2 on DLN.Series=NM2.Series 
--Left Outer Join RDR1 RR1 On DN1.BaseEntry=RR1.DocEntry and DN1.BaseLine=RR1.LineNum 
--left outer Join ORDR RDR On RR1.DocEntry=RDR.DocEntry 
LEFT OUTER JOIN OCRN ON INV.DocCur = OCRN.CurrCode  
LEFT OUTER JOIN OCTG  OCT ON INV.GroupNum = OCT.GroupNum 
-----------------
left outer join CRD1 CD1 on CD1.CardCode=INV.CardCode and CD1.AdresType='S' and INV.ShipToCode=CD1.Address
LEFT OUTER JOIN INV12 IV12 ON IV12.DocEntry=INV.DocEntry
left outer join OCST CST1 on CST1.Code=IV12.BpStateCod and  CST1.Country= IV12.CountryS
left outer join OGTY GTY1 on CD1.GSTType=GTY1.AbsEntry
LEFT OUTER JOIN OCPR AS CPR ON INV.CardCode = CPR.CardCode AND INV.cntctcode = CPR.cntctcode
LEFT OUTER JOIN OITM AS ITM ON ITM.ITEMCODE = IV1.ITEMCODE
-----------------------
--left outer join NNM1 NM11 On RDR.Series=NM11.Series 
left outer join INV4 CGST On IV1.DocEntry=CGST.DocEntry and IV1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 
left outer join INV4 SGST On IV1.DocEntry=SGST.DocEntry and IV1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1
left outer join INV4 IGST On IV1.DocEntry=IGST.DocEntry and IV1.LineNum=IGST.LineNum and IGST.staType in (-120) and IGST.RelateType=1
left outer join oshp shp on inv.TrnspCode=shp.TrnspCode
GO
