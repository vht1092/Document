------ TRUONG HOP HUY CASE LIEN QUAN DEN MO MOI THE
--  update IR346@IM set FX_IR346_REM='COMPLETED CASE',FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',px_ir346_uid='TUYETMN',fx_ir346_hdr_uid='AUTGRP.TUYETMN',F9_IR346_COMPL_TMS=20170415104517028 where FX_IR346_KEY_VAL like '%70228259%';
-- UPDATE ir086@IM set fx_ir086_decsn_stat = 'C',f9_ir086_decsn_dt=20170415 where p9_ir086_pro_no = '70228259';
-- COMMIT

-- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%70228259%';
-- SELECT * FROM ir086@IM WHERE p9_ir086_pro_no = '70228259';


------------HUY CASE DOI VOI TRUONG HOP MASTER SHARE LIMIT


--- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%0793926-25266%'
-- SELECT * FROM ir726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%0793926-25266%';

---- User NHAP THANHPTM


 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.THANHPTM',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',fx_ir346_hdr_uid='AUTGRP.DIEMVTT',
F9_IR346_COMPL_TMS=20170522163217028 where FX_IR346_KEY_VAL like '%0793926-25266%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20170522 ,  fx_ir726_revw_id='DIEMVTT'
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%0793926-25266%';



SELECT * FROM IR346@IM WHERE fx_ir346_key_val LIKE  '0860195%'

----  0860195-25448                                     
--------------------------------------------------
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.NGANHTY',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170526150217028 where FX_IR346_KEY_VAL like '%0860195-25448%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20170526 ,  fx_ir726_revw_id='DIEMVTT'
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%0860195-25448%', fx_ir726_upd_uid='DIEMVTT'


SELECT * FROM IR726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%0860195-25448%'
--------------------------------------------------------------------------------------------------------
--------------------- HUY THE TREN CARDWORKS
--  update IR346@IM set FX_IR346_REM='COMPLETED CASE',FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',px_ir346_uid='VANPH',F9_IR346_COMPL_TMS=20170614104517028 where FX_IR346_KEY_VAL like '%70262470%';
-- UPDATE ir086@IM set fx_ir086_decsn_stat = 'C',f9_ir086_decsn_dt=20170614 where p9_ir086_pro_no = '70262470';
-- COMMIT

-- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%70262470%';
-- SELECT * FROM ir086@IM WHERE p9_ir086_pro_no = '70262470';

--------------------------------------------------------------------------------------------------------------
--------- HUY CASE TREN MASTERSHARE

 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.NGANHTY',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170526150217028 where FX_IR346_KEY_VAL like '%0860195-25448%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20170526 ,  fx_ir726_revw_id='DIEMVTT'
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%0860195-25448%', fx_ir726_upd_uid='DIEMVTT'


SELECT * FROM IR726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%0860195-25448%'

SELECT * from ir346@im where 
fx_ir346_key_val like '0060701-25702%'
--------------------------------------------------------------
----------- HUY CASE MASTERSHARE , CIF: 0558234 - NGUYEN MINH THONG
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.THANHDTG',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='PHUONGND',
F9_IR346_COMPL_TMS=20170616080217028 where FX_IR346_KEY_VAL like '%0558234-26124%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20170616 ,  fx_ir726_revw_id='PHUONGND',  fx_ir726_upd_uid='PHUONGND'
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%0558234-26124%'


SELECT * FROM IR726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '0558234-26124%'

SELECT * from ir346@im where 
fx_ir346_key_val like '0558234-26124%'

----------------------------------------------------------------------------------------------------------------------------------
-----------  HUY CASE MASTERSHARE , CIF: 0688849 - DUONG THAI NHAN
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.KIMDT1',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='HANHTTN',
F9_IR346_COMPL_TMS=20160603101843708 where FX_IR346_KEY_VAL like '%0688849-9717%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20160603 ,  fx_ir726_revw_id='HANHTTN',  fx_ir726_upd_uid='HANHTTN'
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%0688849-9717%'


SELECT * FROM IR726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '0688849-9717%'

SELECT * from ir346@im where 
fx_ir346_key_val like '0688849-9717%'


------------------------------------------------------ HUY CASE VE MAN HINH SPECIAL  

SELECT * FROM IR346@IM WHERE fx_ir346_key_val LIKE '379EF8CB03928CE2XXX-2%'
 ----   4895170064602908-2 ---  379EF8CB03928CE2XXX-2
 
 SELECT * FROM IR617@IM WHERE trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO) ='379EF8CB03928CE2XXX-2' 


----- CAP NHAT 
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.MAIDTT',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170624120217028 where FX_IR346_KEY_VAL like '379EF8CB03928CE2XXX-2%';


update ir617@im
set fx_ir617_upd_uid='DIEMVTT',  
fx_ir617_stat='C', 
f9_ir617_upd_tms= 20170624120217028 
WHERE (trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO)) LIKE '379EF8CB03928CE2XXX-2%' ;

----------------------------------------------------------------------------------------------------------------------------------------------
------------- HUY CASE UPDRADE/ DOWNGRADE
select ccps.ecd2('5455790781743773','') from dual; ---------  AB0977D27BD61A79XXX

select * from ir346@im where 
fx_ir346_key_val like '231C05C5B4D03E22XXX%'
----- processing no:  AB0977D27BD61A79XXX-00034375  

SELECT * FROM IR635@IM WHERE ((FX_IR635_PAN)||'-'||LPAD(P9_IR635_SEQ_NO,8,'0')) LIKE 'AB0977D27BD61A79XXX-00034375%' 

------ CAP NHAT
update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.VANNTH5',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170628165017028 where FX_IR346_KEY_VAL like 'AB0977D27BD61A79XXX-00034375%'  ;

UPDATE IR635@IM
SET f9_ir635_upd_tms=20170628165017028, fx_ir635_revw_id='DIEMVTT', f9_ir635_decsn_dt=20170628,fx_ir635_decsn_stat='C',fx_ir635_upd_uid='DIEMVTT'
WHERE ((FX_IR635_PAN)||'-'||LPAD(P9_IR635_SEQ_NO,8,'0')) LIKE 'AB0977D27BD61A79XXX-00034375%'



select ccps.ecd2('5455790579466207','') from dual;  ------ 231C05C5B4D03E22XXX

------------------------ HUY CASE SPECIAL LIMIT

SELECT CCPS.ECD2('4895160056506753','') FROM DUAL;    --------  AD19A9A0BB6F133BXXX

SELECT * FROM IR346@IM WHERE  
fx_ir346_key_val LIKE 'AD19A9A0BB6F133BXXX-2%'
 
----------
 SELECT * FROM IR617@IM WHERE trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO) ='AD19A9A0BB6F133BXXX-2' 


----- CAP NHAT 
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.NUNN',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170712080217028 where FX_IR346_KEY_VAL like 'AD19A9A0BB6F133BXXX-2%';
----
update ir617@im
set fx_ir617_upd_uid='DIEMVTT',  
fx_ir617_stat='C', 
f9_ir617_upd_tms= 20170712080217028 
WHERE (trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO)) LIKE 'AD19A9A0BB6F133BXXX-2%' ;

------------------------ HUY CASE SPECIAL LIMIT, 5455791322601538

SELECT CCPS.ECD2('5455791322601538','') FROM DUAL;    --------  9EA0299BB21803D6XXX

SELECT * FROM IR346@IM WHERE  
fx_ir346_key_val LIKE '9EA0299BB21803D6XXX-1%'
 
----------
 SELECT * FROM IR617@IM WHERE trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO) ='9EA0299BB21803D6XXX-1' 


----- CAP NHAT 
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.TRUCNT1',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170712080217028 where FX_IR346_KEY_VAL like '9EA0299BB21803D6XXX-1%';
----
update ir617@im
set fx_ir617_upd_uid='DIEMVTT',  
fx_ir617_stat='C', 
f9_ir617_upd_tms= 20170712080217028 
WHERE (trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO)) LIKE '9EA0299BB21803D6XXX-1%' ;

---------------------------------   UPGRADING/ DOWGRADING    SO THE: 5455790760529557
select ccps.ecd2('5455790760529557','') from dual; ---------  C2FF88348DEDF614XXX

select * from ir346@im where 
fx_ir346_key_val like 'C2FF88348DEDF614XXX-00035774%'
----- processing no:  C2FF88348DEDF614XXX-00035774                      

SELECT * FROM IR635@IM WHERE ((FX_IR635_PAN)||'-'||LPAD(P9_IR635_SEQ_NO,8,'0')) LIKE 'C2FF88348DEDF614XXX-00035774%' 

------ CAP NHAT
update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.TRANGNT3',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170712085017028 where FX_IR346_KEY_VAL like 'C2FF88348DEDF614XXX-00035774%'  ;

UPDATE IR635@IM
SET f9_ir635_upd_tms=20170712085017028, fx_ir635_revw_id='DIEMVTT', f9_ir635_decsn_dt=20170712,fx_ir635_decsn_stat='C',fx_ir635_upd_uid='DIEMVTT'
WHERE ((FX_IR635_PAN)||'-'||LPAD(P9_IR635_SEQ_NO,8,'0')) LIKE 'C2FF88348DEDF614XXX-00035774%'

select ccps.ecd2('9704290500056038','') from dual;   -----  9CAEFFC11C6E5867XXX

select * from ir346@im where fx_ir346_key_val like '9CAEFFC11C6E5867XXX%'

-------------------------------------------------------------------------------------------------
------ TRUONG HOP HUY CASE LIEN QUAN DEN MO MOI THE
  update IR346@IM set FX_IR346_REM='COMPLETED CASE',FX_IR346_CASE_BOX='C',f9_ir346_lev='2',
  px_ir346_grp_id='AUTGRP',px_ir346_uid='DIEMVTT',fx_ir346_hdr_uid='CAPGRP.MAIDTT',F9_IR346_COMPL_TMS=20170714104517028 

where FX_IR346_KEY_VAL like '%70274004%';


 UPDATE ir086@IM set fx_ir086_decsn_stat = 'C',f9_ir086_decsn_dt=20170714
  ,fx_ir086_upd_uid='DIEMVTT' ,f9_ir086_upd_tms=20170714104517028 
 where p9_ir086_pro_no = '70274004'
 
COMMIT

-- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%70274004%';
-- SELECT * FROM ir086@IM WHERE p9_ir086_pro_no = '70274004';


------------------------------------------------------------------------------------------------------------
------- truong hop SPECIAL LIMIT 5102350192438500-1

SELECT CCPS.ECD2('5102350192438500','') FROM DUAL;    --------  DF2D1FCE3091FBFFXXX

SELECT * FROM IR346@IM WHERE  
TRIM(fx_ir346_key_val) LIKE 'DF2D1FCE3091FBFFXXX-1'
 
----------
 SELECT * FROM IR617@IM WHERE trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO) ='DF2D1FCE3091FBFFXXX-1' 


----- CAP NHAT 
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.HUONGPT',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170717080217028 where FX_IR346_KEY_VAL like 'DF2D1FCE3091FBFFXXX-1%';
----
update ir617@im
set fx_ir617_upd_uid='DIEMVTT',  
fx_ir617_stat='C', 
f9_ir617_upd_tms= 20170717080217028
WHERE (trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO)) LIKE 'DF2D1FCE3091FBFFXXX-1%' ;

-------------------------------------------------------------------------------------------
--------- TRUONG HOP NEW CARD APPLICATION 70281213
--------------------- HUY THE TREN CARDWORKS
 update IR346@IM set FX_IR346_REM='COMPLETED CASE',FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',px_ir346_uid='HANHDTD',

 F9_IR346_COMPL_TMS=20170718104517028 where FX_IR346_KEY_VAL like '%70281213%';
 
 UPDATE ir086@IM set fx_ir086_decsn_stat = 'C',f9_ir086_decsn_dt=20170718, fx_ir086_upd_uid='TRANGHH'
 where p9_ir086_pro_no = '70281213';


SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%70281213%';
 SELECT * FROM ir086@IM WHERE p9_ir086_pro_no = '70281213';
 
 -------------------------------------------------------------------------------------------------
------ TRUONG HOP HUY CASE LIEN QUAN DEN MO MOI THE, 70285049
  update IR346@IM set FX_IR346_REM='COMPLETED CASE',FX_IR346_CASE_BOX='C',f9_ir346_lev='2',
  px_ir346_grp_id='AUTGRP',px_ir346_uid='DIEMVTT',fx_ir346_hdr_uid='CAPGRP.DUNGPT',F9_IR346_COMPL_TMS=20170726134517028 

where FX_IR346_KEY_VAL like '%70285942%';


 UPDATE ir086@IM set fx_ir086_decsn_stat = 'C',f9_ir086_decsn_dt=20170726
  ,fx_ir086_upd_uid='DIEMVTT' ,f9_ir086_upd_tms=20170726134517028
 where p9_ir086_pro_no = '70285942'
 
COMMIT

-- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%70285942%';
-- SELECT * FROM ir086@IM WHERE p9_ir086_pro_no = '70285942';
-----------------------------------------------------------------------------------------------------------------------
------------ HUY CASE LIEN QUAN DEN SPECIAL LIMIT
------- 5455790718537272-1

SELECT CCPS.ECD2('5455790718537272','') FROM DUAL;  ---------  BAF522D42A3B548AXXX


SELECT * FROM IR346@IM WHERE fx_ir346_key_val LIKE 'BAF522D42A3B548AXXX-1%'
 ----   4895170064602908-2 ---  379EF8CB03928CE2XXX-2
 
 SELECT * FROM IR617@IM WHERE trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO) ='BAF522D42A3B548AXXX-1' 


----- CAP NHAT 
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.HIENNT11',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170729081217028 where FX_IR346_KEY_VAL like 'BAF522D42A3B548AXXX-1%';


update ir617@im
set fx_ir617_upd_uid='DIEMVTT',  
fx_ir617_stat='C', 
f9_ir617_upd_tms=20170729081217028
WHERE (trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO)) LIKE 'BAF522D42A3B548AXXX-1%%' ;
----------------------------------------------------------------------------------------------------------------------

--------- HUY CASE TREN MASTERSHARE cif= 1042924

 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.LINHLK',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170801150217028 where FX_IR346_KEY_VAL like '%1042924-27954%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20170801 ,  fx_ir726_revw_id='DIEMVTT',
f9_ir726_upd_tms=20170801150217028
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%1042924-27954%'


SELECT * FROM IR726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%1042924-27954%'

SELECT * from ir346@im where 
fx_ir346_key_val like '%1042924-27954%'
--------------------------------------------------------------------------------------------------------------------
---------------------------- TRUONG HOP HUY CASE LIEN QUAN DEN MO MOI THE, 70285049
  update IR346@IM set FX_IR346_REM='COMPLETED CASE',FX_IR346_CASE_BOX='C',f9_ir346_lev='2',
  px_ir346_grp_id='AUTGRP',px_ir346_uid='NGANVK',fx_ir346_hdr_uid='CAPGRP.BINHTTV',F9_IR346_COMPL_TMS=20170812113331654 

where FX_IR346_KEY_VAL like '%70289696%';


 UPDATE ir086@IM set fx_ir086_decsn_stat = 'C',f9_ir086_decsn_dt=20170812
  ,fx_ir086_upd_uid='NGANVK' ,f9_ir086_upd_tms=20170812113331654 
 where p9_ir086_pro_no = '70289696'
 
COMMIT

-- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%70289696%';
-- SELECT * FROM ir086@IM WHERE p9_ir086_pro_no = '70289696';

update ir346@im set fx_ir346_case_orgtr='CAPGRP.BINHTTV'
WHERE FX_IR346_KEY_VAL like '%70289696%';
---------------------------------------------------------------------------------------------------------------------
------------ huy case SPECIAL LIMIT - 4895170089675830-4

select ccps.ecd2('4895170089675830','') from dual; ----  E936471607A8BB6DXXX

SELECT * FROM IR346@IM WHERE fx_ir346_key_val LIKE 'E936471607A8BB6DXXX-4%'
 ----   4895170064602908-2 ---  379EF8CB03928CE2XXX-2
 
 SELECT * FROM IR617@IM WHERE trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO) ='E936471607A8BB6DXXX-4' 


----- CAP NHAT 
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.MYHT',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170814165217028 where FX_IR346_KEY_VAL like 'E936471607A8BB6DXXX-4%';


update ir617@im
set fx_ir617_upd_uid='DIEMVTT',  
fx_ir617_stat='C', 
f9_ir617_upd_tms= 20170814165217028 
WHERE (trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO)) LIKE 'E936471607A8BB6DXXX-4%' ;
----------------------------------------------------------------------------------------
-------------------- Huy case mo the :  70290499


 update IR346@IM set FX_IR346_REM='COMPLETED CASE',FX_IR346_CASE_BOX='C',f9_ir346_lev='2',
  px_ir346_grp_id='AUTGRP',px_ir346_uid='MAYNT1',fx_ir346_hdr_uid='CAPGRP.HANGNTT5',
  F9_IR346_COMPL_TMS=20170816113331654 

where FX_IR346_KEY_VAL like '%70290499%';


 UPDATE ir086@IM set fx_ir086_decsn_stat = 'C',f9_ir086_decsn_dt=20170816
  ,fx_ir086_upd_uid='MAYNT1' ,f9_ir086_upd_tms=20170816113331654 
 where p9_ir086_pro_no = '70290499'
 
COMMIT

-- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%70290499%';
-- SELECT * FROM ir086@IM WHERE p9_ir086_pro_no = '70290499';

update ir346@im set fx_ir346_case_orgtr='CAPGRP.HANGNTT5'
WHERE FX_IR346_KEY_VAL like '%70290499%';

--------------------------------------------------------------------------------------------------------
------------ MASTER SHARE LIMIT CIF: 0764834
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.DUYENTTT',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170818170217028 where FX_IR346_KEY_VAL like '%0421922-28495%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20170818 ,  fx_ir726_revw_id='DIEMVTT',
f9_ir726_upd_tms=20170818170217028
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%0421922-28495%'


SELECT * FROM IR726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%0421922%'

SELECT * from ir346@im where 
fx_ir346_key_val like '%0421922%'

------------------------------------------------------------------------------------------------------------------
---------------- huy case SPECIAL LIMIT - 5546270364491661-1

select ccps.ecd2('5546270364491661','') from dual; ---- B16D98BA61D27F1CXXX

SELECT * FROM IR346@IM WHERE fx_ir346_key_val LIKE 'B16D98BA61D27F1CXXX-1%'
 ----   4895170064602908-2 ---  379EF8CB03928CE2XXX-2
 
 SELECT * FROM IR617@IM WHERE trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO) ='B16D98BA61D27F1CXXX-1' 


----- CAP NHAT 
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.KHOAPTD',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='HANHDTD',
F9_IR346_COMPL_TMS=20170901115217028 where FX_IR346_KEY_VAL like 'B16D98BA61D27F1CXXX-1%';


update ir617@im
set fx_ir617_upd_uid='HANHDTD',  
fx_ir617_stat='C', 
f9_ir617_upd_tms= 20170901115217028 
WHERE (trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO)) LIKE 'B16D98BA61D27F1CXXX-1%' ;

------------------------------------------------------------------------------------------------------------
-------------------------------- HUY CASE TAO TH?
----  70297546

update IR346@IM set FX_IR346_REM='COMPLETED CASE',FX_IR346_CASE_BOX='C',f9_ir346_lev='2',
  px_ir346_grp_id='AUTGRP',px_ir346_uid='QUYENVT',fx_ir346_hdr_uid='CAPGRP.HUONGPT6',
  F9_IR346_COMPL_TMS=20170912113331654 

where FX_IR346_KEY_VAL like '%70297546%';


 UPDATE ir086@IM set fx_ir086_decsn_stat = 'C',f9_ir086_decsn_dt=20170912
  ,fx_ir086_upd_uid='QUYENVT' ,f9_ir086_upd_tms=20170912113331654 
 where p9_ir086_pro_no = '70297546'
 
COMMIT

-- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%70297546%';
-- SELECT * FROM ir086@IM WHERE p9_ir086_pro_no = '70297546';

update ir346@im set fx_ir346_case_orgtr='CAPGRP.HANGNTT5'
WHERE FX_IR346_KEY_VAL like '%70290499%';

-----------------------------------------------------------------------------------------------------------------------
---------------- HUY CASE MASTER SHARE LIMIT - CIF: 0752776

 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.THACHTTC',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170925103217028 where FX_IR346_KEY_VAL like '0582531-31866%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20170925 ,  fx_ir726_revw_id='DIEMVTT',
f9_ir726_upd_tms=20170925103217028
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '0582531-31866%'


SELECT * FROM IR726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '0582531-31866%'

SELECT * from ir346@im where 
fx_ir346_key_val like '0582531-31866%' ; 
----  4895160034638462-1
-----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---
---------------- huy case SPECIAL LIMIT - 4895160034638462-1

select ccps.ecd2('4895160034638462','') from dual; ---- C07BBE9C5F18279BXXX

 ----   4895170064602908-2 ---  379EF8CB03928CE2XXX-2
SELECT * FROM IR346@IM WHERE fx_ir346_key_val LIKE 'C07BBE9C5F18279BXXX-1%'
 
 SELECT * FROM IR617@IM WHERE trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO) ='C07BBE9C5F18279BXXX-1'


----- CAP NHAT 
 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.HUONGDT6',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20170930095217028 where FX_IR346_KEY_VAL like 'C07BBE9C5F18279BXXX-1%'


update ir617@im
set fx_ir617_upd_uid='DIEMVTT',  
fx_ir617_stat='C', 
f9_ir617_upd_tms= 20170930095217028
WHERE (trim(P9_IR617_CRD_NO)||'-'||trim(P9_IR617_SEQ_NO)) LIKE 'C07BBE9C5F18279BXXX-1' ;

'B16D98BA61D27F1CXXX-1'

-------------------------------------------------------------------------------------------------------------
--------- HUY CASE TREN MASTERSHARE cif= 0933737

 update IR346@IM set FX_IR346_REM='COMPLETED CASE',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20171011160217028 where FX_IR346_KEY_VAL like '%0934556-31575%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20171011 ,  fx_ir726_revw_id='DIEMVTT',
f9_ir726_upd_tms=20171011160217028
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%0934556-31575%'


SELECT * FROM IR726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%0933737-31574%'

SELECT * from ir346@im where 
fx_ir346_key_val like '%0933737%'

UPDATE ir726@IM set f9_ir726_decsn_dt=20171011

where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%0933737-31574%'

-------------------------------------------------------------------

------------HUY CASE DOI VOI TRUONG HOP MASTER SHARE LIMIT 01234840


--- SELECT * FROM IR346@IM WHERE FX_IR346_KEY_VAL like '%0793926-25266%'
-- SELECT * FROM ir726@IM WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE '%0793926-25266%';

---- User NHAP THANHPTM
SELECT * FROM IR346@IM WHERE fx_ir346_key_val LIKE '%0475410-34661%'


 update IR346@IM set FX_IR346_REM='COMPLETED CASE', fx_ir346_hdr_uid='CAPGRP.TRUCNT3',
FX_IR346_CASE_BOX='C',f9_ir346_lev='2',px_ir346_grp_id='AUTGRP',
px_ir346_uid='DIEMVTT',
F9_IR346_COMPL_TMS=20171031091017028 where FX_IR346_KEY_VAL like '%0475410-34661%';

UPDATE ir726@IM set fx_ir726_decsn_stat = 'D',f9_ir726_decsn_dt=20171031 ,  fx_ir726_revw_id='DIEMVTT',
f9_ir726_upd_tms=20171031091017028
where trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%0475410-34661%';



SELECT * FROM ir726@IM  WHERE trim(PX_IR726_CIF_NO)||'-'||trim(P9_IR726_SEQ) LIKE  '%0475410-34661%';



select PX_IR025_PAN PAN  from ir025@im where (fx_ir025_crd_pgm like 'MC%' OR fx_ir025_crd_pgm like 'VS%') AND fx_ir025_cls=' '
UNION 
select PX_IR275_OWN_PAN PAN  from ir275@im where (fx_ir275_crd_pgm like 'MC%' OR fx_ir275_crd_pgm like 'VS%') AND fx_ir275_cls=' '
