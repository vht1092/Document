--------------------------------------------------------
--  DDL for Procedure SP_FDS_UPDATE_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDS_UPDATE_DATA" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   20SEP2016    UPDATE DATA FROM OA008, OA150 SANG fds_txn_detail*
**********************************************************************************/
(
    sql_str OUT varchar2
)
AS
  v_start_check_tms NUMBER;
  v_end_check_tms NUMBER;
BEGIN
  --1. DEBIT CARD:
  --LAY THOI GIAN DA CAP NHAT THE DEBIT SAU CUNG NHAT
  SELECT DEBIT_UDP_TMS INTO v_start_check_tms FROM FDS_MAX_UPDATE_DATE;
  --LAY THOI GIAN CHOT TAI THOI DIEM CAP NHAT
  select MAX(f9_oa150_upd_tms) INTO v_end_check_tms from oa150@am where f9_oa150_upd_tms <> f9_oa150_cre_tms and fx_oa150_crd_brn = 'MC' and f9_oa150_cre_tms > v_start_check_tms;
  v_end_check_tms := nvl(v_end_check_tms,0);
  --CAP NHAT DU LIEU THE DEBIT
  if v_end_check_tms > v_start_check_tms then
    update fds_txn_detail
    SET (f9_oa008_upd_tms, fx_oa008_stat) = (select f9_oa150_upd_tms, FX_OA150_STAT from oa150@am where f9_oa150_cre_tms = F9_OA008_CRE_TMS and PX_OA150_PAN = px_oa008_pan and f9_oa150_upd_tms <> f9_oa150_cre_tms and f9_oa150_upd_tms > v_start_check_tms AND f9_oa150_upd_tms <= v_end_check_tms)
    where exists (select 1 from oa150@am where f9_oa150_cre_tms = F9_OA008_CRE_TMS and PX_OA150_PAN = px_oa008_pan and f9_oa150_upd_tms <> f9_oa150_cre_tms and f9_oa150_upd_tms > v_start_check_tms AND f9_oa150_upd_tms <= v_end_check_tms);
    COMMIT;
    --LAY THOI GIAN DA CAP NHAT THE DEBIT SAU CUNG NHAT
    UPDATE FDS_MAX_UPDATE_DATE SET DEBIT_UDP_TMS = v_end_check_tms;
    COMMIT;
  end if;
  --HET CAP NHAT DU LIEU THE DEBIT
  --2. CREDIT CARD:
  --LAY THOI GIAN DA CAP NHAT THE CREDIT SAU CUNG NHAT
  SELECT CREDIT_UDP_TMS INTO v_start_check_tms FROM FDS_MAX_UPDATE_DATE;
  --LAY THOI GIAN CHOT TAI THOI DIEM CAP NHAT
  select MAX(f9_oa008_upd_tms) INTO v_end_check_tms from oa008@am where f9_oa008_upd_tms <> f9_oa008_cre_tms and f9_oa008_cre_tms > v_start_check_tms;
  v_end_check_tms := nvl(v_end_check_tms,0);
  --CAP NHAT DU LIEU THE CREDIT
  if v_end_check_tms > v_start_check_tms then
    update fds_txn_detail a
    SET (a.f9_oa008_upd_tms, a.fx_oa008_stat) = (select b.f9_oa008_upd_tms, b.fx_oa008_stat from oa008@am b where b.f9_oa008_cre_tms = a.F9_OA008_CRE_TMS and b.PX_OA008_PAN = a.px_oa008_pan and b.f9_oa008_upd_tms <> b.f9_oa008_cre_tms and b.f9_oa008_upd_tms > v_start_check_tms AND b.f9_oa008_upd_tms <= v_end_check_tms)
    where exists (select 1 from oa008@am b where b.f9_oa008_cre_tms = a.F9_OA008_CRE_TMS and b.PX_OA008_PAN = a.px_oa008_pan and b.f9_oa008_upd_tms <> b.f9_oa008_cre_tms and b.f9_oa008_upd_tms > v_start_check_tms AND b.f9_oa008_upd_tms <= v_end_check_tms);
    COMMIT;
    --LAY THOI GIAN DA CAP NHAT THE CREDIT SAU CUNG NHAT
    UPDATE FDS_MAX_UPDATE_DATE SET CREDIT_UDP_TMS = v_end_check_tms;
    COMMIT;
  end if;
  --HET CAP NHAT DU LIEU THE CREDIT
  COMMIT;
  sql_str := 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      sql_str:= 'FAILED: '||SQLERRM;
END;

/
