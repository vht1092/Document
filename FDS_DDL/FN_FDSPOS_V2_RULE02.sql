--------------------------------------------------------
--  DDL for Function FN_FDSPOS_V2_RULE02
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDSPOS_V2_RULE02" (

/************************************************************************************************
* VER    ID        DATE         ENHANCEMENT                                                     *
* -----  -------   ---------    ----------------------------------------------------------------*
* 2.0    HUYENNT   12SEP2018    TID CO GD THE QUOC TE KHONG THUC HIEN QUA CHIP CO SO TIEN LON   *
*************************************************************************************************/
   p_tid in varchar2,
   p_date in number
) RETURN VARCHAR2
AS
   v_so_tien_vnd number := 20000000;--20 trieu VND
   v_so_tien_usd number := 800;--800 USD
   v_rule_id varchar2(20):= 'RULE02';
   v_cre_tms number;
   v_cnt number := 0;
begin
   FOR RSROW IN (select MA_GD from fds_pos_txn_v2
     where tid = p_tid
         AND ngay_gd = p_date
         AND LOAI_THE IN ('JCB','MAST','VISA','AMEX','DCI','CUP')
         AND pos_mde_2digit <> '05'
         AND ((so_tien_gd_goc >= v_so_tien_vnd and loai_tien = 'VND') or (so_tien_gd_goc >= v_so_tien_usd and loai_tien = 'USD'))
     order by
         NGAY_TAO_GD asc
   )
   LOOP
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
        AND ngay_gd = p_date
        AND LOAI_THE IN ('JCB','MAST','VISA','AMEX','DCI','CUP')
        AND pos_mde_2digit <> '05'
        AND ((so_tien_gd_goc >= v_so_tien_vnd and loai_tien = 'VND') or (so_tien_gd_goc >= v_so_tien_usd and loai_tien = 'USD'));
     commit;
     exit;
   END LOOP;
   return 'SUCCESS';
exception
   when others then return 'ERROR';
end;

/
