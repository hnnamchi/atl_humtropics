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
nplots = 2
nmos =12
xlabel = ispan(0,nmos-1,1)
print(xlabel)
;

day_factor = 86400.
daysmonth = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,31./)
m_daysmonth = avg(daysmonth)
print(m_daysmonth)

;
;
d_histP = new((/24,72,144/),float,1e+20)                ;array to hold the Precipitation
printVarSummary(d_histP)
;
d_histT = new((/24,180,360/),float,1e+20)                ;array to hold the SSTs
printVarSummary(d_histT)
;


;
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
;
hdata_names = (/"ACCESS-CM2","ACCESS-ESM1-5","AWI-CM-1-1-MR","BCC-CSM2-MR","CanESM5","CESM2","CESM2-WACCM","CMCC-CM2-SR5","CMCC-ESM2","EC-Earth3","EC-Earth3-Veg-LR",\
        "EC-Earth3-Veg","FGOALS-f3-L","GFDL-ESM4","INM-CM5-0","IPSL-CM6A-LR","KACE-1-0-G",\
        "MIROC6","MPI-ESM1-2-HR","MPI-ESM1-2-LR","MRI-ESM2-0","NorESM2-LM","NorESM2-MM","TaiESM1"/)
print(hdata_names)
printVarSummary(hdata_names)
;
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
;  GPCC = GPCC*day_factor
  GPCC = GPCC*day_factor*m_daysmonth
  
  GPCC = lonFlip(GPCC)
;=============================================================
;==============================================================
;=============================================================
;   yy = GPCC	;temporary data
;   a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
;   lsdata = a->LSMASK
;   lsm  = landsea_mask(lsdata,GPCC&lat,GPCC&lon)
;;  GPCC = mask(GPCC,conform(GPCC,lsm,(/1,2/)).eq.0,False)
;  GPCC = mask(GPCC,lsm.eq.0,False)
;  delete(a)
;  delete(lsdata)
;  delete(lsm)
;==============================================================
  m_GPCC = dim_avg_n_Wrap(GPCC,0)
  printVarSummary(m_GPCC)
;==============================================================
delete(GPCC)
;delete(yy)
list_vars()
;
;
;
;==================================================================
;==================================================================
; Open the file: Read only the user specified period
;==================================================================
title  = str_upper(varT)+": "+hdata_names(nn)
print(title)

f    = addfiles(diriT+hdataT,"r")
  TIME   = f[nn]->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  HADI   = f[nn]->$varT$(iYYYY,:,:)

  HADI = lonFlip(HADI)
  printVarSummary(HADI)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(HADI,True)
;======================================================================
;======================================================================
;======================================================================
  m_HADI = dim_avg_n_Wrap(HADI,0)
  printVarSummary(m_HADI)
;======================================================================  
delete(HADI)
;======================================================================
;======================================================================
d_histP(nn,:,:) = (/m_GPCC/)
;
d_histT(nn,:,:) = (/m_HADI/)
;
printVarSummary(d_histP)
printVarSummary(d_histT)
delete(m_GPCC)
delete(m_HADI)
;
end do
delete(nn)
;
;
;
d_histT = where(d_histT.gt.-10.and.d_histT.lt.40.,d_histT,d_histT@_FillValue)
m_ensPRE = dim_avg_n_Wrap(d_histP,0)
m_ensSST = dim_avg_n_Wrap(d_histT,0)
printVarSummary(m_ensSST)
printVarSummary(m_ensPRE)
delete(d_histP)
delete(d_histT)
;
;
;
;============================================================
;============================================================
;==============================================================
;==============================================================
 f      = addfile ("/data/datasets/plots/sf/re_prate.mon.mean.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCC   = f->prate(iYYYY,:,:)
  printVarSummary(GPCC)       ; variable overview
  printMinMax(GPCC,True)
; GPCC = GPCC*86400.  
  GPCC = GPCC*86400.*30.437               ;Converts to mm/month


  ; f      = addfile ("/data/datasets/rain/gpcc_full_data_monthly_v2022_1891_2020_25.nc", "r")
  ;TIME   = f->time
  ;YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  ;iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  ;GPCC   = f->precip(iYYYY,:,:)
  
  GPCC = lonFlip(GPCC)
  printVarSummary(GPCC)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(GPCC,True)
;
  m_GPCC = dim_avg_n_Wrap(GPCC,0)
  printVarSummary(m_GPCC)       ; variable overview
;==============================================================
;
  f	=  addfile("/data/datasets/sst/HadISST_sst.nc.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  HADI   = f->sst(iYYYY,:,:)
 
;  HADI = lonFlip(HADI)
  printVarSummary(HADI)       ; variable overview
  HADI = where(HADI.gt.-10.and.HADI.lt.40.,HADI,HADI@_FillValue)
;  HADI = HADI + 273.15

  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(HADI,True)
;
  m_HADI = dim_avg_n_Wrap(HADI,0)
  printVarSummary(m_HADI)       ; variable overview
;==============================================================
;==============================================================
;==============================================================
;==============================================================
;Estimate the model biases
; copy_VarCoords(m_HADI,m_ensSST)
; copy_VarCoords(m_GPCC,m_ensPRE)

print("=================================================")

 printMinMax(m_HADI,True)
 printMinMax(m_ensSST,True)
print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
 printMinMax(m_GPCC,True)
 printMinMax(m_ensPRE,True)
print("==================================================")


 m_HADI = m_ensSST - m_HADI
 m_GPCC = m_ensPRE - m_GPCC
 printVarSummary(m_GPCC)       ; variable overview
 printVarSummary(m_HADI)       ; variable overview


;copy_VarCoords(HADIClm(0:nvar-1,:,:),m_sstP)
;
;
;
;==============================================================
;==============================================================
;==============================================================
  wks = gsn_open_wks("eps","FIG_9")         ; send graphics to PNG file
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
  res@cnMinLevelValF       = -50.0
  res@cnMaxLevelValF       =  50.0
  res@cnLevelSpacingF      =  5.
  res@lbLabelBarOn         = True
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
  res@lbLabelBarOn         =  True       ; turn off individual lb's
  res@lbOrientation        = "vertical"
  res@lbTitleFontHeightF   = .012
  res@lbLabelFontHeightF   = 0.012
  res@lbLeftMarginF        = 0.10
  res@lbRightMarginF       = 0.55
  res@lbLabelFont          = "Helvetica-Bold"     ; label font
  res@lbTitleAngleF        = 270.
  res@lbTitlePosition      = "Right"
  res@lbTitleDirection     = "Across"
  res@lbLabelStride        = 10
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
  ;res@gsnCenterString  = hdata_names(n)

   delete(res@cnFillPalette)
   res@cnFillPalette        = "GMT_panoply"                        ;different colour bar
   res@gsnCenterString  = ""
   res@gsnLeftString  = ""
   res@gsnRightString  = ""
   res@lbTitleString    = "Precipitation bias (mm/month)"

   plot(1) = gsn_csm_contour_map_ce(wks,m_GPCC,res)  
   
;========================================================
  delete(res@cnFillPalette)
  res@cnFillPalette            = "amwg_blueyellowred"       ;different colour bar
  res@cnMinLevelValF       =  -5.0            ; set min contour level
  res@cnMaxLevelValF       =  5.0             ; set max contour level
  res@cnLevelSpacingF      =  0.5            ; set contour spacing
  res@gsnCenterString  = ""
  res@lbTitleString   = "SST bias (K)"
  plot(0) = gsn_csm_contour_map_ce(wks,m_HADI,res)             ;

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
;  xpos0    = fspan(0.15, 0.70,dimsizes(var_names))

; do i = 0,dimsizes(labels0)-1,1
;     gsn_text_ndc(wks,labels0(i),xpos0(i),0.97,txres)
;  end do
;delete(i)
;delete(txres)
;=====================================================================
;=====================================================================
var_names1 = (/"~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5","~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5","~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5"/)
printVarSummary(var_names1)
print(var_names1)

  txres               = True         ; Text resources
  txres@txFontHeightF = 0.010
  txres@txJust        = "CenterLeft"
  txres@txFont        = "Helvetica"
  txres@txAngleF      =  90.

  labels1  = var_names1
  ypos1    = fspan(0.27, 0.88,dimsizes(var_names1))

; do i = 0,dimsizes(labels1)-1,1
;     gsn_text_ndc(wks,labels1(i),0.035,ypos1(i),txres)
;  end do
;delete(i)
;delete(txres)
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;=============================================================================
;===============================================================
  resP                                  = True         ; modify the panel plot
  resP@gsnDraw                          = True      ; don't draw yet
  resP@gsnFrame                         = False        ; don't advance frame yet
  resP@gsnPanelLabelBar                 = False        ; add common colorbar
  resP@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelTop                      = 0.99
  resP@gsnPanelBottom                   = 0.05
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
   gsn_panel(wks,plot(0:),(/2,1/),resP)     ; now draw as one plot
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
 ;  gsn_panel(wks,plot(6:11),(/2,3/),resQ)     ; now draw as one plot
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
