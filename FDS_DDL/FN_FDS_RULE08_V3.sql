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
    V_CNT_CLOSE_CASE NUMBER;
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
              -----START AUTO CLOSE CASE BY MERCHANT & POSMODE
                SELECT COUNT(A.CASE_NO) INTO V_CNT_CLOSE_CASE
                FROM CCPS.FDS_CASE_DETAIL A INNER JOIN CCPS.FDS_SYS_TASK B ON A.CIF_NO = B.OBJECTTASK  
                INNER JOIN CCPS.FDS_DESCRIPTION C ON C.TYPE='MERC' and regexp_like (C.ID,REPLACE(B.MERCHANT,'-','|'))  
                WHERE CHECK_NEW='Y' AND A.MERC_NAME LIKE '%' || C.DESCRIPTION || '%' AND B.MERCHANT IS NOT NULL  
                AND regexp_like (SUBSTR(A.POS_MODE,1,2),REPLACE(B.POSMODE,'-','|'))
                AND CASE_NO=CASE_ID;
                
                IF V_CNT_CLOSE_CASE>=1 THEN
                    UPDATE CCPS.FDS_CASE_DETAIL SET CASE_STATUS='DIC', ASG_TMS=CASE WHEN ASG_TMS=0 THEN to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')) END, UPD_TMS=to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')), USR_ID='SYSTEM', CHECK_NEW=' ', AUTOCLOSE='Y' WHERE CASE_NO=CASE_ID;
                    INSERT INTO CCPS.FDS_CASE_STATUS(ID,CASE_NO,CRE_TMS,USER_ID,CASE_COMMENT,CASE_ACTION,CLOSED_REASON,OTHER) VALUES (SQ_FDS_CASE_STATUS.nextval ,CASE_ID,to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')),'SYSTEM','Kh??ng x??c nh???n GD do KH y??u c???u','DIC','NCR','');
                    COMMIT;
                END IF;
                -----END AUTO CLOSE CASE---
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
              -----START AUTO CLOSE CASE BY MERCHANT & POSMODE
                SELECT COUNT(A.CASE_NO) INTO V_CNT_CLOSE_CASE
                FROM CCPS.FDS_CASE_DETAIL A INNER JOIN CCPS.FDS_SYS_TASK B ON A.CIF_NO = B.OBJECTTASK  
                INNER JOIN CCPS.FDS_DESCRIPTION C ON C.TYPE='MERC' and regexp_like (C.ID,REPLACE(B.MERCHANT,'-','|'))  
                WHERE CHECK_NEW='Y' AND A.MERC_NAME LIKE '%' || C.DESCRIPTION || '%' AND B.MERCHANT IS NOT NULL  
                AND regexp_like (SUBSTR(A.POS_MODE,1,2),REPLACE(B.POSMODE,'-','|'))
                AND CASE_NO=CASE_ID;
                
                IF V_CNT_CLOSE_CASE>=1 THEN
                    UPDATE CCPS.FDS_CASE_DETAIL SET CASE_STATUS='DIC', ASG_TMS=CASE WHEN ASG_TMS=0 THEN to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')) END, UPD_TMS=to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')), USR_ID='SYSTEM', CHECK_NEW=' ', AUTOCLOSE='Y' WHERE CASE_NO=CASE_ID;
                    INSERT INTO CCPS.FDS_CASE_STATUS(ID,CASE_NO,CRE_TMS,USER_ID,CASE_COMMENT,CASE_ACTION,CLOSED_REASON,OTHER) VALUES (SQ_FDS_CASE_STATUS.nextval ,CASE_ID,to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')),'SYSTEM','Kh??ng x??c nh???n GD do KH y??u c???u','DIC','NCR','');
                    COMMIT;
                END IF;
                -----END AUTO CLOSE CASE---
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
              -----START AUTO CLOSE CASE BY MERCHANT & POSMODE
                SELECT COUNT(A.CASE_NO) INTO V_CNT_CLOSE_CASE
                FROM CCPS.FDS_CASE_DETAIL A INNER JOIN CCPS.FDS_SYS_TASK B ON A.CIF_NO = B.OBJECTTASK  
                INNER JOIN CCPS.FDS_DESCRIPTION C ON C.TYPE='MERC' and regexp_like (C.ID,REPLACE(B.MERCHANT,'-','|'))  
                WHERE CHECK_NEW='Y' AND A.MERC_NAME LIKE '%' || C.DESCRIPTION || '%' AND B.MERCHANT IS NOT NULL  
                AND regexp_like (SUBSTR(A.POS_MODE,1,2),REPLACE(B.POSMODE,'-','|'))
                AND CASE_NO=CASE_ID;
                
                IF V_CNT_CLOSE_CASE>=1 THEN
                    UPDATE CCPS.FDS_CASE_DETAIL SET CASE_STATUS='DIC', ASG_TMS=CASE WHEN ASG_TMS=0 THEN to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')) END, UPD_TMS=to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')), USR_ID='SYSTEM', CHECK_NEW=' ', AUTOCLOSE='Y' WHERE CASE_NO=CASE_ID;
                    INSERT INTO CCPS.FDS_CASE_STATUS(ID,CASE_NO,CRE_TMS,USER_ID,CASE_COMMENT,CASE_ACTION,CLOSED_REASON,OTHER) VALUES (SQ_FDS_CASE_STATUS.nextval ,CASE_ID,to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')),'SYSTEM','Kh??ng x??c nh???n GD do KH y??u c???u','DIC','NCR','');
                    COMMIT;
                END IF;
                -----END AUTO CLOSE CASE---
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
              -----START AUTO CLOSE CASE BY MERCHANT & POSMODE
                SELECT COUNT(A.CASE_NO) INTO V_CNT_CLOSE_CASE
                FROM CCPS.FDS_CASE_DETAIL A INNER JOIN CCPS.FDS_SYS_TASK B ON A.CIF_NO = B.OBJECTTASK  
                INNER JOIN CCPS.FDS_DESCRIPTION C ON C.TYPE='MERC' and regexp_like (C.ID,REPLACE(B.MERCHANT,'-','|'))  
                WHERE CHECK_NEW='Y' AND A.MERC_NAME LIKE '%' || C.DESCRIPTION || '%' AND B.MERCHANT IS NOT NULL  
                AND regexp_like (SUBSTR(A.POS_MODE,1,2),REPLACE(B.POSMODE,'-','|'))
                AND CASE_NO=CASE_ID;
                
                IF V_CNT_CLOSE_CASE>=1 THEN
                    UPDATE CCPS.FDS_CASE_DETAIL SET CASE_STATUS='DIC', ASG_TMS=CASE WHEN ASG_TMS=0 THEN to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')) END, UPD_TMS=to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')), USR_ID='SYSTEM', CHECK_NEW=' ', AUTOCLOSE='Y' WHERE CASE_NO=CASE_ID;
                    INSERT INTO CCPS.FDS_CASE_STATUS(ID,CASE_NO,CRE_TMS,USER_ID,CASE_COMMENT,CASE_ACTION,CLOSED_REASON,OTHER) VALUES (SQ_FDS_CASE_STATUS.nextval ,CASE_ID,to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')),'SYSTEM','Kh??ng x??c nh???n GD do KH y??u c???u','DIC','NCR','');
                    COMMIT;
                END IF;
                -----END AUTO CLOSE CASE---
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
              -----START AUTO CLOSE CASE BY MERCHANT & POSMODE
                SELECT COUNT(A.CASE_NO) INTO V_CNT_CLOSE_CASE
                FROM CCPS.FDS_CASE_DETAIL A INNER JOIN CCPS.FDS_SYS_TASK B ON A.CIF_NO = B.OBJECTTASK  
                INNER JOIN CCPS.FDS_DESCRIPTION C ON C.TYPE='MERC' and regexp_like (C.ID,REPLACE(B.MERCHANT,'-','|'))  
                WHERE CHECK_NEW='Y' AND A.MERC_NAME LIKE '%' || C.DESCRIPTION || '%' AND B.MERCHANT IS NOT NULL  
                AND regexp_like (SUBSTR(A.POS_MODE,1,2),REPLACE(B.POSMODE,'-','|'))
                AND CASE_NO=CASE_ID;
                
                IF V_CNT_CLOSE_CASE>=1 THEN
                    UPDATE CCPS.FDS_CASE_DETAIL SET CASE_STATUS='DIC', ASG_TMS=CASE WHEN ASG_TMS=0 THEN to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')) END, UPD_TMS=to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')), USR_ID='SYSTEM', CHECK_NEW=' ', AUTOCLOSE='Y' WHERE CASE_NO=CASE_ID;
                    INSERT INTO CCPS.FDS_CASE_STATUS(ID,CASE_NO,CRE_TMS,USER_ID,CASE_COMMENT,CASE_ACTION,CLOSED_REASON,OTHER) VALUES (SQ_FDS_CASE_STATUS.nextval ,CASE_ID,to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')),'SYSTEM','Kh??ng x??c nh???n GD do KH y??u c???u','DIC','NCR','');
                    COMMIT;
                END IF;
                -----END AUTO CLOSE CASE---
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
