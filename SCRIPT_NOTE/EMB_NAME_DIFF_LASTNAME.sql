SELECT A.F9_DW005_CRN,A.PX_DW005_PAN,A.F9_DW005_LOC_ACCT,A.FX_DW005_EMB_NAME,B.FX_DW002_NAME,
SUBSTR (FX_DW002_NAME, 1, INSTR(TRIM(FX_DW002_NAME), ' ', 1, 1)-1) FIRSTNAME,
SUBSTR (FX_DW002_NAME, INSTR(TRIM(FX_DW002_NAME), ' ', 1) +1, INSTR(TRIM(FX_DW002_NAME), ' ', -1, 1) - INSTR(TRIM(FX_DW002_NAME), ' ', 1, 1)-1) MIDNAME,
SUBSTR (FX_DW002_NAME, INSTR(TRIM(FX_DW002_NAME), ' ', -1) +1)  LASTNAME
FROM DW005 A
INNER JOIN DW002 B ON A.F9_DW005_CRN=B.P9_DW002_CRN
WHERE TRIM(A.FX_DW005_EMB_NAME)<>TRIM(SUBSTR (FX_DW002_NAME, INSTR(TRIM(FX_DW002_NAME), ' ', -1) +1));


SELECT * FROM IR056@IM ;--FX_IR056_NAME

SELECT * FROM IR025@IM ;--FX_IR025_EMB_NAME


SELECT A.F9_IR025_CRN,DED2@IM(A.PX_IR025_PAN,''),F9_IR025_LOC_ACCT,A.FX_IR025_EMB_NAME,B.FX_IR056_NAME,
SUBSTR (FX_IR056_NAME, INSTR(TRIM(FX_IR056_NAME), ' ', -1) +1)  LASTNAME
FROM IR025@IM A
INNER JOIN IR056@IM B ON A.F9_IR025_CRN=B.P9_IR056_CRN
WHERE TRIM(A.FX_IR025_EMB_NAME)<>TRIM(SUBSTR (FX_IR056_NAME, INSTR(TRIM(FX_IR056_NAME), ' ', -1) +1))
AND F9_IR025_CNCL_DT = 0 AND F9_IR025_CRD_ATV_DT <> 0
AND F9_IR025_LOC_ACCT LIKE '20%'