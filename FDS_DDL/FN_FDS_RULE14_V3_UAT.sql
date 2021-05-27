--------------------------------------------------------
--  DDL for Function FN_FDS_RULE14_V3_UAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE14_V3_UAT" 
/***********************************************************************************
  * VER    ID        DATE         ENHANCEMENT                                      *
  * -----  -------   ---------    -------------------------------------------------*
  * 1.0    CHAUTK   07/12/2016    RULE 14: GIAO DICH PHAT SINH TU THE DANG O TINH  *
  *                                        TRANG KHOA                              *
  * 2.0    HUYENNT  21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO    *
  *                               DICH                                             *
  **********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    p_ref_cde IN VARCHAR2,--ADD ON 21022017
    p_cardno IN VARCHAR2,
    p_crd_brn IN VARCHAR2,--ADD ON 20201230
    p_crd_pgm IN VARCHAR2,--ADD ON 20201230
    p_crd_prd IN CHAR,--ADD ON 20201230
    p_merc_name IN VARCHAR2,--ADD ON 20201230
    P_MID IN VARCHAR2,--MID
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
	v_cnt_khoa_nophi number;
    case_id VARCHAR2(50);
    v_block_ind NUMBER;
    V_CNT_CLOSE_CASE NUMBER;
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
	--bien su dung cho sms-----
    V_CRD_NAME VARCHAR2(20);
    V_LAST4DIGIT VARCHAR(19);
    V_HP VARCHAR2(15) := '';--TANVH1
    V_ACT_TYP CHAR(1) := 'N';
    V_SMS_DETAIL VARCHAR2(160);
    V_SMS_TYP VARCHAR2(6) := 'FDSMSG';
    v_id_alert VARCHAR2(20) := 'MASTER_CARD_ALERT';
    v_hotline_vip varchar2(10):='1800545438';
    v_hotline_std varchar2(10):='19006538';
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    v_PROD := 'SP_FDS_RULE14';
    v_TxDate := to_char(sysdate,'YYYYMMDD');
    v_BegTime := to_char(sysdate,'hh24missss');
    v_EndTime := 0;
    v_STS := 'START'; -- START / DONE / ERROR
    v_STSDESC := ' ';
    l_check_point := 1;
    INSERT INTO FDS_LOG VALUES(v_PROD,v_TxDate,v_BegTime,v_EndTime,v_STS,v_STSDESC);
    COMMIT;
    /*-----------LAY TRANG THAI TINH TAM KHOA-----------
    SELECT
        COUNT(1) INTO v_block_ind
    FROM
        oa063@IM
    WHERE
       px_oa063_pan = p_cardno;
    --------------------------------------------------*/
    IF p_ref_cde LIKE '%20%' AND p_ref_cde NOT LIKE '%10%' AND p_ref_cde NOT LIKE '%35%'/* OR v_block_ind > 0*/ THEN

        ----lay dung cif theo the chinh hoac phu
        select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;

        IF V_CRN > 0 THEN
            select trim(FX_IR056_CIF_NO),trim(FX_IR056_HP) INTO V_CIF,V_HP from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
        ELSE
            select trim(FX_IR056_CIF_NO),trim(FX_IR056_HP) INTO V_CIF,V_HP from ir056@im where P9_IR056_CRN = P_CRN;
        END IF;
		STRT_TMS := TMS_ADD_SUBTRACT(1,P_END_TMS);
        SQL_STMT := 'SELECT COUNT(*) FROM OA063@IM WHERE ((FX_OA063_MSG_STAT=''DC'' AND FX_OA063_REAS_CDE IN (''AT'',''OT'',''TB'',''TR'') AND FX_OA063_MSG_DESC <> ''TEMPORARY BLOCK DUE TO FAILED CHARGE FEE PAYMENT'') OR (FX_OA063_MSG_STAT='' '' AND FX_OA063_REAS_CDE=''OT'') OR (FX_OA063_MSG_STAT=''PO'' AND FX_OA063_REAS_CDE=''AT'')) AND PX_OA063_PAN=''' || p_cardno || '''';
        EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;

		IF V_CNT > 0 THEN
			l_check_point := 2;
			SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;

			----thong tin gd co 3D Secure hay khong-
			select count(1) INTO V_3D_CHK FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
			IF V_3D_CHK > 0 THEN
				 SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN = P_CARDNO AND P9_OA126_SEQ_NUM = P_SEQ;
			END IF;

			SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM fds_txn_detail where f9_oa008_amt_req > 0 AND fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms AND P9_OA008_SEQ=P_SEQ;
			DBMS_OUTPUT.put_line('CASE_ID:'||CASE_ID);
            ----CHECK IF CASE ALREADY EXISTED----
			IF p_check = 'FALSE' THEN
				SQL_STMT := 'INSERT INTO FPT.FDS_CASE_DETAIL(CRE_TMS,UPD_TMS,
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
			sql_stmt2 := 'INSERT INTO FPT.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || cre_tms || ''',''' || cre_tms || ''',''BACKEND_USR'',''' || case_id || ''',''RULE14'',f9_oa008_cre_tms,fx_oa008_used_pan,f9_oa008_mcc,p9_oa008_seq,f9_oa008_dt,f9_oa008_tm FROM FDS_TXN_DETAIL where f9_oa008_cre_tms = ' || p_end_tms ||' AND fx_oa008_used_pan = ''' || p_cardno || '''';
			execute immediate sql_stmt2;
			l_check_point := 4;
			sql_stmt2 := 'INSERT INTO FPT.FDS_CASE_HIT_RULES VALUES(' || cre_tms || ',' || cre_tms || ',''BACKEND_USR'',''' || case_id || ''',''RULE14'')';
			execute immediate sql_stmt2;
			commit;
            
            -----START AUTO CLOSE CASE BY MERCHANT & POSMODE
            SELECT COUNT(A.CASE_NO) INTO V_CNT_CLOSE_CASE
            FROM FPT.FDS_CASE_DETAIL A INNER JOIN CCPS.FDS_SYS_TASK B ON A.CIF_NO = B.OBJECTTASK  
            INNER JOIN CCPS.FDS_DESCRIPTION C ON C.TYPE='MERC' and regexp_like (C.ID,REPLACE(B.MERCHANT,'-','|'))  
            WHERE CHECK_NEW='Y' AND A.MERC_NAME LIKE '%' || C.DESCRIPTION || '%' AND B.MERCHANT IS NOT NULL  
            AND regexp_like (SUBSTR(A.POS_MODE,1,2),REPLACE(B.POSMODE,'-','|'))
            AND CASE_NO=CASE_ID;
            
            IF V_CNT_CLOSE_CASE>=1 THEN
                UPDATE FPT.FDS_CASE_DETAIL SET CASE_STATUS='DIC', ASG_TMS=CASE WHEN ASG_TMS=0 THEN to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')) END, UPD_TMS=to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')), USR_ID='SYSTEM', CHECK_NEW=' ', AUTOCLOSE='Y' WHERE CASE_NO=CASE_ID;
                INSERT INTO FPT.FDS_CASE_STATUS(ID,CASE_NO,CRE_TMS,USER_ID,CASE_COMMENT,CASE_ACTION,CLOSED_REASON,OTHER) VALUES (FPT.SQ_FDS_CASE_STATUS.nextval ,CASE_ID,to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')),'SYSTEM','Không xác nhận GD do KH yêu cầu','DIC','NCR','');
                COMMIT;
            END IF;
            
            -----END AUTO CLOSE CASE---
			p_cnt := 1;
			RETURN 'DONE';
		ELSE
            STRT_TMS := TMS_ADD_SUBTRACT(12,P_END_TMS);
			SQL_STMT := 'SELECT COUNT(*) FROM OA063@IM WHERE FX_OA063_REAS_CDE =''TB'' AND FX_OA063_MSG_DESC = ''TEMPORARY BLOCK DUE TO FAILED CHARGE FEE PAYMENT'' AND PX_OA063_PAN=''' || p_cardno || '''';
			EXECUTE IMMEDIATE SQL_STMT INTO v_cnt_khoa_nophi;

            SQL_STMT := 'SELECT count(1) FROM FPT.FDS_TXN_DETAIL T WHERE T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.FX_OA008_MID = '''||P_MID||''' AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
            EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;

			IF v_cnt_khoa_nophi>=1 AND V_CNT=1 AND LENGTH(V_HP) >= 10 THEN
			  --nhan tin cho khach hang
			  SELECT DECODE(p_crd_brn,'MC','MasterCard','Visa') INTO V_CRD_NAME FROM DUAL;
			  select substr(px_irpanmap_panmask,-4,4) into V_LAST4DIGIT from ir_pan_map@IM where px_irpanmap_pan = p_cardno;
			  --select FPT.ded2(p_cardno,'fds') into V_LAST4DIGIT from dual;
			  --CHINH SUA SO HOT LINE THEO HANG THE QUANG NTT YEU CAU 20170911
			  IF p_crd_prd IN ('W','P') THEN--NEU LA THE MC World, MC Debit Signature, VISA Platinum
				V_SMS_DETAIL := 'The SCB '||V_CRD_NAME||' x'||V_LAST4DIGIT||' GD khong thanh cong tai '||trim(p_merc_name)||' do the dang tam khoa do no phi. Vui long LH '||v_hotline_vip||' de duoc ho tro';
			  ELSE
				V_SMS_DETAIL := 'The SCB '||V_CRD_NAME||' x'||V_LAST4DIGIT||' GD khong thanh cong tai '||trim(p_merc_name)||' do the dang tam khoa do no phi. Vui long LH '||v_hotline_std||' de duoc ho tro';
			  END IF;
--			  sms_scb.PROC_INS_MASTERCARD_SMS@eb_link(v_id_alert,'0367621130',V_SMS_DETAIL,V_ACT_TYP,V_SMS_TYP);
                INSERT INTO FPT.SMS_FDS_UAT(CRE_TMS,RULE_NAME,PHONE,SMS_DETAIL,PAN,MID,TXN_TMS) VALUES (to_char(SYSDATE, 'yyyyMMddHH24MISS'),'RULE16',V_HP,V_SMS_DETAIL,p_cardno,P_MID,p_end_tms);
			  -------------------------
			  COMMIT;
			  p_cnt:= 1;
			  return 'FALSE';
			ELSE
			  p_cnt:= 0;
			  return 'FALSE';
			END IF;

		END IF;


        ----------------------------------------

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
             UPDATE FPT.FDS_LOG SET END_TIME = v_EndTime, STATUS = v_STS, STSDESC = v_STSDESC WHERE PROC_NAME = v_PROD AND TXDATE = v_TxDate AND begin_time = v_BegTime;
             COMMIT;
             p_cnt:= 0;
             RETURN 'ERROR';
END FN_FDS_RULE14_V3_UAT;

/
