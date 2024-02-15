begin
;
wcStrt     = systemfunc("date")
;======================================
yrStrt = 1930
yrLast = 2014
latS   = -60.
latN   =  60.
lonL   = -180.
lonR   =  180.
drought = 1.5
p95 = 0.05
nvar = 3
nplots = 18 
nmos =12
xlabel = ispan(0,nmos-1,1)
print(xlabel)
;
d_histP = new((/3,24/),float,1e+20)                ;array to hold the indices
printVarSummary(d_histP)
d_histN = d_histP
day_factor = 86400.
daysmonth = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,31./)
m_daysmonth = avg(daysmonth)
print(m_daysmonth)
;print(xxxxxxxxxxxxx)

nvar = 3
pDATAP = new((/24,nvar,72,144/),float,1e+20)                ;array to hold the PCs
printVarSummary(pDATAP)
pDATAdP = pDATAP
pDATAN = pDATAP
pDATAdN = pDATAN
;
tDATAP = new((/24,nvar,180,360/),float,1e+20)                ;array to hold the PCs
printVarSummary(tDATAP)
tDATAdP = tDATAP
tDATAN = tDATAP
tDATAdN = tDATAN
;
;a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
;   lsdata = a->LSMASK
;   lsm  = landsea_mask(lsdata,data&lat,data&lon)
;   data = mask(data,lsm.eq.1,False)
;   data = mask(data,lsm.eq.3,False)
;
diriT = "/data/datasets/cmip6/historical/tos/"

hdataT = (/"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc",\"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2-WACCM-FV2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3-AerChem_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_EC-Earth3-Veg-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3-Veg-LR_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GFDL-CM4_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_MPI-ESM-1-2-HAM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc","RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc"/)
print(hdataT)
printVarSummary(hdataT)
;print(xxxxxxxxxxx)



diri = "/data/datasets/cmip6/historical/pr/"
;
hdata = (/"RE_pr_Amon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc","RE_pr_Amon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
        "RE_pr_Amon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
        "RE_pr_Amon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc","RE_pr_Amon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\
        "RE_pr_Amon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
        "RE_pr_Amon_CESM2-WACCM_historical_r1i1p1f1_gn_185001-201412.nc",\
        "RE_pr_Amon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc","RE_pr_Amon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
        "RE_pr_Amon_EC-Earth3_historical_r1i1p1f1_gr_185001-201412.nc","RE_pr_Amon_EC-Earth3-Veg-LR_historical_r1i1p1f1_gr_185001-201412.nc",\
        "RE_pr_Amon_EC-Earth3-Veg_historical_r1i1p1f1_gr_185001-201412.nc","RE_pr_Amon_FGOALS-f3-L_historical_r1i1p1f1_gr_185001-201412.nc",\
        "RE_pr_Amon_GFDL-ESM4_historical_r1i1p1f1_gr1_185001-201412.nc",\
        "RE_pr_Amon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
        "RE_pr_Amon_IPSL-CM6A-LR_historical_r1i1p1f1_gr_185001-201412.nc","RE_pr_Amon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
        "RE_pr_Amon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc","RE_pr_Amon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc","RE_pr_Amon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
        "RE_pr_Amon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc","RE_pr_Amon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
        "RE_pr_Amon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc","RE_pr_Amon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc"/)

print(hdata)
printVarSummary(hdata)

;
hdata_names = (/"ACCESS-CM2","ACCESS-ESM1-5","AWI-CM-1-1-MR","BCC-CSM2-MR","CanESM5","CESM2","CESM2-WACCM","CMCC-CM2-SR5","CMCC-ESM2","EC-Earth3","EC-Earth3-Veg-LR",\
        "EC-Earth3-Veg","FGOALS-f3-L","GFDL-ESM4","INM-CM5-0","IPSL-CM6A-LR","KACE-1-0-G",\
        "MIROC6","MPI-ESM1-2-HR","MPI-ESM1-2-LR","MRI-ESM2-0","NorESM2-LM","NorESM2-MM","TaiESM1"/)
print(hdata_names)
printVarSummary(hdata_names)
;
;
;
var = "pr"
varT = "tos"

do nn=0,dimsizes(hdata)-1,1
print("=================================================")
print(nn)
print("=================================================")
title  = str_upper(var)+": "+hdata_names(nn)
print(title)
;===============================================================
; Open the file: Read only the user specified period
;===============================================================
f    = addfiles(diri+hdata,"r")
  TIME   = f[nn]->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCC   = f[nn]->$var$(iYYYY,:,:)
  printVarSummary(GPCC)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  GPCC = GPCC*day_factor*m_daysmonth
  
  GPCC = lonFlip(GPCC)
;=============================================================
;==============================================================
;=============================================================
   yy = GPCC	;temporary data
   a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
   lsdata = a->LSMASK
   lsm  = landsea_mask(lsdata,GPCC&lat,GPCC&lon)
;  GPCC = mask(GPCC,conform(GPCC,lsm,(/1,2/)).eq.0,False)
  GPCC = mask(GPCC,lsm.eq.0,False)
  delete(a)
  delete(lsdata)
  delete(lsm)
;==============================================================
;==============================================================

;==============================================================
;==============================================================
;GPCCClm      = clmMonTLL(GPCC)
;printVarSummary(GPCCClm)                   ; (12,nlat,nlon)   
;GPCC         = calcMonAnomTLL(GPCC, GPCCClm)    ; replace with anonamlies
;GPCC@long_name = "ANOMALIES: "+GPCC@long_name
;==============================================================
htp = new((/dimsizes(GPCC(:,0,0)),nvar/),float,GPCC@_FillValue)                ;array to hold the PCs
htp(:,0) =  wgt_areaave_Wrap(GPCC(time|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
htp(:,1) =  wgt_areaave_Wrap(GPCC(time|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
htp(:,2) =  wgt_areaave_Wrap(GPCC(time|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
htp!0 = "time"
n_months = dimsizes(htp(:,0))
print(n_months)
printVarSummary(htp)
printMinMax(htp,True)
;delete(GPCC)
;
a_spi = htp     ;transfers dims 

 do n=0,nvar-1,1
    ; a_htp(n,:) = rmAnnCycle1D(htp(n,:))
     a_spi(:,n) = dim_spi_n(htp(:,n),6, False, 0)
  end do
delete(n)
printMinMax(a_spi,True)
printVarSummary(a_spi)
;print(xxxxxxxxxxxxx)
;================================================================
delete(GPCC)		;remove masked ocean
GPCC = yy		;No mask
delete(yy)
;==============================================================
;==============================================================
GPCCClm      = clmMonTLL(GPCC)
printVarSummary(GPCCClm)                   ; (12,nlat,nlon)   
GPCC         = calcMonAnomTLL(GPCC, GPCCClm)    ; replace with anonamlies
GPCC@long_name = "ANOMALIES: "+GPCC@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(GPCC)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,GPCC@_FillValue)
printVarSummary(saodP_cases_maps)
d_raindP  = new((/nvar,dimZ(1),dimZ(2)/),float,GPCC@_FillValue)
printVarSummary(d_raindP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = GPCC(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_raindP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(GPCC,0),dim_stddev_n_Wrap(GPCC,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_rainP = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_rainP)
copy_VarCoords(d_rainP,d_raindP)
printVarSummary(d_raindP)
d_raindP@long_name = "Probability: difference between means"
d_raindP = where(abs(d_raindP).le.p95,d_raindP,d_raindP@_FillValue) ; Sig. rains
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)



dimZ = dimsizes(GPCC)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,GPCC@_FillValue)
printVarSummary(saodN_cases_maps)
d_raindN  = new((/nvar,dimZ(1),dimZ(2)/),float,GPCC@_FillValue)
printVarSummary(d_raindN)
;
;
do n = 0,nvar-1
	n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
	print(n_saodN)
	valsN = ind(a_spi(:,n).le.-drought)
	print(valsN)
	saodN_cases_maps(n,valsN,:,:) = GPCC(valsN,:,:)
	printMinMax(saodN_cases_maps,True)
	d_raindN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(GPCC,0),dim_stddev_n_Wrap(GPCC,0)^2, dimZ(0),True, False)
	delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_rainN = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_rainN)
copy_VarCoords(d_rainN,d_raindN)
printVarSummary(d_raindN)
d_raindN@long_name = "Probability: difference between means"
d_raindN = where(abs(d_raindN).le.p95,d_raindN,d_raindN@_FillValue) ; Sig. rains
print("==============================================================")
printMinMax(d_raindN,True) 

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(GPCC)
;delete(GPCCClm)
list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
; Open the file: Read only the user specified period
;===============================================================
title  = str_upper(varT)+": "+hdata_names(nn)
print(title)

f    = addfiles(diriT+hdataT,"r")
  TIME   = f[nn]->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  HADI   = f[nn]->$varT$(iYYYY,:,:)
  printVarSummary(HADI)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(HADI,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
HADIClm      = clmMonTLL(HADI)
printVarSummary(HADIClm)                   ; (12,nlat,nlon)   
HADI         = calcMonAnomTLL(HADI, HADIClm)    ; replace with anonamlies
HADI@long_name = "ANOMALIES: "+HADI@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(HADI)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,HADI@_FillValue)
printVarSummary(saodP_cases_maps)
d_hadidP  = new((/nvar,dimZ(1),dimZ(2)/),float,HADI@_FillValue)
printVarSummary(d_hadidP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = HADI(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_hadidP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(HADI,0),dim_stddev_n_Wrap(HADI,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_hadiP = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_hadiP)
copy_VarCoords(d_hadiP,d_hadidP)
printVarSummary(d_hadidP)
d_hadidP@long_name = "Probability: difference between means"
d_hadidP = where(abs(d_hadidP).le.p95,d_hadidP,d_hadidP@_FillValue) ; Sig. hadis
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)


dimZ = dimsizes(HADI)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,HADI@_FillValue)
printVarSummary(saodN_cases_maps)
d_hadidN  = new((/nvar,dimZ(1),dimZ(2)/),float,HADI@_FillValue)
printVarSummary(d_hadidN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = HADI(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_hadidN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(HADI,0),dim_stddev_n_Wrap(HADI,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_hadiN = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_hadiN)
copy_VarCoords(d_hadiN,d_hadidN)
printVarSummary(d_hadidN)
d_hadidN@long_name = "Probability: difference between means"
d_hadidN = where(abs(d_hadidN).le.p95,d_hadidN,d_hadidN@_FillValue) ; Sig. hadis
print("==============================================================")
printMinMax(d_hadidN,True)

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(HADI)
;delete(HADIClm)
delete(a_spi)
delete(htp)

list_vars()
;======================================================================
;======================================================================
;======================================================================
pDATAP(nn,:,:,:) = (/d_rainP/)
pDATAdP(nn,:,:,:) = (/d_raindP/)
;
tDATAP(nn,:,:,:) = (/d_hadiP/)
tDATAdP(nn,:,:,:) = (/d_hadidP/)
;
printVarSummary(pDATAP)
printMinMax(pDATAP,True)
printVarSummary(tDATAP)
printMinMax(tDATAP,True)
delete(d_rainP)                     ;will be used again
delete(d_raindP)
delete(d_hadiP)                     ;will be used again
delete(d_hadidP)
;========================
pDATAN(nn,:,:,:) = (/d_rainN/)
pDATAdN(nn,:,:,:) = (/d_raindN/)
;
tDATAN(nn,:,:,:) = (/d_hadiN/)
tDATAdN(nn,:,:,:) = (/d_hadidN/)
;
printVarSummary(pDATAN)
printMinMax(pDATAN,True)
printVarSummary(tDATAN)
printMinMax(tDATAN,True)
delete(d_rainN)                     ;will be used again
delete(d_raindN)
delete(d_hadiN)                     ;will be used again
delete(d_hadidN)

;
end do
delete(nn)
;
;copy_VarCoords(cobe(0:dimsizes(hdata_names)-1,:,:),dDATA)
;copy_VarCoords(cobe(0:dimsizes(hdata_names)-1,:,:),dDATAd)
;printVarSummary(dDATA)
;printVarSummary(dDATAd)
;
m_sstP = dim_avg_n_Wrap(tDATAP,0)
m_sstdP = dim_avg_n_Wrap(tDATAdP,0)
printVarSummary(m_sstP)
printVarSummary(m_sstdP)
m_rainP = dim_avg_n_Wrap(pDATAP,0)
m_raindP = dim_avg_n_Wrap(pDATAdP,0)
printVarSummary(m_rainP)
printVarSummary(m_raindP)
;
m_sstN = dim_avg_n_Wrap(tDATAN,0)
m_sstdN = dim_avg_n_Wrap(tDATAdN,0)
printVarSummary(m_sstN)
printVarSummary(m_sstdN)
m_rainN = dim_avg_n_Wrap(pDATAN,0)
m_raindN = dim_avg_n_Wrap(pDATAdN,0)
printVarSummary(m_rainN)
printVarSummary(m_raindN)
;

copy_VarCoords(HADIClm(0:nvar-1,:,:),m_sstP)
copy_VarCoords(HADIClm(0:nvar-1,:,:),m_sstdP)
copy_VarCoords(HADIClm(0:nvar-1,:,:),m_sstN)
copy_VarCoords(HADIClm(0:nvar-1,:,:),m_sstdN)
;m_sstdP = where(abs(m_sstdP).le.p95,m_sstdP,m_sstdP@_FillValue) ; Sig. values
;m_sstdN = where(abs(m_sstdN).le.p95,m_sstdN,m_sstdN@_FillValue) ; Sig. values
;
;
;
;
ens_sst = new((/4,nvar,180,360/),float,1e+20)                ;array to hold the PCs
ens_sst(0,:,:,:) = m_sstP
ens_sst(1,:,:,:) = m_sstdP
ens_sst(2,:,:,:) = m_sstN
ens_sst(3,:,:,:) = m_sstdN
printVarSummary(ens_sst)
;
system("/bin/rm -f ens_sst_m_sstP_m_sstdP_m_sstN_m_sstdN.nc")   ; remove any pre-existing file
ncdf = addfile("ens_sst_m_sstP_m_sstdP_m_sstN_m_sstdN.nc" ,"c")  ; open output netCDF file
;ncdf->m_sstP   = m_sstP
;ncdf->m_sstdP  = m_sstdP
;ncdf->m_sstN   = m_sstN
;ncdf->m_sstdN  = m_sstdN
;============
copy_VarCoords(GPCCClm(0:nvar-1,:,:),m_rainP)
copy_VarCoords(GPCCClm(0:nvar-1,:,:),m_raindP)
copy_VarCoords(GPCCClm(0:nvar-1,:,:),m_rainN)
copy_VarCoords(GPCCClm(0:nvar-1,:,:),m_raindN)
;m_raindP = where(abs(m_raindP).le.p95,m_raindP,m_raindP@_FillValue) ; Sig. values
;m_raindN = where(abs(m_raindN).le.p95,m_raindN,m_raindN@_FillValue) ; Sig. values
;
;
ens_rain = new((/4,nvar,72,144/),float,1e+20)                ;array to hold the PCs
ens_rain(0,:,:,:) = m_rainP
ens_rain(1,:,:,:) = m_raindP
ens_rain(2,:,:,:) = m_rainN
ens_rain(3,:,:,:) = m_raindN
printVarSummary(ens_rain)
system("/bin/rm -f ens_rain_m_rainP_m_raindP_m_rainN_m_raindN.nc")   ; remove any pre-existing file
ncdf = addfile("ens_rain_m_rainP_m_raindP_m_rainN_m_raindN.nc" ,"c")  ; open output netCDF file


;ncdf->m_rainP  = m_rainP
;ncdf->m_raindP = m_raindP
;ncdf->m_rainN  = m_rainN
;ncdf->m_raindN = m_raindN
;print(xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
;==============================================================
  wks = gsn_open_wks("eps","FIG_8")         ; send graphics to PNG file
  plot = new(nplots,graphic)                ; create graphic array ; only needed if paneling
  plotS = new(nplots,graphic)                ; 
  
  res                   = True
  res@gsnFrame          = False ;; Tell NCL not to plot the plot, just yet.
  res@gsnDraw           = False
  res@cnFillOn          = True
  res@cnFillPalette     = "MPL_bwr"
  res@gsnAddCyclic      = False
  res@cnLinesOn         = False
  res@mpLimitMode       = "latlon"
  res@mpMinLatF         = latS
  res@mpMaxLatF         = latN
  res@mpMinLonF         = lonL
  res@mpMaxLonF         = lonR
  ;res@mpCenterLonF        = -90.
  res@pmTickMarkDisplayMode = "Always"
  ;res@mpFillDrawOrder      = "preDraw"
  res@mpFillOn            = False
  res@gsnAddCyclic         = True
  res@mpGeophysicalLineColor  = "black"
  res@mpGeophysicalLineThicknessF = 1.0
  res@mpCenterLonF =    -140.
  ;res@mpCenterLonF = (res@mpMaxLonF + res@mpMinLonF)*0.5
  ;res@mpFillDrawOrder = "postdraw"
  ;res@mpLandFillColor = (/1.0,1.0,1.0,0.0/) ; r,g,b,opacity
  ;res@mpOceanFillColor = (/1.0,1.0,1.0,1.0/) ; r,g,b,opacity
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -20.0
  res@cnMaxLevelValF       =  20.0
  res@cnLevelSpacingF      =  2.
  res@lbLabelBarOn         = False
  ;res@gsnStringFontHeightF = 0.020
  ;res@tmXBLabelFontHeightF = 0.020             
  ;res@tmYLLabelFontHeightF = 0.020       
  res@tiYAxisFontThicknessF  = 1.
  res@tmXBMajorThicknessF    = 1.
  res@tmXBMinorThicknessF    = 1.
  res@tmYLMajorThicknessF    = 1.
  res@tmYLMinorThicknessF    = 1.
  res@tmYLLabelFontThicknessF= 1.
  res@tmBorderThicknessF     = 1.
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
  res1                      =   True
  res1@gsnDraw              = False        ; don't draw yet
  res1@gsnFrame             = False        ; don't advance frame yet
  ;res1@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
 ; res1@cnMinLevelValF       =  -1.0            ; set min contour level
 ; res1@cnMaxLevelValF       =  1.0             ; set max contour level
 ; res1@cnLevelSpacingF      =  .05            ; set contour spacing  
  res1@gsnAddCyclic         = True
  res1@cnLinesOn            = False       ; True is default
  res1@cnLineLabelsOn       = False        ; True is default
  res1@cnInfoLabelOn        = False
  res1@gsnRightString   = ""
  res1@gsnLeftString   = ""
  res1@cnLineLabelDensityF =  5
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
  opt = True
  opt@gsnShadeFillType = "pattern"        ; color is the default
  opt@gsnShadeLow = 17                     ; use fill pattern #17
  opt@gsnShadeHigh = 17                     ; use fill pattern #17
  opt@gsnShadeFillScaleF = 0.5
  opt@gsnShadeFillDotSizeF = 0.001
  ;res@gsnCenterString           = "Linear trend of sea surface heaight"
  ;res@lbTitleString      = "Sea surface height (10~S~-2~N~m/year)"
  ;res@gsnLeftString  = "lag" +  ccr&lag(n)
 ;res@gsnLeftString  = DATA_NAMES(n)
  ;res@gsnCenterString  = hdata_names(n)

   delete(res@cnFillPalette)
   res@cnFillPalette        = "GMT_panoply"                        ;different colour bar
   res@gsnCenterString  = ""
   do n=0,nvar-1,1

   print(n)
   plot(n) = gsn_csm_contour_map_ce(wks,m_rainP(n,:,:),res)  ;           ; 
   plotS(n) = gsn_csm_contour(wks,m_raindP(n,:,:),res1)       ;
   plotS(n) = gsn_contour_shade(plotS(n),p95,m_raindP@_FillValue,opt)
;   overlay(plot(n),plotS(n))
   plot(n) = plot(n)
end do

delete(n)

 do n=0,nvar-1,1

   print(n)
   plot(nvar+n) = gsn_csm_contour_map_ce(wks,m_rainN(n,:,:),res)  ;           ; 
   plotS(nvar+n) = gsn_csm_contour(wks,m_raindN(n,:,:),res1)       ;
   plotS(nvar+n) = gsn_contour_shade(plotS(nvar+n),p95,m_raindN@_FillValue,opt)
;   overlay(plot(nvar+n),plotS(nvar+n))
   plot(nvar+n) = plot(nvar+n)
end do

delete(n)

;========================================================
  delete(res@cnFillPalette)
  res@cnFillPalette            = "amwg_blueyellowred"       ;different colour bar
  res@cnMinLevelValF       =  -0.5            ; set min contour level
  res@cnMaxLevelValF       =  0.5             ; set max contour level
  res@cnLevelSpacingF      =  0.05            ; set contour spacing

  res@gsnCenterString  = ""
   do n=0,nvar-1,1

   print(n)
   plot(2*nvar+n) = gsn_csm_contour_map_ce(wks,m_sstP(n,:,:),res)  ;           ; 
   plotS(2*nvar+n) = gsn_csm_contour(wks,m_sstdP(n,:,:),res1)       ;
   plotS(2*nvar+n) = gsn_contour_shade(plotS(2*nvar+n),p95,m_sstdP@_FillValue,opt)
;   overlay(plot(2*nvar+n),plotS(2*nvar+n))
   plot(2*nvar+n) = plot(2*nvar+n)
end do

delete(n)

 do n=0,nvar-1,1
   print(n)
   plot(3*nvar+n) = gsn_csm_contour_map_ce(wks,m_sstN(n,:,:),res)  ;           ; 
   plotS(3*nvar+n) = gsn_csm_contour(wks,m_sstdN(n,:,:),res1)       ;
   plotS(3*nvar+n) = gsn_contour_shade(plotS(3*nvar+n),p95,m_sstdN@_FillValue,opt)
;   overlay(plot(3*nvar+n),plotS(3*nvar+n))
   plot(3*nvar+n) = plot(3*nvar+n)
end do

delete(n)

;========================================================
   delete(res@cnFillPalette)
  res@cnFillPalette        = "amwg_blueyellowred"       ;different colour bar

  res@cnMinLevelValF       =  -1.            ; set min contour level
  res@cnMaxLevelValF       =  1.             ; set max contour level
  res@cnLevelSpacingF      =  0.1            ; set contour spacing

  res@gsnCenterString  = ""

;   do n=0,nvar-1,1
;   print(n)
;   plot(4*nvar+n) = gsn_csm_contour_map_ce(wks,d_hadiP(n,:,:),res)  ;           ; 
;   plotS(4*nvar+n) = gsn_csm_contour(wks,d_hadidP(n,:,:),res1)       ;
;   plotS(4*nvar+n) = gsn_contour_shade(plotS(4*nvar+n),p95,d_hadidP@_FillValue,opt)
;   overlay(plot(4*nvar+n),plotS(4*nvar+n))
;   plot(4*nvar+n) = plot(4*nvar+n)
;end do

;delete(n)

 ;do n=0,nvar-1,1
;   print(n)
;   plot(5*nvar+n) = gsn_csm_contour_map_ce(wks,d_hadiN(n,:,:),res)  ;           ; 
;   plotS(5*nvar+n) = gsn_csm_contour(wks,d_hadidN(n,:,:),res1)       ;
;   plotS(5*nvar+n) = gsn_contour_shade(plotS(5*nvar+n),p95,d_hadidN@_FillValue,opt)
;   overlay(plot(5*nvar+n),plotS(5*nvar+n))
;   plot(5*nvar+n) = plot(5*nvar+n)
;end do
;delete(n)
;==================================================================================
;==================================================================================
;=========================================================================
  txres5               = True
  txres5@txAngleF      = 0.          ; Rotate string clockwise 
  txres5@txFontHeightF = 0.025   ; Use same font height as left axis
  txres5@txFont                = "Helvetica-Bold"
 ; txid = gsn_create_text(wks, "DT anomaly (~S~o~N~C)", txres)
   txid5 = gsn_create_text(wks, "a", txres5);
; Move text string to center/right edge of plot.;
  amres5                  = True
  amres5@amParallelPosF   =  -0.48 ; 0.5 is the right edge of the plot, so
                                 ; 0.6 is a little further to the right.
  amres5@amOrthogonalPosF =  -0.48   ; This is the center of the plot.
 ; tt_p0X = gsn_add_annotation(plot(0),txid5,amres5)
  
  txres5@txFontHeightF = 0.035   ; Use same font height as left axis
  amres5@amParallelPosF   =  -0.57 ; 0.5 is the right edge of the plot, so
  amres5@amOrthogonalPosF =  -0.55    ; This is the center of the plot.
  amres5@amJust           = "TopLeft"

 tt = (/"a","b","c","d","e","f","g","h","i","j","k","l"/)
create_tt = gsn_create_text(wks,tt,txres5);
tt_p0 = new(12,graphic)                ; create graphic array ; only needed if paneling
;---Attach the polyline
;     do i = 0,4*nvar-1,1
;	print(i)
;        tt_p0(i) = gsn_add_annotation(plot(i),create_tt(i),amres5)
;     end do
;delete(i)
;
;========================================================================
  latEQ = (/ 5.,  5.,  -10.,   -10., 5./)
  lonEQ = (/-80., -50., -50., -80.,-80./)
;---Resources for the polyline
  pres0                  = True           ; polyline mods desired
  pres0@gsLineThicknessF = 2.            ; line thickness   
  pres0@gsLineColor      = "black"         ; color of lines
  pres0@gsLineDashPattern = 0
  pres0@tfPolyDrawOrder   = "PostDraw"
  

; dum0 = gsn_add_polyline(wks,plot(0),lonEQ,latEQ,pres0)

 latEQ1 = (/5.,  5.,  -10.,   -10., 5./)
 lonEQ1 = (/10., 30., 30., 10.,10./)
 ;dum1 = gsn_add_polyline(wks,plot(0),lonEQ1,latEQ1,pres0)
 
 latEQ2 = (/5.,  5.,  -10.,   -10., 5./)
 lonEQ2 = (/100., 150., 150., 100.,100./)
 ;dum2 = gsn_add_polyline(wks,plot(0),lonEQ2,latEQ2,pres0)

 dum0 = new(2*nvar,graphic)    
 dum1 = new(2*nvar,graphic)
 dum2 = new(2*nvar,graphic)

; do i = 0,2*nvar-1,1
;         dum0(i) =  gsn_add_polyline(wks,plot(i),lonEQ,latEQ,pres0)
;	 dum1(i) =  gsn_add_polyline(wks,plot(i),lonEQ1,latEQ1,pres0)
;	 dum2(i) =  gsn_add_polyline(wks,plot(i),lonEQ2,latEQ2,pres0)
; end do
; delete(i)
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;---------------------------------------------------------------------
var_names = (/"Amazon basin","Congo basin","Maritime continent"/)
printVarSummary(var_names)
print(var_names)

  txres               = True         ; Text resources
  txres@txFontHeightF = 0.012
  txres@txJust        = "CenterLeft"
  txres@txFont        = "Helvetica"
  txres@txAngleF      =  0.

  labels0  = var_names
  xpos0    = fspan(0.15, 0.70,dimsizes(var_names))

 do i = 0,dimsizes(labels0)-1,1
     gsn_text_ndc(wks,labels0(i),xpos0(i),0.97,txres)
  end do
delete(i)
delete(txres)
;=====================================================================
;=====================================================================
var_names1 = (/"                         ","                        ","~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5","~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5"/)
printVarSummary(var_names1)
print(var_names1)

  txres               = True         ; Text resources
  txres@txFontHeightF = 0.010
  txres@txJust        = "CenterLeft"
  txres@txFont        = "Helvetica"
  txres@txAngleF      =  90.

  labels1  = var_names1
  ypos1    = fspan(0.27, 0.88,dimsizes(var_names1))

 do i = 0,dimsizes(labels1)-1,1
     gsn_text_ndc(wks,labels1(i),0.035,ypos1(i),txres)
  end do
delete(i)
delete(txres)
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;=============================================================================
;===============================================================
  resP                                  = True         ; modify the panel plot
  resP@gsnDraw                          = True      ; don't draw yet
  resP@gsnFrame                         = False        ; don't advance frame yet
  resP@gsnPanelLabelBar                 = True        ; add common colorbar
  resP@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelTop                      = 0.99
  resP@gsnPanelBottom                   = 0.69
  resP@gsnPanelLeft                     = 0.05
  resP@gsnPanelRight                    = 0.99
  resP@gsnMaximize                      = True         ; large format
  resP@gsnPaperOrientation              = "portrait"   ; force portrait
  resP@gsnLeftString                    = ""
  resP@lbLabelStride                   = 5
  ;resP@pmLabelBarParallelPosF          = 0.50
  ;resP@pmLabelBarOrthogonalPosF        = -0.11
  resP@lbOrientation                    = "vertical"
  resP@lbTitleFontHeightF               = 0.008
  resP@lbLabelFontHeightF               = 0.008
  resP@lbLeftMarginF                    = 0.10
  resP@lbRightMarginF                   = 0.55
  resP@lbTopMarginF                     = -0.65
  resP@lbBottomMarginF                  = -0.55
 ;resP@lbLabelOffsetF                   = 0.20
  resP@lbLabelFont                      = "Helvetica-Bold"     ; label font
  resP@lbTitleFont                      = "Helvetica-Bold"     ; label font
  ;resP@lbLabelPosition                 = "Top"
  resP@lbTitleAngleF                    = 270.
  resP@lbTitlePosition                  = "Right"
  resP@lbTitleDirection                 = "Across"
  resP@lbTitleString                    = "Precipitation (mm/month)"
  resP@gsnPanelFigureStrings            = (/"a","b","c","d","e","f"/) ; add strings to panel
  resP@amJust                           = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF =  0.012
  resP@gsnPanelFigureStringsFont        =  "Helvetica-Bold"

  resP@txFont                           = "Helvetica-Bold"
 ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
   gsn_panel(wks,plot(0:5),(/2,3/),resP)     ; now draw as one plot
;  gsn_panel(wks,plot(6:11),(/2,3/),resP)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;===============================================================
;===============================================================
;=====================================================================
  resQ                                  = True         ; modify the panel plot
  resQ@gsnDraw                          = True      ; don't draw yet
  resQ@gsnFrame                         = False        ; don't advance frame yet
  resQ@gsnPanelLabelBar                 = True        ; add common colorbar
  resQ@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resQ@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resQ@gsnPanelTop                      = 0.74
  resQ@gsnPanelBottom                   = 0.44
  resQ@gsnPanelLeft                     = 0.05
  resQ@gsnPanelRight                    = 0.99
  resQ@gsnMaximize                      = True         ; large format
  resQ@gsnPaperOrientation              = "portrait"   ; force portrait
  resQ@gsnLeftString                    = ""
  resQ@lbLabelStride                   = 5
  ;resQ@pmLabelBarParallelPosF          = 0.50
  ;resQ@pmLabelBarOrthogonalPosF        = -0.11
  resQ@lbOrientation                    = "vertical"
  resQ@lbTitleFontHeightF               = 0.008
  resQ@lbLabelFontHeightF               = 0.008
  resQ@lbLeftMarginF                    = 0.10
  resQ@lbRightMarginF                   = 0.55
  resQ@lbTopMarginF                     = -0.65
  resQ@lbBottomMarginF                  = -0.55
 ;resQ@lbLabelOffsetF                   = 0.20
  resQ@lbLabelFont                      = "Helvetica-Bold"     ; label font
  resQ@lbTitleFont                      = "Helvetica-Bold"     ; label font
  ;resQ@lbLabelPosition                 = "Top"
  resQ@lbTitleAngleF                    = 270.
  resQ@lbTitlePosition                  = "Right"
  resQ@lbTitleDirection                 = "Across"
  resQ@lbTitleString                    = "Sea surface temperature (K)" 
 ;resQ@lbTitleString                    = "850hPa velocity potential (10~S~6~N~ m s~S~-1~N~)"
  resQ@gsnPanelFigureStrings            = (/"g","h","i","j","k","l"/) ; add strings to panel
  resQ@amJust                           = "TopLeft"
  resQ@gsnPanelFigureStringsFontHeightF =  0.012
  resQ@gsnPanelFigureStringsFont        =  "Helvetica-Bold"
  resQ@txFont                           = "Helvetica-Bold"
  ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
   gsn_panel(wks,plot(6:11),(/2,3/),resQ)     ; now draw as one plot
;===============================================================
;===============================================================
;    gsn_panel(wks,plot(0:5),(/2,3/),resQ)     ; now draw as one plot
;===============================================================
 wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
;==================================================================================
;==================================================================================
;==================================================================================
;==================================================================================
frame(wks)
end
