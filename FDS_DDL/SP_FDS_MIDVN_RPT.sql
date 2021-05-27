--------------------------------------------------------
--  DDL for Procedure SP_FDS_MIDVN_RPT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDS_MIDVN_RPT" 
/***********************************************************************************
 * VER    ID        DATE         ENHANCEMENT                                       *
 * -----  -------   ---------    ------------------------------------------------- *
 * 1.0    HUYENNT   03AUG2017    XUAT BAO CAO CHI TIET GIAO DICH TAI MERCHANT CO   *
 *                               TONG GIA TRI GIAO DICH >= 3TY                     *
 ***********************************************************************************/
(
  P_CRD_BRN IN VARCHAR2,
  P_MERCHANT IN VARCHAR2,
  P_TID      IN VARCHAR2,
  P_MID      IN VARCHAR2,
  P_MCC      IN NUMBER,
  P_MONTH   IN NUMBER,
  P_BRCH_CDE IN VARCHAR2,
  OUT_RS     OUT SYS_REFCURSOR
)
IS
  V_MERCHANT VARCHAR2(100);
  V_FROM_DT NUMBER := TO_NUMBER(P_MONTH||'01');
  V_TO_DT NUMBER := TO_NUMBER(P_MONTH||'31');
BEGIN
  V_MERCHANT := '%'||UPPER(P_MERCHANT)||'%';
  OPEN OUT_RS FOR
  ----LAY THONG TIN GIAO DICH----
  with txn_detail as (
  select
    MID,
    TID,
    MERC_NAME,
    DT,
    TM,
    VND_AMT,
    nvl((select fx_dw005_brch_cde from ccps.dw005 where px_dw005_pan = pan and rownum <= 1),(select fx_dw006_brch_cde from ccps.dw006 where px_dw006_own_pan = pan and rownum <= 1)) AS DON_VI_PH,
    (select fx_dw002_cif_no from ccps.dw002 where p9_dw002_crn = crn) AS CIF,
    PAN,
    loc,
    (select fx_dw002_name from ccps.dw002 where p9_dw002_crn = crn) as TEN_CHU_THE,
    POS_MODE,
    MCC,
    'Y' AS POSTED,
    cntry_cde,
    crncy_cde,
    crd_brn
  from
    ccps.FDS_CRCARD_TXN
  where
    DT >= V_FROM_DT and DT <= V_TO_DT
    AND resp_cde = '00'
    and (cntry_cde = 'VN' or cntry_cde = 'VNM' or cntry_cde = '704')
  )
  ----LAY THONG TIN BAO CAO----
  select
    B.MID, TID, MERC_NAME,
    SUBSTR(DT,-2,2)||'/'||SUBSTR(DT,5,2)||'/'||SUBSTR(DT,1,4) AS DT,
    SUBSTR(LPAD(TM,8,'0'),1,2)||':'||SUBSTR(LPAD(TM,8,'0'),3,2)||':'||SUBSTR(LPAD(TM,8,'0'),5,2)||'.'||SUBSTR(LPAD(TM,8,'0'),7,2) AS TM,
    VND_AMT, DON_VI_PH, CIF,(select px_irpanmap_panmask from ir_pan_map@im  where px_irpanmap_pan = PAN) AS PAN, LOC, TEN_CHU_THE, POS_MODE, MCC, POSTED
  FROM
    (
      select
        mid
      from
        TXN_DETAIL
      where
        crd_brn = P_CRD_BRN
      group by
        MID
      having sum(VND_AMT) >= 3000000000
    ) A
    LEFT JOIN TXN_DETAIL B ON A.MID = B.MID
  where
    crd_brn = P_CRD_BRN
    and (B.DON_VI_PH = RPAD(P_BRCH_CDE,5,' ') OR P_BRCH_CDE IS NULL)
    and (B.MCC = P_MCC OR P_MCC IS NULL)
    and (B.MID = P_MID OR P_MID IS NULL)
    and (B.TID = P_TID OR P_TID IS NULL)
    and (upper(MERC_NAME) like V_MERCHANT OR P_MERCHANT IS NULL)
    and VND_AMT > 0;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR - ' || SUBSTR(SQLERRM, 1, 200));
END;

/
