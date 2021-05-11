WITH t AS
(
SELECT FILE_NAME,TRANS_TYPE,LOAI_HACH_TOAN,
SUM(COUNT) SL_GD_CHAP_THUAN,
SUM(ST_TRICH_NO) ST_BIDV_TRICH_NO,
SUM(ST_TRICH_NO)+SUM(THU_PHI_INTERCHANGE)-SUM(PHI_INTERCHANGE_PHAI_TRA) ST_GD,
SUM(THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,
SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,REVERSAL,T140_DATE
FROM
(
    SELECT FILE_NAME,NGAY_ADV,TRANS_TYPE,CARD_BRN,CURR,COUNT,
    CASE WHEN AMOUNT_TYPE='CR' AND REVERSAL='R' THEN -AMOUNT ELSE AMOUNT END ST_TRICH_NO,
    AMOUNT_TYPE,
    CASE WHEN TRANS_TYPE IN ('GDTTHH','GDMSFF','GDCBRTM') THEN
            (CASE WHEN AMOUNT_TYPE='CR' AND REVERSAL='R' THEN -TRANS_FEE ELSE TRANS_FEE END) 
        ELSE 0 END THU_PHI_INTERCHANGE,
        
    CASE WHEN TRANS_TYPE IN ('GDRTM','GDMSFF','GDCBTTHH') THEN
            (CASE WHEN AMOUNT_TYPE='CR' AND REVERSAL='R' THEN -TRANS_FEE ELSE TRANS_FEE END) 
        ELSE 0 END PHI_INTERCHANGE_PHAI_TRA,
    
    CASE WHEN AMOUNT_TYPE = 'DR' OR (AMOUNT_TYPE='CR' AND REVERSAL='R') THEN 'BAO_NO' ELSE 'BAO_CO' END LOAI_HACH_TOAN,
    CASE WHEN TRANS_TYPE='GDTTHH' THEN 'A' 
        WHEN TRANS_TYPE='GDRTM' THEN 'B' 
        WHEN TRANS_TYPE='GDMSFF' THEN 'C' 
        WHEN TRANS_TYPE='GDNONFI' THEN 'D' 
        WHEN TRANS_TYPE IN ('GDCBTTHH','GDCBRTM') THEN 'E' 
        WHEN TRANS_TYPE='FEECOLL' THEN 'E' END SEQ_NO,
    REVERSAL,T140_DATE
    FROM DSQT_HACH_TOAN
    WHERE NGAY_ADV=20200909 AND CURR='VND' AND CARD_BRN='MD'
    order by TRANS_TYPE DESC
)
GROUP BY FILE_NAME,TRANS_TYPE,LOAI_HACH_TOAN,SEQ_NO,REVERSAL,T140_DATE
ORDER BY SEQ_NO,LOAI_HACH_TOAN DESC
)
SELECT 'A. GIAO DỊCH THANH TOÁN HÀNG HÓA' HACH_TOAN, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE, ' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT '1. Báo nợ' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE, ' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA, T140_DATE, FILE_NAME
FROM t
WHERE TRANS_TYPE='GDTTHH' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDTTHH' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT '2. Báo có' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA, T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDTTHH' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM(THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDTTHH' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Tổng' A,SUM(SL_GD_CHAP_THUAN),
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_BIDV_TRICH_NO ELSE ST_BIDV_TRICH_NO END) ST_BIDV_TRICH_NO, 
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_GD ELSE ST_GD END) ST_GD,
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -THU_PHI_INTERCHANGE ELSE THU_PHI_INTERCHANGE END) THU_PHI_INTERCHANGE,
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -PHI_INTERCHANGE_PHAI_TRA ELSE PHI_INTERCHANGE_PHAI_TRA END) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDTTHH'
UNION ALL
SELECT 'B. GIAO DỊCH RÚT TM' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT '1. Báo nợ' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDRTM' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDRTM' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT '2. Báo có' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDRTM' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDRTM' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Tổng' A,SUM(SL_GD_CHAP_THUAN),
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_BIDV_TRICH_NO ELSE ST_BIDV_TRICH_NO END) ST_BIDV_TRICH_NO, 
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_GD ELSE ST_GD END) ST_GD,
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -THU_PHI_INTERCHANGE ELSE THU_PHI_INTERCHANGE END) THU_PHI_INTERCHANGE,
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -PHI_INTERCHANGE_PHAI_TRA ELSE PHI_INTERCHANGE_PHAI_TRA END) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDRTM'
UNION ALL
SELECT 'C. GIAO DỊCH MONEYSEND' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT '1. Báo nợ' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDMSFF' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDMSFF' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT '2. Báo có' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDMSFF' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDMSFF' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Tổng' A,SUM(SL_GD_CHAP_THUAN),
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_BIDV_TRICH_NO ELSE ST_BIDV_TRICH_NO END) ST_BIDV_TRICH_NO, 
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_GD ELSE ST_GD END) ST_GD,
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -THU_PHI_INTERCHANGE ELSE THU_PHI_INTERCHANGE END) THU_PHI_INTERCHANGE,
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -PHI_INTERCHANGE_PHAI_TRA ELSE PHI_INTERCHANGE_PHAI_TRA END) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDMSFF'
UNION ALL
SELECT 'D. PHÍ GIAO DỊCH PHI TÀI CHÍNH (KHCN)' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT '1. Báo nợ' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDNONFI' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDNONFI' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT '2. Báo có' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDNONFI' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDNONFI' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Tổng' A,SUM(SL_GD_CHAP_THUAN),
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_BIDV_TRICH_NO ELSE ST_BIDV_TRICH_NO END) ST_BIDV_TRICH_NO, 
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_GD ELSE ST_GD END) ST_GD,
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -THU_PHI_INTERCHANGE ELSE THU_PHI_INTERCHANGE END) THU_PHI_INTERCHANGE,
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -PHI_INTERCHANGE_PHAI_TRA ELSE PHI_INTERCHANGE_PHAI_TRA END) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDNONFI'
UNION ALL
SELECT 'E. GIAO DỊCH CHARGEBACK' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT '1. GD thanh toán hàng hóa' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDCBTTHH' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDCBTTHH' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT '2. GD rút tiền mặt' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_GD, THU_PHI_INTERCHANGE, PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='GDCBRTM' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN),SUM(ST_BIDV_TRICH_NO), SUM(ST_GD),SUM (THU_PHI_INTERCHANGE) THU_PHI_INTERCHANGE,SUM(PHI_INTERCHANGE_PHAI_TRA) PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='GDCBRTM' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'F. FEECOLL (không tính vào TỔNG)' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT '1. Báo nợ' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO, ST_BIDV_TRICH_NO ST_GD, NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='FEECOLL' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN) SL_GD_CHAP_THUAN,SUM(ST_BIDV_TRICH_NO) ST_BIDV_TRICH_NO,SUM(ST_BIDV_TRICH_NO) ST_GD, NULL THU_PHI_INTERCHANGE,NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='FEECOLL' AND LOAI_HACH_TOAN='BAO_NO'
UNION ALL
SELECT '2. Báo có' A, NULL SL_GD_CHAP_THUAN,NULL ST_BIDV_TRICH_NO, NULL ST_GD,NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM DUAL
UNION ALL
SELECT ' ' A,SL_GD_CHAP_THUAN,ST_BIDV_TRICH_NO,ST_BIDV_TRICH_NO ST_GD, NULL THU_PHI_INTERCHANGE, NULL PHI_INTERCHANGE_PHAI_TRA,T140_DATE,FILE_NAME
FROM t
WHERE TRANS_TYPE='FEECOLL' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Cộng' A,SUM(SL_GD_CHAP_THUAN) SL_GD_CHAP_THUAN, SUM(ST_BIDV_TRICH_NO) ST_BIDV_TRICH_NO,SUM(ST_BIDV_TRICH_NO) ST_GD ,NULL THU_PHI_INTERCHANGE,NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='FEECOLL' AND LOAI_HACH_TOAN='BAO_CO'
UNION ALL
SELECT 'Tổng' A,SUM(SL_GD_CHAP_THUAN),
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_BIDV_TRICH_NO ELSE ST_BIDV_TRICH_NO END) ST_BIDV_TRICH_NO, 
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_BIDV_TRICH_NO ELSE ST_BIDV_TRICH_NO END) ST_GD,
NULL THU_PHI_INTERCHANGE,
NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE='FEECOLL'
UNION ALL
SELECT 'TỔNG' A,SUM(SL_GD_CHAP_THUAN),
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_BIDV_TRICH_NO ELSE ST_BIDV_TRICH_NO END) ST_BIDV_TRICH_NO, 
SUM(CASE WHEN LOAI_HACH_TOAN='BAO_CO' THEN -ST_GD ELSE ST_GD END) ST_GD,
NULL THU_PHI_INTERCHANGE,
NULL PHI_INTERCHANGE_PHAI_TRA,' ' T140_DATE,' ' FILE_NAME
FROM t
WHERE TRANS_TYPE<>'FEECOLL'



