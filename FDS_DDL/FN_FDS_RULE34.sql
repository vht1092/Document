--------------------------------------------------------
--  DDL for Function FN_FDS_RULE34
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE34" 
/**********************************************************************************
 * VER    ID        DATE         ENHANCEMENT                                      *
 * -----  -------   ---------    -------------------------------------------------*
 * 1.0    CHAUTK   17/12/2016    RULE 34: GIAO DICH VUOT QUA HAN MUC - MCS - VSS  *
 * 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
 *                               DICH                                             *
 **********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    p_ref_cde IN VARCHAR2,--ADD ON 21022017
    P_LOC IN NUMBER,--ADD ON 21022017
    P_CASA_ACCT IN VARCHAR2,--ADD ON 21022017
    P_CRD_PGM IN VARCHAR2,--ADD ON 21022017
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
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255);
    L_CHECK_POINT NUMBER;
    V_TXDATE NUMBER;
    V_BEGTIME NUMBER;
    V_ENDTIME NUMBER;
    V_STS VARCHAR(10);
    V_STSDESC VARCHAR2(4000);
    V_RULENAME VARCHAR2(6):='RULE34';
    V_BIN VARCHAR2(10):= SUBSTR(ccps.DED2(P_CARDNO, 'FDS'), 1, 6);
	V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    ---------------------
    V_CRE_TMS VARCHAR(17);
    V_ACC_AVL_BAL NUMBER;
    V_ACCT_LMT NUMBER;
    V_CAP_AVL NUMBER;
    V_P_CAP_AVL NUMBER;
    V_S_CAP_AVL NUMBER;
    V_CAV_PCT_LMT NUMBER;
    V_CAV_AVL_LMT NUMBER;
    V_CAV NUMBER;
    V_CRD_TYP CHAR(1);
    V_CRN_LMT NUMBER;
    V_CRN_CLO_BAL NUMBER;
    V_CRN_LMT_AVL NUMBER;
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    V_PROD := 'SP_FDS_RULE34';
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
    IF p_ref_cde LIKE '%28%' AND (V_BIN = '510235' OR V_BIN = '489516') THEN
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
        -------------lay thong tin insufficent fund--
        --lay ngay gio xu ly gd--
        SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO V_CRE_TMS FROM DUAL;
        IF SUBSTR(P_CRD_PGM,1,2) = 'MD' THEN--LAY SO DU KHA DUNG HIEN TAI CUA THE DEBIT--
            L_CHECK_POINT := 4;
            SELECT fn_get_acc_avlbal(trim(P_CASA_ACCT)) INTO V_ACC_AVL_BAL FROM dual;
            V_CAV_AVL_LMT := 0;
            V_ACCT_LMT := 0;
        ELSE--LAY HAN MUC KHA DUNG HIEN TAI CUA THE CREDIT--
            --lay so du kha dung hien tai cua the cho gd--
            L_CHECK_POINT := 5;
            SELECT F9_OA001_TOT_LMT - (f9_oa001_cls_bal + F9_OA001_APV + F9_OA001_CAV_INC),F9_OA001_ACCT_LMT,F9_OA001_CAV INTO V_ACC_AVL_BAL,V_ACCT_LMT,V_CAV FROM oa001@AM WHERE p9_oa001_acct_id = 1 AND p9_oa001_acct_num = P_LOC;
            --CALCULATE CAP LIMIT---------------------------
            SELECT fx_iw104_crd_typ INTO V_CRD_TYP FROM IW104@IM WHERE fx_iw104_pan = P_CARDNO AND ROWNUM = 1;
            IF V_CRD_TYP = 'B' THEN
                L_CHECK_POINT := 6;
                SELECT F9_OA051_CAP_LMT - F9_OA051_TOT_SPD INTO V_P_CAP_AVL FROM oa051@AM WHERE px_oa051_pan = P_CARDNO;
                V_CAP_AVL := V_P_CAP_AVL;
            ELSE
                L_CHECK_POINT := 7;
                SELECT F9_OA059_CAP_LMT - F9_OA059_TOT_SPD INTO V_S_CAP_AVL FROM OA059@AM WHERE PX_OA059_PAN = P_CARDNO;
                V_CAP_AVL := V_S_CAP_AVL;
            END IF;
            ------------------------------------------------
            L_CHECK_POINT := 8;
            SELECT F9_OA123_CAV_PCT_LMT INTO V_CAV_PCT_LMT FROM OA123@AM WHERE PX_OA123_CRD_PGM = P_CRD_PGM AND ROWNUM = 1;
            V_CAV_AVL_LMT := (V_ACCT_LMT*V_CAV_PCT_LMT/100) - V_CAV;
            IF V_ACC_AVL_BAL < V_CAV_AVL_LMT THEN V_CAV_AVL_LMT := V_ACC_AVL_BAL; END IF;
            IF V_CAV_AVL_LMT < 0 THEN V_CAV_AVL_LMT := 0; END IF;
            --LAY MSL AVAILABLE-----------------------------
            SELECT F9_IR056_CRN_LMT + F9_IR056_CRN_TMP_LMT INTO V_CRN_LMT FROM IR056@IM WHERE P9_IR056_CRN = P_CRN AND ROWNUM = 1;
            SELECT sum(f9_oa001_cls_bal + F9_OA001_APV + F9_OA001_CAV_INC) INTO V_CRN_CLO_BAL FROM oa001@AM where p9_oa001_acct_id = 1 AND p9_oa001_acct_num like '8%' AND p9_oa001_crn = P_CRN;
            V_CRN_LMT_AVL := V_CRN_LMT - V_CRN_CLO_BAL;
            ------------------------------------------------
        END IF;
        L_CHECK_POINT := 9;
        ----------------------------------------
        SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND P9_OA008_SEQ=P_SEQ;
        ----CHECK IF CASE ALREADY EXISTED----
        IF p_check = 'FALSE' THEN
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,'||V_ACC_AVL_BAL||','||V_CAV_AVL_LMT||','||V_CRN_LMT_AVL||','||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
            execute immediate sql_stmt;
        END IF;
        --------------------------------------
        L_CHECK_POINT := 3;
        SQL_STMT2 :='INSERT INTO FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', F9_OA008_CRE_TMS, FX_OA008_USED_PAN, F9_OA008_MCC, P9_OA008_SEQ, F9_OA008_DT, F9_OA008_TM FROM FDS_TXN_DETAIL WHERE F9_OA008_CRE_TMS = '|| P_END_TMS ||' AND FX_OA008_USED_PAN = ''' || P_CARDNO || '''';
        EXECUTE IMMEDIATE SQL_STMT2;
        L_CHECK_POINT := 4;
        SQL_STMT2 := 'INSERT INTO FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
        EXECUTE IMMEDIATE SQL_STMT2;
        COMMIT;
        p_cnt := 1;
        RETURN 'DONE';
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
             DBMS_OUTPUT.put_line('Loi:'||v_STSDESC);
             UPDATE FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
             COMMIT;
             p_cnt:= 0;
             RETURN 'ERROR';
END;

/
