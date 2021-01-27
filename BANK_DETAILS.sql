CREATE VIEW  BANK_DETAILS  AS SELECT
	 DISTINCT "RevOffice" AS "Pan No",
	 "DflBnkCode" AS "bankcode",
	 dsc."BankName",
	 "DflBnkAcct" AS "account no",
	 "DflBranch" AS "branch",
	 dc1."SwiftNum" 
FROM OADM ADM 
LEFT OUTER JOIN ODSC dsc ON adm."DflBnkCode" = dsc."BankCode" 
AND "DflBnkAcct" = "DflBnkCode" 
LEFT OUTER JOIN DSC1 dc1 ON adm."DflBnkCode" = dc1."BankCode" 
AND "DflBnkAcct" ="Account"
-----------------------------------------------------------------------------------------------------------------------------
create View Bank_Details as
select distinct revoffice 'Pan No',dflbnkcode 'bankcode',dflbnkacct 'account no',dflbranch 'branch',
dsc.swiftnum ,dsC.banknaME,+isnull(cast(street as varchar)+' ','')

+isnull(cast(Building as varchar)+' ','')
+isnull(cast(streetno  as varchar)+' ','')
+isnull(cast(Block as varchar)+' ','')
+isnull(cast(City as varchar)+' ','')+isnull(cast(cst.Name as varchar)+' - ','')
+isnull(cast(ocry.Name as varchar)+'.','')
+isnull(cast(zipcode as varchar)+' ','')  'Address'

from oadm ADM
LEFT OUTER JOIN ODSC dsc ON adm."DflBnkCode" = dsc."BankCode" 
AND "DflBnkAcct" = "DflBnkCode" 
LEFT OUTER JOIN DSC1 dc1 ON adm."DflBnkCode" = dc1."BankCode" 
AND "DflBnkAcct" ="Account"

left outer join OCRY on ocry.Code=dc1.Country
left outer join ocst cst on dc1.country=cst.country and cst.code=dc1.state
