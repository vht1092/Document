--------------------------------------------------------
--  DDL for Function FN_FDS_RULE39_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE39_V2" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   16JUN2017    Phat sinh giao dich (khong phai tai Bar, Beer    *
*                               Club, Lounge…--> MCC List:5812, 5813, 5715, 5921)*
*                               voi so tien = 3 trieu VND/giao dich hoac ngoai te*
*                               tuong duong tu 00h - 04h tai Viet Nam            *
* 2.0    HUYENNT   04MAY2018    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
*                               SO 70/BC-GS&XLTST&NHDT                           *
* 3.0    HUYENNT   12FEB2019    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
*                               DC DUYET NGAY 12/02/2019                         *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_CARDNO IN VARCHAR2,
    P_CRD_PGM IN CHAR,--ADD ON 30122017
    P_END_TMS IN VARCHAR2,
    P_MCC IN VARCHAR2,--MCC
    P_POS_MODE IN VARCHAR2,--ADD ON 20190220
    P_LOC IN NUMBER,--ADD ON 20190220
    P_CRCY_CDE IN VARCHAR2,
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    P_CHECK IN VARCHAR2,
    P_CNT OUT NUMBER
 ) RETURN VARCHAR2
 AS
    SQL_STMT VARCHAR2(4000);
    SQL_STMT2 VARCHAR2(4000);
    ---------------------
    STRT_TMS NUMBER := 0;
    END_TMS NUMBER := 4;
    TXN_TMS NUMBER;
    ---------------------
    V_POS_MODE CHAR(2) := SUBSTR(P_POS_MODE,1,2);
    CRE_TMS VARCHAR(17);
    V_CNT NUMBER;
    V_CHECKAMOUNT NUMBER;
    CASE_ID VARCHAR2(50);
    V_AMT number;
    ---------------------
    V_AMOUNT_CR_CHIP NUMBER := 20000000; -- SO TIEN GIAO DICH THE CREDIT CHIP
    V_AMOUNT_DB_CHIP NUMBER := 10000000; -- SO TIEN GIAO DICH THE DEBIT CHIP
    V_AMOUNT_CR_TU NUMBER := 10000000; -- SO TIEN GIAO DICH THE CREDIT TU
    V_AMOUNT_DB_TU NUMBER := 5000000; -- SO TIEN GIAO DICH THE DEBIT TU
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'SP_FDS_RULE39';
    V_RULENAME VARCHAR2(6):='RULE39';
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
BEGIN
    --INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    --COMMIT;
    -------------------------------------------------
    TXN_TMS := TO_NUMBER(SUBSTR(P_END_TMS,9,4));--LAY GIO GIAO DICH
    -------------------------------------------------
    IF ((TXN_TMS >= 2330 and TXN_TMS <= 2359) OR (TXN_TMS >= 0 and TXN_TMS <= 400)) AND TRIM(P_CRCY_CDE) = '704' AND P_MCC NOT IN ('5813','5921') AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN
      IF V_POS_MODE = '05' THEN--giao dich chip
        SELECT sum(T.F9_OA008_AMT_REQ) into V_AMT FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND TRIM(T.F9_OA008_CRNCY_CDE) = '704' AND T.F9_OA008_MCC NOT IN ('5813','5921') AND T.FX_OA008_POS_MODE LIKE '05%' AND T.FX_OA008_USED_PAN = P_CARDNO AND (to_number(substr(lpad(T.F9_OA008_TM,8,'0'),1,4)) BETWEEN 2330 AND 2359 OR to_number(substr(lpad(T.F9_OA008_TM,8,'0'),1,4)) BETWEEN 0 AND 400);
        IF (V_AMT >= V_AMOUNT_CR_CHIP and P_LOC > 800000000000) OR (V_AMT >= V_AMOUNT_DB_CHIP and P_LOC < 800000000000) THEN
          L_CHECK_POINT := 2;
          SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
          ----lay dung cif theo the chinh hoac phu
          select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
          IF V_CRN > 0 THEN
               select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
          ELSE
               select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
          END IF;
          ----thong tin gd co 3D Secure hay khong-
          select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
          IF V_3D_CHK > 0 THEN
               SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
          END IF;
          ----------------------------------------
          SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
          ----CHECK IF CASE ALREADY EXISTED----
          IF P_CHECK = 'FALSE' THEN
                SQL_STMT := 'INSERT INTO CCPS.FDS_CASE_DETAIL (CRE_TMS,UPD_TMS,
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
                                 CRN)
                 SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''')';
                EXECUTE IMMEDIATE SQL_STMT;
          END IF;
          --------------------------------------
          L_CHECK_POINT := 3;
          SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT '''||CRE_TMS||''', '''||CRE_TMS||''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND TRIM(T.F9_OA008_CRNCY_CDE) = ''704'' AND T.F9_OA008_MCC NOT IN (''5813'',''5921'') AND T.FX_OA008_POS_MODE LIKE ''05%'' AND T.FX_OA008_USED_PAN ='||P_CARDNO||' AND (to_number(substr(lpad(T.F9_OA008_TM,8,''0''),1,4)) BETWEEN 2330 AND 2359 OR to_number(substr(lpad(T.F9_OA008_TM,8,''0''),1,4)) BETWEEN 0 AND 400)';
          EXECUTE IMMEDIATE SQL_STMT2;
          L_CHECK_POINT := 4;
          SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
          EXECUTE IMMEDIATE SQL_STMT2;
          COMMIT;
          p_cnt := 1;
          RETURN 'DONE';
        ELSE
          p_cnt:= 0;
          RETURN 'FALSE';
        END IF;
      ELSIF V_POS_MODE = '90' THEN--giao dich tu
        SELECT sum(T.F9_OA008_AMT_REQ) into V_AMT FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND TRIM(T.F9_OA008_CRNCY_CDE) = '704' AND T.F9_OA008_MCC NOT IN ('5813','5921') AND T.FX_OA008_POS_MODE LIKE '90%' AND T.FX_OA008_USED_PAN = P_CARDNO AND (to_number(substr(lpad(T.F9_OA008_TM,8,'0'),1,4)) BETWEEN 2330 AND 2359 OR to_number(substr(lpad(T.F9_OA008_TM,8,'0'),1,4)) BETWEEN 0 AND 400);
        IF (V_AMT >= V_AMOUNT_CR_TU and P_LOC > 800000000000) OR (V_AMT >= V_AMOUNT_DB_TU and P_LOC < 800000000000) THEN
          L_CHECK_POINT := 5;
          SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
          ----lay dung cif theo the chinh hoac phu
          select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
          IF V_CRN > 0 THEN
               select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
          ELSE
               select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
          END IF;
          ----thong tin gd co 3D Secure hay khong-
          select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
          IF V_3D_CHK > 0 THEN
               SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
          END IF;
          ----------------------------------------
          SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
          ----CHECK IF CASE ALREADY EXISTED----
          IF P_CHECK = 'FALSE' THEN
                SQL_STMT := 'INSERT INTO CCPS.FDS_CASE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''')';
                EXECUTE IMMEDIATE SQL_STMT;
          END IF;
          --------------------------------------
          L_CHECK_POINT := 6;
          SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT '''||CRE_TMS||''', '''||CRE_TMS||''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND TRIM(T.F9_OA008_CRNCY_CDE) = ''704'' AND T.F9_OA008_MCC NOT IN (''5813'',''5921'') AND T.FX_OA008_POS_MODE LIKE ''90%'' AND T.FX_OA008_USED_PAN ='||P_CARDNO||' AND (to_number(substr(lpad(T.F9_OA008_TM,8,''0''),1,4)) BETWEEN 2330 AND 2359 OR to_number(substr(lpad(T.F9_OA008_TM,8,''0''),1,4)) BETWEEN 0 AND 400)';
          EXECUTE IMMEDIATE SQL_STMT2;
          L_CHECK_POINT := 7;
          SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
          EXECUTE IMMEDIATE SQL_STMT2;
          COMMIT;
          p_cnt := 1;
          RETURN 'DONE';
        ELSE
          p_cnt:= 0;
          RETURN 'FALSE';
        END IF;
      ELSE
        p_cnt:= 0;
        RETURN 'FALSE';
      END IF;
    ELSE
        p_cnt:= 0;
        RETURN 'FALSE';
    END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_cnt:= 0;
            RETURN 'FALSE';
        WHEN OTHERS THEN
             ROLLBACK;
             v_STS := 'ERROR'; -- START / DONE / ERROR
             v_EndTime := to_char(sysdate,'hh24missss');
             v_STSDESC := SQLERRM||' At:'||l_check_point;
             --DBMS_OUTPUT.put_line('Loi:'||v_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
             --COMMIT;
             p_cnt:= 0;
             RETURN 'RULE39 ERROR:';
END;

/
