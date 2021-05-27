--------------------------------------------------------
--  DDL for Procedure SP_FDSPOS_RULES_PROCESS_VTB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDSPOS_RULES_PROCESS_VTB" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 2.0    HUYENNT   12SEP2018    PROCESS CHECK HIT RULES VTB FOR ALL POS          *
**********************************************************************************/
(
  p_result OUT varchar2
)
AS
  L_CHECK_POINT number;
  v_result varchar2(100);
BEGIN
  FOR c1_row IN (select distinct tid, ngay_gd from ccps.fds_pos_txn_v2 where vtb_chks_stat = ' ' /*and tid = '01028908'*/ ORDER BY tid ASC) LOOP
    --1. START ccps.fn_fdspos_rule14-----------------------------------------------------------
    L_CHECK_POINT := 1;
    v_result := fn_fdspos_v2_rule14(c1_row.tid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule14----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --2. START ccps.fn_fdspos_rule15-----------------------------------------------------------
    L_CHECK_POINT := 2;
    v_result := fn_fdspos_v2_rule15(c1_row.tid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule15----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --3. START ccps.fn_fdspos_rule16-----------------------------------------------------------
    L_CHECK_POINT := 3;
    v_result := fn_fdspos_v2_rule16(c1_row.tid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule16----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --4. START ccps.fn_fdspos_rule17-----------------------------------------------------------
    L_CHECK_POINT := 4;
    v_result := fn_fdspos_v2_rule17(c1_row.tid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule17----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --5. START ccps.fn_fdspos_rule18-----------------------------------------------------------
    L_CHECK_POINT := 5;
    v_result := fn_fdspos_v2_rule18(c1_row.tid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule18----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --CAP NHAT GIAO DICH DA CHECK RULES---
    L_CHECK_POINT := 6;
    UPDATE ccps.fds_pos_txn_v2 SET vtb_chks_stat = 'Y' WHERE tid = c1_row.tid and ngay_gd = c1_row.ngay_gd;
    commit;
    --------------------------------------
  END LOOP;
  p_result := 'DONE';
END;

/
