--------------------------------------------------------
--  DDL for Procedure SP_FDS_SYN_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "CCPS"."SP_FDS_SYN_DATA" 
/*********************************************************************************
* VER    ID        DATE         ENHANCEMENT                                      *
* -----  -------   ---------    -------------------------------------------------*
* 1.0    HUYENNT   20SEP2016    INSERT DATA FROM OA008, OA150 SANG fds_txn_detail*
**********************************************************************************/
(
    sql_str OUT varchar2
)
AS
    v_max_upd_fds NUMBER;
    v_max_upd_oa008 NUMBER;
    v_max_upd_oa150 NUMBER;
    v_start_check_tms NUMBER;
    v_end_check_tms NUMBER;
    --BIEN DUNG GHI LOG--
    V_PROD VARCHAR(255):= 'SP_FDS_SYN_DATA';
    L_CHECK_POINT NUMBER:=1;
    V_TXDATE NUMBER:=TO_CHAR(SYSDATE,'YYYYMMDD');
    V_BEGTIME NUMBER:=TO_CHAR(SYSDATE,'hh24missss');
    V_ENDTIME NUMBER:=0;
    V_STS VARCHAR(10):= 'START';-- START / DONE / ERROR
    V_STSDESC VARCHAR2(4000):=' ';
BEGIN
    --GHI LOG START SP-------------------------------
    --INSERT INTO FDS_LOG VALUES(V_PROD,V_TXDATE,V_BEGTIME,V_ENDTIME,V_STS,V_STSDESC);
    --COMMIT;
    -------------------------------------------------
    SELECT nvl(max(f9_oa008_cre_tms),TO_CHAR(SYSDATE,'YYYYMMDD')||'000000000') INTO v_max_upd_fds FROM fds_txn_detail where f9_oa008_dt = TO_CHAR(SYSDATE,'YYYYMMDD');
    --v_max_upd_fds := 20170731103540369;
    SELECT nvl(max(f9_oa008_cre_tms),TO_CHAR(SYSDATE,'YYYYMMDD')||'000000000') INTO v_max_upd_oa008 FROM oa008@am where f9_oa008_dt = TO_CHAR(SYSDATE,'YYYYMMDD');
    SELECT nvl(max(F9_OA150_CRE_TMS),TO_CHAR(SYSDATE,'YYYYMMDD')||'000000000') INTO v_max_upd_oa150 FROM oa150@am where F9_OA150_DT = TO_CHAR(SYSDATE,'YYYYMMDD');
    -----------------END: OA150 DATA SYN------------------------------------
    L_CHECK_POINT := 2;
    INSERT INTO fds_txn_detail (
           f9_oa008_cre_tms, fx_oa008_upd_uid, f9_oa008_upd_tms,
           px_oa008_pan, p9_oa008_seq, fx_oa008_cb_acct_num,
           f9_oa008_prin_crn, f9_oa008_dt, f9_oa008_tm,
           f9_oa008_req_dt, fx_oa008_mid, fx_oa008_apv_cde,
           fx_oa008_stat, fx_oa008_txn_typ, fx_oa008_ref_cde,
           f9_oa008_amt_req, f9_oa008_req_tm, f9_oa008_rpy_tm,
           fx_oa008_ofc_cde, fx_oa008_upd_flg, fx_oa008_pos,
           fx_oa008_cat_model, fx_oa008_swi_mnl, fx_oa008_tm_out,
           fx_oa008_pos_ln, fx_oa008_pos_mode, fx_oa008_pos_cond_cde,
           f9_oa008_pos_auth_lc, f9_oa008_pos_crncy_cde,
           fx_oa008_pos_zip, fx_oa008_given_resp_cde,
           fx_oa008_given_apv_cde, f9_oa008_gmt_trc, f9_oa008_stan,
           f9_oa008_usd_amt, f9_oa008_mcc, fx_oa008_cntry_cde,
           fx_oa008_ofc_apv, fx_oa008_deliv_flg, f9_oa008_crd_rev_dt,
           f9_oa008_chrg_amt, fx_oa008_chrg_slp_ind,
           f9_oa008_expi_dt_rcv, fx_oa008_cust_txn_cde_rcv,
           fx_oa008_loc_stat, fx_oa008_cr_stat, fx_oa008_prd_typ,
           f9_oa008_num_instl, fx_oa008_merc_name,
           fx_oa008_merc_filler1, fx_oa008_merc_cty,
           fx_oa008_merc_filler2, fx_oa008_merc_st_cntry,
           f9_oa008_adnl_dat_lgth, fx_oa008_txn_categ_cde,
           fx_oa008_sub_elem, fx_oa008_bnet_fi_cd,
           fx_oa008_bnet_ref_num, f9_oa008_acq_ica, f9_oa008_iss_ica,
           f9_oa008_crncy_cde, fx_oa008_crd_brn, f9_oa008_acct_num,
           fx_oa008_crd_prd, fx_oa008_crd_pgm, fx_oa008_used_pan,
           fx_oa008_magprn_ind, f9_oa008_magprn_scr,
           fx_oa008_cvv_rslt_cde, fx_oa008_tid, f9_oa008_serv_cde,
           fx_oa008_contc_less_flg, fx_oa008_fbck_flg,
           f9_oa008_pos_cde, f9_oa008_ori_amt, f9_oa008_rev_amt,
           f9_oa008_acc_fee_lcl_crncy, fx_oa008_ori_mid,
           f9_oa008_load_fee, f9_oa008_de012_lcl_tm,
           f9_oa008_de013_lcl_md, f9_oa008_de03_pro_cde,
           fx_oa008_de102_acct_id1, fx_oa008_de103_acct_id2,
           f9_oa008_surchrg_fee, f9_oa008_surchrg_vat_fee,
           fx_oa008_rte_dest, f9_oa008_txn_serial_num,
           fx_oa008_stnd_in_ind, fx_oa008_intrl_ref_num,
           fx_oa008_trsfr_acct_no, fx_oa008_invoice_no,
           f9_oa008_iss_surchrg_fee, f9_oa008_iss_surchrg_vat_fee,
           fx_oa008_de102_pan, fx_oa008_de103_pan, fx_oa008_mti,
           fx_oa008_serv_prov, f9_oa008_disc_amt, f9_oa008_adv_reas,
           f9_oa008_de62_txn_id, fx_oa008_de048_63_trc_id,
           fx_oa008_de063_nw_dat, f9_oa008_csh_bk,
           f9_oa008_in_de48_lgth, fx_oa008_in_de48_txn_categ_cde,
           fx_oa008_in_de48_sub_elem, f9_oa008_amt_slp_hold,
           f9_oa008_eci_sec_lvl, f9_oa008_mult_clr_seq_num,
           f9_oa008_mult_clr_seq_cnt, fx_oa008_ws_ref_no,FX_CHKS_STAT
        )
        SELECT f9_oa008_cre_tms, fx_oa008_upd_uid, f9_oa008_upd_tms,
           px_oa008_pan, p9_oa008_seq, fx_oa008_cb_acct_num,
           f9_oa008_prin_crn, f9_oa008_dt, f9_oa008_tm,
           f9_oa008_req_dt, fx_oa008_mid, fx_oa008_apv_cde,
           fx_oa008_stat, fx_oa008_txn_typ, fx_oa008_ref_cde,
           f9_oa008_amt_req, f9_oa008_req_tm, f9_oa008_rpy_tm,
           fx_oa008_ofc_cde, fx_oa008_upd_flg, fx_oa008_pos,
           fx_oa008_cat_model, fx_oa008_swi_mnl, fx_oa008_tm_out,
           fx_oa008_pos_ln, fx_oa008_pos_mode, fx_oa008_pos_cond_cde,
           f9_oa008_pos_auth_lc, f9_oa008_pos_crncy_cde,
           fx_oa008_pos_zip, fx_oa008_given_resp_cde,
           fx_oa008_given_apv_cde, f9_oa008_gmt_trc, f9_oa008_stan,
           f9_oa008_usd_amt, f9_oa008_mcc, fx_oa008_cntry_cde,
           fx_oa008_ofc_apv, fx_oa008_deliv_flg, f9_oa008_crd_rev_dt,
           f9_oa008_chrg_amt, fx_oa008_chrg_slp_ind,
           f9_oa008_expi_dt_rcv, fx_oa008_cust_txn_cde_rcv,
           fx_oa008_loc_stat, fx_oa008_cr_stat, fx_oa008_prd_typ,
           f9_oa008_num_instl, fx_oa008_merc_name,
           fx_oa008_merc_filler1, fx_oa008_merc_cty,
           fx_oa008_merc_filler2, fx_oa008_merc_st_cntry,
           f9_oa008_adnl_dat_lgth, fx_oa008_txn_categ_cde,
           fx_oa008_sub_elem, fx_oa008_bnet_fi_cd,
           fx_oa008_bnet_ref_num, f9_oa008_acq_ica, f9_oa008_iss_ica,
           f9_oa008_crncy_cde, fx_oa008_crd_brn, f9_oa008_acct_num,
           fx_oa008_crd_prd, fx_oa008_crd_pgm, fx_oa008_used_pan,
           fx_oa008_magprn_ind, f9_oa008_magprn_scr,
           fx_oa008_cvv_rslt_cde, fx_oa008_tid, f9_oa008_serv_cde,
           fx_oa008_contc_less_flg, fx_oa008_fbck_flg,
           f9_oa008_pos_cde, f9_oa008_ori_amt, f9_oa008_rev_amt,
           f9_oa008_acc_fee_lcl_crncy, fx_oa008_ori_mid,
           f9_oa008_load_fee, f9_oa008_de012_lcl_tm,
           f9_oa008_de013_lcl_md, f9_oa008_de03_pro_cde,
           fx_oa008_de102_acct_id1, fx_oa008_de103_acct_id2,
           f9_oa008_surchrg_fee, f9_oa008_surchrg_vat_fee,
           fx_oa008_rte_dest, f9_oa008_txn_serial_num,
           fx_oa008_stnd_in_ind, fx_oa008_intrl_ref_num,
           fx_oa008_trsfr_acct_no, fx_oa008_invoice_no,
           f9_oa008_iss_surchrg_fee, f9_oa008_iss_surchrg_vat_fee,
           fx_oa008_de102_pan, fx_oa008_de103_pan, fx_oa008_mti,
           fx_oa008_serv_prov, f9_oa008_disc_amt, f9_oa008_adv_reas,
           f9_oa008_de62_txn_id, fx_oa008_de048_63_trc_id,
           fx_oa008_de063_nw_dat, f9_oa008_csh_bk,
           f9_oa008_in_de48_lgth, fx_oa008_in_de48_txn_categ_cde,
           fx_oa008_in_de48_sub_elem, f9_oa008_amt_slp_hold,
           f9_oa008_eci_sec_lvl, f9_oa008_mult_clr_seq_num,
           f9_oa008_mult_clr_seq_cnt, fx_oa008_ws_ref_no,' '
       FROM
           oa008@am where fx_oa008_crd_brn <> 'LC' and fx_oa008_txn_typ <> 'AV' and fx_oa008_txn_typ <> 'BE' AND fx_oa008_merc_name <> 'DDWEB EASYCASH        ' AND f9_oa008_cre_tms > v_max_upd_fds AND f9_oa008_cre_tms <= v_max_upd_oa008;--bo gd be kem theo gd pm 20161226
       ----------------END: OA008 DATA SYN--------------------------------------
       commit;
       ----------------START: OA150 DATA SYN------------------------------------
       L_CHECK_POINT := 3;
       INSERT INTO fds_txn_detail (
           f9_oa008_cre_tms, fx_oa008_upd_uid, f9_oa008_upd_tms,
           px_oa008_pan, p9_oa008_seq, fx_oa008_cb_acct_num,
           f9_oa008_prin_crn, f9_oa008_dt, f9_oa008_tm,
           f9_oa008_req_dt, fx_oa008_mid, fx_oa008_apv_cde,
           fx_oa008_stat, fx_oa008_txn_typ, fx_oa008_ref_cde,
           f9_oa008_amt_req, f9_oa008_req_tm, f9_oa008_rpy_tm,
           fx_oa008_ofc_cde, fx_oa008_upd_flg, fx_oa008_pos,
           fx_oa008_cat_model, fx_oa008_swi_mnl, fx_oa008_tm_out,
           fx_oa008_pos_ln, fx_oa008_pos_mode, fx_oa008_pos_cond_cde,
           f9_oa008_pos_auth_lc, f9_oa008_pos_crncy_cde,
           fx_oa008_pos_zip, fx_oa008_given_resp_cde,
           fx_oa008_given_apv_cde, f9_oa008_gmt_trc, f9_oa008_stan,
           f9_oa008_usd_amt, f9_oa008_mcc, fx_oa008_cntry_cde,
           fx_oa008_ofc_apv, fx_oa008_deliv_flg, f9_oa008_crd_rev_dt,
           f9_oa008_chrg_amt, fx_oa008_chrg_slp_ind,
           f9_oa008_expi_dt_rcv, fx_oa008_cust_txn_cde_rcv,
           fx_oa008_loc_stat, fx_oa008_cr_stat, fx_oa008_prd_typ,
           f9_oa008_num_instl, fx_oa008_merc_name,
           fx_oa008_merc_filler1, fx_oa008_merc_cty,
           fx_oa008_merc_filler2, fx_oa008_merc_st_cntry,
           f9_oa008_adnl_dat_lgth, fx_oa008_txn_categ_cde,
           fx_oa008_sub_elem, fx_oa008_bnet_fi_cd,
           fx_oa008_bnet_ref_num, f9_oa008_acq_ica, f9_oa008_iss_ica,
           f9_oa008_crncy_cde, fx_oa008_crd_brn, f9_oa008_acct_num,
           fx_oa008_crd_prd, fx_oa008_crd_pgm, fx_oa008_used_pan,
           fx_oa008_magprn_ind, f9_oa008_magprn_scr,
           fx_oa008_cvv_rslt_cde, fx_oa008_tid, f9_oa008_serv_cde,
           fx_oa008_contc_less_flg, fx_oa008_fbck_flg,
           f9_oa008_pos_cde, f9_oa008_ori_amt, f9_oa008_rev_amt,
           f9_oa008_acc_fee_lcl_crncy, fx_oa008_ori_mid,
           f9_oa008_load_fee, f9_oa008_de012_lcl_tm,
           f9_oa008_de013_lcl_md, f9_oa008_de03_pro_cde,
           fx_oa008_de102_acct_id1, fx_oa008_de103_acct_id2,
           f9_oa008_surchrg_fee, f9_oa008_surchrg_vat_fee,
           fx_oa008_rte_dest, f9_oa008_txn_serial_num,
           fx_oa008_stnd_in_ind, fx_oa008_intrl_ref_num,
           fx_oa008_trsfr_acct_no, fx_oa008_invoice_no,
           f9_oa008_iss_surchrg_fee, f9_oa008_iss_surchrg_vat_fee,
           fx_oa008_de102_pan, fx_oa008_de103_pan, fx_oa008_mti,
           fx_oa008_serv_prov, f9_oa008_disc_amt, f9_oa008_adv_reas,
           f9_oa008_de62_txn_id, fx_oa008_de048_63_trc_id,
           fx_oa008_de063_nw_dat, f9_oa008_csh_bk,
           f9_oa008_in_de48_lgth, fx_oa008_in_de48_txn_categ_cde,
           fx_oa008_in_de48_sub_elem, f9_oa008_amt_slp_hold,
           f9_oa008_eci_sec_lvl, f9_oa008_mult_clr_seq_num,
           f9_oa008_mult_clr_seq_cnt, fx_oa008_ws_ref_no,FX_CHKS_STAT
        )
        SELECT F9_OA150_CRE_TMS, FX_OA150_UPD_UID, F9_OA150_UPD_TMS,
           PX_OA150_PAN, P9_OA150_SEQ, FX_OA150_CB_ACCT_NUM,
           F9_OA150_PRIN_CRN, F9_OA150_DT, F9_OA150_TM,
           F9_OA150_REQ_DT, FX_OA150_MID, FX_OA150_APV_CDE,
           FX_OA150_STAT, FX_OA150_TXN_TYP, FX_OA150_REF_CDE,
           F9_OA150_AMT_REQ, F9_OA150_REQ_TM, F9_OA150_RPY_TM,
           FX_OA150_OFC_CDE, FX_OA150_UPD_FLG, FX_OA150_POS,
           FX_OA150_CAT_MODEL, FX_OA150_SWI_MNL, FX_OA150_TM_OUT,
           FX_OA150_POS_LN, FX_OA150_POS_MODE, FX_OA150_POS_COND_CDE,
           F9_OA150_POS_AUTH_LC, F9_OA150_POS_CRNCY_CDE,
           FX_OA150_POS_ZIP, FX_OA150_GIVEN_RESP_CDE,
           FX_OA150_GIVEN_APV_CDE, F9_OA150_GMT_TRC, F9_OA150_STAN,
           F9_OA150_USD_AMT, F9_OA150_MCC, FX_OA150_CNTRY_CDE,
           FX_OA150_OFC_APV, FX_OA150_DELIV_FLG, F9_OA150_CRD_REV_DT,
           F9_OA150_CHRG_AMT, FX_OA150_CHRG_SLP_IND,
           F9_OA150_EXPI_DT_RCV, FX_OA150_CUST_TXN_CDE_RCV,
           FX_OA150_LOC_STAT, FX_OA150_CR_STAT, FX_OA150_PRD_TYP,
           F9_OA150_NUM_INSTL, FX_OA150_MERC_NAME,
           FX_OA150_MERC_FILLER1, FX_OA150_MERC_CTY,
           FX_OA150_MERC_FILLER2, FX_OA150_MERC_ST_CNTRY,
           F9_OA150_ADNL_DAT_LGTH, FX_OA150_TXN_CATEG_CDE,
           FX_OA150_SUB_ELEM, FX_OA150_BNET_FI_CD,
           FX_OA150_BNET_REF_NUM, F9_OA150_ACQ_ICA, F9_OA150_ISS_ICA,
           F9_OA150_CRNCY_CDE, FX_OA150_CRD_BRN, F9_OA150_ACCT_NUM,
           FX_OA150_CRD_PRD, FX_OA150_CRD_PGM, FX_OA150_USED_PAN,
           FX_OA150_MAGPRN_IND, F9_OA150_MAGPRN_SCR,
           FX_OA150_CVV_RSLT_CDE, FX_OA150_TID, F9_OA150_SERV_CDE,
           FX_OA150_CONTC_LESS_FLG, FX_OA150_FBCK_FLG,
           F9_OA150_POS_CDE, F9_OA150_ORI_AMT, F9_OA150_REV_AMT,
           0, FX_OA150_ORI_MID,F9_OA150_LOAD_FEE+F9_OA150_LOAD_VAT_FEE+f9_oa150_markup_fee+f9_oa150_markup_vat_fee,
           F9_OA150_DE012_LCL_TM,F9_OA150_DE013_LCL_MD, F9_OA150_DE03_PRO_CDE,
           ' ',' ',F9_OA150_SURCHRG_FEE, F9_OA150_SURCHRG_VAT_FEE,
           FX_OA150_RTE_DEST, F9_OA150_TXN_SERIAL_NUM,
           FX_OA150_STND_IN_IND, FX_OA150_INTRL_REF_NUM,
           FX_OA150_TRSFR_ACCT_NO, FX_OA150_INVOICE_NO,
           0,0,FX_OA150_DE102_PAN, FX_OA150_DE103_PAN, FX_OA150_MTI,
           FX_OA150_SERV_PROV, F9_OA150_DISC_AMT, F9_OA150_ADV_REAS,
           F9_OA150_DE62_TXN_ID,' ',' ', 0,F9_OA150_IN_DE48_LGTH, FX_OA150_IN_DE48_TXN_CATEG_CDE,
           FX_OA150_IN_DE48_SUB_ELEM, F9_OA150_AMT_SLP_HOLD,
           0, 0,0,' ',' '
       FROM
           OA150@AM
       WHERE
           fx_oa150_crd_brn in ('MC','VS') AND fx_oa150_txn_typ NOT IN ('AV') AND F9_OA150_CRE_TMS > v_max_upd_fds AND F9_OA150_CRE_TMS <= v_max_upd_oa150;
       ------------------END: OA150 DATA SYN------------------------------------
       COMMIT;
       V_STS := 'DONE'; -- START / DONE / ERROR
       V_ENDTIME := TO_CHAR(SYSDATE,'hh24missss');
       V_STSDESC := 'END At:'||L_CHECK_POINT;
       --UPDATE FDS_LOG SET END_TIME = V_ENDTIME, STATUS = V_STS, STSDESC = V_STSDESC WHERE PROC_NAME = V_PROD AND TXDATE = V_TXDATE AND BEGIN_TIME = V_BEGTIME;
       --COMMIT;
       sql_str := 'DONE';
       --cap nhat data co phat sinh cap nhat tu live
       sp_fds_update_data(sql_str);
       --SYN DU LIEU GIAO DICH SAMSUNG PAY
       insert into ccps.dw_ssp_txn(fx_ssptxn_cre_tms,
                                    fx_ssptxn_upd_uid,
                                    fx_ssptxn_upd_tms,
                                    fx_ssptxn_pan,
                                    f9_ssptxn_seq,
                                    f9_ssptxn_dttm,
                                    f9_ssptxn_stan,
                                    f9_ssptxn_exp_dt,
                                    f9_ssptxn_fwd_ica,
                                    fx_ssptxn_rrn,
                                    fx_ssptxn_resp_cde,
                                    f9_ssptxn_txn_id,
                                    f9_ssptxn_net_id,
                                    f9_ssptxn_msg_reas,
                                    f9_ssptxn_swt_reas,
                                    f9_ssptxn_net_code,
                                    fx_ssptxn_file_name,
                                    fx_ssptxn_add_trc_dat,
                                    fx_ssptxn_aam_vlcty_chk_rslt,
                                    fx_ssptxn_token,
                                    fx_ssptxn_tok_assurance_lvl,
                                    f9_ssptxn_tok_requestor_id,
                                    fx_ssptxn_tok_ref_id,
                                    f9_ssptxn_tok_expi_dt,
                                    fx_ssptxn_tok_typ,
                                    fx_ssptxn_tok_stat,
                                    fx_ssptxn_pan_ref_id,
                                    f9_ssptxn_elapsed_tm_to_live,
                                    f9_ssptxn_no_txn_cnt,
                                    f9_ssptxn_sum_txn_amt_usd,
                                    f9_ssptxn_actv_ver_res,
                                    fx_ssptxn_device_typ,
                                    fx_ssptxn_device_id,
                                    f9_ssptxn_device_no,
                                    fx_ssptxn_device_loc,
                                    fx_ssptxn_pan_src,
                                    fx_ssptxn_wlt_acct_id,
                                    fx_ssptxn_wlt_acct_email,
                                    fx_ssptxn_term_cond_ver,
                                    fx_ssptxn_term_cond_dttm)
        select fx_oa303_cre_tms,
                    fx_oa303_upd_uid,
                    fx_oa303_upd_tms,
                    fx_oa303_pan,
                    f9_oa303_seq,
                    f9_oa303_dttm,
                    f9_oa303_stan,
                    f9_oa303_exp_dt,
                    f9_oa303_fwd_ica,
                    fx_oa303_rrn,
                    fx_oa303_resp_cde,
                    f9_oa303_txn_id,
                    f9_oa303_net_id,
                    f9_oa303_msg_reas,
                    f9_oa303_swt_reas,
                    f9_oa303_net_code,
                    fx_oa303_file_name,
                    fx_oa303_add_trc_dat,
                    fx_oa303_aam_vlcty_chk_rslt,
                    fx_oa303_token,
                    fx_oa303_tok_assurance_lvl,
                    f9_oa303_tok_requestor_id,
                    fx_oa303_tok_ref_id,
                    f9_oa303_tok_expi_dt,
                    fx_oa303_tok_typ,
                    fx_oa303_tok_stat,
                    fx_oa303_pan_ref_id,
                    f9_oa303_elapsed_tm_to_live,
                    f9_oa303_no_txn_cnt,
                    f9_oa303_sum_txn_amt_usd,
                    f9_oa303_actv_ver_res,
                    fx_oa303_device_typ,
                    fx_oa303_device_id,
                    f9_oa303_device_no,
                    fx_oa303_device_loc,
                    fx_oa303_pan_src,
                    fx_oa303_wlt_acct_id,
                    fx_oa303_wlt_acct_email,
                    fx_oa303_term_cond_ver,
                    fx_oa303_term_cond_dttm from ccps.oa303@am where fx_oa303_cre_tms > NVL((select max(FX_SSPTXN_CRE_TMS) from DW_SSP_TXN where FX_SSPTXN_CRE_TMS > to_number(to_char(sysdate-1,'yyyymmdd')||'000000000')),to_number(to_char(sysdate-1,'yyyymmdd')||'000000000'));
        commit; 
    EXCEPTION
        WHEN OTHERS THEN
             ROLLBACK;
             V_STS := 'ERROR'; -- START / DONE / ERROR
             V_ENDTIME := TO_CHAR(SYSDATE,'hh24missss');
             V_STSDESC := SQLERRM||' At:'||L_CHECK_POINT;
             --DBMS_OUTPUT.PUT_LINE('Loi:'||V_STSDESC);
             --UPDATE FDS_LOG SET END_TIME = V_ENDTIME, STATUS = V_STS, STSDESC = V_STSDESC WHERE PROC_NAME = V_PROD AND TXDATE = V_TXDATE AND BEGIN_TIME = V_BEGTIME;
             --COMMIT;
            sql_str:= 'FAILED'||V_STSDESC;
END;

/
