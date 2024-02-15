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
;==============================================================
;==============================================================
f      = addfile ("/data/datasets/sst/COBE_sst.mon.mean_V2.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  COBE   = f->sst(iYYYY,:,:)
  printVarSummary(COBE)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(COBE,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
COBEClm      = clmMonTLL(COBE)
printVarSummary(COBEClm)                   ; (12,nlat,nlon)   
COBE         = calcMonAnomTLL(COBE, COBEClm)    ; replace with anonamlies
COBE@long_name = "ANOMALIES: "+COBE@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(COBE)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,COBE@_FillValue)
printVarSummary(saodP_cases_maps)
d_cobedP  = new((/nvar,dimZ(1),dimZ(2)/),float,COBE@_FillValue)
printVarSummary(d_cobedP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = COBE(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_cobedP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(COBE,0),dim_stddev_n_Wrap(COBE,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_cobeP = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_cobeP)
copy_VarCoords(d_cobeP,d_cobedP)
printVarSummary(d_cobedP)
d_cobedP@long_name = "Probability: difference between means"
d_cobedP = where(abs(d_cobedP).le.p95,d_cobedP,d_cobedP@_FillValue) ; Sig. cobes
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)


dimZ = dimsizes(COBE)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,COBE@_FillValue)
printVarSummary(saodN_cases_maps)
d_cobedN  = new((/nvar,dimZ(1),dimZ(2)/),float,COBE@_FillValue)
printVarSummary(d_cobedN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = COBE(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_cobedN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(COBE,0),dim_stddev_n_Wrap(COBE,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_cobeN = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_cobeN)
copy_VarCoords(d_cobeN,d_cobedN)
printVarSummary(d_cobedN)
d_cobedN@long_name = "Probability: difference between means"
d_cobedN = where(abs(d_cobedN).le.p95,d_cobedN,d_cobedN@_FillValue) ; Sig. cobes
print("==============================================================")
printMinMax(d_cobedN,True)

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(COBE)

list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;================================================================
;==============================================================
;==============================================================
;==============================================================
;==============================================================
;==============================================================
f      = addfile("/data/datasets/sst/NOAA_sst.mnmean.v5.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  ERSST   = f->sst(iYYYY,:,:)
  printVarSummary(ERSST)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(ERSST,True)
;==============================================================
;================================================================
;==============================================================
;==============================================================
ERSSTClm      = clmMonTLL(ERSST)
printVarSummary(ERSSTClm)                   ; (12,nlat,nlon)   
ERSST         = calcMonAnomTLL(ERSST, ERSSTClm)    ; replace with anonamlies
ERSST@long_name = "ANOMALIES: "+ERSST@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(ERSST)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,ERSST@_FillValue)
printVarSummary(saodP_cases_maps)
d_ersstdP  = new((/nvar,dimZ(1),dimZ(2)/),float,ERSST@_FillValue)
printVarSummary(d_ersstdP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = ERSST(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_ersstdP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(ERSST,0),dim_stddev_n_Wrap(ERSST,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_ersstP = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_ersstP)
copy_VarCoords(d_ersstP,d_ersstdP)
printVarSummary(d_ersstdP)
d_ersstdP@long_name = "Probability: difference between means"
d_ersstdP = where(abs(d_ersstdP).le.p95,d_ersstdP,d_ersstdP@_FillValue) ; Sig. erssts
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)


dimZ = dimsizes(ERSST)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,ERSST@_FillValue)
printVarSummary(saodN_cases_maps)
d_ersstdN  = new((/nvar,dimZ(1),dimZ(2)/),float,ERSST@_FillValue)
printVarSummary(d_ersstdN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = ERSST(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_ersstdN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(ERSST,0),dim_stddev_n_Wrap(ERSST,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_ersstN = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_ersstN)
copy_VarCoords(d_ersstN,d_ersstdN)
printVarSummary(d_ersstdN)
d_ersstdN@long_name = "Probability: difference between means"
d_ersstdN = where(abs(d_ersstdN).le.p95,d_ersstdN,d_ersstdN@_FillValue) ; Sig. erssts
print("==============================================================")
printMinMax(d_ersstdN,True)

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(ERSST)

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
   f      = addfile ("//data/datasets/sst/KAPLAN_sst.mon.anom_V2.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  KAPL   = dble2flt(f->sst(iYYYY,:,:))
  printVarSummary(KAPL)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(KAPL,True)
;  KAPL = KAPL*86400.               ;Converts to K/day

;==============================================================
;================================================================
;==============================================================
;==============================================================
KAPLClm      = clmMonTLL(KAPL)
printVarSummary(KAPLClm)                   ; (12,nlat,nlon)   
KAPL         = calcMonAnomTLL(KAPL, KAPLClm)    ; replace with anonamlies
KAPL@long_name = "ANOMALIES: "+KAPL@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(KAPL)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,KAPL@_FillValue)
printVarSummary(saodP_cases_maps)
d_kapldP  = new((/nvar,dimZ(1),dimZ(2)/),float,KAPL@_FillValue)
printVarSummary(d_kapldP)
;
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = KAPL(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_kapldP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(KAPL,0),dim_stddev_n_Wrap(KAPL,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_kaplP = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_kaplP)
copy_VarCoords(d_kaplP,d_kapldP)
printVarSummary(d_kapldP)
d_kapldP@long_name = "Probability: difference between means"
d_kapldP = where(abs(d_kapldP).le.p95,d_kapldP,d_kapldP@_FillValue) ; Sig. kapls
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)
dimZ = dimsizes(KAPL)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,KAPL@_FillValue)
printVarSummary(saodN_cases_maps)
d_kapldN  = new((/nvar,dimZ(1),dimZ(2)/),float,KAPL@_FillValue)
printVarSummary(d_kapldN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = KAPL(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_kapldN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(KAPL,0),dim_stddev_n_Wrap(KAPL,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_kaplN = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_kaplN)
copy_VarCoords(d_kaplN,d_kapldN)
printVarSummary(d_kapldN)
d_kapldN@long_name = "Probability: difference between means"
d_kapldN = where(abs(d_kapldN).le.p95,d_kapldN,d_kapldN@_FillValue) ; Sig. kapls
print("==============================================================")
printMinMax(d_kapldN,True)

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(KAPL)

list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
  wks = gsn_open_wks("eps","FIG_5")         ; send graphics to PNG file
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

;=============================================================
;=============================================================
;==============Extreme wet cases
do n=0,nvar-1,1

   ;plot COBE
   print(n)
   plot(n) = gsn_csm_contour_map_ce(wks,d_cobeP(n,:,:),res)  ;           ; 
   plotS(n) = gsn_csm_contour(wks,d_cobedP(n,:,:),res1)       ;
   plotS(n) = gsn_contour_shade(plotS(n),p95,d_cobedP@_FillValue,opt)
   overlay(plot(n),plotS(n))
   plot(n) = plot(n)

   ;plot ERSST
   print(nvar+n)
   plot(nvar+n) = gsn_csm_contour_map_ce(wks,d_ersstP(n,:,:),res)  ;           ; 
   plotS(nvar+n) = gsn_csm_contour(wks,d_ersstdP(n,:,:),res1)       ;
   plotS(nvar+n) = gsn_contour_shade(plotS(nvar+n),p95,d_ersstdP@_FillValue,opt)
   overlay(plot(nvar+n),plotS(nvar+n))
   plot(nvar+n) = plot(nvar+n)

    ;plot HadISST
   print(2*nvar+n)
   plot(2*nvar+n) = gsn_csm_contour_map_ce(wks,d_hadiP(n,:,:),res)  ;           ; 
   plotS(2*nvar+n) = gsn_csm_contour(wks,d_hadidP(n,:,:),res1)       ;
   plotS(2*nvar+n) = gsn_contour_shade(plotS(2*nvar+n),p95,d_hadidP@_FillValue,opt)
   overlay(plot(2*nvar+n),plotS(2*nvar+n))
   plot(2*nvar+n) = plot(2*nvar+n)

   ;plot KAPLAN
   print(3*nvar+n)
   plot(3*nvar+n) = gsn_csm_contour_map_ce(wks,d_kaplP(n,:,:),res)  ;           ; 
   plotS(3*nvar+n) = gsn_csm_contour(wks,d_kapldP(n,:,:),res1)       ;
   plotS(3*nvar+n) = gsn_contour_shade(plotS(3*nvar+n),p95,d_kapldP@_FillValue,opt)
   overlay(plot(3*nvar+n),plotS(3*nvar+n))
   plot(3*nvar+n) = plot(3*nvar+n)


end do
delete(n)
print("==============================================================================")
print("==============================================================================")
print("-------------------------------Wet cases done----------------------------------------------")
print("==============================================================================")
print("==============================================================================")
;===============================================================
;===============================================================
;=============================================================
;==================Extreme dry cases
do n=0,nvar-1,1
   ;plot COBE
   print(4*nvar+n)
   plot(4*nvar+n) = gsn_csm_contour_map_ce(wks,d_cobeN(n,:,:),res)  ;           ; 
   plotS(4*nvar+n) = gsn_csm_contour(wks,d_cobedN(n,:,:),res1)       ;
   plotS(4*nvar+n) = gsn_contour_shade(plotS(4*nvar+n),p95,d_cobedN@_FillValue,opt)
   overlay(plot(4*nvar+n),plotS(4*nvar+n))
   plot(4*nvar+n) = plot(4*nvar+n)

   ;plot ERSST
   print(5*nvar+n)
   plot(5*nvar+n) = gsn_csm_contour_map_ce(wks,d_ersstN(n,:,:),res)  ;           ; 
   plotS(5*nvar+n) = gsn_csm_contour(wks,d_ersstdN(n,:,:),res1)       ;
   plotS(5*nvar+n) = gsn_contour_shade(plotS(5*nvar+n),p95,d_ersstdN@_FillValue,opt)
   overlay(plot(5*nvar+n),plotS(5*nvar+n))
   plot(5*nvar+n) = plot(5*nvar+n)

    ;plot HadISST
   print(6*nvar+n)
   plot(6*nvar+n) = gsn_csm_contour_map_ce(wks,d_hadiN(n,:,:),res)  ;           ; 
   plotS(6*nvar+n) = gsn_csm_contour(wks,d_hadidN(n,:,:),res1)       ;
   plotS(6*nvar+n) = gsn_contour_shade(plotS(6*nvar+n),p95,d_hadidN@_FillValue,opt)
   overlay(plot(6*nvar+n),plotS(6*nvar+n))
   plot(6*nvar+n) = plot(6*nvar+n)

   ;plot KAPLAN
   print(7*nvar+n)
   plot(7*nvar+n) = gsn_csm_contour_map_ce(wks,d_kaplN(n,:,:),res)  ;           ; 
   plotS(7*nvar+n) = gsn_csm_contour(wks,d_kapldN(n,:,:),res1)       ;
   plotS(7*nvar+n) = gsn_contour_shade(plotS(7*nvar+n),p95,d_kapldN@_FillValue,opt)
   overlay(plot(7*nvar+n),plotS(7*nvar+n))
   plot(7*nvar+n) = plot(7*nvar+n)


end do
delete(n)

;===============================================================
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
  resP@gsnPanelBottom                   = 0.50
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
  resP@lbTitleString                    = "SST anomaly (K)"
  resP@gsnPanelFigureStrings            = (/"a","b","c","d","e","f","g","h","i","j","k","l"/) ; add strings to panel
  resP@amJust                           = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF =  0.012
  resP@gsnPanelFigureStringsFont        =  "Helvetica-Bold"

  resP@txFont                           = "Helvetica-Bold"
 ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
   gsn_panel(wks,plot(0:11),(/4,3/),resP)     ; now draw as one plot
;  gsn_panel(wks,plot(6:11),(/2,3/),resP)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================
;=====================================================================
;=====================================================================
  resY                                  = True         ; modify the panel plot
  resY@gsnDraw                          = True      ; don't draw yet
  resY@gsnFrame                         = False        ; don't advance frame yet
  resY@gsnPanelLabelBar                 = True        ; add common colorbar
  resY@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resY@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resY@gsnPanelTop                      = 0.50
  resY@gsnPanelBottom                   = 0.01
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
  resY@lbTitleString                    = "SST anomaly (K)"
  resY@gsnPanelFigureStrings            = (/"m","n","o","p","q","r","s","t","u","v","w","x"/) ; add strings to panel
  resY@amJust                           = "TopLeft"
  resY@gsnPanelFigureStringsFontHeightF =  0.012
  resY@gsnPanelFigureStringsFont        =  "Helvetica-Bold"
  resY@txFont                           = "Helvetica-Bold"
  ;resY@txString                        = "SST trends: 1984-2008"
  ;resY@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
   gsn_panel(wks,plot(12:),(/4,3/),resY)     ; now draw as one plot
;===============================================================
;===============================================================
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
     gsn_text_ndc(wks,labels0(i),xpos0(i),0.485,txres)
  end do
delete(i)
delete(txres)
;=====================================================================
;=====================================================================
var_names1 = (/"KAPLAN","HadISST","ERSST","COBE","","KAPLAN","HadISST","ERSST","COBE"/)
printVarSummary(var_names1)
print(var_names1)

  txres               = True         ; Text resources
  txres@txFontHeightF = 0.010
  txres@txJust        = "CenterLeft"
  txres@txFont        = "Helvetica"
  txres@txAngleF      =  90.

  labels1  = var_names1
  ypos1    = fspan(0.07, 0.88,dimsizes(var_names1))

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
