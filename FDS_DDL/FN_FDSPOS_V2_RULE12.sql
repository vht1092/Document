--------------------------------------------------------
--  DDL for Function FN_FDSPOS_V2_RULE12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDSPOS_V2_RULE12" (

/************************************************************************************************
* VER    ID        DATE         ENHANCEMENT                                                     *
* -----  -------   ---------    ----------------------------------------------------------------*
* 2.0    HUYENNT   12SEP2018    TID CO SO TIEN GD LON TAI CUA HANG NHO LE                       *
*************************************************************************************************/
   p_tid in varchar2,
   p_date in number
) RETURN VARCHAR2
AS
   v_count number;
   v_so_lan number := 3;
   v_rule_id varchar2(20):= 'RULE12';
   v_cre_tms number;
   v_cnt number := 0;
   V_MA_GD NUMBER;
begin
   select count(1), MIN(MA_GD) into v_count, V_MA_GD--DEM SO LUONG GIAO DICH TRONG KHOANG THOI GIAN TU 0H DEN 5H
   from fds_pos_txn_v2
   where TID = p_tid
         and ngay_gd = p_date
         and MCC in ('5942', '7299', '5992', '5462', '5947', '5997', '5499', '4225', '5411', '5311')
         and ((SO_TIEN_GD_GOC >= 10000000 and loai_tien = 'VND') or (SO_TIEN_GD_GOC >= 450 and loai_tien = 'USD'));
   IF v_count >= v_so_lan THEN
     select count(1) into v_cnt from fds_pos_case_detail_v2 where ngay_gd = p_date AND case_id = V_MA_GD;
     if v_cnt = 0 then
        SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO v_cre_tms FROM dual;
        --insert du lieu case detail
        INSERT INTO fds_pos_case_detail_v2(cre_tms, upd_tms, case_id, check_dt, case_status, check_new,
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
     INSERT INTO fds_pos_case_hit_rule_v2(case_id, rule_id) VALUES(V_MA_GD,v_rule_id);
     --insert du lieu case hit rule detail
     INSERT INTO fds_pos_casehitruledetail_v2(case_id, rule_id, MA_GD, mid, ten_mid, tid, so_hd, dia_chi_gd,
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
        and ngay_gd = p_date
        and MCC in ('5942', '7299', '5992', '5462', '5947', '5997', '5499', '4225', '5411', '5311')
        and ((SO_TIEN_GD_GOC >= 10000000 and loai_tien = 'VND') or (SO_TIEN_GD_GOC >= 450 and loai_tien = 'USD'));
     commit;
   end if;
   return 'SUCCESS';
exception
   when others then return 'ERROR';
end;

/
