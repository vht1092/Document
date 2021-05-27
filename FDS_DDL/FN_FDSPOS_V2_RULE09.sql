--------------------------------------------------------
--  DDL for Function FN_FDSPOS_V2_RULE09
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDSPOS_V2_RULE09" (

/************************************************************************************************
* VER    ID        DATE         ENHANCEMENT                                                     *
* -----  -------   ---------    ----------------------------------------------------------------*
* 2.0    HUYENNT   12SEP2018    TID CO NHIEU GIAO VOI SO TIEN CHAN                              *
*************************************************************************************************/
   p_tid in varchar2,
   p_date in number
) RETURN VARCHAR2
AS
   v_count number;
   v_start_tms number;
   v_end_tms number;
   v_so_lan number := 3;
   v_rule_id varchar2(20):= 'RULE09';
   v_cre_tms number;
   v_cnt number := 0;
begin
   FOR RSROW IN (select * from fds_pos_txn_v2 where tid = p_tid AND ngay_gd = p_date and MOD(so_tien_gd_goc,1000000) = 0 order by NGAY_TAO_GD asc)
   LOOP
     v_end_tms := RSROW.NGAY_TAO_GD;
     v_start_tms := to_number(substr(tms_add_subtract(1/2,v_end_tms),1,14));--lay thoi gian truoc v_end_tms 1h
     select count(1) into v_count--dem so luong giao dich trong 30P
     from fds_pos_txn_v2
     where TID = p_tid
           and MOD(so_tien_gd_goc,1000000) = 0
           and NGAY_TAO_GD >= v_start_tms
           and NGAY_TAO_GD <= v_end_tms;
     IF v_count >= v_so_lan THEN
       select count(1) into v_cnt from fds_pos_case_detail_v2 where ngay_gd = p_date AND case_id = RSROW.MA_GD;
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
            ma_gd = RSROW.MA_GD;
       end if;
       --insert du lieu case hit rule
       INSERT INTO fds_pos_case_hit_rule_v2(case_id, rule_id) VALUES(RSROW.MA_GD,v_rule_id);
       --insert du lieu case hit rule detail
       INSERT INTO fds_pos_casehitruledetail_v2(case_id, rule_id, MA_GD, mid, ten_mid, tid, so_hd, dia_chi_gd,
          ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi,
          so_tien_gd_goc, loai_tien, so_tien_tip, so_bin,
          so_the, loai_the, ket_qua_gd, dao_huy, pos_mde_2digit,
          pos_mode, ma_loi, bao_co, ngay_gd, mcc
       )
       select
          RSROW.MA_GD,v_rule_id,MA_GD, mid, ten_mid, tid, so_hd, dia_chi_gd,
          ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi,
          so_tien_gd_goc, loai_tien, so_tien_tip, so_bin,
          so_the, loai_the, ket_qua_gd, dao_huy, pos_mde_2digit,
          pos_mode, ma_loi, bao_co, ngay_gd, mcc
       from
          fds_pos_txn_v2
       where
          tid = p_tid
          and MOD(so_tien_gd_goc,1000000) = 0
          and NGAY_TAO_GD >= v_start_tms
          and NGAY_TAO_GD <= v_end_tms;
       commit;
     end if;
   END LOOP;
   return 'SUCCESS';
exception
   when others then return 'ERROR';
end;

/
