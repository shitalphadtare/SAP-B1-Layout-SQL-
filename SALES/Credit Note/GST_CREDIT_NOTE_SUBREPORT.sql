/****************Created by: SHITAL*****************/
/***********LAST UPDATED:22-12-2017 13:03PM  BY:SHITAL*************/

/********************AAKASH CREDIT NOTE SUB***********************/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='GST_CREDIT_NOTE_SUB')
DROP VIEW GST_CREDIT_NOTE_SUB
GO

CREATE VIEW GST_CREDIT_NOTE_SUB
AS

select 
C.ExpnsCode,C.ExpnsName 'CEX',C.SacCode 'CSAC',I.SacCode 'ISAC',RIN.DocEntry,I.ExpnsName 'IEX'
,CASE when RIN.DocCur='INR' then CGSTBASESUM else CGSTBASESUMFRG end 'CGSTBASESUM',CGSTTAXRATE
,CASE when RIN.DocCur='INR' then CGSTTAXSUM else CGSTTAXSUMFRG end 'CGSTTAXSUM'
,CASE when RIN.DocCur='INR' then SGSTBASESUM else SGSTBASESUMFRG end 'SGSTBASESUM',SGSTRATE
,CASE when RIN.DocCur='INR' then SGSTTAXSUM else SGSTTAXSUMFRG end 'SGSTTAXSUM'
,CASE when RIN.DocCur='INR' then IGSTBASESUM else IGSTBASESUMFRGN end 'IGSTBASESUM',IGSTRATE
,case when RIN.DocCur='INR' then IGSTTAXSUM else IGSTTAXSUMFRG end 'IGSTTAXSUM'

 from orin  RIN
  left outer join
(select distinct i4.DocEntry,ox.ExpnsCode,ox.ExpnsName,ox.SacCode,max(i4.TaxRate) 'IGSTRATE',sum(i4.TaxSum) 'IGSTTAXSUM',sum(i4.TaxSumFrgn) 'IGSTTAXSUMFRG',sum(i4.BaseSum) 'IGSTBASESUM',sum(i4.BaseSumFrg) 'IGSTBASESUMFRGN'
 from RIN4 i4 left outer join oexd ox on ox.expnscode=i4.expnscode where RelateType in (2,3) and  staType=-120 
 group by ox.ExpnsCode,ox.ExpnsName,i4.DocEntry,ox.SacCode) I on  i.DocEntry=RIN.DocEntry   
 left outer join
 (select distinct i4.DocEntry,ox.ExpnsCode,ox.ExpnsName,ox.SacCode,max(i4.TaxRate) 'CGSTTAXRATE',sum(i4.TaxSum) 'CGSTTAXSUM',sum(i4.TaxSumFrgn) 'CGSTTAXSUMFRG',sum(i4.BaseSum) 'CGSTBASESUM',sum(i4.BaseSumFrg) 'CGSTBASESUMFRG'
 from RIN4 i4 left outer join oexd ox on ox.expnscode=i4.expnscode where RelateType in (2,3) and staType=-100 
group by ox.ExpnsCode,ox.ExpnsName,i4.DocEntry,ox.SacCode ) C on RIN.DocEntry=c.DocEntry
left outer join
(select distinct i4.DocEntry,ox.ExpnsCode,ox.ExpnsName,max(i4.TaxRate) 'SGSTRATE',sum(i4.TaxSum) 'SGSTTAXSUM',sum(i4.TaxSumFrgn) 'SGSTTAXSUMFRG',sum(i4.BaseSum) 'SGSTBASESUM',sum(i4.BaseSumFrg) 'SGSTBASESUMFRG'
 from RIN4 i4 left outer join oexd ox on ox.expnscode=i4.expnscode where RelateType in (2,3) and  staType=-110  
group by ox.ExpnsCode,ox.ExpnsName,i4.DocEntry ) S on c.ExpnsCode=s.ExpnsCode and s.DocEntry=RIN.DocEntry

GO

