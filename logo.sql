Create view logo as
SELECT CAST("BitmapPath" AS varchar(5000)) + CAST("LogoFile" AS varchar) AS "logo" FROM OADP
