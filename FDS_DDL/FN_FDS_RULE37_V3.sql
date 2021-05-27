--------------------------------------------------------
--  DDL for Function FN_FDS_RULE37_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE37_V3" 
/**********************************************************************************
 * VER    ID        DATE         ENHANCEMENT                                      *
 * -----  -------   ---------    -------------------------------------------------*
 * 1.0    HUYENNT   21DEC2016    RULE 37: GIAO DICH BI TU CHOI                    *
 * 2.0    HUYENNT   21FEB2017     LAY CIF THEO DUNG THE CHINH HOAC THE PHU GIAO   *
 *                               DICH                                             *
 * 3.0    HUYENNT   04MAY2018    CAP NHAT DIEU KIEN LOC THEO THONG BAO DIEU CHINH *
 *                               SO 70/BC-GS&XLTST&NHDT                           *
 **********************************************************************************/
(
    P_CRN IN NUMBER,--ADD ON 21022017
    P_SEQ IN NUMBER,--ADD ON 21022017
    P_TXN_AMT IN NUMBER,--ADD ON 21022017
    P_CARDNO IN VARCHAR2,
    p_crd_brn IN VARCHAR2,--ADD ON 20200107
    p_crd_pgm IN VARCHAR2,--ADD ON 20200107
    p_crd_prd IN CHAR,--ADD ON 20200107
    p_merc_name IN VARCHAR2,--ADD ON 20200107
    P_MID IN VARCHAR2,--MID
    P_END_TMS IN VARCHAR2,
    P_REF_CDE IN VARCHAR2,
    P_RESP_CDE IN VARCHAR2,--ADD ON 20170728
    P_CHECK IN VARCHAR2,
    P_CNT OUT NUMBER
 ) RETURN VARCHAR2
 AS
    SQL_STMT VARCHAR2(4000);
    SQL_STMT2 VARCHAR2(4000);
    strt_tms varchar(17);
    CRE_TMS VARCHAR(17);
    V_CNT NUMBER;
	V_CNT_GD_LON NUMBER;
	V_CNT_SAI_PIN NUMBER;
    CASE_ID VARCHAR2(50);
    V_CNT_CLOSE_CASE NUMBER;
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255);
    L_CHECK_POINT NUMBER;
    V_TXDATE NUMBER;
    V_BEGTIME NUMBER;
    V_ENDTIME NUMBER;
    V_STS VARCHAR(10);
    V_STSDESC VARCHAR2(4000);
    V_RULENAME VARCHAR2(6):='RULE37';
	V_BIN VARCHAR2(10):= SUBSTR(CCPS.DED2(P_CARDNO, 'FDS'), 1, 6);
	V_PAN VARCHAR2(30):=' ';
    ---------------------
    V_CRN number;
    V_3D_CHK number;
    V_CIF VARCHAR2(10) := ' ';
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
BEGIN
    --KHOI TAO GIA TRI CHO CAC BIEN GHI LOG----------
    V_PROD := 'SP_FDS_RULE37';
    V_TXDATE := TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME := TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME := 0;
    V_STS := 'START'; -- START / DONE / ERROR
    V_STSDESC := ' ';
    L_CHECK_POINT := 1;
    INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    COMMIT;
    SQL_STMT := 'SELECT TRIM(P9_OA008_SEQ)||''-''||TRIM(FX_OA008_GIVEN_APV_CDE)||''-''||TRIM(F9_OA008_STAN)||''-''||TRIM(F9_OA008_MCC) FROM CCPS.FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = '''||P_CARDNO||''' AND F9_OA008_CRE_TMS ='|| P_END_TMS || ' AND P9_OA008_SEQ=' || P_SEQ;
    EXECUTE IMMEDIATE SQL_STMT INTO CASE_ID;
    SQL_STMT := 'SELECT COUNT(1) FROM CCPS.FDS_CASE_HIT_RULES WHERE rule_id IN (''RULE13'',''RULE14'',''RULE15'',''RULE16'',''RULE20'',''RULE34'',''RULE35'',''RULE43'') AND CASE_NO = '''||CASE_ID||'''';
    EXECUTE IMMEDIATE SQL_STMT INTO V_CNT;
	SELECT PX_OA008_PAN INTO V_PAN FROM CCPS.FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
    IF V_CNT = 0--khong co trong cac rule da hit theo danh sach loai tru o tren
       AND (P_REF_CDE LIKE '%01%'
            OR P_REF_CDE LIKE '%02%'
            OR P_REF_CDE LIKE '%05%'
            OR P_REF_CDE LIKE '%06%'
            OR P_REF_CDE LIKE '%07%'
            OR P_REF_CDE LIKE '%08%'
            OR P_REF_CDE LIKE '%09%'
            --OR P_REF_CDE LIKE '%10%'
            OR P_REF_CDE LIKE '%11%'
            OR P_REF_CDE LIKE '%12%'
            OR P_REF_CDE LIKE '%15%'
            OR P_REF_CDE LIKE '%17%'
            OR P_REF_CDE LIKE '%18%'
            OR P_REF_CDE LIKE '%19%'
            OR P_REF_CDE LIKE '%21%'
            OR P_REF_CDE LIKE '%22%'
            OR P_REF_CDE LIKE '%23%'
            OR P_REF_CDE LIKE '%24%'
            OR P_REF_CDE LIKE '%26%'
            OR P_REF_CDE LIKE '%27%'
            --OR P_REF_CDE LIKE '%28%'
            OR P_REF_CDE LIKE '%30%'
            OR P_REF_CDE LIKE '%31%'
            OR P_REF_CDE LIKE '%32%'
            --OR P_REF_CDE LIKE '%33%'
--            OR P_REF_CDE LIKE '%34%'
            OR P_REF_CDE LIKE '%36%'
            OR P_REF_CDE LIKE '%37%'
--            OR P_REF_CDE LIKE '%39%'
            OR P_REF_CDE LIKE '%40%'
            OR (P_RESP_CDE <> '00' and trim(P_REF_CDE) is null)
            )
            AND P_REF_CDE NOT LIKE '%10%' AND P_REF_CDE NOT LIKE '%35%' 
            AND P_REF_CDE NOT LIKE '%34%' AND P_REF_CDE NOT LIKE '%39%'
            AND P_REF_CDE NOT LIKE '%13%' AND P_REF_CDE NOT LIKE '%20%'
            AND P_REF_CDE NOT LIKE '%14%' AND P_REF_CDE NOT LIKE '%25%'
            AND P_REF_CDE NOT LIKE '%28%' AND P_REF_CDE NOT LIKE '%34%'
            AND P_REF_CDE NOT LIKE '%39%' AND P_REF_CDE NOT LIKE '%04%'
            AND P_REF_CDE NOT LIKE '%33%' 
    THEN
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
        SELECT trim(p9_oa008_seq)||'-'||trim(fx_oa008_given_apv_cde)||'-'||trim(f9_oa008_stan)||'-'||trim(f9_oa008_mcc) INTO case_id FROM CCPS.fds_txn_detail where f9_oa008_amt_req >= 0 AND fx_oa008_used_pan = p_cardno AND f9_oa008_cre_tms = p_end_tms;
        ----CHECK IF CASE ALREADY EXISTED----
        IF p_check = 'FALSE' THEN
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
             SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM CCPS.FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
            execute immediate sql_stmt;
        END IF;
        --------------------------------------
        L_CHECK_POINT := 3;
        SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', '''|| CRE_TMS ||''', ''BACKEND_USR'', '''|| CASE_ID ||''', '''||V_RULENAME||''', F9_OA008_CRE_TMS, FX_OA008_USED_PAN, F9_OA008_MCC, P9_OA008_SEQ, F9_OA008_DT, F9_OA008_TM FROM CCPS.FDS_TXN_DETAIL WHERE F9_OA008_CRE_TMS = '|| P_END_TMS ||' AND FX_OA008_USED_PAN = '''|| P_CARDNO||'''';
        EXECUTE IMMEDIATE SQL_STMT2;
        L_CHECK_POINT := 4;
        SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES('||CRE_TMS||','||CRE_TMS||',''BACKEND_USR'','''||CASE_ID||''','''||V_RULENAME||''')';
        EXECUTE IMMEDIATE SQL_STMT2;
        COMMIT;
        -----START AUTO CLOSE CASE BY MERCHANT & POSMODE
        SELECT COUNT(A.CASE_NO) INTO V_CNT_CLOSE_CASE
        FROM CCPS.FDS_CASE_DETAIL A INNER JOIN CCPS.FDS_SYS_TASK B ON A.CIF_NO = B.OBJECTTASK  
        INNER JOIN CCPS.FDS_DESCRIPTION C ON C.TYPE='MERC' and regexp_like (C.ID,REPLACE(B.MERCHANT,'-','|'))  
        WHERE CHECK_NEW='Y' AND A.MERC_NAME LIKE '%' || C.DESCRIPTION || '%' AND B.MERCHANT IS NOT NULL  
        AND regexp_like (SUBSTR(A.POS_MODE,1,2),REPLACE(B.POSMODE,'-','|'))
        AND CASE_NO=CASE_ID;
        
        IF V_CNT_CLOSE_CASE>=1 THEN
            UPDATE CCPS.FDS_CASE_DETAIL SET CASE_STATUS='DIC', ASG_TMS=CASE WHEN ASG_TMS=0 THEN to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')) END, UPD_TMS=to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')), USR_ID='SYSTEM', CHECK_NEW=' ', AUTOCLOSE='Y' WHERE CASE_NO=CASE_ID;
            INSERT INTO CCPS.FDS_CASE_STATUS(ID,CASE_NO,CRE_TMS,USER_ID,CASE_COMMENT,CASE_ACTION,CLOSED_REASON,OTHER) VALUES (SQ_FDS_CASE_STATUS.nextval ,CASE_ID,to_number(to_char(SYSDATE, 'yyyyMMddHH24MISSSSS')),'SYSTEM','Không xác nhận GD do KH yêu cầu','DIC','NCR','');
            COMMIT;
        END IF;
        -----END AUTO CLOSE CASE---
        p_cnt := 1;
        RETURN 'DONE';
    ELSE
        ----lay dung cif theo the chinh hoac phu
          select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
          IF V_CRN > 0 THEN
              select trim(FX_IR056_CIF_NO),trim(FX_IR056_HP) INTO V_CIF,V_HP from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = P_CARDNO);
          ELSE
              select trim(FX_IR056_CIF_NO),trim(FX_IR056_HP) INTO V_CIF,V_HP from ir056@im where P9_IR056_CRN = P_CRN;
          END IF;

        STRT_TMS := TMS_ADD_SUBTRACT(1,P_END_TMS);
		SQL_STMT := 'SELECT count(1) FROM CCPS.FDS_TXN_DETAIL T WHERE T.fx_oa008_ref_cde LIKE ''%28%'' AND T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.FX_OA008_MID = '''||P_MID||''' AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
		EXECUTE IMMEDIATE SQL_STMT INTO V_CNT_GD_LON;

		SQL_STMT := 'SELECT count(1) FROM CCPS.FDS_TXN_DETAIL T WHERE (T.fx_oa008_ref_cde LIKE ''%04%'' OR T.fx_oa008_ref_cde LIKE ''%33%'' ) AND T.FX_OA008_USED_PAN = '''||P_CARDNO||''' AND T.FX_OA008_MID = '''||P_MID||''' AND T.F9_OA008_CRE_TMS BETWEEN ' || STRT_TMS || ' AND ' ||P_END_TMS;
		EXECUTE IMMEDIATE SQL_STMT INTO V_CNT_SAI_PIN;

		IF p_ref_cde LIKE '%28%' AND (V_BIN = '453618' OR V_BIN = '512454' OR V_BIN = '524188' OR V_BIN = '547139' OR V_BIN = '550796') AND V_CNT_GD_LON=1 AND LENGTH(V_HP) >= 10 THEN
			  --nhan tin cho khach hang
			  SELECT DECODE(p_crd_brn,'MC','MasterCard','Visa') INTO V_CRD_NAME FROM DUAL;
			  select substr(px_irpanmap_panmask,-4,4) into V_LAST4DIGIT from ir_pan_map@IM where px_irpanmap_pan = p_cardno;
			  --select CCPS.ded2(p_cardno,'fds') into V_LAST4DIGIT from dual;
			  --CHINH SUA SO HOT LINE THEO HANG THE QUANG NTT YEU CAU 20170911

			  IF p_crd_prd IN ('W','P') THEN--NEU LA THE MC World, MC Debit Signature, VISA Platinum
				V_SMS_DETAIL := 'The SCB x'||V_LAST4DIGIT||' GD khong thanh cong tai '||trim(p_merc_name)||' do so tien GD lon hon so du kha dung tren TKTT. Chi tiet LH '||v_hotline_vip||' de duoc ho tro';
			  ELSE
                DBMS_OUTPUT.put_line('p_crd_prd: '||'The SCB x'||V_LAST4DIGIT||' giao dich khong thanh cong tai '||trim(p_merc_name)||' do so tien GD lon hon so du kha dung tren TKTT. Chi tiet LH '||v_hotline_std||' de duoc ho tro');
				V_SMS_DETAIL := 'The SCB x'||V_LAST4DIGIT||' GD khong thanh cong tai '||trim(p_merc_name)||' do so tien GD lon hon so du kha dung tren TKTT. Chi tiet LH '||v_hotline_std||' de duoc ho tro';
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


		IF (p_ref_cde LIKE '%04%' OR p_ref_cde LIKE '%33%') AND V_CNT_SAI_PIN=2 AND LENGTH(V_HP) >= 10 THEN
			  --nhan tin cho khach hang
			  SELECT DECODE(p_crd_brn,'MC','MasterCard','Visa') INTO V_CRD_NAME FROM DUAL;
			  select substr(px_irpanmap_panmask,-4,4) into V_LAST4DIGIT from ir_pan_map@IM where px_irpanmap_pan = p_cardno;
			  --select CCPS.ded2(p_cardno,'fds') into V_LAST4DIGIT from dual;
			  --CHINH SUA SO HOT LINE THEO HANG THE QUANG NTT YEU CAU 20170911
			  IF p_crd_prd IN ('W','P') THEN--NEU LA THE MC World, MC Debit Signature, VISA Platinum
				V_SMS_DETAIL := 'The SCB x'||V_LAST4DIGIT||' GD khong thanh cong do nhap sai PIN. Quy khach doi ma PIN tai https://card.scb.com.vn/changepin/login.html. Chi tiet LH '||v_hotline_vip;
			  ELSE
				V_SMS_DETAIL := 'The SCB x'||V_LAST4DIGIT||' GD khong thanh cong do nhap sai PIN. Quy khach doi ma PIN tai https://card.scb.com.vn/changepin/login.html. Chi tiet LH '||v_hotline_std;
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
