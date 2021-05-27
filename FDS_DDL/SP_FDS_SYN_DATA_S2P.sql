--------------------------------------------------------
--  DDL for Procedure SP_FDS_SYN_DATA_S2P
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDS_SYN_DATA_S2P" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   22NOV2017    INSERT DATA FROM OA126 SANG fds_s2p_txn          *
**********************************************************************************/
(
    sql_str OUT varchar2
)
AS
    v_max_upd_s2p NUMBER;
    v_max_upd_st002 NUMBER;
BEGIN
    SELECT nvl(max(UPD_TMS),TO_CHAR(SYSDATE,'YYYYMMDD')||'000000001') INTO v_max_upd_s2p FROM FDS_S2P_TXN where TXN_DT = TO_CHAR(SYSDATE-1,'YYYYMMDD');
    SELECT nvl(max(F9_ST002_UPD_TMS),TO_CHAR(SYSDATE,'YYYYMMDD')||'000000000') INTO v_max_upd_st002 FROM st002@sp.world where F9_ST002_UPD_TMS >= TO_CHAR(SYSDATE-1,'YYYYMMDD')||'000000000';
    if v_max_upd_s2p < v_max_upd_st002 then
      insert into fds_s2p_txn(upd_tms,
                              txn_dt,
                              pan,
                              acq_merc_id,
                              EREC_KEY,
                              enroll_typ,
                              txn_stat,
                              checked)
      --select F9_ST002_UPD_TMS,F9_ST002_TXN_DT,FX_ST002_PAN||'XXX' as FX_ST002_PAN,FX_ST002_ACQ_MERC_ID,P9_ST002_EREC_KEY,FX_ST002_ENROLL_TYP,FX_ST002_TXN_STAT,'N' from st002@sp.world where F9_ST002_UPD_TMS > v_max_upd_s2p and F9_ST002_UPD_TMS <= v_max_upd_st002;
      SELECT
        F9_ST002_UPD_TMS,F9_ST002_TXN_DT,FX_ST002_PAN||'XXX' as FX_ST002_PAN,FX_ST002_ACQ_MERC_ID,P9_ST002_EREC_KEY,FX_ST002_ENROLL_TYP,FX_ST002_TXN_STAT,'N'
      FROM
        ST002@SP
        LEFT JOIN ST003@SP ON P9_ST002_EREC_KEY= P9_ST003_EREC_KEY
      WHERE
        F9_ST002_UPD_TMS > v_max_upd_s2p and F9_ST002_UPD_TMS <= v_max_upd_st002
        AND FX_ST002_ENROLL_TYP = 'Y'
        AND (FX_ST003_TXN_STAT <> 'S' OR FX_ST003_TXN_STAT IS NULL);
      COMMIT;
    end if;
    sql_str := 'DONE';
    EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          sql_str:= 'FAILED'||sqlerrm;
END;

/
