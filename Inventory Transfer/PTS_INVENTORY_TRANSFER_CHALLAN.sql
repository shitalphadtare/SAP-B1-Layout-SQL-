
IF EXISTS(SELECT *
     FROM sys.views
     WHERE name = 'PTS_INVENTORY_TRANSFER_CHALLAN' AND
     schema_id = SCHEMA_ID('dbo'))
DROP VIEW [dbo].[PTS_INVENTORY_TRANSFER_CHALLAN]
GO

/****** Object:  View [dbo].[PTS_INVENTORY_TRANSFER_CHALLAN]    Script Date: 07/20/2016 15:33:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PTS_INVENTORY_TRANSFER_CHALLAN]
AS



select  
T0.DocEntry,
T0.DocNum as 'Delivery No',
T0.DocDate as 'Date',
t1.SeriesName + '/' + CAST(t0.DocNum as CHAR(20))  as 'Del Series No',
T0.CardName as 'CardName',
t0.Address as 'Address',
(CASE When T0.CntctCode is Not null   THEN (select Name from OCPR where  CntctCode=T0.CntctCode and CardCode=T0.CardCode )else '' END) as 'Contact Person',
T0.U_Purpose as 'Process1',
T2.ItemCode as 'Item Code',
T2.Dscription as 'Item Description',
T2.Quantity as 'Quantity',
T0.U_lnrefdt as 'Delivery Date',
(CASE when T0.U_Purpose IS not null then (select ufd1.Descr from ufd1 inner join CUFD on  UFD1.TableID = CUFD.TableID where CUFD.TableID = 'OWTR' and UFD1.FieldID = CUFD.FieldID and cufd.AliasID = 'Purpose' and T0.U_Purpose = UFD1.FldValue ) else '' end ) as 'Process'

from OWTR as T0
INNER JOIN NNM1 AS T1 ON T0.Series = T1.Series
INNER JOIN WTR1 AS T2 ON T0.DocEntry = T2.DocEntry


GO