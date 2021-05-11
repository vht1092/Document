--- UPDATE PPT BY LIST

SELECT a.* FROM FPT.ppt_crd_detail a
INNER JOIN CCPS.TANVH1_PPT b ON A.CIF_NO=B.CIF AND a.CRD_TYPE=b.CARD_TYPE AND a.ISSUE_DATE=b.ISSUE_DATE AND a.CRD_PRIN_SUPP=b.CRD_PRIN_SUPP
ORDER BY A.CIF_NO,a.CRD_TYPE,a.ISSUE_DATE
/
DELETE PPT_EMB_CARD_DETAIL
WHERE PAN IN (
SELECT a.PAN FROM FPT.PPT_EMB_CARD_DETAIL a
INNER JOIN CCPS.TANVH1_PPT b ON A.CIF=B.CIF AND a.CRD_PGM=b.CARD_TYPE AND a.EMB_DT=b.ISSUE_DATE AND a.PRIN_SUPP=b.CRD_PRIN_SUPP
--ORDER BY A.CIF,a.CRD_PGM,a.EMB_DT
)

/--- DSKH Tu choi nhan the ---
SELECT   CIF_NO
         , ID
         , CRD_TYPE loaithe
         , CUST_NAME hoten
         , CRD_PRIN_SUPP chinhphu
         , (select PX_IRPANMAP_PANMASK from ir_pan_map@im where PX_IRPANMAP_PAN = PAN) as sothe
         , ISSUE_TYPE loaiphathanh
         , to_char(to_date(ISSUE_DATE, 'yyyyMMdd'), 'dd/mm/yyyy') as ngayphathanh
         , to_char(to_date(TRANS_BRANCH_REC_DATE, 'yyyyMMdd'),'dd/mm/yyyy') as ngaydonvinhanthe
         , trim(BRCH_CDE) as madonvi
         , NVL(TRIM(FW_BRN_CDE), ' ') AS CHUYENTIEPDONVI 
FROM   fpt.ppt_crd_detail crddetail
WHERE trans_cust_status='02'
AND ISSUE_DATE >= 20200701 and ISSUE_DATE <= 20201231
ORDER BY ISSUE_DATE ASC

/--- Export data PPT ---

select 
    a.cif SO_CIF,
    a.crd_pgm LOAI_THE,
    a.cust_name TEN_CHU_THE,
    a.prin_supp CHINH_PHU,
    a.panmask SO_THE,
    nvl(a.crd_cat,' ') LOAI_PHAT_HANH,
    a.emb_dt NGAY_PHAT_HANH,
    a.brch_cde MA_DON_VI,
    CASE nvl(crddetail.gttn, 0) WHEN 1 THEN 'Y' WHEN 2 THEN 'N' ELSE ' ' END GTTN,
    nvl(saleofficer_code,a.sls_ofc_cde) sale_officer_code,
    -- Chuyen file den MK
--    nvl(crddetail.trans_mk, 0),
    nvl(crddetail.trans_mk_date, '0') CHUYEN_MKS_NGAY_HOAN_THANH,
    nvl(crddetail.fw_brn_cde,' ') CHUYEN_MKS_CHUYEN_TIEP_DV,
    nvl(crddetail.trans_branch_note,' ') CHUYEN_MKS_GHI_CHU,
    nvl(crddetail.trans_mk_lock, 0) CHUYEN_MKS_LOCK,
    nvl(crddetail.trans_mk_ischeck, 0) CHUYEN_MKS_CHECK,
    -- Don vi nhan the
--    nvl(crddetail.trans_branch_rec, 0) ,
    nvl(crddetail.trans_branch_rec_date,'0') DV_NHAN_MKS_NGAY_HOAN_THANH,
    nvl(crddetail.trans_branch_rec_lock, 0) DV_NHAN_MKS_LOCK,
    nvl(crddetail.trans_branch_rec_check, 0) DV_NHAN_MKS_CHECK,
    -- Giao the cho KH
--    nvl(crddetail.trans_cust, 0) ,
    nvl(crddetail.trans_cust_date,'0') GIAO_THE_KH_NGAY_HOAN_THANH,
    nvl(crddetail.trans_cust_lock, 0) GIAO_THE_KH_LOCK,
    CASE trans_cust_status 
        WHEN '00' THEN ' '
        WHEN '01' THEN 'Giao thẻ thành công'
        WHEN '02' THEN 'KH từ chối nhận thẻ'
        WHEN '03' THEN 'KH hẹn đến nhận'
        WHEN '04' THEN 'Không liên lạc được'
        WHEN '05' THEN 'Đã chuyển đối tác chuyển phát thẻ'
        WHEN '06' THEN 'Khác' 
        WHEN '07' THEN 'Thẻ PH sai thông số'  END GIAO_THE_KH_TRANG_THAI,

    trans_cust_note GIAO_THE_KH_GHI_CHU,
    nvl(crddetail.trans_cust_ischeck, 0) GIAO_THE_KH_CHECK,
    CASE WHEN nvl(crddetail.xacnhan_gttn, 0)=1 THEN 'Y' ELSE 'N' END xac_nhan_gttn
  from
    fpt.ppt_emb_card_detail a
    left join fpt.full_branch b on trim(a.brch_cde) = trim(b.branch_code)
    left join fpt.ppt_crd_detail crddetail on a.cif = crddetail.cif_no and a.prin_supp = crddetail.crd_prin_supp and a.pan = crddetail.pan and a.crd_cat = crddetail.issue_type and crddetail.issue_date = a.emb_dt
--  where
--    (a.emb_dt between P_FROM_DT and P_TO_DT or P_FROM_DT is null or P_TO_DT is null)
--    and a.crd_pgm in (select PX_IR121_CRD_PGM from fpt.ppt_crd_pgm where PX_IR121_CRD_PGM like P_CRD_BRN||'%')
--    and ((a.cif = P_CIF AND P_KEY = 1) or (a.cust_name = P_CIF AND P_KEY = 0) or (a.loc = P_CIF AND P_KEY = 2) or P_CIF is null)
--    and (a.brch_cde in (select trim(t.branch_code) from fpt.ppt_sys_usr_branch t where t.username = P_USERNAME) or crddetail.fw_brn_cde in (select trim(t.branch_code) from fpt.ppt_sys_usr_branch t where t.username = P_USERNAME))
--    and (a.brch_cde in (SELECT trim(BRANCH_CODE) FROM fpt.FULL_BRANCH WHERE PARENT_BRANCH = rpad(trim(P_BRCH_CDE),5,' ')) or P_BRCH_CDE is null or crddetail.fw_brn_cde in (SELECT trim(BRANCH_CODE) FROM fpt.FULL_BRANCH WHERE PARENT_BRANCH = rpad(trim(P_BRCH_CDE),5,' ')))
--    and (a.brch_cde = P_MA_PGD or P_MA_PGD is null or crddetail.fw_brn_cde = P_MA_PGD)
--    and ((NVL(crddetail.trans_mk_ischeck,0) = V_TRANS_MK_APV_STAT and TRANS_MK_LOCK = 1) OR V_TRANS_MK_APV_STAT IS NULL)
--    AND ((NVL(crddetail.TRANS_BRANCH_REC_CHECK,0) = V_REC_MK_APV_STAT and TRANS_BRANCH_REC_LOCK = 1) OR V_REC_MK_APV_STAT IS NULL)
--    AND ((NVL(crddetail.trans_cust_ischeck,0) = V_TRANS_CUST_APV_STAT and TRANS_CUST_LOCK = 1) OR V_TRANS_CUST_APV_STAT IS NULL)
--    AND ((NVL(crddetail.xacnhan_gttn,0) = V_CHUAXACNHAN_GTTN and GTTN in('1', '2')) OR V_CHUAXACNHAN_GTTN IS NULL)
--    AND (crddetail.deliv_by_brch = V_GTTN or V_GTTN is null);
WHERE a.emb_dt between 20191223 and 20201231
ORDER BY a.emb_dt DESC
/
