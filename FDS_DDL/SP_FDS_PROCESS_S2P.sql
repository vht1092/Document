--------------------------------------------------------
--  DDL for Procedure SP_FDS_PROCESS_S2P
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDS_PROCESS_S2P" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   20SEP2016    TEST RULE 42                                     *
**********************************************************************************/
(   cnt OUT NUMBER,
    cnt_h OUT NUMBER,
    sql_str OUT varchar2
)
AS
    cnt_diff number;
    v_tms_check number;
BEGIN
    cnt := 0;
    cnt_h := 0;
    cnt_diff := 0;
    SELECT TMS_ADD_SUBTRACT(0.03,TO_CHAR(systimestamp(3),'YYYYMMDDHH24MISSFF3')) INTO v_tms_check FROM dual;
    --MAIN PROCESS------------------------------------------------
    FOR c1_row IN (SELECT * FROM fds_s2p_txn where CHECKED = 'N' and upd_tms <= v_tms_check)
    LOOP
        --START ccps.SP_FDS_RULE43-----------------------------------------------------------
        sql_str:=fn_fds_rule43(
            c1_row.upd_tms,
            c1_row.txn_dt,
            c1_row.pan,
            c1_row.erec_key,
            cnt_diff
        );
        cnt_h := cnt_h + cnt_diff;
        cnt := cnt + 1;
        --END ccps.SP_FDS_RULE43----------------------------------------------------------------
        update fds_s2p_txn set CHECKED = 'Y' where erec_key = c1_row.erec_key;
        commit;
    END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            sql_str:= 'FAILED';
END;

/
