--------------------------------------------------------
--  DDL for Function FN_FDS_RULE43
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDS_RULE43" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   22NOV2017    Giao dich 3DS co tren Safe2Pay nhung khong co    *
*                               trong Cardworks                                  *
**********************************************************************************/
(
  p_upd_tms in number,
  p_txn_dt in number,
  p_pan IN VARCHAR2,
  p_EREC_KEY in number,
  p_cnt OUT NUMBER
) RETURN VARCHAR2
AS
  v_start_tms number;
  v_end_tms number;
  v_cnt number;
  v_cnt1 number;
  CRE_TMS number;
  V_CIF VARCHAR2(10);
  V_3D_IND VARCHAR2(5) := 'N';
  V_3D_ECI VARCHAR2(5) := ' ';
  v_card_type char(2);
  V_LOC NUMBER;
  V_CRN NUMBER;
  V_RULENAME VARCHAR2(20) := 'RULE43';
BEGIN
  v_start_tms := TMS_ADD_SUBTRACT(0.03,p_upd_tms);--xet trong 3 phut
  v_end_tms := TMS_ADD_SUBTRACT(-0.03,p_upd_tms);
  --select count(1) into v_cnt from oa126@am where PX_OA126_PAN = p_pan and F9_OA126_CRE_TMS > v_start_tms and F9_OA126_CRE_TMS <= v_end_tms;
  --v_cnt := nvl(v_cnt,0);
  --lay cardtype------------
  SELECT FX_DW005_CRD_BRN,F9_DW005_LOC_ACCT,F9_DW005_CRN INTO v_card_type,V_LOC,V_CRN FROM DW005 WHERE PX_DW005_PAN = p_pan AND ROWNUM <= 1;
  IF v_card_type IS NULL THEN
    SELECT FX_DW006_CRD_BRN,F9_DW006_LOC_ACCT,F9_DW006_CRN INTO v_card_type,V_LOC,V_CRN FROM DW006 WHERE PX_DW006_OWN_PAN = p_pan AND ROWNUM <= 1;
  END IF;
  --------------------------
  if V_LOC > 800000000000 then
    select count(1) into v_cnt1 from oa008@am where FX_OA008_USED_PAN = p_pan and F9_OA008_CRE_TMS > v_start_tms and F9_OA008_CRE_TMS <= v_end_tms and FX_OA008_GIVEN_RESP_CDE = '00';
  else
    select count(1) into v_cnt1 from oa150@am where FX_OA150_USED_PAN = p_pan and F9_OA150_CRE_TMS > v_start_tms and F9_OA150_CRE_TMS <= v_end_tms and FX_OA150_GIVEN_RESP_CDE = '00';
  end if;
  if /*v_cnt = 0 and */v_cnt1 = 0 then--hit rule
    SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO CRE_TMS FROM dual;
    ----lay dung cif theo the chinh hoac phu
    select count(1) INTO v_cnt from oa059@IM where PX_OA059_PAN = p_pan;
    IF v_cnt > 0 THEN
        select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA059_CRN from oa059@IM where PX_OA059_PAN = p_pan);
    ELSE
        select trim(FX_IR056_CIF_NO) INTO V_CIF from ir056@im where P9_IR056_CRN = (select F9_OA051_PRIN_CRN from oa051@IM where PX_OA051_PAN = p_pan);
    END IF;
    INSERT INTO fpt.FDS_CASE_DETAIL (CRE_TMS,UPD_TMS,
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
                                 CRN) values(CRE_TMS,CRE_TMS,'BACKEND_USR',0,'BACKEND_USR', ' ', V_CIF, p_EREC_KEY, 0, 0, 0, 'NEW', 'Y', 'N', p_pan, 0, 0, p_upd_tms, v_card_type, ' ', ' ', ' ', ' ', ' ', V_3D_IND,V_3D_ECI, V_LOC,0,0,0,V_CRN);
    INSERT INTO FPT.FDS_CASE_HIT_RULE_DETAIL VALUES(cre_tms,cre_tms,'BACKEND_USR',p_EREC_KEY,V_RULENAME,p_upd_tms,p_pan,0,0,p_txn_dt,0);
    INSERT INTO FPT.FDS_CASE_HIT_RULES VALUES(cre_tms,cre_tms,'BACKEND_USR',p_EREC_KEY,V_RULENAME);
    COMMIT;
    p_cnt := 1;
    RETURN 'DONE';
  ELSE
    p_cnt := 0;
    RETURN 'DONE';
  end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_cnt:= 0;
      RETURN 'FALSE';
    WHEN OTHERS THEN
      p_cnt:= 0;
      RETURN 'ERROR';
END;

/
