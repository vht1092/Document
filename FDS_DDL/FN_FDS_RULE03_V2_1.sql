--------------------------------------------------------
--  DDL for Function FN_FDS_RULE03_V2_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE03_V2_1" 
/*************************************************************************************
* VER    ID        DATE         ENHANCEMENT                                          *
* -----  -------   ---------    -----------------------------------------------------*
* 1.0    HUYENNT   28MAR2019    TRONG 1H THE PHAT SINH GIAO DICH 3DS VOI TONG SO TIEN*
*                               + THE DEBIT, CHUAN SO TIEN >= 30TR                   *
*                               + THE VANG SO TIEN >= 50TR                           *
*                               + THE PLATINUM, WORLD CLASS SO TIEN >= 80TR          *
**************************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_CARDNO IN VARCHAR2,
    P_END_TMS IN VARCHAR2,
    P_CRD_PRD IN CHAR,
    P_CRD_PGM IN CHAR,--ADD ON 27DEC2017
    P_POS_MODE IN CHAR,--ADD ON 12FEB2019
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    P_CHECK IN VARCHAR2,
    P_TIME_PERIOD IN NUMBER,-- TRUYEN VAO: 1
    P_CNT OUT NUMBER

) RETURN VARCHAR2
 AS
    SQL_STMT VARCHAR2(4000);
    SQL_STMT2 VARCHAR2(4000);
    STRT_TMS VARCHAR(17);
    STRT_3DS_TMS VARCHAR(17);
    CRE_TMS VARCHAR(17);
    V_CNT NUMBER;
    CASE_ID VARCHAR2(50);
    V_AMOUNT_R NUMBER:=30000000; -- SO TIEN GIAO DICH THE CHUAN
    V_AMOUNT_G NUMBER:=50000000; -- SO TIEN GIAO DICH THE VANG
    V_AMOUNT_PW NUMBER:=80000000; -- SO TIEN GIAO DICH THE P,W
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'FN_FDS_RULE03';
    V_RULENAME VARCHAR2(6):='RULE03';
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
    IF P_POS_MODE LIKE '81%' OR P_POS_MODE LIKE '%01%' THEN--GD QUA MANG
      ----thong tin gd co 3D Secure hay khong-
      select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
      ----------------------------------------
      IF P_TXN_AMT > 0 and V_3D_CHK > 0 THEN
        SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
        STRT_TMS := TMS_ADD_SUBTRACT(P_TIME_PERIOD,P_END_TMS);
        STRT_3DS_TMS := TMS_ADD_SUBTRACT(0.5,STRT_TMS);
        SQL_STMT := 'SELECT SUM(F9_OA008_AMT_REQ) FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND (T.FX_OA008_POS_MODE LIKE ''81%'' or T.FX_OA008_POS_MODE LIKE ''01%'') AND EXISTS(SELECT 1 FROM OA126@IM WHERE PX_OA126_PAN = T.FX_OA008_USED_PAN AND P9_OA126_SEQ_NUM = T.P9_OA008_SEQ AND F9_OA126_CRE_TMS > ' || STRT_3DS_TMS || ') AND T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
        EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;
        IF (P_CRD_PRD = 'R' AND V_CNT >= V_AMOUNT_R) OR (P_CRD_PRD = 'G' AND V_CNT >= V_AMOUNT_G) OR (P_CRD_PRD IN ('P','W') AND V_CNT >= V_AMOUNT_PW) THEN
            L_CHECK_POINT := 2;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE F9_OA008_AMT_REQ > 0 AND FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
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
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND (T.FX_OA008_POS_MODE LIKE ''81%'' or T.FX_OA008_POS_MODE LIKE ''01%'') AND EXISTS(SELECT 1 FROM OA126@IM WHERE PX_OA126_PAN = T.FX_OA008_USED_PAN AND P9_OA126_SEQ_NUM = T.P9_OA008_SEQ AND F9_OA126_CRE_TMS > ' || STRT_3DS_TMS || ') AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
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
             V_STS := 'ERROR'; -- START / DONE / ERROR
             V_ENDTIME := TO_CHAR(SYSDATE,'hh24missss');
             V_STSDESC := SQLERRM||' At:'||L_CHECK_POINT||','||SQL_STMT;
             DBMS_OUTPUT.PUT_LINE('Loi:'||V_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = V_ENDTIME, STATUS = V_STS, STSDESC = V_STSDESC WHERE PROC_NAME = V_PROD AND TXDATE = V_TXDATE AND BEGIN_TIME = V_BEGTIME;
             --COMMIT;
             P_CNT:= 0;
             RETURN 'ERROR';
END;

/
