--------------------------------------------------------
--  DDL for Procedure SP_FDS_RULES_PROCESS_V2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDS_RULES_PROCESS_V2" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 2.0    HUYENNT   12JUL2017    PROCESS CHECK ALL RULES FROM FUNCTIONS           *
**********************************************************************************/
(
    cnt OUT NUMBER,
    cnt_h OUT NUMBER,
    sql_str OUT varchar2
)
AS
    v_start_check_tms NUMBER;
    v_start_check_tms2 number;
    v_end_check_tms NUMBER;
    v_sys_date NUMBER;
    v_check VARCHAR2(20);
    v_check_tmp VARCHAR2(20);
    cnt_diff number;
    sql_str_temp VARCHAR2(4000);
    v_pan varchar2(19);
    v_p_tms number;
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'SP_FDS_RULES_PROCESS_V2';
    L_CHECK_POINT NUMBER:=1;
    V_TXDATE NUMBER:=TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME NUMBER:=TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME NUMBER:=0;
    V_STS VARCHAR(10):= 'START';-- START / DONE / ERROR
    V_STSDESC VARCHAR2(4000):=' ';
BEGIN
    cnt := 0;
    cnt_h := 0;
    cnt_diff := 0;
    sql_str_temp := '';
    v_check := 'FALSE';
    v_check_tmp := v_check;
    --------------------------------------------------------------
    --GHI LOG START SP-------------------------------
    --INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    --COMMIT;
    --MAIN PROCESS------------------------------------------------
    SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO v_sys_date FROM dual;
    SELECT end_tms INTO v_start_check_tms FROM fds_processed_date;
    SELECT min(f9_oa008_cre_tms) INTO v_start_check_tms2 FROM fds_txn_detail WHERE fx_chks_stat = ' ' and f9_oa008_dt >= TO_CHAR(SYSDATE-1,'YYYYMMDD');
    IF v_start_check_tms > v_start_check_tms2 THEN v_start_check_tms := v_start_check_tms2-1; END IF;
    SELECT nvl(max(f9_oa008_cre_tms),TO_CHAR(SYSDATE,'YYYYMMDD')||'000000000') INTO v_end_check_tms FROM fds_txn_detail where f9_oa008_dt = TO_CHAR(SYSDATE,'YYYYMMDD');
    ----------------------------------------------
    FOR c1_row IN (select FX_OA008_STAT,f9_oa008_cre_tms,fx_oa008_used_pan,fx_oa008_merc_name,f9_oa008_mcc,F9_OA008_CRNCY_CDE,fx_oa008_cntry_cde,F9_OA008_AMT_REQ,fx_oa008_ori_mid,fx_oa008_tid,FX_OA008_CRD_BRN,fx_oa008_crd_pgm,fx_oa008_crd_prd,fx_oa008_ref_cde,fx_oa008_given_resp_cde,F9_OA008_STAN,FX_OA008_GIVEN_APV_CDE,P9_OA008_SEQ,FX_CHKS_STAT,f9_oa008_acct_num,f9_oa008_prin_crn,fx_oa008_cb_acct_num,fx_oa008_pos_mode,fx_oa008_merc_st_cntry,fx_oa008_txn_typ,fx_oa008_ofc_cde,fx_oa008_mid,F9_OA008_DT FROM fds_txn_detail where f9_oa008_cre_tms > v_start_check_tms AND f9_oa008_cre_tms <= v_end_check_tms AND FX_CHKS_STAT = ' ' order by f9_oa008_cre_tms asc) LOOP
      v_pan := c1_row.fx_oa008_used_pan;
      v_p_tms := c1_row.f9_oa008_cre_tms;
      v_check_tmp := 'FALSE';

      --3. START CCPS.FN_FDS_RULE03-------------------------------------------------------------
        L_CHECK_POINT := 4;
        sql_str_temp := FN_FDS_RULE03_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.f9_oa008_acct_num,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,c1_row.fx_oa008_crd_prd,c1_row.fx_oa008_crd_pgm,c1_row.fx_oa008_pos_mode,c1_row.fx_oa008_ref_cde,v_check_tmp,1,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
           v_check_tmp := v_check;
        END IF;
      --END CCPS.FN_FDS_RULE03------------------------------------------------------------------

      --17. START CCPS.FN_FDS_RULE17------------------------------------------------------------
        L_CHECK_POINT := 18;
        sql_str_temp := FN_FDS_RULE17_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.f9_oa008_acct_num,c1_row.fx_oa008_pos_mode,c1_row.fx_oa008_used_pan,c1_row.fx_oa008_crd_prd,c1_row.f9_oa008_crncy_cde,c1_row.fx_oa008_ref_cde,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END CCPS.FN_FDS_RULE17------------------------------------------------------------------

       --4. START CCPS.FN_FDS_RULE08-------------------------------------------------------------
        L_CHECK_POINT := 7;
        sql_str_temp := FN_FDS_RULE08_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_used_pan,c1_row.fx_oa008_pos_mode,c1_row.f9_oa008_mcc,c1_row.f9_oa008_acct_num,c1_row.fx_oa008_ref_cde,0.5,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
           v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE08------------------------------------------------------------------

       --21. START ccps.FN_FDS_RULE21-----------------------------------------------------------
          L_CHECK_POINT := 20;
          sql_str_temp := FN_FDS_RULE21_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_pos_mode,c1_row.fx_oa008_used_pan,c1_row.fx_oa008_ref_cde,3,0.084,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
          cnt_h := cnt_h + cnt_diff;
          v_check := sql_str_temp;
          IF v_check = 'DONE' THEN
              v_check_tmp := v_check;
          END IF;
      --END ccps.FN_FDS_RULE21----------------------------------------------------------------

      --5. START CCPS.FN_FDS_RULE33-------------------------------------------------------------
        L_CHECK_POINT := 32;
        sql_str_temp := FN_FDS_RULE33_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_used_pan,c1_row.fx_oa008_crd_pgm,c1_row.f9_oa008_mcc,c1_row.fx_oa008_ref_cde,c1_row.f9_oa008_cre_tms,v_check_tmp,c1_row.fx_oa008_mid,0.25,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END CCPS.FN_FDS_RULE33------------------------------------------------------------------

      --9. START ccps.FN_FDS_RULE23-----------------------------------------------------------
        L_CHECK_POINT := 22;
        sql_str_temp := FN_FDS_RULE23_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_pos_mode,c1_row.fx_oa008_used_pan,c1_row.fx_oa008_ref_cde,12,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE23----------------------------------------------------------------

      --1. START ccps.FN_FDS_RULE26-----------------------------------------------------------
--        L_CHECK_POINT := 25;
--        sql_str_temp := FN_FDS_RULE26(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,c1_row.fx_oa008_merc_name,c1_row.f9_oa008_mcc,c1_row.fx_oa008_ori_mid,c1_row.fx_oa008_tid,c1_row.fx_oa008_merc_st_cntry,c1_row.f9_oa008_crncy_cde,v_check_tmp,cnt_diff);
--        cnt_h := cnt_h + cnt_diff;
--        v_check := sql_str_temp;
--        IF v_check = 'DONE' THEN
--            v_check_tmp := v_check;
--        END IF;
      --END ccps.FN_FDS_RULE26----------------------------------------------------------------

       --6. START ccps.FN_FDS_RULE29-------------------------------------------------------------
        L_CHECK_POINT := 28;
        sql_str_temp := FN_FDS_RULE29_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,c1_row.f9_oa008_mcc,c1_row.fx_oa008_cntry_cde,c1_row.fx_oa008_pos_mode,c1_row.fx_oa008_ref_cde,c1_row.F9_OA008_AMT_REQ,c1_row.FX_OA008_CRD_BRN,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE29----------------------------------------------------------------

      --7. START ccps.FN_FDS_RULE30-----------------------------------------------------------
          L_CHECK_POINT := 29;
          sql_str_temp := FN_FDS_RULE30_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,c1_row.f9_oa008_mcc,c1_row.fx_oa008_cntry_cde,c1_row.fx_oa008_pos_mode,c1_row.fx_oa008_ref_cde,c1_row.FX_OA008_CRD_BRN,v_check_tmp,cnt_diff);
          cnt_h := cnt_h + cnt_diff;
          v_check := sql_str_temp;
          IF v_check = 'DONE' THEN
              v_check_tmp := v_check;
          END IF;
      --END ccps.FN_FDS_RULE30----------------------------------------------------------------

      --29. START CCPS.FN_FDS_RULE39------------------------------------------------------------
        L_CHECK_POINT := 38;
        sql_str_temp := FN_FDS_RULE39_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_used_pan,c1_row.fx_oa008_crd_pgm,c1_row.f9_oa008_cre_tms,c1_row.f9_oa008_mcc,c1_row.fx_oa008_pos_mode,c1_row.f9_oa008_acct_num,c1_row.f9_oa008_crncy_cde,c1_row.fx_oa008_ref_cde,c1_row.F9_OA008_DT,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END CCPS.FN_FDS_RULE39-----------------------------------------------------------------

      --II. NHOM 2------------------------------------------------------------------------------
      --18. START ccps.FN_FDS_RULE13-----------------------------------------------------------
        L_CHECK_POINT := 12;
        sql_str_temp := FN_FDS_RULE13_V2(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_used_pan,c1_row.fx_oa008_crd_brn,c1_row.fx_oa008_merc_name,c1_row.f9_oa008_cre_tms,c1_row.fx_oa008_ref_cde,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE13-----------------------------------------------------------------

      --19. START ccps.FN_FDS_RULE14-----------------------------------------------------------
        L_CHECK_POINT := 13;
        sql_str_temp := FN_FDS_RULE14(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_ref_cde,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE14----------------------------------------------------------------

      --20. START ccps.FN_FDS_RULE15-----------------------------------------------------------
        L_CHECK_POINT := 14;
        sql_str_temp := FN_FDS_RULE15(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_ref_cde,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE15----------------------------------------------------------------
      --21. START ccps.FN_FDS_RULE16-----------------------------------------------------------
        L_CHECK_POINT := 15;
        sql_str_temp := FN_FDS_RULE16_V2(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_ref_cde,c1_row.fx_oa008_used_pan,c1_row.fx_oa008_crd_brn,c1_row.fx_oa008_crd_pgm,c1_row.fx_oa008_crd_prd,c1_row.fx_oa008_merc_name,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE16----------------------------------------------------------------
      --22. START ccps.FN_FDS_RULE34-----------------------------------------------------------
        L_CHECK_POINT := 33;
        sql_str_temp := FN_FDS_RULE34(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_ref_cde,c1_row.f9_oa008_acct_num,c1_row.fx_oa008_cb_acct_num,c1_row.fx_oa008_crd_pgm,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE34----------------------------------------------------------------

      --23. START ccps.FN_FDS_RULE35-----------------------------------------------------------
        L_CHECK_POINT := 34;
        sql_str_temp := FN_FDS_RULE35(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_ref_cde,c1_row.f9_oa008_acct_num,c1_row.fx_oa008_cb_acct_num,c1_row.fx_oa008_crd_pgm,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE35----------------------------------------------------------------

      --24. START ccps.FN_FDS_RULE20-----------------------------------------------------------
        L_CHECK_POINT := 19;
        sql_str_temp := FN_FDS_RULE20(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_ref_cde,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE20----------------------------------------------------------------
      --27. START ccps.FN_FDS_RULE37-----------------------------------------------------------
        L_CHECK_POINT := 36;
        sql_str_temp := FN_FDS_RULE37(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,c1_row.fx_oa008_ref_cde,c1_row.fx_oa008_given_resp_cde,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --END ccps.FN_FDS_RULE37----------------------------------------------------------------

      --29. TEST CCPS.FN_FDS_RULE42------------------------------------------------------------
        L_CHECK_POINT := 41;
        --v_pan := c1_row.f9_oa008_cre_tms;
        sql_str_temp :=  FN_FDS_RULE42_V2(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,c1_row.fx_oa008_stat,c1_row.fx_oa008_given_resp_cde,c1_row.fx_oa008_ref_cde,c1_row.fx_oa008_ofc_cde,v_check_tmp,cnt_diff);
        cnt_h := cnt_h + cnt_diff;
        v_check := sql_str_temp;
        IF v_check = 'DONE' THEN
            v_check_tmp := v_check;
        END IF;
      --HET NHOM 2-----------------------------------------------------------------------------

    --19. START ccps.FN_FDS_RULE14-----------------------------------------------------------
--        L_CHECK_POINT := 13;
--        sql_str_temp := FN_FDS_RULE14_V3(c1_row.f9_oa008_prin_crn,c1_row.P9_OA008_SEQ,c1_row.F9_OA008_AMT_REQ,c1_row.fx_oa008_ref_cde,c1_row.fx_oa008_used_pan,c1_row.f9_oa008_cre_tms,v_check_tmp,cnt_diff);
--        cnt_h := cnt_h + cnt_diff;
--        v_check := sql_str_temp;
--        IF v_check = 'DONE' THEN
--            v_check_tmp := v_check;
--        END IF;
      --END ccps.FN_FDS_RULE14----------------------------------------------------------------

      --CAP NHAT GIAO DICH DA CHECK RULES---
      L_CHECK_POINT := 32;
      UPDATE fds_txn_detail SET FX_CHKS_STAT = 'Y' WHERE f9_oa008_cre_tms = c1_row.f9_oa008_cre_tms AND fx_oa008_used_pan = c1_row.fx_oa008_used_pan;
      commit;
      --------------------------------------
      --UPDATE FDS_LOG SET END_TIME = TO_CHAR(SYSDATE,'hh24missss'), STATUS = 'DONE', STSDESC = 'At:'||L_CHECK_POINT||':'||c1_row.f9_oa008_cre_tms WHERE PROC_NAME = V_PROD AND TXDATE = V_TXDATE AND BEGIN_TIME = V_BEGTIME;
    END LOOP;
    sql_str_temp := 'UPDATE fds_processed_date SET upd_tms = '||v_sys_date||',upd_uid = ''BACKEND_USR'',start_tms = '||v_start_check_tms||',end_tms = '||v_end_check_tms;
    execute immediate sql_str_temp;
    commit;
    sql_str := 'DONE WITH '||cnt_h||' CASES';
    V_STS := 'DONE'; -- START / DONE / ERROR
    V_ENDTIME := TO_CHAR(SYSDATE,'hh24missss');
    V_STSDESC := 'DONE At:'||L_CHECK_POINT;
    DBMS_OUTPUT.PUT_LINE('Loi:'||V_STSDESC);
    --UPDATE FDS_LOG SET END_TIME = V_ENDTIME, STATUS = V_STS, STSDESC = V_STSDESC WHERE PROC_NAME = V_PROD AND TXDATE = V_TXDATE AND BEGIN_TIME = V_BEGTIME;
    --COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
             ROLLBACK;
             V_STS := 'ERROR'; -- START / DONE / ERROR
             V_ENDTIME := TO_CHAR(SYSDATE,'hh24missss');
             V_STSDESC := SQLERRM||' At:'||L_CHECK_POINT;
             --DBMS_OUTPUT.PUT_LINE('Loi:'||V_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = V_ENDTIME, STATUS = V_STS, STSDESC = V_STSDESC WHERE PROC_NAME = V_PROD AND TXDATE = V_TXDATE AND BEGIN_TIME = V_BEGTIME;
             --COMMIT;
             sql_str:= 'FAILED AT:'||L_CHECK_POINT||','||SQLERRM||',pan='||v_pan;
END;

/
