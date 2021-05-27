--------------------------------------------------------
--  DDL for Function FN_FDS_RULE42_V3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE42_V3" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   23FEB2019    Trong 10 phut, he thong phat sinh >= 20 giao dich*
*                               khong thanh cong sys status = C or D             *
**********************************************************************************/
(
  P_CRN IN NUMBER,
  P_SEQ IN NUMBER,
  P_TXN_AMT IN NUMBER,
  P_CARDNO IN VARCHAR2,
  P_END_TMS IN VARCHAR2,
  P_TXN_STAT IN CHAR,
  P_RESP_CDE IN VARCHAR2,
  P_REF_CDE IN VARCHAR2,
  P_USR_ID IN VARCHAR2,
  P_CHECK IN VARCHAR2,
  p_cnt OUT NUMBER
) RETURN VARCHAR2
AS
  SQL_STMT VARCHAR2(4000);
  SQL_STMT2 VARCHAR2(4000);
  CASE_ID VARCHAR2(50);
  strt_tms number;
  v_cnt number;
  CRE_TMS number;
  V_CRN number;
  V_3D_CHK number;
  V_CIF VARCHAR2(10) := ' ';
  V_3D_IND VARCHAR2(5) := 'N';
  V_3D_ECI VARCHAR2(5) := ' ';
  V_RULENAME VARCHAR2(20) := 'RULE42';
  L_CHECK_POINT NUMBER:=1;
  V_PAN VARCHAR2(30):=' ';
  V_CNT_CLOSE_CASE NUMBER;
BEGIN
  SELECT PX_OA008_PAN INTO V_PAN FROM CCPS.FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN=P_CARDNO AND P9_OA008_SEQ=P_SEQ AND F9_OA008_CRE_TMS=P_END_TMS;
--  IF P_TXN_AMT > 0 THEN
    STRT_TMS := TMS_ADD_SUBTRACT(0.083,P_END_TMS);--trong 10 phut(1/12)
    IF /*P_TXN_STAT in ('C','D')
      OR */((P_RESP_CDE = '05' and trim(P_REF_CDE) is null and P_USR_ID = 'SIP ')
      OR (P_RESP_CDE = '05' and P_REF_CDE like '%26%')
      OR (P_RESP_CDE = '96' and (P_REF_CDE like '%23%' OR P_REF_CDE like '%24%')))
      AND p_ref_cde NOT LIKE '%10%' AND p_ref_cde NOT LIKE '%35%' 
    THEN
      SELECT COUNT(1) INTO v_cnt FROM CCPS.FDS_TXN_DETAIL T WHERE T.f9_oa008_amt_req > 0 AND (/*T.FX_OA008_STAT in ('C','D') OR */(T.FX_OA008_GIVEN_RESP_CDE = '05' and trim(T.FX_OA008_REF_CDE) is null and FX_OA008_OFC_CDE = 'SIP ') OR (T.FX_OA008_GIVEN_RESP_CDE = '05' and T.FX_OA008_REF_CDE like '%26%') OR (T.FX_OA008_GIVEN_RESP_CDE = '96' and (T.FX_OA008_REF_CDE like '%23%' OR T.FX_OA008_REF_CDE like '%24%'))) AND T.F9_OA008_CRE_TMS BETWEEN STRT_TMS AND P_END_TMS;
      IF v_cnt >= 20 THEN--THOA ÐK HIT RULE
        L_CHECK_POINT := 2;
        SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
        ----thong tin gd co 3D Secure hay khong-
        L_CHECK_POINT := 21;
        select count(1) INTO V_3D_CHK FROM OA126@AM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
        IF V_3D_CHK > 0 THEN
          L_CHECK_POINT := 22;
           SELECT FX_OA126_3D_IND, FX_OA126_3D_ECI INTO V_3D_IND,V_3D_ECI FROM OA126@IM WHERE PX_OA126_PAN IN (P_CARDNO,V_PAN) AND P9_OA126_SEQ_NUM = P_SEQ;
        END IF;
        L_CHECK_POINT := 23;
        ----lay dung cif theo the chinh hoac phu
        select count(1) INTO V_CRN from oa059@am where PX_OA059_PAN = P_CARDNO;
        IF V_CRN > 0 THEN
          L_CHECK_POINT := 24;
            select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@am where PX_OA059_PAN = P_CARDNO);
        ELSE
            select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = P_CRN;
        END IF;
        L_CHECK_POINT := 25;
        ----------------------------------------
        SELECT TRIM(P9_OA008_SEQ)||'-'||TRIM(FX_OA008_GIVEN_APV_CDE)||'-'||TRIM(F9_OA008_STAN)||'-'||TRIM(F9_OA008_MCC) INTO CASE_ID FROM FDS_TXN_DETAIL WHERE FX_OA008_USED_PAN = P_CARDNO AND F9_OA008_CRE_TMS = P_END_TMS AND P9_OA008_SEQ=P_SEQ;
        ----CHECK IF CASE ALREADY EXISTED----
        IF P_CHECK = 'FALSE' THEN
          L_CHECK_POINT := 26;
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
                                 CRN) SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', 0, ''BACKEND_USR'', '' '', '''|| V_CIF ||''' , '''|| CASE_ID ||''', F9_OA008_ORI_AMT, 0, 0, ''NEW'', ''Y'', ''N'', FX_OA008_USED_PAN, F9_OA008_MCC, 0, F9_OA008_CRE_TMS, FX_OA008_CRD_BRN, FX_OA008_MERC_NAME, F9_OA008_CRNCY_CDE, FX_OA008_POS_MODE, DECODE(FX_OA008_REF_CDE, '' '', ''00'', DECODE(FX_OA008_CRD_BRN, ''MC'', (SELECT FX_OA274_MC_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE), (SELECT FX_OA274_VS_RESP_CDE FROM OA274@IM WHERE TRIM(PX_OA274_REF_CDE) = FX_OA008_REF_CDE))) AS RESP_CDE, FX_OA008_STAT,  '''|| V_3D_IND ||''' , '''|| V_3D_ECI ||''', F9_OA008_ACCT_NUM,0,0,0,'||P_CRN||' FROM (SELECT T.F9_OA008_CRE_TMS, T.F9_OA008_PRIN_CRN, T.PX_OA008_PAN, T.F9_OA008_ACCT_NUM, T.FX_OA008_USED_PAN, T.P9_OA008_SEQ, T.FX_OA008_GIVEN_APV_CDE, T.F9_OA008_AMT_REQ, T.F9_OA008_ORI_AMT, T.F9_OA008_MCC, T.FX_OA008_CRD_BRN, T.FX_OA008_MERC_NAME, T.F9_OA008_CRNCY_CDE, T.FX_OA008_POS_MODE, T.FX_OA008_STAT, NVL(SUBSTR(TRIM(T.FX_OA008_REF_CDE), 1, 2), '' '') AS FX_OA008_REF_CDE FROM CCPS.FDS_TXN_DETAIL T WHERE T.F9_OA008_CRE_TMS = ' || P_END_TMS ||' AND T.FX_OA008_USED_PAN = ''' || P_CARDNO ||''' AND T.P9_OA008_SEQ='||P_SEQ||')';
            EXECUTE IMMEDIATE SQL_STMT;
        END IF;
        --------------------------------------
        L_CHECK_POINT := 3;
        SQL_STMT2 :='INSERT INTO CCPS.FDS_CASE_HIT_RULE_DETAIL SELECT ''' || CRE_TMS || ''', ''' || CRE_TMS || ''', ''BACKEND_USR'', ''' || CASE_ID || ''', '''||V_RULENAME||''', T.F9_OA008_CRE_TMS, T.FX_OA008_USED_PAN, T.F9_OA008_MCC, T.P9_OA008_SEQ, T.F9_OA008_DT, T.F9_OA008_TM FROM CCPS.FDS_TXN_DETAIL T WHERE T.F9_OA008_AMT_REQ > 0 AND ((T.FX_OA008_GIVEN_RESP_CDE = ''05'' and trim(T.FX_OA008_REF_CDE) is null and FX_OA008_OFC_CDE = ''SIP '') OR (T.FX_OA008_GIVEN_RESP_CDE = ''05'' and T.FX_OA008_REF_CDE like ''%26%'') OR (T.FX_OA008_GIVEN_RESP_CDE = ''96'' and (T.FX_OA008_REF_CDE like ''%23%'' OR T.FX_OA008_REF_CDE like ''%24%''))) AND T.F9_OA008_CRE_TMS BETWEEN '||STRT_TMS||' AND '||P_END_TMS||' ORDER BY T.F9_OA008_CRE_TMS DESC';
        EXECUTE IMMEDIATE SQL_STMT2;
        L_CHECK_POINT := 4;
        SQL_STMT2 := 'INSERT INTO CCPS.FDS_CASE_HIT_RULES VALUES(' || CRE_TMS || ',' || CRE_TMS || ',''BACKEND_USR'',''' || CASE_ID || ''','''||V_RULENAME||''')';
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
--  ELSE
--    p_cnt:= 0;
--    RETURN 'FALSE';
--  END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_cnt:= 0;
      RETURN 'FALSE';
    WHEN OTHERS THEN
      p_cnt:= 0;
      RETURN 'ERROR at,'||L_CHECK_POINT||','||sqlerrm||','||SQL_STMT;
END;

/
