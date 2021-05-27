--------------------------------------------------------
--  DDL for Function FN_FDS_RULE16_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE16_V2" 
/***********************************************************************************
  * VER    ID        DATE         ENHANCEMENT                                      *
  * -----  -------   ---------    -------------------------------------------------*
  * 1.0    CHAUTK   07/12/2016    RULE 16: THE CHUA KICH HOAT THUC HIEN GIAO DICH  *
  * 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
  *                               DICH                                             *
  * 2.1    HUYENNT  13JUL2017     NHAN TIN CHO KHACH HANG VOI GD LOI NAY DEN LAN   *
  *                               THU 4 SE CHO HIT RULE TAO CASE                   *
  * 3.0    HUYENNT  21FEB2019     NHAN TIN CHO KHACH HANG VOI GD LOI NAY DEN LAN   *
  *                               THU 2 SE CHO HIT RULE TAO CASE                   *
  **********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    p_ref_cde IN VARCHAR2,--ADD ON 21022017
    p_cardno IN VARCHAR2,
    p_crd_brn IN VARCHAR2,--ADD ON 13072017
    p_crd_pgm IN VARCHAR2,--ADD ON 11092017
    p_crd_prd IN CHAR,--ADD ON 11092017
    p_merc_name IN VARCHAR2,--ADD ON 13072017
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
    v_RULENAME varchar2(6):='RULE16';
	V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10);
    V_3D_IND VARCHAR2(5) := 'N';
    V_3D_ECI VARCHAR2(5) := ' ';
    ---bien su dung cho sms-----
    V_CRD_NAME VARCHAR2(20);
    V_LAST4DIGIT VARCHAR(19);
    V_HP VARCHAR2(15) := '';--QUANGNTT
    V_ACT_TYP CHAR(1) := 'N';
    V_SMS_DETAIL VARCHAR2(160);
    V_SMS_TYP VARCHAR2(6) := 'FDSMSG';
    v_id_alert VARCHAR2(20) := 'MASTER_CARD_ALERT';
    v_hotline_vip varchar2(10):='1800545438';
    v_hotline_std varchar2(10):='19006538';
    ----------------------------
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    v_PROD := 'FN_FDS_RULE16';
    v_TxDate := to_char(sysdate,'YYYYMMDD');
    v_BegTime := to_char(sysdate,'hh24missss');
    v_EndTime := 0;
    v_STS := 'START'; -- START / DONE / ERROR
    v_STSDESC := ' ';
    l_check_point := 1;
    INSERT INTO FDS_LOG VALUES(v_PROD,v_TxDate,v_BegTime,v_EndTime,v_STS,v_STSDESC);
    COMMIT;
    -------------------------------------------------
	SELECT PX_OA008_PAN INTO V_PAN FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF P_TXN_AMT >= 0 AND p_ref_cde LIKE '%25%' THEN
      ----lay dung cif theo the chinh hoac phu
      select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
      IF V_CRN > 0 THEN
          select trim(FX_IR056_CIF_NO),trim(FX_IR056_HP) INTO V_CIF,V_HP from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
      ELSE
          select trim(FX_IR056_CIF_NO),trim(FX_IR056_HP) INTO V_CIF,V_HP from ir056@im where P9_IR056_CRN = P_CRN;
      END IF;
      STRT_TMS := TMS_ADD_SUBTRACT(1,P_END_TMS);
      SQL_STMT := 'SELECT count(1) FROM FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ >= 0 AND T.fx_oa008_ref_cde LIKE ''%25%'' AND T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
      EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;
      IF V_CNT > 1 THEN--tu 2 giao dich tro len moi hit rule tao case
        l_check_point := 2;
        SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
        ----thong tin gd co 3D Secure hay khong-
        select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
        IF V_3D_CHK > 0 THEN
             SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
        END IF;
        ----------------------------------------
        SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where f9_oa008_amt_req >= 0 AND fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND P9_OA008_SEQ=P_SEQ;
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
        sql_stmt2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', F9_OA008_CRE_TMS, FX_OA008_USED_PAN, F9_OA008_MCC, P9_OA008_SEQ, F9_OA008_DT, F9_OA008_TM FROM FDS_TXN_DETAIL WHERE F9_OA008_CRE_TMS = '|| P_END_TMS ||' AND FX_OA008_USED_PAN = ''' || P_CARDNO || ''' ORDER BY F9_OA008_CRE_TMS DESC';
        execute immediate sql_stmt2;
        l_check_point := 4;
        sql_stmt2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''','''||v_RULENAME||''')';
        execute immediate sql_stmt2;
        commit;
        p_cnt := 1;
        RETURN 'DONE';
      ELSE
        IF LENGTH(V_HP) >= 10 THEN
          --nhan tin cho khach hang
          SELECT DECODE(p_crd_brn,'MC','MasterCard','Visa') INTO V_CRD_NAME FROM DUAL;
          select substr(px_irpanmap_panmask,-4,4) into V_LAST4DIGIT from ir_pan_map@IM where px_irpanmap_pan = p_cardno;
          --select ccps.ded2(p_cardno,'fds') into V_LAST4DIGIT from dual;
          --CHINH SUA SO HOT LINE THEO HANG THE QUANG NTT YEU CAU 20170911
          IF p_crd_prd IN ('W','P') OR SUBSTR(p_crd_pgm,3,1) = 'S' THEN--NEU LA THE MC World, MC Debit Signature, VISA Platinum
            V_SMS_DETAIL := 'The SCB '||V_CRD_NAME||' x'||V_LAST4DIGIT||' giao dich khong thanh cong tai '||trim(p_merc_name)||' do the chua duoc kich hoat. Chi tiet LH '||v_hotline_vip||' de duoc ho tro';
          ELSE
            V_SMS_DETAIL := 'The SCB '||V_CRD_NAME||' x'||V_LAST4DIGIT||' giao dich khong thanh cong tai '||trim(p_merc_name)||' do the chua duoc kich hoat. Chi tiet LH '||v_hotline_std||' de duoc ho tro';
          END IF;
          sms_scb.PROC_INS_MASTERCARD_SMS@eb_link(v_id_alert,V_HP,V_SMS_DETAIL,V_ACT_TYP,V_SMS_TYP);
          -------------------------
          COMMIT;
          p_cnt:= 1;
          return 'FALSE';
        ELSE
          p_cnt:= 0;
          return 'FALSE';
        END IF;
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
           v_STS := 'ERROR'; -- START / DONE / ERROR
           v_EndTime := to_char(sysdate,'hh24missss');
           v_STSDESC := SQLERRM||' At:'||l_check_point||','||sql_stmt;
           DBMS_OUTPUT.put_line('Loi:'||v_STSDESC);
           UPDATE FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
           COMMIT;
           p_cnt:= 0;
           RETURN 'ERROR';
END;

/
