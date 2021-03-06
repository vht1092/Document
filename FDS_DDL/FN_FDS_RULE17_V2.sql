--------------------------------------------------------
--  DDL for Function FN_FDS_RULE17_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE17_V2" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    CHAUTK   19DEC2016     THE GIAO DICH ONLINE KHONG CO 3D SECURE VOI SO   *
*                               TIEN >= 5TR VND HOAC NGOAI TE TUONG DUONG        *
* 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
*                               DICH                                             *
* 2.1    HUYENNT  05JUL2017     THE GIAO DICH KEY ENTER & ECOMMERCE KHONG CO 3DS *
*                               TRONG VONG 2H THEO HANG THE VA SO TIEN GD        *
* 3.0    HUYENNT  04MAY2018     CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
*                               SO 70/BC-GS&XLTST&NHDT                           *
* 4.0    HUYENNT  12FEB2019     CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
*                               NGAY 21JAN2019                                   *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_POS_MOD IN VARCHAR2,--ADD ON 21022017
    P_CARDNO IN VARCHAR2,
    P_CRD_PRD IN CHAR,--ADD ON 20170705
    P_CRCY_CDE IN CHAR,--ADD ON 20170705
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    P_END_TMS IN VARCHAR2,
    P_CHECK IN VARCHAR2,
    P_CNT OUT NUMBER
 ) RETURN VARCHAR2
 AS
    SQL_STMT VARCHAR2(4000);
    SQL_STMT2 VARCHAR2(4000);
    STRT_TMS VARCHAR(17);
    CRE_TMS VARCHAR(17);
    CASE_ID VARCHAR2(50);
    V_R_VND_AMT NUMBER:=1000000; --TONG SO TIEN GIAO DICH THE CHUAN VND
    V_G_VND_AMT NUMBER:=2000000; --TONG SO TIEN GIAO DICH THE VANG VND
    --V_R_OTH_AMT NUMBER:=800000; --TONG SO TIEN GIAO DICH THE CHUAN NGOAI TE
    --V_G_OTH_AMT NUMBER:=2000000; --TONG SO TIEN GIAO DICH THE VANG NGOAI TE
    V_TOTAL_AMT NUMBER;
    V_TOTAL_AMT1 NUMBER;
    V_TOTAL_AMT2 NUMBER;
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'SP_FDS_RULE17';
    V_RULENAME VARCHAR2(6):='RULE17';
    L_CHECK_POINT NUMBER:=1;
    V_TXDATE NUMBER:=TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME NUMBER:=TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME NUMBER:=0;
    V_STS VARCHAR(10):= 'START';-- START / DONE / ERROR
    V_STSDESC VARCHAR2(4000):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    V_POS_MOD VARCHAR2(3) := SUBSTR(P_POS_MOD,1,2);
    V_TIME_PERIOD NUMBER := 2;
BEGIN
    --INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    --COMMIT;
    IF P_TXN_AMT > 0 AND (V_POS_MOD = '01' OR V_POS_MOD = '81' OR V_POS_MOD = '10') AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN
      ---CHECK thong tin gd co 3D Secure hay khong---
      select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
      V_3D_CHK := NVL(V_3D_CHK,0);
      IF V_3D_CHK = 0 THEN--GD KHONG QUA 3DS
          STRT_TMS := TMS_ADD_SUBTRACT(V_TIME_PERIOD,P_END_TMS);
          ---START: TINH TONG GD THEO LOAI TIEN TRONG VONG 2H---
          SELECT SUM(T.F9_OA008_AMT_REQ) INTO V_TOTAL_AMT FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN ('01','81','10') AND T.FX_OA008_USED_PAN = P_CARDNO AND (upper(T.FX_OA008_MERC_NAME) not like '%AGODA%' and upper(T.FX_OA008_MERC_NAME) not like '%BOOKING.COM%' and upper(T.FX_OA008_MERC_NAME) not like '%TRAVELOKA%' and upper(T.FX_OA008_MERC_NAME) not like '%AIRBNB%' and T.F9_OA008_MCC not in (select mcc from ccps.fds_excpt_mcc where tcc = 'Airline')) and T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;
          --TONG SO TIEN GD TAI CAC DVCNT: AGODA, BOOKING.COM, TRAVELOKA, AIRBNB
          SELECT SUM(T.F9_OA008_AMT_REQ) INTO V_TOTAL_AMT1 FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN ('01','81','10') AND T.FX_OA008_USED_PAN = P_CARDNO AND (upper(T.FX_OA008_MERC_NAME) like '%AGODA%' or upper(T.FX_OA008_MERC_NAME) like '%BOOKING.COM%' OR upper(T.FX_OA008_MERC_NAME) like '%TRAVELOKA%' OR upper(T.FX_OA008_MERC_NAME) like '%AIRBNB%') and T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;
          --TONG SO TIEN GD TAI CAC DVCNT: VIETJET, JETSTAR
          SELECT SUM(T.F9_OA008_AMT_REQ) INTO V_TOTAL_AMT2 FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN ('01','81','10') AND T.FX_OA008_USED_PAN = P_CARDNO AND T.F9_OA008_MCC in (select mcc from ccps.fds_excpt_mcc where tcc = 'Airline') and T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;
          --BAT DAU CHECK CHUOI CAC DIEU KIEN LOC
          IF P_CRD_PRD = 'R' AND V_TOTAL_AMT >= V_R_VND_AMT THEN--THE HANG CHUAN
            L_CHECK_POINT := 2;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            ----------------------------------------
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
            ----CHECK IF CASE ALREADY EXISTED----
            IF P_CHECK = 'FALSE' THEN
                SQL_STMT := 'INSERT INTO CCPS.FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
                                 UPD_UID,ASG_TMS,INIT_USR_ID,USR_ID,
                                 CIF_NO,CASE_NO,AMOUNT,AVL_BAL,AVL_BAL_CRNCY,
                                 CASE_STATUS,CHECK_NEW,SMS_FLG,ENC_CRD_NO,
                                 MCC,INIT_ASG_TMS,TXN_CRE_TMS,CRD_BRN,
                                 MERC_NAME,CRNCY_CDE,
                                 POS_MODE,
                                 RESP_CDE,
                                 TXN_STAT,
                                 TXN_3D_IND,
                                 TXN_3D_ECI,
                                 LOC,
                                 ACC_AVL_BAL,
                                 CAV_AVL_LMT,
                                 CRN_LMT_AVL,
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'',''10'') AND (upper(T.FX_OA008_MERC_NAME) not like ''%AGODA%'' and upper(T.FX_OA008_MERC_NAME) not like ''%BOOKING.COM%'' and upper(T.FX_OA008_MERC_NAME) not like ''%TRAVELOKA%'' and upper(T.FX_OA008_MERC_NAME) not like ''%AIRBNB%'' and T.F9_OA008_MCC not in (select mcc from ccps.fds_excpt_mcc where tcc = ''Airline'')) AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
            RETURN 'DONE';
          ELSIF P_CRD_PRD <> 'R' AND V_TOTAL_AMT >= V_G_VND_AMT THEN--HANG KHAC CHUAN
            L_CHECK_POINT := 2;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            ----------------------------------------
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
            ----CHECK IF CASE ALREADY EXISTED----
            IF P_CHECK = 'FALSE' THEN
                SQL_STMT := 'INSERT INTO CCPS.FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
                                 UPD_UID,ASG_TMS,INIT_USR_ID,USR_ID,
                                 CIF_NO,CASE_NO,AMOUNT,AVL_BAL,AVL_BAL_CRNCY,
                                 CASE_STATUS,CHECK_NEW,SMS_FLG,ENC_CRD_NO,
                                 MCC,INIT_ASG_TMS,TXN_CRE_TMS,CRD_BRN,
                                 MERC_NAME,CRNCY_CDE,
                                 POS_MODE,
                                 RESP_CDE,
                                 TXN_STAT,
                                 TXN_3D_IND,
                                 TXN_3D_ECI,
                                 LOC,
                                 ACC_AVL_BAL,
                                 CAV_AVL_LMT,
                                 CRN_LMT_AVL,
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'') AND (upper(T.FX_OA008_MERC_NAME) not like ''%AGODA%'' and upper(T.FX_OA008_MERC_NAME) not like ''%BOOKING.COM%'' and upper(T.FX_OA008_MERC_NAME) not like ''%TRAVELOKA%'' and upper(T.FX_OA008_MERC_NAME) not like ''%AIRBNB%'' and T.F9_OA008_MCC not in (select mcc from ccps.fds_excpt_mcc where tcc = ''Airline'')) AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
            RETURN 'DONE';
          ELSIF V_TOTAL_AMT1 >= 12000000 THEN--AGODA, BOOKING.COM, TRAVELOKA, AIRBNB
            L_CHECK_POINT := 3;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            ----------------------------------------
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
            ----CHECK IF CASE ALREADY EXISTED----
            IF P_CHECK = 'FALSE' THEN
                SQL_STMT := 'INSERT INTO CCPS.FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
                                 UPD_UID,ASG_TMS,INIT_USR_ID,USR_ID,
                                 CIF_NO,CASE_NO,AMOUNT,AVL_BAL,AVL_BAL_CRNCY,
                                 CASE_STATUS,CHECK_NEW,SMS_FLG,ENC_CRD_NO,
                                 MCC,INIT_ASG_TMS,TXN_CRE_TMS,CRD_BRN,
                                 MERC_NAME,CRNCY_CDE,
                                 POS_MODE,
                                 RESP_CDE,
                                 TXN_STAT,
                                 TXN_3D_IND,
                                 TXN_3D_ECI,
                                 LOC,
                                 ACC_AVL_BAL,
                                 CAV_AVL_LMT,
                                 CRN_LMT_AVL,
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'') AND (upper(T.FX_OA008_MERC_NAME) like ''%AGODA%'' or upper(T.FX_OA008_MERC_NAME) like ''%BOOKING.COM%'' OR upper(T.FX_OA008_MERC_NAME) like ''%TRAVELOKA%'' OR upper(T.FX_OA008_MERC_NAME) like ''%AIRBNB%'') AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
            RETURN 'DONE';
          ELSIF V_TOTAL_AMT2 >= 20000000 THEN--CAC HANG HANG KHONG
            L_CHECK_POINT := 4;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            ----------------------------------------
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
            ----CHECK IF CASE ALREADY EXISTED----
            IF P_CHECK = 'FALSE' THEN
                SQL_STMT := 'INSERT INTO CCPS.FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
                                 UPD_UID,ASG_TMS,INIT_USR_ID,USR_ID,
                                 CIF_NO,CASE_NO,AMOUNT,AVL_BAL,AVL_BAL_CRNCY,
                                 CASE_STATUS,CHECK_NEW,SMS_FLG,ENC_CRD_NO,
                                 MCC,INIT_ASG_TMS,TXN_CRE_TMS,CRD_BRN,
                                 MERC_NAME,CRNCY_CDE,
                                 POS_MODE,
                                 RESP_CDE,
                                 TXN_STAT,
                                 TXN_3D_IND,
                                 TXN_3D_ECI,
                                 LOC,
                                 ACC_AVL_BAL,
                                 CAV_AVL_LMT,
                                 CRN_LMT_AVL,
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'') AND T.F9_OA008_MCC not in (select mcc from ccps.fds_excpt_mcc where tcc = ''Airline'') AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
            RETURN 'DONE';
          ELSE
            P_CNT := 0;
            RETURN 'FALSE';
          END IF;
          ---END: TINH TONG GD THEO LOAI TIEN TRONG VONG 2H---
      ELSE
        P_CNT:= 0;
        RETURN 'FALSE';
      END IF;
    ELSE
      P_CNT:= 0;
      RETURN 'FALSE';
    END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_cnt:= 0;
            RETURN 'FALSE';
        WHEN OTHERS THEN
             ROLLBACK;
             V_STS := 'ERROR'; -- START / DONE / ERROR
             V_ENDTIME := TO_CHAR(SYSDATE,'hh24missss');
             V_STSDESC := SQLERRM||' At:'||L_CHECK_POINT;
             DBMS_OUTPUT.PUT_LINE('Loi:'||V_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = V_ENDTIME, STATUS = V_STS, STSDESC = V_STSDESC WHERE PROC_NAME = V_PROD AND TXDATE = V_TXDATE AND BEGIN_TIME = V_BEGTIME;
             --COMMIT;
             P_CNT:= 0;
             RETURN 'ERROR';
END;

/
