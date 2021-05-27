--------------------------------------------------------
--  DDL for Function FN_FDSPOS_V3_RULE07
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDSPOS_V3_RULE07" (

/************************************************************************************************
* VER    ID        DATE         ENHANCEMENT                                                     *
* -----  -------   ---------    ----------------------------------------------------------------*
* 2.0    HUYENNT   12SEP2018    TID CO 2 GD CUNG SO THE TRONG THOI GIAN NGAN                    *
*************************************************************************************************/
   p_tid in varchar2,
   p_date in number
) RETURN VARCHAR2
AS
   v_count number;
   v_amt_vnd number;
   v_amt_usd number;
   v_start_tms number;
   v_end_tms number;
   v_so_tien_vnd number := 10000000;
   v_so_tien_usd number := 450;
   v_so_lan number := 2;
   v_rule_id varchar2(20):= 'RULE07';
   v_cre_tms number;
   v_cnt number := 0;
begin
   FOR RSROW IN (select * from fds_pos_txn_v3 where tid = p_tid AND ngay_gd = p_date order by NGAY_TAO_GD asc)
   LOOP
     v_end_tms := RSROW.NGAY_TAO_GD;
     v_start_tms := to_number(substr(tms_add_subtract(1/6,v_end_tms),1,14));--lay thoi gian truoc v_end_tms 1h
     select count(1), SUM(decode(loai_tien,'VND',so_tien_gd_goc,0)),sum(decode(loai_tien,'USD',so_tien_gd_goc,0)) into v_count, v_amt_vnd, v_amt_usd--dem so luong giao dich trong 10P
     from fds_pos_txn_v3
     where TID = p_tid
           AND so_the = RSROW.SO_THE
           and NGAY_TAO_GD >= v_start_tms
           and NGAY_TAO_GD <= v_end_tms;
     IF v_count >= v_so_lan and (v_amt_vnd >= v_so_tien_vnd or v_amt_usd >= v_so_tien_usd ) THEN
       select count(1) into v_cnt from fds_pos_case_detail_v3 where ngay_gd = p_date AND case_id = RSROW.MA_GD;
       if v_cnt = 0 then
          SELECT TO_CHAR(SYSDATE,'yyyymmddhh24misssss') INTO v_cre_tms FROM dual;
          --insert du lieu case detail
          INSERT INTO fds_pos_case_detail_v3(cre_tms, upd_tms, case_id, check_dt, case_status, check_new,
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
            fds_pos_txn_v3
          where
            ma_gd = RSROW.MA_GD;
       end if;
       --insert du lieu case hit rule
       INSERT INTO fds_pos_case_hit_rule_v3(case_id, rule_id) VALUES(RSROW.MA_GD,v_rule_id);
       --insert du lieu case hit rule detail
       INSERT INTO fds_pos_casehitruledetail_v3(case_id, rule_id, MA_GD, mid, ten_mid, tid, so_hd, dia_chi_gd,
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
          fds_pos_txn_v3
       where
          tid = p_tid
          AND so_the = RSROW.SO_THE
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
