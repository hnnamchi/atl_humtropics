begin
;
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
nplots = 24 
nmos =12
xlabel = ispan(0,nmos-1,1)
print(xlabel)
;
d_histP = new((/3,24/),float,1e+20)                ;array to hold the indices
printVarSummary(d_histP)
d_histN = d_histP
;
;

   f      = addfile ("/data/datasets/rain/gpcc_full_data_monthly_v2022_1891_2020_25.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCC   = f->precip(iYYYY,:,:)
  printVarSummary(GPCC)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(GPCC,True)
;==============================================================
yyyymm = cd_calendar(GPCC&time,-1)
yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0); not used here
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
;==============================================================
;==============================================================
;==============================================================
f      = addfile ("/data/datasets/20cr/v3/chi.ud.vd.mon.200hPa.1900.2015.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  UD   = f->ud(iYYYY,:,:)
  printVarSummary(UD)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(UD,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
;==============================================================
UDClm      = clmMonTLL(UD)
printVarSummary(UDClm)                   ; (12,nlat,nlon)   
UD         = calcMonAnomTLL(UD, UDClm)    ; replace with anonamlies
UD@long_name = "ANOMALIES: "+UD@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(UD)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,UD@_FillValue)
printVarSummary(saodP_cases_maps)
d_uddP  = new((/nvar,dimZ(1),dimZ(2)/),float,UD@_FillValue)
printVarSummary(d_uddP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = UD(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_uddP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(UD,0),dim_stddev_n_Wrap(UD,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_udP = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_udP)
copy_VarCoords(d_udP,d_uddP)
printVarSummary(d_uddP)
d_uddP@long_name = "Probability: difference between means"
d_uddP = where(abs(d_uddP).le.p95,d_uddP,d_uddP@_FillValue) ; Sig. uds
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)



dimZ = dimsizes(UD)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,UD@_FillValue)
printVarSummary(saodN_cases_maps)
d_uddN  = new((/nvar,dimZ(1),dimZ(2)/),float,UD@_FillValue)
printVarSummary(d_uddN)
;
;
do n = 0,nvar-1
	n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
	print(n_saodN)
	valsN = ind(a_spi(:,n).le.-drought)
	print(valsN)
	saodN_cases_maps(n,valsN,:,:) = UD(valsN,:,:)
	printMinMax(saodN_cases_maps,True)
	d_uddN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(UD,0),dim_stddev_n_Wrap(UD,0)^2, dimZ(0),True, False)
	delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_udN = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_udN)
copy_VarCoords(d_udN,d_uddN)
printVarSummary(d_uddN)
d_uddN@long_name = "Probability: difference between means"
d_uddN = where(abs(d_uddN).le.p95,d_uddN,d_uddN@_FillValue) ; Sig. uds
print("==============================================================")
printMinMax(d_uddN,True) 

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(UD)

list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
f      = addfile ("/data/datasets/20cr/v3/chi.ud.vd.mon.200hPa.1900.2015.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  VD   = f->vd(iYYYY,:,:)
  printVarSummary(VD)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(VD,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
VDClm      = clmMonTLL(VD)
printVarSummary(VDClm)                   ; (12,nlat,nlon)   
VD         = calcMonAnomTLL(VD, VDClm)    ; replace with anonamlies
VD@long_name = "ANOMALIES: "+VD@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(VD)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,VD@_FillValue)
printVarSummary(saodP_cases_maps)
d_vddP  = new((/nvar,dimZ(1),dimZ(2)/),float,VD@_FillValue)
printVarSummary(d_vddP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = VD(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_vddP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(VD,0),dim_stddev_n_Wrap(VD,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_vdP = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_vdP)
copy_VarCoords(d_vdP,d_vddP)
printVarSummary(d_vddP)
d_vddP@long_name = "Probability: difference between means"
;d_vddP = where(abs(d_vddP).le.p95,d_vddP,d_vddP@_FillValue) ; Sig. vds
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)


dimZ = dimsizes(VD)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,VD@_FillValue)
printVarSummary(saodN_cases_maps)
d_vddN  = new((/nvar,dimZ(1),dimZ(2)/),float,VD@_FillValue)
printVarSummary(d_vddN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = VD(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_vddN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(VD,0),dim_stddev_n_Wrap(VD,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_vdN = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_vdN)
copy_VarCoords(d_vdN,d_vddN)
printVarSummary(d_vddN)
d_vddN@long_name = "Probability: difference between means"
;d_vddN = where(abs(d_vddN).le.p95,d_vddN,d_vddN@_FillValue) ; Sig. vds
print("==============================================================")
;printMinMax(d_vddN,True)
;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(VD)
;list_vars()

;==============================================================
;E_U  = where((E_Ud.lt.p95.or.E_Vd.lt.p95),E_U,E_U@_FillValue)
;E_V  = where((E_Vd.lt.p95.or.E_Ud.lt.p95),E_V,E_V@_FillValue)
;printMinMax(E_U,True)

d_udP  = where((d_uddP.lt.p95.or.d_vddP.lt.p95),d_udP,d_udP@_FillValue)
d_vdP  = where((d_vddP.lt.p95.or.d_uddP.lt.p95),d_vdP,d_vdP@_FillValue)
;
d_udN  = where((d_uddN.lt.p95.or.d_vddN.lt.p95),d_udN,d_udN@_FillValue)
d_vdN  = where((d_vddN.lt.p95.or.d_uddN.lt.p95),d_vdN,d_vdN@_FillValue)
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
f      = addfile ("/data/datasets/20cr/v3/chi.ud.vd.mon.200hPa.1900.2015.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  CHI   = f->chi(iYYYY,:,:)
  printVarSummary(CHI)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(CHI,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
CHIClm      = clmMonTLL(CHI)
printVarSummary(CHIClm)                   ; (12,nlat,nlon)   
CHI         = calcMonAnomTLL(CHI, CHIClm)    ; replace with anonamlies
CHI@long_name = "ANOMALIES: "+CHI@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(CHI)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,CHI@_FillValue)
printVarSummary(saodP_cases_maps)
d_chidP  = new((/nvar,dimZ(1),dimZ(2)/),float,CHI@_FillValue)
printVarSummary(d_chidP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = CHI(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_chidP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(CHI,0),dim_stddev_n_Wrap(CHI,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_chiP = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_chiP)
copy_VarCoords(d_chiP,d_chidP)
printVarSummary(d_chidP)
d_chidP@long_name = "Probability: difference between means"
d_chidP = where(abs(d_chidP).le.p95,d_chidP,d_chidP@_FillValue) ; Sig. chis
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)


dimZ = dimsizes(CHI)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,CHI@_FillValue)
printVarSummary(saodN_cases_maps)
d_chidN  = new((/nvar,dimZ(1),dimZ(2)/),float,CHI@_FillValue)
printVarSummary(d_chidN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = CHI(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_chidN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(CHI,0),dim_stddev_n_Wrap(CHI,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_chiN = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_chiN)
copy_VarCoords(d_chiN,d_chidN)
printVarSummary(d_chidN)
d_chidN@long_name = "Probability: difference between means"
d_chidN = where(abs(d_chidN).le.p95,d_chidN,d_chidN@_FillValue) ; Sig. chis
print("==============================================================")
printMinMax(d_chidN,True)

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(CHI)

list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;================================================================
;==============================================================
;==============================================================
;==============================================================
f      = addfile ("/data/datasets/20cr/v3/chi.ud.vd.mon.850hPa.1900.2015.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  UD8   = f->ud(iYYYY,:,:)
  printVarSummary(UD8)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(UD8,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
;==============================================================
UD8Clm      = clmMonTLL(UD8)
printVarSummary(UD8Clm)                   ; (12,nlat,nlon)   
UD8         = calcMonAnomTLL(UD8, UD8Clm)    ; replace with anonamlies
UD8@long_name = "ANOMALIES: "+UD8@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(UD8)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,UD8@_FillValue)
printVarSummary(saodP_cases_maps)
d_ud8dP  = new((/nvar,dimZ(1),dimZ(2)/),float,UD8@_FillValue)
printVarSummary(d_ud8dP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = UD8(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_ud8dP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(UD8,0),dim_stddev_n_Wrap(UD8,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_ud8P = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_ud8P)
copy_VarCoords(d_ud8P,d_ud8dP)
printVarSummary(d_ud8dP)
d_ud8dP@long_name = "Probability: difference between means"
d_ud8dP = where(abs(d_ud8dP).le.p95,d_ud8dP,d_ud8dP@_FillValue) ; Sig. ud8s
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)



dimZ = dimsizes(UD8)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,UD8@_FillValue)
printVarSummary(saodN_cases_maps)
d_ud8dN  = new((/nvar,dimZ(1),dimZ(2)/),float,UD8@_FillValue)
printVarSummary(d_ud8dN)
;
;
do n = 0,nvar-1
	n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
	print(n_saodN)
	valsN = ind(a_spi(:,n).le.-drought)
	print(valsN)
	saodN_cases_maps(n,valsN,:,:) = UD8(valsN,:,:)
	printMinMax(saodN_cases_maps,True)
	d_ud8dN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(UD8,0),dim_stddev_n_Wrap(UD8,0)^2, dimZ(0),True, False)
	delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_ud8N = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_ud8N)
copy_VarCoords(d_ud8N,d_ud8dN)
printVarSummary(d_ud8dN)
d_ud8dN@long_name = "Probability: difference between means"
d_ud8dN = where(abs(d_ud8dN).le.p95,d_ud8dN,d_ud8dN@_FillValue) ; Sig. ud8s
print("==============================================================")
printMinMax(d_ud8dN,True) 

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(UD8)

list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
f      = addfile ("/data/datasets/20cr/v3/chi.ud.vd.mon.850hPa.1900.2015.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  VD8   = f->vd(iYYYY,:,:)
  printVarSummary(VD8)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(VD8,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
VD8Clm      = clmMonTLL(VD8)
printVarSummary(VD8Clm)                   ; (12,nlat,nlon)   
VD8         = calcMonAnomTLL(VD8, VD8Clm)    ; replace with anonamlies
VD8@long_name = "ANOMALIES: "+VD8@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(VD8)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,VD8@_FillValue)
printVarSummary(saodP_cases_maps)
d_vd8dP  = new((/nvar,dimZ(1),dimZ(2)/),float,VD8@_FillValue)
printVarSummary(d_vd8dP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = VD8(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_vd8dP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(VD8,0),dim_stddev_n_Wrap(VD8,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_vd8P = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_vd8P)
copy_VarCoords(d_vd8P,d_vd8dP)
printVarSummary(d_vd8dP)
d_vd8dP@long_name = "Probability: difference between means"
;d_vd8dP = where(abs(d_vd8dP).le.p95,d_vd8dP,d_vd8dP@_FillValue) ; Sig. vd8s
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)


dimZ = dimsizes(VD8)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,VD8@_FillValue)
printVarSummary(saodN_cases_maps)
d_vd8dN  = new((/nvar,dimZ(1),dimZ(2)/),float,VD8@_FillValue)
printVarSummary(d_vd8dN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = VD8(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_vd8dN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(VD8,0),dim_stddev_n_Wrap(VD8,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_vd8N = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_vd8N)
copy_VarCoords(d_vd8N,d_vd8dN)
printVarSummary(d_vd8dN)
d_vd8dN@long_name = "Probability: difference between means"
;d_vd8dN = where(abs(d_vd8dN).le.p95,d_vd8dN,d_vd8dN@_FillValue) ; Sig. vd8s
print("==============================================================")
;printMinMax(d_vd8dN,True)
;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(VD8)
;list_vars()

;==============================================================
;E_U  = where((E_Ud.lt.p95.or.E_Vd.lt.p95),E_U,E_U@_FillValue)
;E_V  = where((E_Vd.lt.p95.or.E_Ud.lt.p95),E_V,E_V@_FillValue)
;printMinMax(E_U,True)

d_ud8P  = where((d_ud8dP.lt.p95.or.d_vd8dP.lt.p95),d_ud8P,d_ud8P@_FillValue)
d_vd8P  = where((d_vd8dP.lt.p95.or.d_ud8dP.lt.p95),d_vd8P,d_vd8P@_FillValue)
;
d_ud8N  = where((d_ud8dN.lt.p95.or.d_vd8dN.lt.p95),d_ud8N,d_ud8N@_FillValue)
d_vd8N  = where((d_vd8dN.lt.p95.or.d_ud8dN.lt.p95),d_vd8N,d_vd8N@_FillValue)
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
f      = addfile ("/data/datasets/20cr/v3/chi.ud.vd.mon.850hPa.1900.2015.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  CHI8   = f->chi(iYYYY,:,:)
  printVarSummary(CHI8)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(CHI8,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
CHI8Clm      = clmMonTLL(CHI8)
printVarSummary(CHI8Clm)                   ; (12,nlat,nlon)   
CHI8         = calcMonAnomTLL(CHI8, CHI8Clm)    ; replace with anonamlies
CHI8@long_name = "ANOMALIES: "+CHI8@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(CHI8)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,CHI8@_FillValue)
printVarSummary(saodP_cases_maps)
d_chi8dP  = new((/nvar,dimZ(1),dimZ(2)/),float,CHI8@_FillValue)
printVarSummary(d_chi8dP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = CHI8(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_chi8dP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(CHI8,0),dim_stddev_n_Wrap(CHI8,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_chi8P = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_chi8P)
copy_VarCoords(d_chi8P,d_chi8dP)
printVarSummary(d_chi8dP)
d_chi8dP@long_name = "Probability: difference between means"
d_chi8dP = where(abs(d_chi8dP).le.p95,d_chi8dP,d_chi8dP@_FillValue) ; Sig. chi8s
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)


dimZ = dimsizes(CHI8)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,CHI8@_FillValue)
printVarSummary(saodN_cases_maps)
d_chi8dN  = new((/nvar,dimZ(1),dimZ(2)/),float,CHI8@_FillValue)
printVarSummary(d_chi8dN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = CHI8(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_chi8dN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(CHI8,0),dim_stddev_n_Wrap(CHI8,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_chi8N = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_chi8N)
copy_VarCoords(d_chi8N,d_chi8dN)
printVarSummary(d_chi8dN)
d_chi8dN@long_name = "Probability: difference between means"
d_chi8dN = where(abs(d_chi8dN).le.p95,d_chi8dN,d_chi8dN@_FillValue) ; Sig. chi8s
print("==============================================================")
printMinMax(d_chi8dN,True)

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(CHI8)

list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
;==============================================================
   f      = addfile ("/data/datasets/sst/HadISST_sst.nc.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  HADI   = f->sst(iYYYY,:,:)
  printVarSummary(HADI)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(HADI,True)
;  HADI = HADI*86400.               ;Converts to K/day
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

list_vars()

;==============================================================
;==============================================================
;==============================================================
   f      = addfile ("/data/datasets/q1/q1q2.mon.20crv3.YANAI.apparent_heat.1900.2015.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  Q1   = dble2flt(f->q1(iYYYY,{500},:,:))
; qq   = dble2flt(f->q1(iYYYY,{1000},:,:))
; Q1 = qq - Q1
; delete(qq)
  printVarSummary(Q1)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(Q1,True)
;  Q1 = Q1*86400.               ;Converts to K/day

;==============================================================
;================================================================
;==============================================================
;==============================================================
Q1Clm      = clmMonTLL(Q1)
printVarSummary(Q1Clm)                   ; (12,nlat,nlon)   
Q1         = calcMonAnomTLL(Q1, Q1Clm)    ; replace with anonamlies
Q1@long_name = "ANOMALIES: "+Q1@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(Q1)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,Q1@_FillValue)
printVarSummary(saodP_cases_maps)
d_q1dP  = new((/nvar,dimZ(1),dimZ(2)/),float,Q1@_FillValue)
printVarSummary(d_q1dP)
;
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = Q1(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_q1dP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(Q1,0),dim_stddev_n_Wrap(Q1,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_q1P = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_q1P)
copy_VarCoords(d_q1P,d_q1dP)
printVarSummary(d_q1dP)
d_q1dP@long_name = "Probability: difference between means"
d_q1dP = where(abs(d_q1dP).le.p95,d_q1dP,d_q1dP@_FillValue) ; Sig. q1s
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)
dimZ = dimsizes(Q1)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,Q1@_FillValue)
printVarSummary(saodN_cases_maps)
d_q1dN  = new((/nvar,dimZ(1),dimZ(2)/),float,Q1@_FillValue)
printVarSummary(d_q1dN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = Q1(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_q1dN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(Q1,0),dim_stddev_n_Wrap(Q1,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_q1N = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_q1N)
copy_VarCoords(d_q1N,d_q1dN)
printVarSummary(d_q1dN)
d_q1dN@long_name = "Probability: difference between means"
d_q1dN = where(abs(d_q1dN).le.p95,d_q1dN,d_q1dN@_FillValue) ; Sig. q1s
print("==============================================================")
printMinMax(d_q1dN,True)

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(Q1)

list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
  wks = gsn_open_wks("eps","FIG_6")         ; send graphics to PNG file
  plot = new(nplots,graphic)                ; create graphic array ; only needed if paneling
  plotS = new(nplots,graphic)                ; 
  

  res                   = True
  res@gsnFrame 		= False ;; Tell NCL not to plot the plot, just yet.
  res@gsnDraw 		= False
  res@cnFillOn          = True
  res@cnFillPalette     = "MPL_bwr"
  res@gsnAddCyclic      = False
  res@cnLinesOn         = False
  res@mpLimitMode 	= "latlon"
  res@mpMinLatF 	= latS
  res@mpMaxLatF 	= latN
  res@mpMinLonF 	= lonL
  res@mpMaxLonF 	= lonR
  ;res@mpCenterLonF        = -90.
  res@pmTickMarkDisplayMode = "Always"
  ;res@mpFillDrawOrder      = "preDraw"
  res@mpFillOn            = False
  res@gsnAddCyclic         = True
  res@mpGeophysicalLineColor  = "black"
  res@mpGeophysicalLineThicknessF = 1.0
  res@mpCenterLonF = 	-140.
  ;res@mpCenterLonF = (res@mpMaxLonF + res@mpMinLonF)*0.5
  ;res@mpFillDrawOrder = "postdraw"
  ;res@mpLandFillColor = (/1.0,1.0,1.0,0.0/) ; r,g,b,opacity
  ;res@mpOceanFillColor = (/1.0,1.0,1.0,1.0/) ; r,g,b,opacity
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -1.0
  res@cnMaxLevelValF       =  1.0
  res@cnLevelSpacingF      =  0.1
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
 ; res1@mpFillDrawOrder      = "preDraw"
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
  opt@gsnShadeFillScaleF = 1.2
  opt@gsnShadeFillDotSizeF = 0.001
  ;res@gsnCenterString           = "Linear trend of sea surface heaight"
  ;res@lbTitleString      = "Sea surface height (10~S~-2~N~m/year)"
  ;res@gsnLeftString  = "lag" +  ccr&lag(n)
 ;res@gsnLeftString  = DATA_NAMES(n)
  ;res@gsnCenterString  = hdata_names(n)

   delete(res@cnFillPalette)
   res@cnFillPalette        	= "amwg_blueyellowred"       ;different colour bar
   res@gsnCenterString  	= ""
   res@gsnLeftString  		= ""
   res@gsnRightString  		= ""

   do n=0,nvar-1,1
   print(n)
   plot(n) = gsn_csm_contour_map_ce(wks,d_hadiP(n,:,:),res)  ;           ; 
   plotS(n) = gsn_csm_contour(wks,d_hadidP(n,:,:),res1)       ;
   plotS(n) = gsn_contour_shade(plotS(n),p95,d_hadidP@_FillValue,opt)
   overlay(plot(n),plotS(n))
   plot(n) = plot(n)
end do
delete(n)

 do n=0,nvar-1,1
   print(n)
   plot(nvar+n) = gsn_csm_contour_map_ce(wks,d_hadiN(n,:,:),res)  ;           ; 
   plotS(nvar+n) = gsn_csm_contour(wks,d_hadidN(n,:,:),res1)       ;
   plotS(nvar+n) = gsn_contour_shade(plotS(nvar+n),p95,d_hadidN@_FillValue,opt)
   overlay(plot(nvar+n),plotS(nvar+n))
   plot(nvar+n) = plot(nvar+n)
end do
delete(n)


 delete(res@cnMinLevelValF)
 delete(res@cnMaxLevelValF)
 delete(res@cnLevelSpacingF)
;===============================================================
;===============================================================
;===============================================================
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
  resP@lbTitleString                    = "Sea surface temperature (K)"
  resP@gsnPanelFigureStrings            = (/"a","b","c","d","e","f"/) ; add strings to panel
  resP@amJust                           = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF =  0.012
  resP@gsnPanelFigureStringsFont        =  "Helvetica-Bold"

  resP@txFont                           = "Helvetica-Bold"
 ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
;   gsn_panel(wks,plot(0:5),(/2,3/),resP)     ; now draw as one plot
;  gsn_panel(wks,plot(6:11),(/2,3/),resP)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================
;=====================================================================
;=====================================================================

   delete(res@cnFillPalette)
   delete(res@cnMinLevelValF)
   delete(res@cnMaxLevelValF)
   delete(res@cnLevelSpacingF)

   res@cnFillPalette        = "amwg_blueyellowred"       ;different colour bar
   res@cnMinLevelValF       =  -0.5            ; set min contour level
   res@cnMaxLevelValF       =  0.5             ; set max contour level
   res@cnLevelSpacingF      =  0.05            ; set contour spacing
   res@gsnCenterString  = ""
    do n=0,nvar-1,1
    print(n)
    plot(6*nvar+n) = gsn_csm_contour_map_ce(wks,d_q1P(n,:,:),res)  ;           ; 
    plotS(6*nvar+n) = gsn_csm_contour(wks,d_q1dP(n,:,:),res1)       ;
    plotS(6*nvar+n) = gsn_contour_shade(plotS(6*nvar+n),p95,d_q1dP@_FillValue,opt)
    overlay(plot(6*nvar+n),plotS(6*nvar+n))
    plot(6*nvar+n) = plot(6*nvar+n)
 end do
 delete(n)

  do n=0,nvar-1,1
    print(n)
    plot(7*nvar+n) = gsn_csm_contour_map_ce(wks,d_q1N(n,:,:),res)  ;           ; 
    plotS(7*nvar+n) = gsn_csm_contour(wks,d_q1dN(n,:,:),res1)       ;
    plotS(7*nvar+n) = gsn_contour_shade(plotS(7*nvar+n),p95,d_q1dN@_FillValue,opt)
    overlay(plot(7*nvar+n),plotS(7*nvar+n))
    plot(7*nvar+n) = plot(7*nvar+n)
 end do
 delete(n)
;==================================================================================
;==================================================================================
;=========================================================================
;===============================================================
;=====================================================================
  resY                                  = True         ; modify the panel plot
  resY@gsnDraw                          = True      ; don't draw yet
  resY@gsnFrame                         = False        ; don't advance frame yet
  resY@gsnPanelLabelBar                 = True        ; add common colorbar
  resY@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resY@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resY@gsnPanelTop                      = 0.50
  resY@gsnPanelBottom                   = 0.20
 
 ;resY@gsnPanelTop                      = 0.25
  ;resY@gsnPanelBottom                   = 0.00
  resY@gsnPanelLeft                     = 0.05
  resY@gsnPanelRight                    = 0.99
  resY@gsnMaximize                      = True         ; large format
  resY@gsnPaperOrientation              = "portrait"   ; force portrait
  resY@gsnLeftString                    = ""
  resY@lbLabelStride                   = 5
  ;resY@pmLabelBarParallelPosF          = 0.50
  ;resY@pmLabelBarOrthogonalPosF        = -0.11
  resY@lbOrientation                    = "vertical"
  resY@lbTitleFontHeightF               = 0.008
  resY@lbLabelFontHeightF               = 0.008
  resY@lbLeftMarginF                    = 0.10
  resY@lbRightMarginF                   = 0.55
  resY@lbTopMarginF                     = -0.65
  resY@lbBottomMarginF                  = -0.55
 ;resY@lbLabelOffsetF                   = 0.20
  resY@lbLabelFont                      = "Helvetica-Bold"     ; label font
  resY@lbTitleFont                      = "Helvetica-Bold"     ; label font
  ;resY@lbLabelPosition                 = "Top"
  resY@lbTitleAngleF                    = 270.
  resY@lbTitlePosition                  = "Right"
  resY@lbTitleDirection                 = "Across"
  resY@lbTitleString                    = "Q1 at 500hPa (K/day)"
  resY@gsnPanelFigureStrings            = (/"m","n","o","p","q","r"/) ; add strings to panel
  resY@amJust                           = "TopLeft"
  resY@gsnPanelFigureStringsFontHeightF =  0.012
  resY@gsnPanelFigureStringsFont        =  "Helvetica-Bold"
  resY@txFont                           = "Helvetica-Bold"
  ;resY@txString                        = "SST trends: 1984-2008"
  ;resY@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
   gsn_panel(wks,plot(18:),(/2,3/),resY)     ; now draw as one plot
;===============================================================
;===============================================================

;==================================================================================
;==================================================================================
;==================================================================================
;==================================================================================
  delete(res@cnFillPalette)
  res@cnFillPalette        = "GMT_panoply"                        ;different colour bar
  res@cnMinLevelValF       =  -2.0            ; set min contour level
  res@cnMaxLevelValF       =  2.0             ; set max contour level
  res@cnLevelSpacingF      =  0.2            ; set contour spacing
  res@gsnCenterString  = ""
;
  res@gsnScalarContour        = True
  res@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  res@vcRefMagnitudeF         = 1.0             ; define vector ref mag
  res@vcRefAnnoString1        = "1 m s~S~-1~N~ "
  res@vcRefAnnoFontHeightF    = 0.012
  res@vcRefLengthF            = 0.050
  res@vcGlyphStyle            = "LineArrow"
  res@vcMinDistanceF          = 0.030
  res@vcLineArrowThicknessF   = 1.2
  res@vcLineArrowColor        = "foreground"           ; change vector color
  res@vcLineArrowHeadMaxSizeF = 0.35
;-----------------------------------------------------------------------------
;plotA0 = gsn_csm_vector_scalar_map(wks,pc1uU(0,:,:),pc1uV(0,:,:),pc1uP(0,:,:),res)  ;

  res@gsnCenterString  = ""
  res@gsnLeftString  = ""
  res@gsnRightString  = ""
;=========================200hPa level=============
 do n=0,nvar-1,1
   print(n)
   plot(2*nvar+n) = gsn_csm_vector_scalar_map(wks,d_udP(n,:,:),d_vdP(n,:,:),d_chiP(n,:,:),res)  ;           
   plotS(2*nvar+n) = gsn_csm_contour(wks,d_chidP(n,:,:),res1)       ;
   plotS(2*nvar+n) = gsn_contour_shade(plotS(2*nvar+n),p95,d_chidP@_FillValue,opt)
   overlay(plot(2*nvar+n),plotS(2*nvar+n))
   plot(2*nvar+n) = plot(2*nvar+n)
end do
delete(n)

 do n=0,nvar-1,1
   print(n)
   plot(3*nvar+n) = gsn_csm_vector_scalar_map(wks,d_udN(n,:,:),d_vdN(n,:,:),d_chiN(n,:,:),res)             ; 
   plotS(3*nvar+n) = gsn_csm_contour(wks,d_chidN(n,:,:),res1)       
   plotS(3*nvar+n) = gsn_contour_shade(plotS(3*nvar+n),p95,d_chidN@_FillValue,opt)
   overlay(plot(3*nvar+n),plotS(3*nvar+n))
   plot(3*nvar+n) = plot(3*nvar+n)
end do
delete(n)

;=========================850hPa level=============

 do n=0,nvar-1,1
   print(4*nvar+n)
   plot(4*nvar+n) = gsn_csm_vector_scalar_map(wks,d_ud8P(n,:,:),d_vd8P(n,:,:),d_chi8P(n,:,:),res)  ;           
   plotS(4*nvar+n) = gsn_csm_contour(wks,d_chi8dP(n,:,:),res1)       ;
   plotS(4*nvar+n) = gsn_contour_shade(plotS(4*nvar+n),p95,d_chi8dP@_FillValue,opt)
   overlay(plot(4*nvar+n),plotS(4*nvar+n))
   plot(4*nvar+n) = plot(4*nvar+n)
end do
delete(n)

 do n=0,nvar-1,1
   print(n)
   plot(5*nvar+n) = gsn_csm_vector_scalar_map(wks,d_ud8N(n,:,:),d_vd8N(n,:,:),d_chi8N(n,:,:),res)             ; 
   plotS(5*nvar+n) = gsn_csm_contour(wks,d_chi8dN(n,:,:),res1)
   plotS(5*nvar+n) = gsn_contour_shade(plotS(5*nvar+n),p95,d_chi8dN@_FillValue,opt)
   overlay(plot(5*nvar+n),plotS(5*nvar+n))
   plot(5*nvar+n) = plot(5*nvar+n)
end do
delete(n)



delete(res@gsnScalarContour)
delete(res@vcRefAnnoOrthogonalPosF)
delete(res@vcRefMagnitudeF)
delete(res@vcRefAnnoString1)
delete(res@vcRefLengthF)
delete(res@vcGlyphStyle)
delete(res@vcMinDistanceF)
delete(res@vcLineArrowThicknessF)
delete(res@vcLineArrowColor)
delete(res@vcLineArrowHeadMaxSizeF)
;========================================================
;===============================================================
;===============================================================
;=====================================================================
  resQ                                  = True         ; modify the panel plot
  resQ@gsnDraw                          = True      ; don't draw yet
  resQ@gsnFrame                         = False        ; don't advance frame yet
  resQ@gsnPanelLabelBar                 = True        ; add common colorbar
  resQ@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resQ@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resQ@gsnPanelTop                      = 0.99
  resQ@gsnPanelBottom                   = 0.69

  ;resQ@gsnPanelTop                      = 0.74
  ;resQ@gsnPanelBottom                   = 0.44
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
  resQ@lbTitleString                    = "850hPa velocity potential (10~S~6~N~ m s~S~-1~N~)"
  resQ@gsnPanelFigureStrings            = (/"a","b","c","d","e","f"/) ; add strings to panel
  resQ@amJust                           = "TopLeft"
  resQ@gsnPanelFigureStringsFontHeightF =  0.012
  resQ@gsnPanelFigureStringsFont        =  "Helvetica-Bold"
  resQ@txFont                           = "Helvetica-Bold"
  ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
   gsn_panel(wks,plot(12:17),(/2,3/),resQ)     ; now draw as one plot
;===============================================================
;===============================================================
;    gsn_panel(wks,plot(0:5),(/2,3/),resQ)     ; now draw as one plot
;===============================================================
;===============================================================
;===============================================================
;=====================================================================
;===============================================================
  resT                                  = True         ; modify the panel plot
  resT@gsnDraw                          = True      ; don't draw yet
  resT@gsnFrame                         = False        ; don't advance frame yet
  resT@gsnPanelLabelBar                 = True        ; add common colorbar
  resT@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resT@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resT@gsnPanelTop                      = 0.74
  resT@gsnPanelBottom                   = 0.44

 ; resT@gsnPanelTop                      = 0.50
 ; resT@gsnPanelBottom                   = 0.20
  resT@gsnPanelLeft                     = 0.05
  resT@gsnPanelRight                    = 0.99
  resT@gsnMaximize                      = True         ; large format
  resT@gsnPaperOrientation              = "portrait"   ; force portrait
  resT@gsnLeftString                    = ""
  resT@lbLabelStride                   = 5
  ;resT@pmLabelBarParallelPosF          = 0.50
  ;resT@pmLabelBarOrthogonalPosF        = -0.11
  resT@lbOrientation                    = "vertical"
  resT@lbTitleFontHeightF               = 0.008
  resT@lbLabelFontHeightF               = 0.008
  resT@lbLeftMarginF                    = 0.10
  resT@lbRightMarginF                   = 0.55
  resT@lbTopMarginF                     = -0.65
  resT@lbBottomMarginF                  = -0.55
 ;resT@lbLabelOffsetF                   = 0.20
  resT@lbLabelFont                      = "Helvetica-Bold"     ; label font
  resT@lbTitleFont                      = "Helvetica-Bold"     ; label font
  ;resT@lbLabelPosition                 = "Top"
  resT@lbTitleAngleF                    = 270.
  resT@lbTitlePosition                  = "Right"
  resT@lbTitleDirection                 = "Across"
  resT@lbTitleString                    = "200hPa velocity potential (10~S~6~N~ m s~S~-1~N~)"
  ;resT@gsnPanelFigureStrings            = (/"a","b","c","d","e","f"/) ; add strings to panel 
  resT@gsnPanelFigureStrings            = (/"g","h","i","j","k","l"/) ; add strings to panel
  resT@amJust                           = "TopLeft"
  resT@gsnPanelFigureStringsFontHeightF =  0.012
  resT@gsnPanelFigureStringsFont        =  "Helvetica-Bold"

  resT@txFont                           = "Helvetica-Bold"

  ;resT@txString                        = "SST trends: 1984-2008"
  ;resT@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plot(6:11),(/2,3/),resT)     ; now draw as one plot
;=====================================================================
;=====================================================================
;=====================================================================
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
  txres@txFont        = "Helvetica-Bold"
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
var_names1 = (/"","","~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5",\
	"~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5","~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5"/)
printVarSummary(var_names1)
print(var_names1)

  txres               = True         ; Text resources
  txres@txFontHeightF = 0.010
  txres@txJust        = "CenterLeft"
  txres@txFont        = "Helvetica"
  txres@txAngleF      =  90.

  labels1  = var_names1
  ypos1    = fspan(0.04, 0.88,dimsizes(var_names1))

 do i = 0,dimsizes(labels1)-1,1
     gsn_text_ndc(wks,labels1(i),0.035,ypos1(i),txres)
  end do
delete(i)
delete(txres)
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;=============================================================================
;=====================================================================
  resT1                                  = True         ; modify the panel plot
  resT1@gsnDraw                          = True      ; don't draw yet
  resT1@gsnFrame                         = False        ; don't advance frame yet
  resT1@gsnPanelLabelBar                 = False        ; add common colorbar
  resT1@gsnPanelYWhiteSpacePercent       = 0.0    ; default is 1.0
  resT1@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resT1@gsnPanelTop                      = 0.99
  resT1@gsnPanelBottom                   = 0.01
  resT1@gsnPanelLeft                     = 0.55
  resT1@gsnPanelRight                    = 0.99
  resT1@gsnMaximize                      = True         ; large format
  resT1@gsnPaperOrientation              = "portrait"   ; force portrait
  resT1@gsnLeftString                    = ""
  ;resT1@txString                        = "SST trends: 1984-2008"
  ;resT1@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
 ; gsn_panel(wks,plot(3:),(/3,1/),resT1)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================
frame(wks)
end
