--------------------------------------------------------
--  DDL for Procedure SP_DAILYBACKUP_FDSCARD_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_DAILYBACKUP_FDSCARD_DATA" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   21AUG2019    XU LY MOVE DU LIEU QUA 1 THANG VAO TABLE HIST    *
**********************************************************************************/
(
    P_RESULT OUT VARCHAR2
)
IS
    v_cutoff_time number;
    V_L_CHECK NUMBER := 0;
BEGIN
    select to_char(add_months(sysdate,-1),'yyyymmdd')||'999999999' into v_cutoff_time from dual;
    --1.BACKUP TABLE fds_case_hit_rule_detail
    V_L_CHECK := 1;
    insert into fds_case_hit_rule_detail_hist
    select * from fds_case_hit_rule_detail where case_no in (select case_no from fds_case_detail where TXN_CRE_TMS <= v_cutoff_time);
    delete from fds_case_hit_rule_detail where case_no in (select case_no from fds_case_detail where TXN_CRE_TMS <= v_cutoff_time);
    COMMIT;
    --2.BACKUP TABLE fds_case_hit_rules
    V_L_CHECK := 2;
    insert into fds_case_hit_rules_hist
    select * from fds_case_hit_rules where case_no in (select case_no from fds_case_detail where TXN_CRE_TMS <= v_cutoff_time);
    delete from fds_case_hit_rules where case_no in (select case_no from fds_case_detail where TXN_CRE_TMS <= v_cutoff_time);
    COMMIT;
    --3.BACKUP TABLE fds_case_status
    V_L_CHECK := 3;
    insert into fds_case_status_hist
    select * from fds_case_status where case_no in (select case_no from fds_case_detail where TXN_CRE_TMS <= v_cutoff_time);
    delete from fds_case_status where case_no in (select case_no from fds_case_detail where TXN_CRE_TMS <= v_cutoff_time);
    COMMIT;
    --4.BACKUP TABLE fds_case_detail
    V_L_CHECK := 4;
    insert into fds_case_detail_hist select * from fds_case_detail where TXN_CRE_TMS <= v_cutoff_time;
    delete from fds_case_detail where TXN_CRE_TMS <= v_cutoff_time;
    COMMIT;
    --5.BACKUP TABLE fds_txn_detail
    V_L_CHECK := 5;
    insert into fds_txn_detail_hist
    select * from fds_txn_detail where f9_oa008_cre_tms <= v_cutoff_time;
    delete from fds_txn_detail where f9_oa008_cre_tms <= v_cutoff_time;
    COMMIT;
    -------------------------------
    P_RESULT := 'THANH CONG';
EXCEPTION
    WHEN OTHERS THEN P_RESULT := 'ERROR AT:'||V_L_CHECK||',ERR DESC:'||sqlerrm;
END; -- Procedure

/
