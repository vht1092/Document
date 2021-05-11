--------------------------------------------------------
--  DDL for Function FN_FDS_RULE08_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE08_V3" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   06DEC2016    The phat sinh tu 5 giao dich tro len trong 1H    *
* 2.0    HUYENNT   21FEB2017    LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
*                               DICH                                             *
* 2.1    HUYENNT   27DEC2017    TACH RIENG TIEU CHI CANH BAO CHO GIAO THANH TOAN *
*                               HANG HOA VA RUT TIEN                             *
* 2.2    HUYENNT   04MAY2018    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
*                               SO 70/BC-GS&XLTST&NHDT                           *
* 3.0    HUYENNT   12FEB2019    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
*                               DC DUYET NGAY 21/01/2019                         *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    p_cardno IN VARCHAR2,
    P_POS_MOD IN VARCHAR2,--ADD ON 04MAY2018,#P_MERC_NAME IN VARCHAR2,--ADD ON 27DEC2017
    P_MCC IN NUMBER,--ADD ON 12FEB2019
    p_loc in number,--ADD ON 27DEC2017
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    p_time_period IN NUMBER,
    p_end_tms in VARCHAR2,
    p_check IN VARCHAR2,
    p_cnt OUT NUMBER
 ) RETURN VARCHAR2
 AS
    sql_stmt varchar2(4000);
    sql_stmt2 varchar2(4000);
    strt_tms varchar(17);
    cre_tms varchar(17);
    v_cnt number;
    case_id VARCHAR2(50);
    --BIEN DUNG GHI LOG--
    v_PROD varchar(255);
    V_RULENAME VARCHAR2(6):='RULE08';
    l_check_point number;
    v_TxDate number;
    v_BegTime number;
    v_EndTime number;
    v_STS varchar(10);
    v_STSDESC varchar2(4000);
    V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    V_AMT_SALE NUMBER;
    V_AMT_CW NUMBER;
    p_qty NUMBER := 4;
    p_qty_db NUMBER := 5;
    V_POS_MOD VARCHAR2(3) := SUBSTR(P_POS_MOD,1,2);--ADD ON 04MAY2018
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    v_PROD := 'FN_FDS_RULE08';
    v_TxDate := to_char(sysdate,'YYYYMMDD');
    v_BegTime := to_char(sysdate,'hh24missss');
    v_EndTime := 0;
    v_STS := 'START'; -- START / DONE / ERROR
    v_STSDESC := ' ';
    l_check_point := 1;
    --INSERT INTO FDS_LOG VALUES(v_PROD,v_TxDate,v_BegTime,v_EndTime,v_STS,v_STSDESC);
    --COMMIT;
    -------------------------------------------------
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    
    IF P_TXN_AMT > 0 AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN
        strt_tms := TMS_ADD_SUBTRACT(p_time_period,p_end_tms);--truyen vao 1 cho p_time_period
        
		select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;

		IF (P_POS_MOD LIKE '81%' OR P_POS_MOD LIKE '10%' OR P_POS_MOD LIKE '01%') AND V_3D_CHK > 0 THEN --GD QUA MANG, 3DS

          --SO LUONG VA TONG SO TIEN GD 3DS >= 5GD
          SELECT nvl(COUNT(1),0) INTO v_cnt FROM FDS_TXN_DETAIL A INNER JOIN OA126@IM B ON fx_oa008_used_pan=PX_OA126_PAN AND P9_OA126_SEQ_NUM=P9_OA008_SEQ where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE '81%' OR FX_OA008_POS_MODE LIKE '10%' OR FX_OA008_POS_MODE LIKE '01%') AND f9_oa008_cre_tms >= strt_tms AND f9_oa008_cre_tms <= p_end_tms AND fx_oa008_used_pan = p_cardno;

          IF v_cnt >= 5 THEN
              l_check_point := 2;
              SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
              ----lay dung cif theo the chinh hoac phu
              select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
              IF V_CRN > 0 THEN
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
              ELSE
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
              END IF;
              ----thong tin gd co 3D Secure hay khong-
              select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              IF V_3D_CHK > 0 THEN
                   SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              END IF;
              ----------------------------------------
              SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND p9_oa008_seq = P_SEQ;
              ----CHECK IF CASE ALREADY EXISTED----
              IF p_check = 'FALSE' THEN
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, UPPER(FX_OA008_MERC_NAME), F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                  execute immediate sql_stmt;
              END IF;
              ------------------------------------
              l_check_point := 3;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''' || V_RULENAME || ''',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL A INNER JOIN OA126@IM B ON fx_oa008_used_pan=PX_OA126_PAN AND P9_OA126_SEQ_NUM=P9_OA008_SEQ where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE ''81%'' OR FX_OA008_POS_MODE LIKE ''10%'' OR FX_OA008_POS_MODE LIKE ''01%'') AND f9_oa008_cre_tms >= '|| strt_tms ||' AND f9_oa008_cre_tms <= ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || ''' ORDER BY f9_oa008_cre_tms desc';
              execute immediate sql_stmt2;
              l_check_point := 4;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''','''||V_RULENAME||''')';
              execute immediate sql_stmt2;
              commit;
              p_cnt := 1;
              RETURN 'DONE';
          ELSE
              p_cnt:= 0;
              RETURN 'FALSE';
          END IF;
		ELSIF  (P_POS_MOD LIKE '05%' OR P_POS_MOD LIKE '07%') AND P_MCC<>6011 THEN --GD CHIP, TAI POS >=5GD

          --SO LUONG GD
          SELECT nvl(COUNT(1),0) INTO v_cnt FROM FDS_TXN_DETAIL A  where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE '05%' OR FX_OA008_POS_MODE LIKE '07%') AND F9_OA008_MCC<>6011 AND f9_oa008_cre_tms >= strt_tms AND f9_oa008_cre_tms <= p_end_tms AND fx_oa008_used_pan = p_cardno;

          IF v_cnt >= 5 THEN
              l_check_point := 2;
              SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
              ----lay dung cif theo the chinh hoac phu
              select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
              IF V_CRN > 0 THEN
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
              ELSE
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
              END IF;
              ----thong tin gd co 3D Secure hay khong-
              select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              IF V_3D_CHK > 0 THEN
                   SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN)AND P9_OA126_SEQ_NUM = P_SEQ;
              END IF;
              ----------------------------------------
              SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND p9_oa008_seq = P_SEQ;
              ----CHECK IF CASE ALREADY EXISTED----
              IF p_check = 'FALSE' THEN
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, UPPER(FX_OA008_MERC_NAME), F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                  execute immediate sql_stmt;
              END IF;
              ------------------------------------
              l_check_point := 3;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''' || V_RULENAME || ''',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL A where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE ''05%'' OR FX_OA008_POS_MODE LIKE ''07%'') and F9_OA008_MCC <> 6011 AND f9_oa008_cre_tms >= '|| strt_tms ||' AND f9_oa008_cre_tms <= ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || ''' ORDER BY f9_oa008_cre_tms desc';
              execute immediate sql_stmt2;
              l_check_point := 4;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''','''||V_RULENAME||''')';
              execute immediate sql_stmt2;
              commit;
              p_cnt := 1;
              RETURN 'DONE';
          ELSE
              p_cnt:= 0;
              RETURN 'FALSE';
          END IF;
		ELSIF  (P_POS_MOD LIKE '05%' OR P_POS_MOD LIKE '07%') AND P_MCC=6011 AND p_loc LIKE '8%' THEN --GD CHIP, TAI ATM, CREDIT >=5GD

          --SO LUONG GD
          SELECT nvl(COUNT(1),0) INTO v_cnt FROM FDS_TXN_DETAIL A  where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE '05%' OR FX_OA008_POS_MODE LIKE '07%') AND F9_OA008_MCC=6011 AND FX_OA008_LOC_STAT LIKE '8%' AND f9_oa008_cre_tms >= strt_tms AND f9_oa008_cre_tms <= p_end_tms AND fx_oa008_used_pan = p_cardno;

          IF v_cnt >= 5 THEN
              l_check_point := 2;
              SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
              ----lay dung cif theo the chinh hoac phu
              select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
              IF V_CRN > 0 THEN
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
              ELSE
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
              END IF;
              ----thong tin gd co 3D Secure hay khong-
              select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              IF V_3D_CHK > 0 THEN
                   SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              END IF;
              ----------------------------------------
              SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND p9_oa008_seq = P_SEQ;
              ----CHECK IF CASE ALREADY EXISTED----
              IF p_check = 'FALSE' THEN
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, UPPER(FX_OA008_MERC_NAME), F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                  execute immediate sql_stmt;
              END IF;
              ------------------------------------
              l_check_point := 3;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''' || V_RULENAME || ''',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL A where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE ''05%'' OR FX_OA008_POS_MODE LIKE ''07%'') and F9_OA008_MCC=6011 AND FX_OA008_LOC_STAT LIKE ''8%'' AND f9_oa008_cre_tms >= '|| strt_tms ||' AND f9_oa008_cre_tms <= ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || ''' ORDER BY f9_oa008_cre_tms desc';
              execute immediate sql_stmt2;
              l_check_point := 4;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''','''||V_RULENAME||''')';
              execute immediate sql_stmt2;
              commit;
              p_cnt := 1;
              RETURN 'DONE';
          ELSE
              p_cnt:= 0;
              RETURN 'FALSE';
          END IF;
		ELSIF  (P_POS_MOD LIKE '05%' OR P_POS_MOD LIKE '07%') AND P_MCC=6011 AND p_loc NOT LIKE '8%' THEN --GD CHIP, TAI ATM, CREDIT >=7GD

          --SO LUONG GD
          SELECT nvl(COUNT(1),0) INTO v_cnt FROM FDS_TXN_DETAIL A  where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE '05%' OR FX_OA008_POS_MODE LIKE '07%') AND F9_OA008_MCC=6011 AND FX_OA008_LOC_STAT NOT LIKE '8%' AND f9_oa008_cre_tms >= strt_tms AND f9_oa008_cre_tms <= p_end_tms AND fx_oa008_used_pan = p_cardno;

          IF v_cnt >= 7 THEN
              l_check_point := 2;
              SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
              ----lay dung cif theo the chinh hoac phu
              select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
              IF V_CRN > 0 THEN
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
              ELSE
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
              END IF;
              ----thong tin gd co 3D Secure hay khong-
              select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              IF V_3D_CHK > 0 THEN
                   SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              END IF;
              ----------------------------------------
              SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND p9_oa008_seq = P_SEQ;
              ----CHECK IF CASE ALREADY EXISTED----
              IF p_check = 'FALSE' THEN
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, UPPER(FX_OA008_MERC_NAME), F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                  execute immediate sql_stmt;
              END IF;
              ------------------------------------
              l_check_point := 3;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''' || V_RULENAME || ''',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL A where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE ''05%'' OR FX_OA008_POS_MODE LIKE ''07%'') and F9_OA008_MCC=6011 AND FX_OA008_LOC_STAT NOT LIKE ''8%'' AND f9_oa008_cre_tms >= '|| strt_tms ||' AND f9_oa008_cre_tms <= ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || ''' ORDER BY f9_oa008_cre_tms desc';
              execute immediate sql_stmt2;
              l_check_point := 4;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''','''||V_RULENAME||''')';
              execute immediate sql_stmt2;
              commit;
              p_cnt := 1;
              RETURN 'DONE';
          ELSE
              p_cnt:= 0;
              RETURN 'FALSE';
          END IF;
		ELSIF  (P_POS_MOD LIKE '90%' OR P_POS_MOD LIKE '80%') THEN --GD TU >= 3GD

          --SO LUONG GD
          SELECT nvl(COUNT(1),0) INTO v_cnt FROM FDS_TXN_DETAIL A  where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE '90%' OR FX_OA008_POS_MODE LIKE '80%') AND f9_oa008_cre_tms >= strt_tms AND f9_oa008_cre_tms <= p_end_tms AND fx_oa008_used_pan = p_cardno;

          IF v_cnt >= 3 THEN
              l_check_point := 2;
              SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
              ----lay dung cif theo the chinh hoac phu
              select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
              IF V_CRN > 0 THEN
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
              ELSE
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
              END IF;
              ----thong tin gd co 3D Secure hay khong-
              select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              IF V_3D_CHK > 0 THEN
                   SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
              END IF;
              ----------------------------------------
              SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND p9_oa008_seq = P_SEQ;
              ----CHECK IF CASE ALREADY EXISTED----
              IF p_check = 'FALSE' THEN
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, UPPER(FX_OA008_MERC_NAME), F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                  execute immediate sql_stmt;
              END IF;
              ------------------------------------
              l_check_point := 3;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''' || V_RULENAME || ''',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL A where f9_oa008_amt_req > 0 AND (FX_OA008_POS_MODE LIKE ''90%'' OR FX_OA008_POS_MODE LIKE ''80%'') AND f9_oa008_cre_tms >= '|| strt_tms ||' AND f9_oa008_cre_tms <= ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || ''' ORDER BY f9_oa008_cre_tms desc';
              execute immediate sql_stmt2;
              l_check_point := 4;
              sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''','''||V_RULENAME||''')';
              execute immediate sql_stmt2;
              commit;
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
             v_STSDESC := SQLERRM||' At:'||l_check_point||','||sql_stmt;
             DBMS_OUTPUT.put_line('Loi:'||v_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
             --COMMIT;
             p_cnt:= 0;
             RETURN 'ERROR';
END;

/
--------------------------------------------------------
--  DDL for Function FN_FDS_RULE03_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE03_V3" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    CHAUTK   19DEC2016     TONG SO GIAO DICH CUA 1 THE TRONG VONG 1H >= 20TR*
*                               HOAC NGOAI TE TUONG DUONG                        *
* 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
*                               DICH                                             *
* 2.1    HUYENNT  27DEC2017     BO SUNG CANH BAO DOI VOI THE MCDB, MC WORLD      *
*                                                                                *
* 3.0    HUYENNT  12FEB2019     CAP NHAT RULE THEO THONG BAO DC DUYET 20190121   *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_LOC_ACCT IN NUMBER, --ADD ON 20201126
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
    CRE_TMS VARCHAR(17);
    V_CNT NUMBER;
    CASE_ID VARCHAR2(50);
    V_AMOUNT05_R NUMBER:=30000000; -- SO TIEN GIAO DICH CHIP THE CHUAN
    V_AMOUNT05_G NUMBER:=50000000; -- SO TIEN GIAO DICH CHIP THE VANG
    V_AMOUNT05_PW NUMBER:=80000000; -- SO TIEN GIAO DICH CHIP THE P,W

    V_AMOUNT90_R NUMBER:=5000000; -- SO TIEN GIAO DICH TU THE CHUAN
    V_AMOUNT90_G NUMBER:=10000000; -- SO TIEN GIAO DICH TU THE VANG
    V_AMOUNT90_PW NUMBER:=15000000; -- SO TIEN GIAO DICH TU THE P,W
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'FN_FDS_RULE03';
    V_RULENAME VARCHAR2(6):='RULE03';
    L_CHECK_POINT NUMBER:=1;
    V_TXDATE NUMBER:=TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME NUMBER:=TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME NUMBER:=0;
    V_STS VARCHAR(10):= 'START';-- START / DONE / ERROR
    V_STSDESC VARCHAR2(4000):=' ';
    V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
BEGIN
    --INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    --COMMIT;
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    -------------------------------------------------
    IF (P_POS_MODE LIKE '81%' OR P_POS_MODE LIKE '10%' OR P_POS_MODE LIKE '01%') AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN--GD 3DS
      IF P_TXN_AMT > 0 THEN
        
        ----thong tin gd co 3D Secure hay khong-
        select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
        IF V_3D_CHK > 0 THEN
           SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
          ----------------------------------------
          STRT_TMS := TMS_ADD_SUBTRACT(P_TIME_PERIOD,P_END_TMS);
          SQL_STMT := 'SELECT SUM(F9_OA008_AMT_REQ) FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND (T.FX_OA008_POS_MODE LIKE ''81%'' OR T.FX_OA008_POS_MODE LIKE ''10%'' OR T.FX_OA008_POS_MODE LIKE ''01%'') AND T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
          EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;
          IF ((P_CRD_PRD = 'R' OR P_LOC_ACCT NOT LIKE '8%') AND V_CNT >= V_AMOUNT05_R) OR (P_CRD_PRD = 'G' AND V_CNT >= V_AMOUNT05_G) OR (P_CRD_PRD IN ('P','W') AND V_CNT >= V_AMOUNT05_PW) THEN
              L_CHECK_POINT := 2;
              SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
              ----lay dung cif theo the chinh hoac phu
              select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
              IF V_CRN > 0 THEN
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
              ELSE
                  select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
              END IF;
              SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE F9_OA008_AMT_REQ > 0 AND FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ ;
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
                                   CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
              END IF;
              --------------------------------------
              L_CHECK_POINT := 3;
              SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND (T.FX_OA008_POS_MODE LIKE ''81%'' OR T.FX_OA008_POS_MODE LIKE ''10%'' OR T.FX_OA008_POS_MODE LIKE ''01%'') AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
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
        ELSE--gd khong co 3ds
          p_cnt:= 0;
          RETURN 'FALSE';
        END IF;
      ELSE--so tien gd <= 0
          p_cnt:= 0;
          RETURN 'FALSE';
      END IF;
    ELSIF (P_POS_MODE LIKE '05%'/*chip*/ OR P_POS_MODE LIKE '07%'/*contactless*/) AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN--GD CHIP
      IF P_TXN_AMT > 0 THEN
        STRT_TMS := TMS_ADD_SUBTRACT(P_TIME_PERIOD,P_END_TMS);
        SQL_STMT := 'SELECT SUM(F9_OA008_AMT_REQ) FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND (T.FX_OA008_POS_MODE LIKE ''05%'' OR T.FX_OA008_POS_MODE LIKE ''07%'') AND T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
        EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;
        IF ((P_CRD_PRD = 'R' OR P_LOC_ACCT NOT LIKE '8%') AND V_CNT >= V_AMOUNT05_R) OR (P_CRD_PRD = 'G' AND V_CNT >= V_AMOUNT05_G) OR (P_CRD_PRD IN ('P','W') AND V_CNT >= V_AMOUNT05_PW) THEN
            L_CHECK_POINT := 2;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            ----thong tin gd co 3D Secure hay khong-
            select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
            IF V_3D_CHK > 0 THEN
               SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN)AND P9_OA126_SEQ_NUM = P_SEQ;
            END IF;
            ----------------------------------------
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE F9_OA008_AMT_REQ > 0 AND FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ ;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
              EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND (T.FX_OA008_POS_MODE LIKE ''05%'' OR T.FX_OA008_POS_MODE LIKE ''07%'') AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
            RETURN 'DONE';
        ELSE--ko hit rule
            p_cnt:= 0;
            RETURN 'FALSE';
        END IF;
      ELSE--so tien <= 0
          p_cnt:= 0;
          RETURN 'FALSE';
      END IF;
    ELSIF (P_POS_MODE LIKE '90%' OR P_POS_MODE LIKE '80%') AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN--GD TU
      IF P_TXN_AMT > 0 THEN
        STRT_TMS := TMS_ADD_SUBTRACT(P_TIME_PERIOD,P_END_TMS);
        SQL_STMT := 'SELECT SUM(F9_OA008_AMT_REQ) FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND (T.FX_OA008_POS_MODE LIKE ''90%'' OR T.FX_OA008_POS_MODE LIKE ''80%'') AND T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
        EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;
        IF ((P_CRD_PRD = 'R' OR P_LOC_ACCT NOT LIKE '8%') AND V_CNT >= V_AMOUNT90_R) OR (P_CRD_PRD = 'G' AND V_CNT >= V_AMOUNT90_G) OR (P_CRD_PRD IN ('P','W') AND V_CNT >= V_AMOUNT90_PW) THEN
            L_CHECK_POINT := 2;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            ----thong tin gd co 3D Secure hay khong-
            select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN)AND P9_OA126_SEQ_NUM = P_SEQ;
            IF V_3D_CHK > 0 THEN
               SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
            END IF;
            ----------------------------------------
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE F9_OA008_AMT_REQ > 0 AND FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ ;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
              EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND (T.FX_OA008_POS_MODE LIKE ''90%'' OR T.FX_OA008_POS_MODE LIKE ''80%'') AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
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
--------------------------------------------------------
--  DDL for Function FN_FDS_RULE33_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE33_V3" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    CHAUTK   19DEC2016     TRONG VONG 24H, THE CO TU 5 GIAO DICH TRO LEN TAI*
*                               CUNG 1 TERMINAL                                  *
* 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
*                               DICH                                             *
* 3.0    HUYENNT  12FEB2019    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH  *
*                               DC DUYET NGAY 12/02/2019                         *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_CARDNO IN VARCHAR2,
    P_CRD_PGM IN VARCHAR2,--ADD ON 27122017
    P_MCC IN NUMBER, --ADD ON 12FEB2019
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    P_END_TMS IN VARCHAR2,
    P_CHECK IN VARCHAR2,
    P_MID IN VARCHAR2,--MID
    P_TIME_PERIOD IN NUMBER,-- TRUYEN VAO 24
    P_CNT OUT NUMBER
 ) RETURN VARCHAR2
 AS
    SQL_STMT VARCHAR2(4000);
    SQL_STMT2 VARCHAR2(4000);
    STRT_TMS VARCHAR(17);
    CRE_TMS VARCHAR(17);
    V_CNT NUMBER;
    CASE_ID VARCHAR2(50);
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'FN_FDS_RULE33';
    V_RULENAME VARCHAR2(6):='RULE33';
    L_CHECK_POINT NUMBER:=1;
    V_TXDATE NUMBER:=TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME NUMBER:=TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME NUMBER:=0;
    V_STS VARCHAR(10):= 'START';-- START / DONE / ERROR
    V_STSDESC VARCHAR2(4000):=' ';
    V_PAN VARCHAR2(30):=' ';
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
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF P_TXN_AMT > 0 AND P_MCC <> 6011 AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN
      STRT_TMS := TMS_ADD_SUBTRACT(P_TIME_PERIOD,P_END_TMS);
      SQL_STMT := 'SELECT COUNT(1) FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM T2 ON PX_OA126_PAN = FX_OA008_USED_PAN AND P9_OA126_SEQ_NUM = P9_OA008_SEQ WHERE T.F9_OA008_AMT_REQ > 0 AND T.F9_OA008_MCC <> 6011 AND T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.FX_OA008_MID = '''||P_MID||''' AND PX_OA126_PAN IS NULL AND P9_OA126_SEQ_NUM IS NULL AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
      EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;
      IF V_CNT >= 3 THEN
          L_CHECK_POINT := 2;
          SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
          ----lay dung cif theo the chinh hoac phu
          select count(1) INTO V_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO;
          IF V_CRN > 0 THEN
              select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
          ELSE
              select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
          END IF;
          ----thong tin gd co 3D Secure hay khong-
          select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
          IF V_3D_CHK > 0 THEN
               SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
          END IF;
          ----------------------------------------
          SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL where f9_oa008_amt_req > 0 AND fx_oa008_used_pan = p_cardno AND P9_OA008_SEQ=P_SEQ AND f9_oa008_cre_tms = p_end_tms;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
          END IF;
          --------------------------------------
          L_CHECK_POINT := 3;
          SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT '''||CRE_TMS||''', '''||CRE_TMS||''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', F9_OA008_CRE_TMS, FX_OA008_USED_PAN, F9_OA008_MCC, P9_OA008_SEQ, F9_OA008_DT, F9_OA008_TM FROM FDS_TXN_DETAIL LEFT JOIN OA126@IM T2 ON PX_OA126_PAN = FX_OA008_USED_PAN AND P9_OA126_SEQ_NUM = P9_OA008_SEQ WHERE F9_OA008_MCC <> 6011 AND FX_OA008_USED_PAN = '''|| P_CARDNO ||''' AND FX_OA008_MID = '''||P_MID||''' AND PX_OA126_PAN IS NULL AND P9_OA126_SEQ_NUM IS NULL AND F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS|| ' ORDER BY F9_OA008_CRE_TMS DESC';
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
             RETURN 'ERROR';
END;

/
--------------------------------------------------------
--  DDL for Function FN_FDS_RULE23_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE23_V3" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   06DEC2016    RULE23: GD phat sinh tai 2 QGia khac nhau trong  *
*                               24h                                              *
* 2.0    HUYENNT   21FEB2017    LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
*                               DICH                                             *
* 2.1    HUYENNT   14APR2018    CHECK THEO MERC_ST_CNTRY                         *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_POS_MODE IN VARCHAR2, --ADD ON 21022017
    p_cardno IN VARCHAR2,
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    p_time_period IN NUMBER,
    p_end_tms in VARCHAR2,
    p_check IN VARCHAR2,
    p_cnt OUT NUMBER
 ) RETURN VARCHAR2
 AS
    sql_stmt varchar2(4000);
    sql_stmt2 varchar2(4000);
    strt_tms varchar(17);
    cre_tms varchar(17);
    v_cnt number;
    case_id VARCHAR2(50);
	V_TOTAL_AMT NUMBER;
    --BIEN DUNG GHI LOG--
    v_PROD varchar(255);
    l_check_point number;
    v_TxDate number;
    v_BegTime number;
    v_EndTime number;
    v_STS varchar(10);
    v_STSDESC varchar2(4000);
    V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    V_POS_MODE VARCHAR2(5) := SUBSTR(P_POS_MODE,1,2);
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    v_PROD := 'SP_FDS_RULE23';
    v_TxDate := to_char(sysdate,'YYYYMMDD');
    v_BegTime := to_char(sysdate,'hh24missss');
    v_EndTime := 0;
    v_STS := 'START'; -- START / DONE / ERROR
    v_STSDESC := ' ';
    l_check_point := 1;
    --INSERT INTO FDS_LOG VALUES(v_PROD,v_TxDate,v_BegTime,v_EndTime,v_STS,v_STSDESC);
    --COMMIT;
    -------------------------------------------------
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF (V_POS_MODE = '05' OR V_POS_MODE = '90' OR V_POS_MODE = '91') AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN
        strt_tms := TMS_ADD_SUBTRACT(p_time_period,p_end_tms);
        l_check_point := 2;
       SELECT
          COUNT(DISTINCT CNTR_CDE),SUM(F9_OA008_AMT_REQ) INTO v_cnt,V_TOTAL_AMT
        FROM
          (

          SELECT nvl(nvl((case when trim(fx_oa008_merc_st_cntry) = '04' then 'VNM' when trim(fx_oa008_merc_st_cntry) = '70' then 'VNM' when fx_oa008_merc_st_cntry = '704' then 'VNM' when upper(trim(fx_oa008_merc_st_cntry)) = 'VN' then 'VNM' else null end),(select ISO_COUNTRY_CODE from iso_uscan_province_code where ISO_PROVINCE_CODE = upper(trim(fx_oa008_merc_st_cntry)))),upper(fx_oa008_merc_st_cntry)) AS CNTR_CDE,F9_OA008_AMT_REQ
          FROM
              fds_txn_detail        
          where  substr(fx_oa008_pos_mode,1,2) in ('05','07','80','90','91') 
          AND NOT (f9_oa008_mcc=6011 AND (FX_OA008_STAT<>' ' OR FX_OA008_GIVEN_RESP_CDE<>'00'))
              AND fx_oa008_used_pan = p_cardno
              AND f9_oa008_cre_tms >= strt_tms
              AND f9_oa008_cre_tms <= p_end_tms
          )
        /*WHERE CNTR_CDE <> ' '*/;
        v_cnt := nvl(v_cnt,0);
        IF v_cnt >= 2 AND V_TOTAL_AMT>=2000000 THEN
            l_check_point := 3;
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
            SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND P9_OA008_SEQ=P_SEQ AND f9_oa008_cre_tms = p_end_tms;
            ----CHECK IF CASE ALREADY EXISTED----
            IF p_check = 'FALSE' THEN
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                execute immediate sql_stmt;
            END IF;
            ------------------------------------
            l_check_point := 4;
            sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''RULE23'',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL where substr(fx_oa008_pos_mode,1,2) in (''05'',''07'',''80'',''90'',''91'') AND NOT (f9_oa008_mcc=6011 AND (FX_OA008_STAT<>'' '' OR FX_OA008_GIVEN_RESP_CDE<>''00'')) AND f9_oa008_cre_tms >= ' || strt_tms ||' AND f9_oa008_cre_tms <= ' || p_end_tms || ' AND fx_oa008_used_pan = ''' || p_cardno || ''' ORDER BY f9_oa008_cre_tms desc';
            execute immediate sql_stmt2;
            l_check_point := 5;
            sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''',''RULE23'')';
            execute immediate sql_stmt2;
            commit;
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
             RETURN 'ERROR';
END;

/
--------------------------------------------------------
--  DDL for Function FN_FDS_RULE21_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE21_V3" 
/************************************************************************************
* VER    ID        DATE         ENHANCEMENT                                         *
* -----  -------   ---------    ----------------------------------------------------*
* 1.0    HUYENNT   20OCT2016    THE PS 3 GD ONLINE/KEY ENTER TRO LEN TRONG 5 PHUT   *
* 2.0    HUYENNT   21FEB2017    LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO       *
*                               DICH                                                *
* 3.0    HUYENNT   12FEB2019    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH    *
*                               DC DUYET NGAY 12/02/2019(THEM GD CREDENTIAL ON FILE)*
*************************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_POS_MOD IN VARCHAR2,--ADD ON 21022017
    p_cardno IN VARCHAR2,
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    p_qty IN NUMBER,
    p_time_period IN NUMBER,
    p_end_tms in VARCHAR2,
    p_check IN VARCHAR2,
    p_cnt OUT NUMBER
) RETURN VARCHAR2
 AS
    sql_stmt varchar2(4000);
    sql_stmt2 varchar2(4000);
    strt_tms varchar(17);
    cre_tms varchar(17);
    v_cnt number;
    case_id VARCHAR2(50);
    --BIEN DUNG GHI LOG--
    v_PROD varchar(255);
    l_check_point number;
    v_TxDate number;
    v_BegTime number;
    v_EndTime number;
    v_STS varchar(10);
    v_STSDESC varchar2(4000);
    V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    V_POS_MOD VARCHAR2(5) := SUBSTR(P_POS_MOD,1,2);
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    v_PROD := 'SP_FDS_RULE21';
    v_TxDate := to_char(sysdate,'YYYYMMDD');
    v_BegTime := to_char(sysdate,'hh24missss');
    v_EndTime := 0;
    v_STS := 'START'; -- START / DONE / ERROR
    v_STSDESC := ' ';
    l_check_point := 1;
    --INSERT INTO FDS_LOG VALUES(v_PROD,v_TxDate,v_BegTime,v_EndTime,v_STS,v_STSDESC);
    --COMMIT;
    -------------------------------------------------
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF (V_POS_MOD = '01' OR V_POS_MOD = '81' OR V_POS_MOD = '10') AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN
        strt_tms := TMS_ADD_SUBTRACT(p_time_period,p_end_tms);
        sql_stmt := 'SELECT COUNT(1) FROM FDS_TXN_DETAIL LEFT JOIN OA126@IM ON PX_OA126_PAN = fx_oa008_used_pan AND P9_OA126_SEQ_NUM = P9_OA008_SEQ where f9_oa008_amt_req >= 0 AND f9_oa008_cre_tms >= ' || strt_tms ||' AND f9_oa008_cre_tms <= ' || p_end_tms ||' AND substr(fx_oa008_pos_mode,1,2) in (''81'',''01'',''10'') AND fx_oa008_used_pan = ''' || p_cardno || ''' AND PX_OA126_PAN IS NULL AND P9_OA126_SEQ_NUM IS NULL ';
        execute immediate sql_stmt into v_cnt;
        select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
        V_3D_CHK := NVL(V_3D_CHK,0);
        IF v_cnt >= p_qty AND V_3D_CHK = 0 THEN
            l_check_point := 2;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            ----thong tin gd co 3D Secure hay khong-

            IF V_3D_CHK > 0 THEN
                 SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
            END IF;
            ----------------------------------------
            SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where f9_oa008_amt_req > 0 AND fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND P9_OA008_SEQ=P_SEQ;
            ----CHECK IF CASE ALREADY EXISTED----
            IF p_check = 'FALSE' THEN
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                execute immediate sql_stmt;
            END IF;
            --------------------------------------
            l_check_point := 3;
            sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''RULE21'',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL LEFT JOIN OA126@IM ON PX_OA126_PAN = fx_oa008_used_pan AND P9_OA126_SEQ_NUM = P9_OA008_SEQ where f9_oa008_amt_req > 0 AND f9_oa008_cre_tms >= ' || strt_tms ||' AND f9_oa008_cre_tms <= ' || p_end_tms ||' AND substr(fx_oa008_pos_mode,1,2) in (''81'',''01'',''10'') AND fx_oa008_used_pan = ''' || p_cardno || ''' AND PX_OA126_PAN IS NULL AND P9_OA126_SEQ_NUM IS NULL ORDER BY f9_oa008_cre_tms desc';
            execute immediate sql_stmt2;
            l_check_point := 4;
            sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''',''RULE21'')';
            execute immediate sql_stmt2;
            commit;
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
             RETURN 'ERROR';
END;

/
--------------------------------------------------------
--  DDL for Function FN_FDS_RULE17_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE17_V3" 
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
    P_LOC_ACCT IN NUMBER, --ADD ON 20201201
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
    V_R_VND_AMT NUMBER:=2000000; --TONG SO TIEN GIAO DICH THE CHUAN VND
    V_G_VND_AMT NUMBER:=3000000; --TONG SO TIEN GIAO DICH THE VANG VND
    --V_R_OTH_AMT NUMBER:=800000; --TONG SO TIEN GIAO DICH THE CHUAN NGOAI TE
    --V_G_OTH_AMT NUMBER:=2000000; --TONG SO TIEN GIAO DICH THE VANG NGOAI TE
    V_TOTAL_AMT NUMBER;
    V_TOTAL_AMT1 NUMBER;
    V_TOTAL_AMT2 NUMBER;
    V_TOTAL_AMT3 NUMBER;
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'FN_FDS_RULE17';
    V_RULENAME VARCHAR2(6):='RULE17';
    L_CHECK_POINT NUMBER:=1;
    V_TXDATE NUMBER:=TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME NUMBER:=TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME NUMBER:=0;
    V_STS VARCHAR(10):= 'START';-- START / DONE / ERROR
    V_STSDESC VARCHAR2(4000):=' ';
    V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    V_POS_MOD VARCHAR2(3) := SUBSTR(P_POS_MOD,1,2);
    V_TIME_PERIOD NUMBER := 1;
BEGIN
    --INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    --COMMIT;
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF P_TXN_AMT > 0 AND (V_POS_MOD = '01' OR V_POS_MOD = '81' OR V_POS_MOD = '10') AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN
      ---CHECK thong tin gd co 3D Secure hay khong---
      select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
      V_3D_CHK := NVL(V_3D_CHK,0);
      IF V_3D_CHK = 0 THEN--GD KHONG QUA 3DS
          STRT_TMS := TMS_ADD_SUBTRACT(V_TIME_PERIOD,P_END_TMS);
          ---START: TINH TONG GD THEO LOAI TIEN TRONG VONG 2H---
          SELECT SUM(T.F9_OA008_AMT_REQ) INTO V_TOTAL_AMT FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN ('01','81','10') AND T.FX_OA008_USED_PAN = P_CARDNO AND T.F9_OA008_MCC NOT IN (7011,4511,6300) and T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;

          --TONG SO TIEN GD TAI CAC DVCNT: MCC 7011 - LODGING - HOTELS, MOTELS, RESORTS
          SELECT SUM(T.F9_OA008_AMT_REQ) INTO V_TOTAL_AMT1 FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN ('01','81','10') AND T.FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_MCC=7011 and T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;

          --TONG SO TIEN GD TAI CAC DVCNT: MCC 4511 - AIRLINES, AIR CARRIERS
          SELECT SUM(T.F9_OA008_AMT_REQ) INTO V_TOTAL_AMT2 FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN ('01','81','10') AND T.FX_OA008_USED_PAN = P_CARDNO AND T.F9_OA008_MCC=4511 and T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;

          --TONG SO TIEN GD TAI CAC DVCNT: MCC 6311 - INSURANCE
          SELECT SUM(T.F9_OA008_AMT_REQ) INTO V_TOTAL_AMT3 FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN ('01','81','10') AND T.FX_OA008_USED_PAN = P_CARDNO AND T.F9_OA008_MCC=6300 and T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;

          --BAT DAU CHECK CHUOI CAC DIEU KIEN LOC
          IF (P_CRD_PRD = 'R' OR P_LOC_ACCT NOT LIKE '8%') AND V_TOTAL_AMT >= V_R_VND_AMT THEN--THE HANG CHUAN HOAC DEBIT
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
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'',''10'') AND T.F9_OA008_MCC NOT IN (7011,4511,6300) AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
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
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'') AND T.F9_OA008_MCC NOT IN (7011,4511,6300) AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
            RETURN 'DONE';
          ELSIF V_TOTAL_AMT1 >= 5000000 THEN--MCC 7011 - LODGING - HOTELS, MOTELS, RESORTS
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
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ; 
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'') AND T.F9_OA008_MCC = 7011 AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
            RETURN 'DONE';
          ELSIF V_TOTAL_AMT2 >= 10000000 THEN--MCC 4511 - AIRLINES, AIR CARRIERS
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
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'') AND T.F9_OA008_MCC = 4511 AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
            EXECUTE IMMEDIATE SQL_STMT2;
            L_CHECK_POINT := 4;
            SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
            EXECUTE IMMEDIATE SQL_STMT2;
            COMMIT;
            P_CNT := 1;
            RETURN 'DONE';
          ELSIF V_TOTAL_AMT3 >= 20000000 THEN--MCC 6300 - INSURANCE
            L_CHECK_POINT := 5;
            SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
            ----lay dung cif theo the chinh hoac phu
            select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
            IF V_CRN > 0 THEN
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
            ELSE
                select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
            END IF;
            ----------------------------------------
            SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
            END IF;
            --------------------------------------
            L_CHECK_POINT := 3;
            SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T LEFT JOIN OA126@IM ON T.FX_OA008_USED_PAN = PX_OA126_PAN AND T.P9_OA008_SEQ = P9_OA126_SEQ_NUM WHERE T.f9_oa008_amt_req > 0 AND FX_OA126_3D_IND IS NULL AND SUBSTR(T.FX_OA008_POS_MODE,1,2) IN (''01'',''81'') AND T.F9_OA008_MCC = 6300 AND T.FX_OA008_USED_PAN = ''' || P_CARDNO || ''' AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
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
--------------------------------------------------------
--  DDL for Function FN_FDS_RULE29_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE29_V3" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   06DEC2016    Giao dich the MasterCard tai cac ATM o An Do,    *
*                               Nepal, Indonesia voi so tien ngoai te tuong duong*
*                               >= 5 trieu VND/ giao dich                        *
* 2.0    HUYENNT   21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO   *
*                               DICH                                             *
* 3.0    HUYENNT   12FEB2019    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
*                               DC DUYET NGAY 12/02/2019                         *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    p_cardno IN VARCHAR2,
    p_end_tms in VARCHAR2,
    p_mcc IN number,
    P_cntr_cde VARCHAR2,
    p_pos_mode IN VARCHAR2,--ADD ON 20190218
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    P_txn_amt IN NUMBER,
    p_crd_brn VARCHAR2,
    p_check IN VARCHAR2,
    p_cnt OUT NUMBER
 ) RETURN VARCHAR2
 AS
    sql_stmt varchar2(4000);
    sql_stmt2 varchar2(4000);
    cre_tms varchar(17);
    v_cnt number;
    case_id VARCHAR2(50);
    --BIEN DUNG GHI LOG--
    v_PROD varchar(255);
    l_check_point number;
    v_TxDate number;
    v_BegTime number;
    v_EndTime number;
    v_STS varchar(10);
    v_STSDESC varchar2(4000);
    V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    ---------------------
    V_POS_MODE CHAR(2);
BEGIN
    V_POS_MODE := SUBSTR(p_pos_mode,1,2);
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    v_PROD := 'SP_FDS_RULE29';
    v_TxDate := to_char(sysdate,'YYYYMMDD');
    v_BegTime := to_char(sysdate,'hh24missss');
    v_EndTime := 0;
    v_STS := 'START'; -- START / DONE / ERROR
    v_STSDESC := ' ';
    l_check_point := 1;
    --INSERT INTO FDS_LOG VALUES(v_PROD,v_TxDate,v_BegTime,v_EndTime,v_STS,v_STSDESC);
    --COMMIT;
    -------------------------------------------------
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF p_mcc = 6011 AND P_cntr_cde = '360' AND V_POS_MODE = '90' AND p_crd_brn = 'MC' AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN--GD TU TAI ATM O INDONESIA
        l_check_point := 2;
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
        SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms;
        ----CHECK IF CASE ALREADY EXISTED----
        IF p_check = 'FALSE' THEN
            SQL_STMT := 'INSERT INTO FPS.FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
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
            execute immediate sql_stmt;
        END IF;
        ------------------------------------
        l_check_point := 3;
        sql_stmt2 := 'INSERT INTO FPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''RULE29'',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL where f9_oa008_amt_req >= 5000000 AND f9_oa008_cre_tms = ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || ''' ORDER BY f9_oa008_cre_tms desc';
        execute immediate sql_stmt2;
        l_check_point := 4;
        sql_stmt2 := 'INSERT INTO FPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''',''RULE29'')';
        execute immediate sql_stmt2;
        commit;
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
             --DBMS_OUTPUT.put_line('Loi:'||v_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
             --COMMIT;
             p_cnt:= 0;
             RETURN 'ERROR';
END;

/
--------------------------------------------------------
--  DDL for Function FN_FDS_RULE39_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE39_V3" 
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
	p_NGAY_GD IN VARCHAR2,
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
    V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_AMOUNT_CR_CHIP NUMBER := 10000000; -- SO TIEN GIAO DICH THE CREDIT CHIP
    V_AMOUNT_DB_CHIP NUMBER := 5000000; -- SO TIEN GIAO DICH THE DEBIT CHIP
    V_AMOUNT_CR_TU NUMBER := 5000000; -- SO TIEN GIAO DICH THE CREDIT TU
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
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF ((TXN_TMS >= 2300 and TXN_TMS <= 2359) OR (TXN_TMS >= 0 and TXN_TMS <= 459)) AND TRIM(P_CRCY_CDE) = '704' AND P_MCC NOT IN ('5813','5921') AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN
      IF V_POS_MODE = '05' THEN--giao dich chip
        SELECT sum(T.F9_OA008_AMT_REQ) into V_AMT FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND TRIM(T.F9_OA008_CRNCY_CDE) = '704' AND T.F9_OA008_MCC NOT IN ('5813','5921') AND T.FX_OA008_POS_MODE LIKE '05%' AND T.FX_OA008_USED_PAN = P_CARDNO AND ((to_number(substr(lpad(T.F9_OA008_TM,8,'0'),1,4)) BETWEEN 2300 AND 2359 AND F9_OA008_DT BETWEEN p_NGAY_GD AND TO_CHAR(TO_DATE(p_NGAY_GD, 'YYYYMMDD') +1,'yyyymmdd'))
OR (to_number(substr(lpad(T.F9_OA008_TM,8,'0'),1,4)) BETWEEN 0 AND 459 AND F9_OA008_DT BETWEEN TO_CHAR(TO_DATE(p_NGAY_GD, 'YYYYMMDD') - 1,'yyyymmdd') AND p_NGAY_GD))
;
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
          select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
          IF V_3D_CHK > 0 THEN
               SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
          END IF;
          ----------------------------------------
          SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ;
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
                 SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
          END IF;
          --------------------------------------
          L_CHECK_POINT := 3;
          SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT '''||CRE_TMS||''', '''||CRE_TMS||''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND TRIM(T.F9_OA008_CRNCY_CDE) = ''704'' AND T.F9_OA008_MCC NOT IN (''5813'',''5921'') AND T.FX_OA008_POS_MODE LIKE ''05%'' AND T.FX_OA008_USED_PAN ='''||P_CARDNO||''' AND ((to_number(substr(lpad(T.F9_OA008_TM,8,''0''),1,4)) BETWEEN 2300 AND 2359 AND F9_OA008_DT BETWEEN '''|| p_NGAY_GD ||''' AND TO_CHAR(TO_DATE('''|| p_NGAY_GD ||''', ''YYYYMMDD'') +1,''yyyymmdd''))
OR (to_number(substr(lpad(T.F9_OA008_TM,8,''0''),1,4)) BETWEEN 0 AND 459 AND F9_OA008_DT BETWEEN TO_CHAR(TO_DATE('''|| p_NGAY_GD ||''', ''YYYYMMDD'') - 1,''yyyymmdd'') AND '''|| p_NGAY_GD ||'''))';
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
        SELECT sum(T.F9_OA008_AMT_REQ) into V_AMT FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND TRIM(T.F9_OA008_CRNCY_CDE) = '704' AND T.F9_OA008_MCC NOT IN ('5813','5921') AND T.FX_OA008_POS_MODE LIKE '90%' AND T.FX_OA008_USED_PAN = P_CARDNO AND ((to_number(substr(lpad(T.F9_OA008_TM,8,'0'),1,4)) BETWEEN 2300 AND 2359 AND F9_OA008_DT BETWEEN p_NGAY_GD AND TO_CHAR(TO_DATE(p_NGAY_GD, 'YYYYMMDD') +1,'yyyymmdd'))
OR (to_number(substr(lpad(T.F9_OA008_TM,8,'0'),1,4)) BETWEEN 0 AND 459 AND F9_OA008_DT BETWEEN TO_CHAR(TO_DATE(p_NGAY_GD, 'YYYYMMDD') - 1,'yyyymmdd') AND p_NGAY_GD));
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
          select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
          IF V_3D_CHK > 0 THEN
               SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
          END IF;
          ----------------------------------------
          SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
                EXECUTE IMMEDIATE SQL_STMT;
          END IF;
          --------------------------------------
          L_CHECK_POINT := 6;
          SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT '''||CRE_TMS||''', '''||CRE_TMS||''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND TRIM(T.F9_OA008_CRNCY_CDE) = ''704'' AND T.F9_OA008_MCC NOT IN (''5813'',''5921'') AND T.FX_OA008_POS_MODE LIKE ''90%'' AND T.FX_OA008_USED_PAN ='''||P_CARDNO||''' AND AND ((to_number(substr(lpad(T.F9_OA008_TM,8,''0''),1,4)) BETWEEN 2300 AND 2359 AND F9_OA008_DT BETWEEN '''|| p_NGAY_GD ||''' AND TO_CHAR(TO_DATE('''|| p_NGAY_GD ||''', ''YYYYMMDD'') +1,''yyyymmdd''))
OR (to_number(substr(lpad(T.F9_OA008_TM,8,''0''),1,4)) BETWEEN 0 AND 459 AND F9_OA008_DT BETWEEN TO_CHAR(TO_DATE('''|| p_NGAY_GD ||''', ''YYYYMMDD'') - 1,''yyyymmdd'') AND '''|| p_NGAY_GD ||'''))
';
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
             v_STSDESC := SQLERRM||' At:'||l_check_point || ' SQL: ' || SQL_STMT2;
             DBMS_OUTPUT.put_line('Loi:'||v_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
             --COMMIT;
             p_cnt:= 0;
             RETURN 'RULE39 ERROR:';
END;

/
--------------------------------------------------------
--  DDL for Function FN_FDS_RULE30_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE30_V3" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   06DEC2016    Giao dich the VISA tai cac ATM o Trung Quoc,An Do*
*                               Nepal, Nhat ban va Thai lan voi so tien ngoai te *
*                               tuong duong >= 5 trieu VND/ giao dich            *
* 2.0    HUYENNT   21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO   *
*                               DICH                                             *
* 3.0    HUYENNT   12FEB2019    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
*                               DC DUYET NGAY 12/02/2019                         *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    p_cardno IN VARCHAR2,
    p_end_tms in VARCHAR2,
    p_mcc IN number,
    p_pos_mode IN VARCHAR2,--ADD ON 20190218
    P_REF_CDE IN VARCHAR2,--ADD ON 12FEB2019
    P_cntr_cde VARCHAR2,
    p_crd_brn VARCHAR2,
    p_check IN VARCHAR2,
    p_cnt OUT NUMBER
 ) RETURN VARCHAR2
 AS
    sql_stmt varchar2(4000);
    sql_stmt2 varchar2(4000);
    cre_tms varchar(17);
    v_cnt number;
    case_id VARCHAR2(50);
    --BIEN DUNG GHI LOG--
    v_PROD varchar(255);
    l_check_point number;
    v_TxDate number;
    v_BegTime number;
    v_EndTime number;
    v_STS varchar(10);
    v_STSDESC varchar2(4000);
    V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    ---------------------
    V_POS_MODE CHAR(2);
BEGIN
    V_POS_MODE := SUBSTR(p_pos_mode,1,2);
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    v_PROD := 'SP_FDS_RULE30';
    v_TxDate := to_char(sysdate,'YYYYMMDD');
    v_BegTime := to_char(sysdate,'hh24missss');
    v_EndTime := 0;
    v_STS := 'START'; -- START / DONE / ERROR
    v_STSDESC := ' ';
    l_check_point := 1;
    --INSERT INTO FDS_LOG VALUES(v_PROD,v_TxDate,v_BegTime,v_EndTime,v_STS,v_STSDESC);
    --COMMIT;
    -------------------------------------------------
    SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF p_mcc = 6011 AND P_cntr_cde ='360' AND p_crd_brn = 'VS' AND V_POS_MODE = '90' AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' THEN--GD THE VISA QUA TU TAI ATM INDONESIA
        l_check_point := 2;
        SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
        ----lay dung cif theo the chinh hoac phu
        select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
        IF V_CRN > 0 THEN
            select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
        ELSE
            select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
        END IF;
        ----thong tin gd co 3D Secure hay khong-
        select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN)AND P9_OA126_SEQ_NUM = P_SEQ;
        IF V_3D_CHK > 0 THEN
             SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN)AND P9_OA126_SEQ_NUM = P_SEQ;
        END IF;
        SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms;
        ----CHECK IF CASE ALREADY EXISTED----
        IF p_check = 'FALSE' THEN
            SQL_STMT := 'INSERT INTO FPS.FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
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
            execute immediate sql_stmt;
        END IF;
        ------------------------------------
        l_check_point := 3;
        sql_stmt2 := 'INSERT INTO FPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''RULE30'',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL where f9_oa008_cre_tms = ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || '''';
        execute immediate sql_stmt2;
        l_check_point := 4;
        sql_stmt2 := 'INSERT INTO FPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''',''RULE30'')';
        execute immediate sql_stmt2;
        commit;
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
             --DBMS_OUTPUT.put_line('Loi:'||v_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
             --COMMIT;
             p_cnt:= 0;
             RETURN 'ERROR';
END;

/
