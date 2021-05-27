--------------------------------------------------------
--  DDL for Function FN_FDS_RULE20
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE20" 
/***********************************************************************************
  * VER    ID        DATE         ENHANCEMENT                                      *
  * -----  -------   ---------    -------------------------------------------------*
  * 1.0    CHAUTK   17/12/2016    RULE 20: GIAO DICH CUA THE HET HAN               *
  * 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
  *                               DICH                                             *
  **********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    p_ref_cde IN VARCHAR2,--ADD ON 21022017
    P_CARDNO IN VARCHAR2,
    P_END_TMS IN VARCHAR2,
    P_CHECK IN VARCHAR2,
    P_CNT OUT NUMBER
 ) RETURN VARCHAR2
 AS
    SQL_STMT VARCHAR2(4000);
    SQL_STMT2 VARCHAR2(4000);
    CRE_TMS VARCHAR(17);
    V_CNT NUMBER;
    CASE_ID VARCHAR2(50);
    --BIEN DUNG GHI LOG
    V_PROD VARCHAR(255);
    L_CHECK_POINT NUMBER;
    V_TXDATE NUMBER;
    V_BEGTIME NUMBER;
    V_ENDTIME NUMBER;
    V_STS VARCHAR(10);
    V_STSDESC VARCHAR2(4000);
    V_RULENAME VARCHAR2(6):='RULE20';
	V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG
    V_PROD := 'SP_FDS_RULE20';
    V_TXDATE := TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME := TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME := 0;
    V_STS := 'START'; -- START / DONE / ERROR
    V_STSDESC := ' ';
    L_CHECK_POINT := 1;
    INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    COMMIT;
    -------------------------------------------------
	SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF p_ref_cde LIKE '%08%' THEN
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
        select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
        IF V_3D_CHK > 0 THEN
             SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
        END IF;
        ----------------------------------------
        SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
            EXECUTE IMMEDIATE SQL_STMT;
        END IF;
        --------------------------------------
        L_CHECK_POINT := 3;
        SQL_STMT2 :='INSERT INTO FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', F9_OA008_CRE_TMS, FX_OA008_USED_PAN, F9_OA008_MCC, P9_OA008_SEQ, F9_OA008_DT, F9_OA008_TM FROM FDS_TXN_DETAIL WHERE F9_OA008_CRE_TMS = '|| P_END_TMS ||' AND FX_OA008_USED_PAN = ''' || P_CARDNO || ''' ORDER BY F9_OA008_CRE_TMS DESC';
        EXECUTE IMMEDIATE SQL_STMT2;
        L_CHECK_POINT := 4;
        SQL_STMT2 := 'INSERT INTO FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
        EXECUTE IMMEDIATE SQL_STMT2;
        COMMIT;
        P_CNT := 1;
        RETURN 'DONE';
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
             UPDATE FDS_LOG SET END_TIME = V_ENDTIME, STATUS = V_STS, STSDESC = V_STSDESC WHERE PROC_NAME = V_PROD AND TXDATE = V_TXDATE AND BEGIN_TIME = V_BEGTIME;
             COMMIT;
             P_CNT:= 0;
             RETURN 'ERROR';
END;

/
