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
    V_CNT_CLOSE_CASE NUMBER;
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
