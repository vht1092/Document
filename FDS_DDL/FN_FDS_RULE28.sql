--------------------------------------------------------
--  DDL for Function FN_FDS_RULE28
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE28" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   06DEC2016    The gd qua tu the chuan co so tien gd tu 5tr VND *
*                               hoac ngoai te tuong duong, the vang co so tien gd*
*                               tu 8tr VND hoac ngoai te tuong duong             *
* 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
*                               DICH                                             *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_POS_MOD IN VARCHAR2,--ADD ON 21022017
    P_CARDNO IN VARCHAR2,
    P_CRD_PRD IN CHAR,--ADD ON 20170705
    P_END_TMS IN VARCHAR2,
    P_CHECK IN VARCHAR2,
    P_CNT OUT NUMBER
 ) RETURN VARCHAR2
 AS
    STRT_TMS VARCHAR(17);
    SQL_STMT VARCHAR2(4000);
    SQL_STMT2 VARCHAR2(4000);
    CRE_TMS VARCHAR(17);
    CASE_ID VARCHAR2(50);
    V_AMT_R_VND NUMBER:=5000000; -- SO TIEN GIAO DICH VND THE CHUAN
    V_AMT_G_VND NUMBER:=10000000; -- SO TIEN GIAO DICH VND THE VANG, PLATINUM, WORLD
    V_TOTAL_AMT NUMBER;
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'SP_FDS_RULE28';
    V_RULENAME VARCHAR2(6):='RULE28';
    L_CHECK_POINT NUMBER:=1;
    V_TXDATE NUMBER:=TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME NUMBER:=TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME NUMBER:=0;
    V_STS VARCHAR(10):= 'START';-- START / DONE / ERROR
    V_STSDESC VARCHAR2(4000):=' ';
    ---------------------
    V_CRN number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    V_POS_MOD VARCHAR2(3) := SUBSTR(P_POS_MOD,1,2);
BEGIN
    SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
    --INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    --COMMIT;
    IF V_POS_MOD IN ('90','91') AND P_TXN_AMT > 0 THEN
      STRT_TMS := TMS_ADD_SUBTRACT(2,P_END_TMS);
      SELECT
       SUM(F9_OA008_AMT_REQ) INTO V_TOTAL_AMT
      FROM
       FDS_TXN_DETAIL
      WHERE
       F9_OA008_AMT_REQ > 0
       AND SUBSTR(fx_oa008_pos_mode,1,2) IN ('90','91')
       AND FX_OA008_USED_PAN = P_CARDNO
       AND F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;
       ----------------------
       IF P_CRD_PRD = 'R' AND V_TOTAL_AMT >= V_AMT_R_VND THEN--THE CHUAN
          ----lay dung cif theo the chinh hoac phu
          select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
          IF V_CRN > 0 THEN
               select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
          ELSE
               select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
          END IF;
          ----------------------------------------
          SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE F9_OA008_AMT_REQ > 0 AND FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
          ----CHECK IF CASE ALREADY EXISTED----
          IF P_CHECK = 'FALSE' THEN
              SQL_STMT := 'INSERT INTO FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
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
          l_check_point := 3;
          sql_stmt2 :='INSERT INTO FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', F9_OA008_CRE_TMS, FX_OA008_USED_PAN, F9_OA008_MCC, P9_OA008_SEQ, F9_OA008_DT, F9_OA008_TM FROM FDS_TXN_DETAIL WHERE F9_OA008_AMT_REQ > 0 AND SUBSTR(fx_oa008_pos_mode,1,2) IN (''90'',''91'') AND F9_OA008_CRE_TMS = '|| P_END_TMS ||' AND FX_OA008_USED_PAN = ''' || P_CARDNO || ''' ORDER BY F9_OA008_CRE_TMS DESC';
          execute immediate sql_stmt2;
          l_check_point := 4;
          sql_stmt2 := 'INSERT INTO FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''','''||v_RULENAME||''')';
          execute immediate sql_stmt2;
          commit;
          p_cnt := 1;
          RETURN 'DONE';
       ELSIF P_CRD_PRD <> 'R' AND V_TOTAL_AMT >= V_AMT_G_VND THEN--THE VANG,PLATINUM, WORLD
          ----lay dung cif theo the chinh hoac phu
          select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
          IF V_CRN > 0 THEN
               select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
          ELSE
               select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
          END IF;
          ----------------------------------------
          SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE F9_OA008_AMT_REQ > 0 AND FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS;
          ----CHECK IF CASE ALREADY EXISTED----
          IF P_CHECK = 'FALSE' THEN
              SQL_STMT := 'INSERT INTO FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
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
          l_check_point := 3;
          sql_stmt2 :='INSERT INTO FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', F9_OA008_CRE_TMS, FX_OA008_USED_PAN, F9_OA008_MCC, P9_OA008_SEQ, F9_OA008_DT, F9_OA008_TM FROM FDS_TXN_DETAIL WHERE F9_OA008_AMT_REQ > 0 AND SUBSTR(fx_oa008_pos_mode,1,2) IN (''90'',''91'') AND F9_OA008_CRE_TMS = '|| P_END_TMS ||' AND FX_OA008_USED_PAN = ''' || P_CARDNO || ''' ORDER BY F9_OA008_CRE_TMS DESC';
          execute immediate sql_stmt2;
          l_check_point := 4;
          sql_stmt2 := 'INSERT INTO FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''','''||v_RULENAME||''')';
          execute immediate sql_stmt2;
          commit;
          p_cnt := 1;
          RETURN 'DONE';
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
