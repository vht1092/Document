--------------------------------------------------------
--  DDL for Procedure SP_FDSPOS_RULES_PROCESS_EIB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDSPOS_RULES_PROCESS_EIB" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    TANVH1    16JUL2020    PROCESS CHECK HIT RULES FOR ALL POS              *
**********************************************************************************/
(
  p_result OUT varchar2
)
AS
  L_CHECK_POINT number;
  v_result varchar2(100);
BEGIN
  FOR c1_row IN (select distinct mid, ngay_gd from ccps.fds_pos_txn_v2 where scb_chks_stat = ' ' ORDER BY tid ASC) LOOP
    --1. START ccps.fn_fdspos_rule01-----------------------------------------------------------
    L_CHECK_POINT := 1;
    v_result := fn_fdspos_eib_rule01(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule01----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --2. START ccps.fn_fdspos_rule02-----------------------------------------------------------
    L_CHECK_POINT := 2;
    v_result := fn_fdspos_eib_rule02(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule02----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --3. START ccps.fn_fdspos_rule03-----------------------------------------------------------
    L_CHECK_POINT := 3;
    v_result := fn_fdspos_eib_rule03(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule03----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --4. START ccps.fn_fdspos_rule04-----------------------------------------------------------
    L_CHECK_POINT := 4;
    v_result := fn_fdspos_eib_rule04(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule04----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --5. START ccps.fn_fdspos_rule05-----------------------------------------------------------
    L_CHECK_POINT := 5;
    v_result := fn_fdspos_eib_rule05(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule05----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --6. START ccps.fn_fdspos_rule06-----------------------------------------------------------
    L_CHECK_POINT := 6;
    v_result := fn_fdspos_eib_rule06(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule06----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --7. START ccps.fn_fdspos_rule07-----------------------------------------------------------
    L_CHECK_POINT := 7;
    v_result := fn_fdspos_eib_rule07(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule07----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --9. START ccps.fn_fdspos_rule09-----------------------------------------------------------
    L_CHECK_POINT := 8;
    v_result := fn_fdspos_eib_rule09(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule09----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;
    --10. START ccps.fn_fdspos_rule10-----------------------------------------------------------
    L_CHECK_POINT := 9;
    v_result := fn_fdspos_eib_rule10(c1_row.mid, c1_row.ngay_gd);
    --END ccps.fn_fdspos_rule10----------------------------------------------------------------
    if v_result = 'ERROR' then p_result := 'Result: '||v_result||', L_check= '||L_CHECK_POINT; END IF;

    --CAP NHAT GIAO DICH DA CHECK RULES---
    UPDATE ccps.fds_pos_txn_v2 SET SCB_CHKS_STAT = 'Y' WHERE tid = c1_row.mid and ngay_gd = c1_row.ngay_gd;
    commit;
    --------------------------------------
  END LOOP;
  p_result := 'DONE';
END;

/
