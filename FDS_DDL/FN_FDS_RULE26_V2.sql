--------------------------------------------------------
--  DDL for Function FN_FDS_RULE26_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE26_V2" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   06DEC2016    The gd thanh toan tai DVCNT duoc canh bao tu to  *
*                               chuc the, Tieu ban quan ly rui ro...Tuy thuoc vao*
*                               thong tin canh bao, P.T&NHDT se cap nhat ten     *
*                               DVCNT len he thong FDS                           *
* 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
*                               DICH                                             *
**********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    p_cardno IN VARCHAR2,
    p_end_tms in VARCHAR2,
    p_merc_desc IN VARCHAR2,
    p_mcc IN NUMBER,
    p_mid IN VARCHAR2,
    p_tid IN VARCHAR2,
    p_cntry_cde in varchar2,
    p_curcy_cde in number,
    p_check IN VARCHAR2,
    p_cnt OUT NUMBER
 ) RETURN VARCHAR2
 AS
    sql_stmt varchar2(4000);
    sql_stmt2 varchar2(4000);
    cre_tms varchar(17);
    v_cnt number;
    case_id VARCHAR2(50);
    v_merc_desc VARCHAR2(500);
    --BIEN DUNG GHI LOG--
    v_PROD varchar(255);
    l_check_point number;
    v_TxDate number;
    v_BegTime number;
    v_EndTime number;
    v_STS varchar(10);
    v_STSDESC varchar2(4000);
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    v_PROD := 'SP_FDS_RULE26';
    v_TxDate := to_char(sysdate,'YYYYMMDD');
    v_BegTime := to_char(sysdate,'hh24missss');
    v_EndTime := 0;
    v_STS := 'START'; -- START / DONE / ERROR
    v_STSDESC := ' ';
    l_check_point := 1;
    INSERT INTO FDS_LOG VALUES(v_PROD,v_TxDate,v_BegTime,v_EndTime,v_STS,v_STSDESC);
    COMMIT;
    v_merc_desc := UPPER(p_merc_desc);
    -------------------------------------------------
    IF  /*v_merc_desc LIKE 'NEIMAN MARCUS%'
        OR v_merc_desc LIKE 'TARGET%'
        OR v_merc_desc LIKE 'APPLE STORE%'
        OR v_merc_desc LIKE 'BLOOMINGDALE''S%'
        OR v_merc_desc LIKE 'WALMART%'
        OR v_merc_desc LIKE 'WAL-MART%'
        OR p_mcc = 6050
        OR p_mcc = 6051*/--cap nhat theo yeu cau QUYNH NGA 12Jun2017
        --v_merc_desc LIKE '%VUON %PHO-VUNG %TVUNG %TAU %VN%'--cap nhat theo yeu cau QUYNH NGA 03NOV2017
        --OR trim(p_mid) = '000108701103254'--cap nhat theo yeu cau QUYNH NGA 03NOV2017
        --OR trim(p_tid) = '01034225'----cap nhat theo yeu cau QUANGNTT 10AUG2017--bo ra ngay 12OCT2017
        --OR
        /*((p_cntry_cde = 'TH ' OR p_cntry_cde = 'THA' OR p_cntry_cde = '764') AND (v_merc_desc LIKE '%CENTRAL%DEPT%' or v_merc_desc LIKE '%CRC %SPORTS%' or v_merc_desc LIKE '%BIG %C %SUPERCENTER%'))---them theo y/c NgaPQ 21Aug2017
        OR
        (p_cntry_cde = 'LAO' AND (v_merc_desc LIKE '%LAO %DUTY %FREE%' OR trim(p_tid) = '23400946'))---them theo y/c NgaPQ 09Nov2017
        OR
        */--Ngung check canh bao theo y/c NGAPQ ngay 26/01/2018
        /*(v_merc_desc LIKE 'PES%' AND trim(p_tid) = '12888888' and p_curcy_cde = 156)--them theo y/c NgaPQ 20171117*/--Ngung canh bao theo y/c NGAPQ 20180414
        --OR trim(p_tid) = '00010001'----cap nhat theo yeu cau NGAPQ 22AUG2017
        /*(trim(p_tid) = '00001126' and p_mcc = 6011)--them theo y/c NgaPQ 20180414*/--bo check theo y/c NGAPQ 14:43 20180416
        --da tat check rule 26 vi ko con dk loc --> khi nao co dk loc bat lai trong sp_fds_rules_process_v2
        1 = 2
    THEN
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
        select count(1) INTO V_3D_CHK FROM OA126@AM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
        IF V_3D_CHK > 0 THEN
             SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@AM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
        END IF;
        ----------------------------------------
        SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''')';
            execute immediate sql_stmt;
        END IF;
        ----------------------------------------
        l_check_point := 3;
        sql_stmt2 := 'INSERT INTO FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''RULE26'',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL where f9_oa008_cre_tms = ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || '''';
        execute immediate sql_stmt2;
        l_check_point := 4;
        sql_stmt2 := 'INSERT INTO FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''',''RULE26'')';
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
             DBMS_OUTPUT.put_line('Loi:'||v_STSDESC);
             UPDATE FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
             COMMIT;
             p_cnt:= 0;
             RETURN 'ERROR';
END;

/
