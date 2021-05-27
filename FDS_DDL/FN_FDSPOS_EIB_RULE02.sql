--------------------------------------------------------
--  DDL for Function FN_FDSPOS_EIB_RULE02
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "CCPS"."FN_FDSPOS_EIB_RULE02" (

/************************************************************************************************
* VER    ID        DATE         ENHANCEMENT                                                     *
* -----  -------   ---------    ----------------------------------------------------------------*
* 1.0    TANVH1    16JUL2020    MID phát sinh giao dịch thẻ quốc tế không thực hiện qua chip ≥ 20 triệu đồng/giao dịch HOẶC ngoại tệ  ≥ 800 USD/GD (áp dụng cho ĐVNCT được phép giao dịch bằng ngoại tệ)    *
*************************************************************************************************/
   p_mid in varchar2,
   p_date in number
) RETURN VARCHAR2
AS
   v_count number;
   v_so_lan number := 1;
   v_rule_id varchar2(20):= 'RULE02';
   v_cre_tms number;
   v_cnt number := 0;
   V_CASE_NO varchar2(15);
begin
   select count(1) into v_count --DEM SO LUONG GIAO DICH
   from fds_pos_txn_v2
   where MID = p_mid     
     AND ngay_gd = p_date
     AND SO_THE NOT LIKE '9%'
     AND pos_mde_2digit <> '05'
     AND ((SO_TIEN_GD_GOC>=20000000 AND LOAI_TIEN='VND') OR (SO_TIEN_GD_GOC>=800 AND LOAI_TIEN='USD'));

   IF v_count >= v_so_lan THEN
     SELECT TO_CHAR(SYSDATE,'yyyymmdd') || '-' || TRIM(TO_CHAR(SEQNO_FDS_POS_TXN_V2.nextval,'000000')) INTO V_CASE_NO FROM dual;
     select count(1) into v_cnt from fds_pos_case_detail_v2 where ngay_gd = p_date AND case_id = V_CASE_NO;
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
          v_cre_tms, v_cre_tms, V_CASE_NO, 0, 'NEW', 'Y', 0, 'SYSTEM', mid, ten_mid, tid, so_hd, dia_chi_gd,
          ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi, so_tien_gd_goc,
          loai_tien, so_tien_tip, so_bin, so_the, loai_the, ket_qua_gd,
          dao_huy, pos_mde_2digit, pos_mode, ma_loi, bao_co, ngay_gd, mcc
        from
          fds_pos_txn_v2
        where rownum=1;
     end if;
     --insert du lieu case hit rule
     INSERT INTO fds_pos_case_hit_rule_v2(case_id, rule_id) VALUES(V_CASE_NO,v_rule_id);
     --insert du lieu case hit rule detail
     INSERT INTO fds_pos_casehitruledetail_v2(case_id, rule_id, MA_GD, mid, ten_mid, tid, so_hd, dia_chi_gd,
        ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi,
        so_tien_gd_goc, loai_tien, so_tien_tip, so_bin,
        so_the, loai_the, ket_qua_gd, dao_huy, pos_mde_2digit,
        pos_mode, ma_loi, bao_co, ngay_gd, mcc
     )
     select
        V_CASE_NO,v_rule_id,MA_GD, mid, ten_mid, tid, so_hd, dia_chi_gd,
        ngay_tao_gd, ngay_gio_gd, so_hoa_don, ma_chuan_chi,
        so_tien_gd_goc, loai_tien, so_tien_tip, so_bin,
        so_the, loai_the, ket_qua_gd, dao_huy, pos_mde_2digit,
        pos_mode, ma_loi, bao_co, ngay_gd, mcc
     from
        fds_pos_txn_v2
     where MID = p_mid     
      AND ngay_gd = p_date
      AND SO_THE NOT LIKE '9%'
      AND pos_mde_2digit <> '05'
      AND ((SO_TIEN_GD_GOC>=20000000 AND LOAI_TIEN='VND') OR (SO_TIEN_GD_GOC>=800 AND LOAI_TIEN='USD'));
     commit;
   end if;
   return 'SUCCESS';
exception
   when others then return 'ERROR';
end;

/
