--------------------------------------------------------
--  DDL for Function FN_FDS_RULE44
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE44" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   12JAN2018    TRONG 1 PHUT THE PHAT SINH TU 2 GIAO DICH KEY    *
*                               ENTER & ECOMMERCE KHONG CO 3DS SE TAM KHOA THE   *
**********************************************************************************/
(
    P_CRN IN NUMBER,
    P_SEQ IN NUMBER,
    P_TXN_AMT IN NUMBER,
    P_POS_MOD IN VARCHAR2,
    P_CARDNO IN VARCHAR2,
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
    ---------------------
    V_CNT number;
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    V_POS_MOD VARCHAR2(3) := SUBSTR(P_POS_MOD,1,2);
    V_TIME_PERIOD NUMBER := 0.017;
    V_RULENAME VARCHAR2(50) := 'RULE44';
BEGIN
    IF P_TXN_AMT > 0 AND (V_POS_MOD = '01' OR V_POS_MOD = '81' OR V_POS_MOD = '80') THEN
      ---CHECK thong tin gd co 3D Secure hay khong---
      select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
      IF V_3D_CHK = 0 THEN--GD KHONG QUA 3DS
        STRT_TMS := TMS_ADD_SUBTRACT(V_TIME_PERIOD,P_END_TMS);
        --dem so luong giao dich----------------
        SELECT COUNT(1) INTO V_CNT FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND substr(T.FX_OA008_POS_MODE,1,2) in ('01','81','80') AND T.FX_OA008_USED_PAN = P_CARDNO AND T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS and not exists (select 1 FROM OA126@IM WHERE PX_OA126_PAN = T.FX_OA008_USED_PAN AND P9_OA126_SEQ_NUM = T.P9_OA008_SEQ);
        ----------------------------------------
        IF V_CNT >= 2 THEN
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
              SQL_STMT := 'INSERT INTO FPT.FDS_CASE_DETAIL (CRE_TMS,UPD_TMS,
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
          SQL_STMT2 :='INSERT INTO FPT.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''80'',''81'') AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' AND not exists (select 1 FROM OA126@IM WHERE PX_OA126_PAN = T.FX_OA008_USED_PAN AND P9_OA126_SEQ_NUM = T.P9_OA008_SEQ) ORDER BY T.F9_OA008_CRE_TMS DESC';
          EXECUTE IMMEDIATE SQL_STMT2;
          SQL_STMT2 := 'INSERT INTO FPT.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
          EXECUTE IMMEDIATE SQL_STMT2;
          COMMIT;
          P_CNT := 1;
          RETURN 'DONE';
        ELSE
          P_CNT:= 0;
          RETURN 'FALSE';
        END IF;
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
             P_CNT:= 0;
             RETURN 'ERROR';
END;

/
