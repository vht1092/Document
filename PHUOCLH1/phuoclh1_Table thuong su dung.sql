----------------Thong tin Database-----------------
il023 -- xem thong tin cap nhat lai KH
il062 -- xem thong tin cap nhat lai KH
ir056 -- xem thong tin khach hang
irc02 -- xem thong tin Sao Kê
select * from irc02 
where f9_irc_loc_acct = 800000478709 --and f9_irc_stmt_mth = 201604
order by f9_irc_stmt_mth DESC

select * from oa001; --Total Exposure Enquiry thông tin du no hien tai
select * from ccps.oa150; --giao dich scb the noi dia 3 thang gan nhat
select * from ccps.oa126; -- check gd 3DS
select * from ccps.oa008; -- thong tin the quoc te SCB giao dich tren ATM(trong 1 thang). VD: hom nay 11/11 thi se luu tu 12/10 den 11/11
select * from ccps.ib006@im; -- 1 thang truoc do tro ve sau cho giao dich the tin dung quoc te SCB, link voi IB007 lay TID
select * from ccps.ib009@im; -- 3 thang truoc do tro ve sau cho giao dich the noi dia SCB
select * from ccps.ib007@im; -- TID cua cua the quoc te qua khu
select * from ccps.oa303; --giao dich samsung pay link voi bang oa008 bang SEQ_NO va so PAN
select * from ccps.oa006; -- The lien minh tren POS cua minh
select * from ccps.ib003@im; --Qua khu cua the lien minh tren POS SCB link TID voi oa037
select * from ccps.oa163; --TXN details for NOT-US ATM cards (bang giao dich off-us) (the lien minh tren may SCB about 6 months)
select * from ccps.ib010@im; -- bang giao dich qua khu cua the lien minh tren ATM SCB cach hien tai 6 thang
dw005 -  Bang the chinh(DW - thẻ đóng, thẻ cancel từ đời nào đều có)
dw006 -  Bang the phu(DW)
dw008 -  Bang giao dich the local
il006 - The chinh qua khu, xem lich su kich hoat
il121 - The phu qua khu
IR124 - Lay giao dich tai Ha Noi, TP.HCM
IR025(ko chứa thẻ đã đóng), IR056-- Cap nhat full name, first name, last name
ir121 -- Thong tin Cardtype Maintenance
oa160 -- Cash Withdrawal Maintenance
oa194 -- Transaction Fee Maintenace (ISS)
oa173 -- Transaction Fee Maintenace (ACQ)
ir150 -- Financial Maintenance
oa158 -- Transaction Parameter
oa001 -- Xem han muc con lai the MC
IR134 -- Thong tin so the, loc, cif, scheme…--thong tin tai chinh the tin dung
IR166 -- Thong tin loai khach hang
IR275 -- Thong tin supp Card Master Credit full
IR338 -- Bang chua diem thuong
OA006 -- Giao dich cua the sml tren scb pos 
OA035 -- Thong tin merchant
OA051 -- Bang thong tin the chinh
OA059 -- Bang thong tin the phu
OA037 -- Bang  thong tin POS
OA150 -- Bang giao dich  on-us(*)
OA163 -- Bang giao dich off-us(the lien minh tren ATM SCB)
OA177 -- Bang thong tin ATM
oa194 -- Transaction Fee Maintenace (ISS)
oa173 -- Transaction Fee Maintenace (ACQ)
ir150 -- Financial Maintenance
oa158 -- Transaction Parameter
il134 -- Han muc the
oa158 -- Transaction Parameter
IR513 -- Fees Structure Maintenance
AZ006 -- Thong tin user cardworks
RA005 -- Reward Points Allocation 
oa115 -- APM Checking by High Single Charge 
oa114 -- APM Checking by Daily High Frequency Uses
IW104 -- Thẻ mới tạo
IR087 -- Thong tin tat ca dau BIN SCB
IR145 -- thoi gian batch
ir166 -- Customer Category Maintenance 
al001
irb01--chot sao ke--F9_IRB_CLO_BAL--F9_IRB_OPEN_BAL
oa275--bang chua thong tin by pass
IR635 - bang gia han the
IR170 - Ho so Phat hanh the
select * from AG001@im WHERE PX_AG001_FLD = 'IN-DIRECT-ID';
oa274- Chua thong tin REF CODE

BRANCH_REGION: Chứa thông tin Vùng/Đơn vị
select * from OA212@am where PX_OA212_PAN = 'E7C7A85AEC6A72BEXXX' -- xem lich su tam khoa thẻ
select * from ccps.oa063; -- the tam khoa
select * from OA212@am where PX_OA212_PAN = 'E7C7A85AEC6A72BEXXX' -- (quá khứ)
select * from ir516@im;--bang ma vung theo chi nhanh ket hop voi ir124
select * from ir124@im;--bang ma vung theo chi nhanh ket hop voi ir516
select * from fpt.khu_vuc

-- Source Code Mapping
select a.PX_IR269_CRD_PGM, a.PX_IR269_SRC_CDE, a.PX_IR269_CAMPGN_CDE, b.FX_IR047_SCHM_CDE
from ccps.ir269@im a, ccps.ir047@im b
where a.PX_IR269_CAMPGN_CDE = b.PX_IR047_CAMPGN_CDE

/* conversion */
  SELECT   *
    FROM   ir635
   WHERE   TRIM (fx_ir635_crd_pgm) = 'MDT3'
           AND TRIM (fx_ir635_crd_pgm) <> TRIM (fx_ir635_new_crd_pgm)
ORDER BY   f9_ir635_cre_tms DESC

--oa115 - APM Checking by High Single Charge  DEBIT

--APM Checking by Daily High Frequency Uses: CREDIT
SELECT   px_oa114_crd_pgm,
         p9_oa114_fuel_ind,
         f9_oa114_tot_amt_pday,
         f9_oa114_reten_alw,
         f9_oa114_reten_alw_s
  FROM   oa114
 WHERE   trim(px_oa114_crd_pgm) = '04'

--IRC02 
select F9_IRC_CRE_TMS, F9_IRC_LOC_ACCT, FX_IRC_CRD_PGM, F9_IRC_TXN_DT, F9_IRC_STMT_MTH, F9_IRC_TXN_CDE, F9_IRC_TXN_AMT, FX_IRC_TXN_DESC
from irc02 where F9_IRC_STMT_MTH >= 202001 and FX_IRC_CRD_PGM = 'MCWC  '
and F9_IRC_TXN_CDE in (3260, 3270) order by F9_IRC_CRE_TMS desc

--Grant
GRANT SELECT, INSERT, UPDATE, DELETE on ir340X TO locttX

--Tim so CIF theo Card Type
select DISTINCT(trim(FX_IR056_CIF_NO))
from ir025 aa, ir056 bb
where aa.F9_IR025_CRN = bb.P9_IR056_CRN
and FX_IR025_CRD_PGM not in('MCW   ', 'MCW2  ', 'MCW3  ')

--SALE OFFICER CODE <=> DIRECT ID
SELECT * FROM IR259 WHERE FX_IR259_BR_CDE = '001'

--IN-DIRECT-ID
SELECT * FROM AG001 WHERE PX_AG001_FLD = 'IN-DIRECT-ID'

--Check Email AZ006
select * from az006 WHERE trim(FX_AZ006_USR_EMAIL_ADDR) = 'nhuttq@scb.com.vn'
update az006 set FX_AZ006_USR_EMAIL_ADDR = 'nhuttq_@scb.com.vn' where PX_AZ006_UID = 'DUNGNV4 '

--Fees Structure Maintenance
select PX_IR513_FEE_TYP, trim(PX_IR513_CRD_PGM) CRD_PGM, PX_IR513_VIP_IND, px_ir513_crd_typ, f9_ir513_fee_amt,
fx_ir513_chrg_typ, f9_ir513_fee_min, f9_ir513_fee_max, f9_ir513_fee_pct, f9_ir513_vat_pct
from ir513

--So the che
substr(ccps.ded2(PAN, ''), 1, 6) || 'XXXXXX' || substr(ccps.ded2(PAN, ''), -4, 4)

--BIN
select * from IR087 --where PX_IR087_CRD_BRN = 'MC'

insert into user_acc
VALUES('hunglq', 'LE QUOC HUNG', '000', 'HOI SO', '8', '1', 'U2NiQDEyMzQ=', '0', '0', 'HUNGLQ@SCB.COM.VN')

/* LAY SO THE TIN DUNG */
SELECT   ccps.ded2 (px_ir025_pan, ''),
         px_ir025_pan,
         fx_ir025_crd_pgm,
         f9_ir025_loc_acct
  FROM   ir025
 WHERE       fx_ir025_cls = ' '
         AND f9_ir025_cncl_dt = 0
         AND f9_ir025_ren_dt = 0
         AND fx_ir025_crd_pgm IN (SELECT   px_ir121_crd_pgm
                                    FROM   ir121
                                   WHERE   fx_ir121_serv_cde = 201)
