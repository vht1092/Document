--------------------------------------------------------
--  DDL for Function FN_FDSPOS_V2_RULE17
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDSPOS_V2_RULE17" (
/************************************************************************************************
* VER    ID        DATE         ENHANCEMENT                                                     *
* -----  -------   ---------    ----------------------------------------------------------------*
* 2.0    HUYENNT   19SEP2018    TID CO SO LUONG GIAO DICH BANG TU 1 NGAY LON BAT THUONG         *
*************************************************************************************************/
   p_tid in varchar2,
   p_date in number
) RETURN VARCHAR2
AS
   v_total_amt number;
   v_total_amtof7day number;
   v_rule_id varchar2(20):= 'RULE17';
   v_cre_tms number;
   v_cnt number := 0;
   V_MA_GD NUMBER;
begin
   select COUNT(1), MIN(MA_GD) into v_total_amt, V_MA_GD--SO LUONG GIAO DICH 1 NGAY CUA TID
   from fds_pos_txn_v2
   where TID = p_tid
         and pos_mde_2digit = '90'--gd tu
         and ngay_gd = p_date;
   select ROUND(COUNT(1)/7) into v_total_amtof7day--SO LUONG GIAO DICH TRUNG BINH 7 NGAY LIEN KE CUA TID
   from fds_pos_txn_v2
   where TID = p_tid
         and pos_mde_2digit = '90'
         and ngay_gd BETWEEN TO_CHAR(TO_DATE(p_date,'YYYYMMDD')-8,'YYYYMMDD') AND TO_CHAR(TO_DATE(p_date,'YYYYMMDD')-1,'YYYYMMDD');
   IF v_total_amt/v_total_amtof7day >= 3/2 THEN--DOANH SO NGAY TANG >= 150% DOANH SO TB CUA 7 NGAY LIEN KE
     select count(1) into v_cnt from fds_pos_case_detail_vtb where ngay_gd = p_date AND case_id = V_MA_GD;
     if v_cnt = 0 then
        SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO v_cre_tms FROM dual;
        --insert du lieu case detail
        INSERT INTO fds_pos_case_detail_vtb(cre_tms, upd_tms, case_id, check_dt, case_status, check_new,
          asg_tms, usr_id, mid, ten_mid, tid, so_hd, dia_chi_gd,
          ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi,
          so_tien_gd_goc, loai_tien, so_tien_tip, so_bin, so_the,
          loai_the, ket_qua_gd, dao_huy, pos_mde_2digit, pos_mode,
          ma_loi, bao_co, ngay_gd, mcc
        )
        select
          v_cre_tms, v_cre_tms, ma_gd, 0, 'NEW', 'Y', 0, 'SYSTEM', mid, ten_mid, tid, so_hd, dia_chi_gd,
          ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi, so_tien_gd_goc,
          loai_tien, so_tien_tip, so_bin, so_the, loai_the, ket_qua_gd,
          dao_huy, pos_mde_2digit, pos_mode, ma_loi, bao_co, ngay_gd, mcc
        from
          fds_pos_txn_v2
        where
          ma_gd = V_MA_GD;
     end if;
     --insert du lieu case hit rule
     INSERT INTO fds_pos_case_hit_rule_vtb(case_id, rule_id) VALUES(V_MA_GD,v_rule_id);
     --insert du lieu case hit rule detail
     INSERT INTO fds_pos_casehitruledetail_vtb(case_id, rule_id, MA_GD, mid, ten_mid, tid, so_hd, dia_chi_gd,
        ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi,
        so_tien_gd_goc, loai_tien, so_tien_tip, so_bin,
        so_the, loai_the, ket_qua_gd, dao_huy, pos_mde_2digit,
        pos_mode, ma_loi, bao_co, ngay_gd, mcc
     )
     select
        V_MA_GD,v_rule_id,MA_GD, mid, ten_mid, tid, so_hd, dia_chi_gd,
        ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi,
        so_tien_gd_goc, loai_tien, so_tien_tip, so_bin,
        so_the, loai_the, ket_qua_gd, dao_huy, pos_mde_2digit,
        pos_mode, ma_loi, bao_co, ngay_gd, mcc
     from
        fds_pos_txn_v2
     where
        tid = p_tid
        and pos_mde_2digit = '90'
        and ngay_gd = p_date;
     commit;
   end if;
   return 'SUCCESS';
exception
   when others then return 'ERROR';
end;

/
