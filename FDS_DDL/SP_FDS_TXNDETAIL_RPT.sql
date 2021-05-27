--------------------------------------------------------
--  DDL for Procedure SP_FDS_TXNDETAIL_RPT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDS_TXNDETAIL_RPT" 
/***********************************************************************************
 * VER    ID        DATE         ENHANCEMENT                                       *
 * -----  -------   ---------    ------------------------------------------------- *
 * 1.0    HUYENNT   10MAY2017    XUAT BAO CAO CHI TIET GIAO DICH THE THEO: MERCHANT*
 *                               NAME, TID, SO THE, MCC                            *
 ***********************************************************************************/
(
  P_MERCHANT IN VARCHAR2,
  P_TID      IN VARCHAR2,
  P_CRDNO    IN VARCHAR2,
  P_MID      IN VARCHAR2,
  P_MCC      IN VARCHAR2,
  P_TODATE   IN NUMBER,
  P_FROMDATE IN NUMBER,
  OUT_RS     OUT SYS_REFCURSOR
)
IS
  V_CARDENC varchar2(19);
  V_MERCHANT VARCHAR2(100);
BEGIN
  IF (P_CRDNO IS NOT NULL) THEN
    --V_CARDENC := CCPS.ECD2(P_CRDNO,'A');
    SELECT PAN INTO V_CARDENC FROM FPT.IR_PAN_MAP WHERE PAN_UNLOCK = SUBSTR(P_CRDNO,1,6)||'XXXXXX'||SUBSTR(P_CRDNO,-4) AND PX_IRPANMAP_MID = SUBSTR(P_CRDNO,7,6);
  ELSE
    V_CARDENC := 'ABCDEFGHIJKLMNOPQRS';
  END IF;
  V_MERCHANT := UPPER(P_MERCHANT);
  OPEN OUT_RS FOR
  SELECT
      nvl((SELECT PAN_UNLOCK FROM FPT.IR_PAN_MAP WHERE PAN = px_oa008_pan),/*ded2(px_oa008_pan,'A')*/'THE_KHONG_TON_TAI') PAN,
      NVL(F9_DW005_LOC_ACCT, F9_DW006_LOC_ACCT) LOC,
      TO_CHAR(TO_DATE(f9_oa008_dt,'yyyymmdd'),'dd/mm/yyyy') ||' '||substr(lpad(nvl(F9_OA008_TM,0),8,'0'),1,2)||':'||substr(lpad(nvl(F9_OA008_TM,0),8,'0'),3,2)||':'||substr(lpad(nvl(F9_OA008_TM,0),8,'0'),5,2)||'.'||substr(lpad(nvl(F9_OA008_TM,0),8,'0'),7,2) TMS,
      F9_OA008_ORI_AMT as ORI_AMT,
      F9_OA008_CRNCY_CDE as CRNCY_CDE,
      F9_OA008_AMT_REQ as VND_AMT,
      FX_OA008_POS_MODE as POS_MODE,
      FX_OA008_GIVEN_APV_CDE as APV_CDE,
      FX_OA008_GIVEN_RESP_CDE as RESP_CDE,
      FX_OA008_MERC_ST_CNTRY as CNTRY_CDE,
      trim(FX_OA008_ORI_MID) as MID,
      trim(FX_OA008_MERC_NAME) as MERC_NAME,
      FX_OA008_TID as TID,
      F9_OA008_MCC as MCC,
      --(SELECT trim(FX_IR056_CIF_NO) FROM IR056@im WHERE (P9_IR056_CRN = F9_DW005_CRN OR P9_IR056_CRN = F9_DW006_CRN) and rownum = 1) CIF_NO,
      --(select trim(fx_dw002_cif_no) from ccps.dw002 where (p9_dw002_crn = F9_DW005_CRN or p9_dw002_crn = F9_DW006_CRN) and rownum = 1) CIF_NO,
      nvl((select trim(fx_dw002_cif_no) from ccps.dw002 where p9_dw002_crn = F9_DW005_CRN and rownum = 1), (select trim(fx_dw002_cif_no) from ccps.dw002 where p9_dw002_crn = F9_DW006_CRN and rownum = 1)) CIF_NO,
      --(SELECT trim(FX_IR056_NAME) FROM IR056@im WHERE (P9_IR056_CRN = F9_DW005_CRN OR P9_IR056_CRN = F9_DW006_CRN) and rownum = 1) CUST_NAME,
      --(select trim(fx_dw002_name) from ccps.dw002 where (p9_dw002_crn = F9_DW005_CRN or p9_dw002_crn = F9_DW006_CRN) and rownum = 1) CUST_NAME,
      nvl((select trim(fx_dw002_name) from ccps.dw002 where p9_dw002_crn = F9_DW005_CRN and rownum = 1), (select trim(fx_dw002_name) from ccps.dw002 where p9_dw002_crn = F9_DW006_CRN and rownum = 1)) CUST_NAME,
      NVL(FX_DW005_CRD_STAT, FX_DW006_CRD_STAT) CRD_STAT,      
      NVL(FX_DW005_BRCH_CDE, FX_DW006_BRCH_CDE) BRCH_CDE,
      NVL(DECODE(FX_OA126_3D_IND, ' ', 'N',FX_OA126_3D_IND), 'N') "3D_IND",
      --(SELECT nvl(trim(FX_IR056_HP),' ') FROM IR056@im WHERE (P9_IR056_CRN = F9_DW005_CRN OR P9_IR056_CRN = F9_DW006_CRN) and rownum = 1) HP
      --(select nvl(trim(fx_dw002_hp),' ') from ccps.dw002 where (p9_dw002_crn = F9_DW005_CRN or p9_dw002_crn = F9_DW006_CRN) and rownum = 1) HP
      nvl((select nvl(trim(fx_dw002_hp),' ') from ccps.dw002 where p9_dw002_crn = F9_DW005_CRN and rownum = 1), (select nvl(trim(fx_dw002_hp),' ') from ccps.dw002 where p9_dw002_crn = F9_DW006_CRN and rownum = 1)) HP
  FROM
      (--filter by Merchant name
      SELECT * FROM fds_txn_detail WHERE P_MERCHANT is not null and (f9_oa008_dt >= SUBSTR(P_FROMDATE,1,8) AND f9_oa008_dt <= SUBSTR(P_TODATE,1,8) AND UPPER(FX_OA008_MERC_NAME) LIKE '%'||UPPER(V_MERCHANT)||'%')
      union all
      SELECT * FROM fds_txn_detail_hist WHERE P_MERCHANT is not null and (f9_oa008_dt >= SUBSTR(P_FROMDATE,1,8) AND f9_oa008_dt <= SUBSTR(P_TODATE,1,8) AND UPPER(FX_OA008_MERC_NAME) LIKE '%'||UPPER(V_MERCHANT)||'%')
      union all
      --Filter by tid
      SELECT * FROM fds_txn_detail WHERE P_TID is not null and (f9_oa008_dt >= SUBSTR(P_FROMDATE,1,8) AND f9_oa008_dt <= SUBSTR(P_TODATE,1,8) AND FX_OA008_TID = P_TID)
      union all
      SELECT * FROM fds_txn_detail_hist WHERE P_TID is not null and (f9_oa008_dt >= SUBSTR(P_FROMDATE,1,8) AND f9_oa008_dt <= SUBSTR(P_TODATE,1,8) AND FX_OA008_TID = P_TID)
      --Filter by CardNo
      union all
      SELECT * FROM fds_txn_detail WHERE P_CRDNO is not null and (f9_oa008_dt >= P_FROMDATE AND f9_oa008_dt <= P_TODATE AND px_oa008_pan = V_CARDENC)
      union all
      SELECT * FROM fds_txn_detail_hist WHERE P_CRDNO is not null and (f9_oa008_dt >= P_FROMDATE AND f9_oa008_dt <= P_TODATE AND px_oa008_pan = V_CARDENC)
      --Filter by MID
      union all
      SELECT * FROM fds_txn_detail WHERE P_MID is not null and (f9_oa008_dt >= P_FROMDATE AND f9_oa008_dt <= P_TODATE AND trim(FX_OA008_ORI_MID) = trim(P_MID))
      union all
      SELECT * FROM fds_txn_detail_hist WHERE P_MID is not null and (f9_oa008_dt >= P_FROMDATE AND f9_oa008_dt <= P_TODATE AND trim(FX_OA008_ORI_MID) = trim(P_MID))
      --Filter by MCC
      union all
      SELECT * FROM fds_txn_detail WHERE P_MCC is not null and (f9_oa008_dt >= P_FROMDATE AND f9_oa008_dt <= P_TODATE AND F9_OA008_MCC = P_MCC)
      union all
      SELECT * FROM fds_txn_detail_hist WHERE P_MCC is not null and (f9_oa008_dt >= P_FROMDATE AND f9_oa008_dt <= P_TODATE AND F9_OA008_MCC = P_MCC)
      )
      LEFT JOIN DW005 ON PX_DW005_PAN = px_oa008_pan
      LEFT JOIN DW006 ON PX_DW006_OWN_PAN = px_oa008_pan
      LEFT JOIN OA126@AM ON px_oa008_pan = PX_OA126_PAN AND P9_OA008_SEQ = P9_OA126_SEQ_NUM
   order by
      f9_oa008_dt,F9_OA008_TM asc;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR - ' || SUBSTR(SQLERRM, 1, 200));
END;

/
