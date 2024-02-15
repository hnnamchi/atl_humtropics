begin
;
;======================================
yrStrt = 1930
yrLast = 2014
latS   = -40.
latN   =  40.
lonL   = -180.
lonR   =  180.
nplots =  5
nmos =12
xlabel = ispan(0,nmos-1,1)
print(xlabel)
yyyymm = yyyymm_time(yrStrt, yrLast, "integer")
printVarSummary(yyyymm)
dlen   =  1
rad    = 4.0*atan(1.0)/180.0
lag = 1		;lag-1 autocorrelation
mxlag = 20
p95 = 0.05
;
day_factor = 86400.
daysmonth = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,31./)
m_daysmonth = avg(daysmonth)
print(m_daysmonth)
;print(xxxxxxxxxxxxx)
dDATA = new((/24,72,144/),float,1e+20)                ;array to hold the PCs
printVarSummary(dDATA)
dDATAd = dDATA
;
a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
   lsdata = a->LSMASK
;   lsm  = landsea_mask(lsdata,data&lat,data&lon)
;   data = mask(data,lsm.eq.1,False)
;   data = mask(data,lsm.eq.3,False)


  f      = addfile ("/data/datasets/rain/gpcp_precip.mon.mean.nc","r")

  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  gpcp   = f->precip(iYYYY,:,:)
  printVarSummary(gpcp)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  gpcp  = lonFlip(gpcp)
  printMinMax(gpcp,True)
; gpcp = gpcp*day_factor*m_daysmonth
;==============================================================
;============================================================
  m_gpcp = dim_avg_n_Wrap(gpcp,0)   ; annual total, no weighting
  printVarSummary(m_gpcp)
;==============================================================
;==============================================================
;f      = addfile ("/data/datasets/rain/gpcp_precip.mon.mean.nc","r")
   f      = addfile ("/data/datasets/rain/gpcc_full_data_monthly_v2022_1891_2020_25.nc", "r")
;   f      = addfile ("/data/datasets/rain/full_data_monthly_v2022_1891_2020_025.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCC   = f->precip(iYYYY,:,:)
  printVarSummary(GPCC)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
;  GPCC = lonFlip(GPCC)
  printMinMax(GPCC,True)
; GPCC = GPCC*day_factor*m_daysmonth
;==============================================================
;============================================================
m_GPCC = dim_avg_n_Wrap(month_to_annual(GPCC,0),0)   ; annual total, no weighting
;
;m_GPCC = dim_avg_n_Wrap(month_to_annual_weighted(yyyymm,GPCC,0),0)   ; annual total, no weighting
;m_GPCC = dim_avg_n_Wrap(GPCC,0)   ; 
printVarSummary(m_GPCC)
;==============================================================
 ;  lsm  = landsea_mask(lsdata,GPCC&lat,GPCC&lon)
;   GPCC = mask(GPCC,lsm.eq.0,False)
;   delete(lsm)
;==============================================================
  GPCCClm      = clmMonTLL(GPCC)
  printVarSummary(GPCCClm)                   ; (12,nlat,nlon)
; GPCC         = calcMonAnomTLL(GPCC,GPCCClm)    ; replace with anonamlies
; GPCC@long_name = "ANOMALIES: "+GPCC@long_name
; GPCC = where(GPCC.gt.-10.and.GPCC.lt.40.,GPCC,GPCC@_FillValue)  
;==============================================================
;--------------------------------------------------------------
;==============================================================
printVarSummary(GPCCClm)
htp = new((/3,nmos/),float,1e+20)                ;array to hold the PCs
htp(0,:) =  wgt_areaave_Wrap(GPCCClm(month|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
htp(1,:) =  wgt_areaave_Wrap(GPCCClm(month|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
htp(2,:) =  wgt_areaave_Wrap(GPCCClm(month|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
htp!0 = "lev"
printVarSummary(htp)
print(htp)
delete(GPCC)
delete(GPCCClm)
;============================================================
f      = addfile ("/data/datasets/sst/UDEL_air.mon.mean.v401.nc","r")
;f      = addfile ("/data/datasets/era5/t2m_adaptor.mars.internal-1668238483.362303-27514-1-42e60d72-a455-4137-8539-9e6467e287ad.nc","r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  T2M   = f->air(iYYYY,:,:)
 ; T2M   = short2flt(f->t2m(iYYYY,:,:))
  printVarSummary(T2M)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)

  T2M!1 = "lat"
  T2M!2 = "lon"
;
  T2M = lonFlip(T2M)
  ;T2M = T2M - 273.15 
  printMinMax(T2M,True)
;==============================================================
;==============================================================
;   lsm  = landsea_mask(lsdata,T2M&lat,T2M&lon)
;   T2M = mask(T2M,lsm.eq.0,False)
;   delete(lsm)
;==============================================================
  T2MClm      = clmMonTLL(T2M)
  printVarSummary(T2MClm)             
;==============================================================
htt = new((/3,nmos/),float,1e+20)                ;array to hold the PCs
htt(0,:) =  wgt_areaave_Wrap(T2MClm(month|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
htt(1,:) =  wgt_areaave_Wrap(T2MClm(month|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
htt(2,:) =  wgt_areaave_Wrap(T2MClm(month|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
htt!0 = "lev"
printVarSummary(htt)
print(htt)
delete(T2M)
delete(T2MClm)
;
;
;=======================================================
yrStrt = 1900
yrLast = 2020
;=======================================================
   f      = addfile ("/data/datasets/rain/gpcc_full_data_monthly_v2022_1891_2020_25.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCC   = f->numgauge(iYYYY,:,:)
  printVarSummary(GPCC)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(GPCC,True)
;==============================================================
;============================================================
  gpcc = month_to_annual(GPCC,1)   ; annual total, no weighting
;==============================================================
;==============================================================
;--------------------------------------------------------------
;==============================================================
htg = new((/3,dimsizes(gpcc(:,0,0))/),float,gpcc@_FillValue)                ;array to hold the indices
htg(0,:) =  wgt_areaave_Wrap(gpcc(year|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
htg(1,:) =  wgt_areaave_Wrap(gpcc(year|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
htg(2,:) =  wgt_areaave_Wrap(gpcc(year|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
htg!0 = "lev"
printVarSummary(htg)
print(htg)
delete(GPCC)
delete(gpcc)
;=============================================================
;=============================================================
;=============================================================
  wks = gsn_open_wks("eps","FIG_1")         ; send graphics to PNG file
  plot = new(nplots,graphic)                ; create graphic array ; only needed if paneling
  plotS = new(nplots,graphic)                ; 

  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res@cnMinLevelValF       =  0.            ; set min contour level
  res@cnMaxLevelValF       =  3000.             ; set max contour level
  res@cnLevelSpacingF      =  300.            ; set contour spacing     
  res@gsnPolar             = "SH"
  ;res@mpProjection      = "LambertConformal"       ; choose projection
  res@mpFillOn             = False    ; turn off gray continents
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR
  ;res@mpCenterLonF 	    = -150.0 
  res@pmTickMarkDisplayMode = "Always"
  res@tmXBLabelFontHeightF = 0.012
  res@tmYLLabelFontHeightF = 0.012
  ;res@mpGeophysicalLineColor  = "transparent"
  ;res@mpFillColor	      = -1
  ;res@mpOceanFillColor	      = 1
;   res@mpFillDrawOrder      = "Draw"
;  res@mpOutlineBoundarySets = "National"
  ;res@mpDataSetName		= "Earth..4"
  ;res@mpDataBaseVersion		= "Ncarg4_1"
  ;res@mpFillOn              = True        ; Turn on map fill.
  ;;res@mpFillAreaSpecifiers  = (/"Water","Land"/)
  ;;res@mpSpecifiedFillColors = (/"transparent","transparent"/)
  ;;res@mpFillBoundarySets    = (/"Geophysical","Geophysical"/)
 ; res@mpAreaMaskingOn       = True            ; Indicate we want to 
 ; res@mpMaskAreaSpecifiers  = "Ocean"  ; mask land.
  ;res@mpPerimOn             = True            ; Turn on a perimeter.
  ;res@mpGridMaskMode        = "MaskOcean"      ; Mask grid over land.
  ;res@mpFillColors	 	= (/-1,0,28,-1/) ; Fill land and leave oceans
  ;res@mpOceanFillColor		= "grey"
  ;res@mpMaskAreaSpecifiers	= "Ocean"
;  res@mpAreaTypes		= 1
  ;res@gsnAddCyclic         = True
  res@cnFillOn             = True         ; turn on color fill
  res@cnFillPalette        = "CBR_wet"
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = True     ; turn off individual lb's
  ;res@lbOrientation        = "verticial"
  ;res@lbTitleFontHeightF   = 0.010
  ;res@lbLabelFontHeightF   = 0.010
  ;res@lbLabelFont          = "Helvetica-Bold"     ; label font
  ;res@lbTitleString        = ""
  ;res@lbTitleAngleF       = 270.
  ;res@lbTitlePosition      = "Right"
  ;res@lbTitleDirection     = "Across"
 ; res@lbTitleAngleF       = 90.
  ;res@lbTitlePosition     = "Right"
  ;res@lbTitleDirection    = "Across"
  ;res@lbTopMarginF         = 0.30
  ;res@lbBottomMarginF      = 0.35
  ;res@vpWidthF            = 0.40
  ;res@vpHeightF           = 0.80
  res@lbLabelStride        = 5
  res@gsnXRefLine         =  -20.          ; reflines
  ;res@pmLabelBarParallelPosF = 0.50
  ;res@pmLabelBarOrthogonalPosF = -0.11
  res@lbOrientation        = "vertical"
  res@lbTitleFontHeightF  = 0.008 
  res@lbLabelFontHeightF  = 0.008
  res@lbLeftMarginF       = 0.10
  res@lbRightMarginF      = 0.55
  ;res@lbLabelOffsetF	  = 0.20
  res@lbLabelFont   	  = "Helvetica-Bold"     ; label font
  ;res@lbLabelPosition	  = "Top"
  res@lbTitleAngleF       = 270.
  res@lbTitlePosition      = "Right"
  res@lbTitleDirection     = "Across"
  res@lbTitleString         = "Annual precipitation (mm)"
  res@gsnCenterString         = ""
  res@gsnLeftString           = ""
  res@gsnRightString          = ""
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
  res1@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res1@cnMinLevelValF       =  3.0            ; set min contour level
  res1@cnMaxLevelValF       =  20.0             ; set max contour level
  res1@cnLevelSpacingF      =  1.            ; set contour spacing  
  res1@gsnAddCyclic         = True
  res1@cnLinesOn            = True       ; True is default
  res1@cnLineLabelsOn       = False        ; True is default
  res1@cnFillOn              = False         ; turn on color fill
  res1@cnInfoLabelOn        = False
  res1@cnLineColor          = "grey15"        ;
  res1@gsnRightString   = ""
  res1@gsnLeftString   = ""
  res1@cnLineLabelDensityF =  5
;-----------------------------------------------------------------------------
  opt = True
  opt@gsnShadeFillType = "pattern"        ; color is the default
  opt@gsnShadeLow = 17                     ; use fill pattern #17
  opt@gsnShadeHigh = 17                     ; use fill pattern #17
  opt@gsnShadeFillScaleF = 1.5
  opt@gsnShadeFillDotSizeF = 0.001
  ;res@gsnCenterString           = "Linear trend of sea surface heaight"
  ;res@lbTitleString      = "Sea surface height (10~S~-2~N~m/year)"
  ;res@gsnLeftString  = "lag" +  ccr&lag(n)
 ;res@gsnLeftString  = DATA_NAMES(n)
  ;res@gsnCenterString  = hdata_names(n)
  
   res@gsnCenterString  = "Observations 1930-2014"
   plotA0 = gsn_csm_contour_map_ce(wks,m_GPCC,res)
   plotB0 = gsn_csm_contour(wks,m_gpcp,res1)
   overlay(plotA0,plotB0)
   plot(0) = plotA0
;==================================================================================
   r0               = True                        ; plot mods desired
   r0@gsnDraw       = False                       ; do not draw
   r0@gsnFrame      = False                       ; do not advance frame
   r0@tiMainString  = ""                       ; title
   r0@tiMainFontHeightF  = 0.025              
   r0@tiXAxisString = "Calendar month"                  ; yaxis
   r0@tiXAxisFontHeightF = 0.020
   r0@tiYAxisFontHeightF = 0.020
   r0@tiYAxisString = "Precipitation (mm month ~S~-1~N~)"                  ; yaxis
   r0@tmXBLabelFontHeightF = 0.020
   r0@tmYLLabelFontHeightF = 0.020
   r0@trYLog              = False                ; log scaling
   r0@trXLog              = False               ; log scaling
   r0@trYMinF             =  0.0                 ; manually set lower limit
   r0@trYMaxF             =  300.0           
   r0@trXMinF             =  -1.0                 ; manually set lower limit
   r0@trXMaxF             =  12.0                 ;   "          upper
   r0@xyLineColors        =  "blue"		;
   r0@tmXTBorderOn            =  True
   r0@tmXTOn                  =  True
   r0@tmYLFormat	      = "@*+^sg"	; use "e" symbol, don't force 0's (see documentation)
   r0@vpWidthF                = 0.40
   r0@vpHeightF               = 0.40
   r0@xyLineThicknesses   = (/1.5,1.5,1.5,1.5,1.5,1.5/)       ; Define line thicknesses 
   r0@xyDashPatterns      = (/0.,0.,0.,0.,0.,0./)           ; Dash patterns 
   r0@tmYLLabelFontColor = "blue"   ; and right axes are same.
   r0@tiYAxisFontColor  = "blue"
   ;r0@tmBorderLineColor = "deepskyblue"
   ;r0@tmYLMajorLineColor = "red" ; YR axis uses YL resources, can
   ;r0@tmYLMinorLineColor = "red" ; change by setting tmYUseLeft = False 
   ;r0@tmBorderLineColor =  "red"
   r0@tmXBMode = "Explicit"
   r0@tmXBValues = (/"0", "1","2","3","4","5","6","7","8","9","10","11"/)
   r0@tmXBLabels = (/"J", "F","M","A","M","J","J","A","S","O","N","D"/)
   ;r0@tmXBLabels = (/"-5", "-4","-3","-2","-1","0","+1","+2","+3","+4","+5","+6"/)
   ;r0@tmXBLabels = (/"Jan", "Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
   r0@tmXMajorGrid                = False          ; implement x grid 
   r0@tmXMajorGridThicknessF      = 1.0           ; 2.0 is default
   r0@tmXMajorGridLineDashPattern = 2             ; select short dash lines
   r0@tmXMajorGridLineColor	 = "black"
   r0@tmYMajorGrid                = False          ; implement y grid
   r0@tmYMajorGridThicknessF      = 1.0           ; 2.0 is default
   r0@tmYMajorGridLineDashPattern = 2             ; select short dash lines
   r0@tmYMajorGridLineColor	 = "black"
   r0@tiYAxisFontThicknessF  = 1.
   r0@tmXBMajorThicknessF    = 1.
   r0@tmXBMinorThicknessF    = 1.
   r0@tmYLMajorThicknessF    = 1.
   r0@tmYLMinorThicknessF    = 1.
   r0@tmYLLabelFontThicknessF= 1.
   r0@tmBorderThicknessF     = 1.


   r0@gsnXYBarChart         = True                 ; turn on bar chart
   r0@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
;***********************************************
   r1               = True                        ; plot mods desired
   r1@gsnDraw       = False                       ; do not draw
   r1@gsnFrame      = False                       ; do not advance frame
   r1@tiYAxisString = "Air temperature (~S~o~N~C)"      
   r1@tiYAxisAngleF  =  270. 
   r1@xyLineColors          = (/"brown","yellow3","deepskyblue","black","darksalmon","black"/)
   r1@xyLineThicknesses   = (/1.5,1.5,1.5,1.5,1.5,1.5/)       ; Define line thicknesses 
   r1@xyDashPatterns      = (/16.,0.,0.,0.,0.,0./)           ; Dash patterns 
   r1@tiXAxisFontHeightF = 0.017
   r1@tiYAxisFontHeightF = 0.017
   r1@tmXBLabelFontHeightF = 0.017
   r1@tmYRLabelFontHeightF = 0.017
   r1@tmYUseLeft          =  False
   r1@trYMinF             =  0.0                 ; manually set lower limit
   r1@trYMaxF             =  30.0                 ;   "          upper
   r1@trXMinF             =  -1.0                 ; manually set lower limit
   r1@trXMaxF             =  12.0                 ;   "          upper
   r1@vpWidthF                = 0.60
   r1@vpHeightF               = 0.30
   r1@tmXTBorderOn            =  True
   r1@tmXTOn                  =  False
   r1@tmXTMode = "Explicit"
   r1@tmXTValues = (/"0", "1","2","3","4","5","6","7","8","9","10","11"/)
   ;r1@tmXTLabels = (/"1", "2","3","4","5","6","7","8","10","10","11","12"/)
   r1@tmXBLabels = (/"J", "F","M","A","M","J","J","A","S","O","N","D"/)
  ; r1@tmXBLabels = (/"Jan", "Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  r1@tmYRLabelFontColor = "brown"   ; and right axes are same.
  r1@tiYAxisFontColor  = "brown"
  r1@tmXTLabelsOn        = False    ; have tick mark labels
  r1@tmXTOn              = True      ; have tick marks
  r1@tmYRLabelFontColor = "brown"   ; and right axes are same.
  r1@tiYAxisFontColor  = "brown"
 ; r1@tmBorderLineColor =  "deepskyblue"
  r1@tmYLBorderOn 	 = False
  r1@tmYRBorderOn	 = True
  r1@tmXTBorderOn	 = False
  r1@tmXBBorderOn	 = False
  ;r1@tmBorderLineColor = "deepskyblue"
  ;r1@tmYRMajorLineColor = "deepskyblue" ; YR axis uses YL r1ources, can
  ;r1@tmYRMinorLineColor = "deepskyblue" ; change by setting tmYUseLeft = False 
  ;r1@gsnYRefLine           = avg(RAPID)
  ;r1@gsnYRefLineColor     = "deepskyblue"
  r1@tmYRFormat   	=  "@*+^sg"          ; trim the uneccecary "0" in labels. 
   ;r1@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   ;r1@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
  ; r1@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
  ; r1@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   ;r1@tmXTMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   ;r1@tmXTMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   ;r1@tmYRMajorOutwardLengthF = 0.0               ; draw tickmarks inward
  ; r1@tmYRMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r1@tiYAxisFontThicknessF  = 1.
   r1@tmXBMajorThicknessF    = 1.
   r1@tmXBMinorThicknessF    = 1.
   r1@tmYLMajorThicknessF    = 1.
   r1@tmYLMinorThicknessF    = 1.
   r1@tmYLLabelFontThicknessF= 1.
   r1@tmBorderThicknessF     = 1.
;========================================================================
;========================================================================
  r0@tiMainString  = "Amazon basin"                       ; title
  plot(1)  =  gsn_csm_x2y2(wks,xlabel,xlabel,htp(lev|0,month|:),htt(lev|0,month|:),r0,r1)
  
  r0@tiMainString  = "Congo basin"                       ; title
  plot(2)  =  gsn_csm_x2y2(wks,xlabel,xlabel,htp(lev|1,month|:),htt(lev|1,month|:),r0,r1)

  r0@tiMainString  = "Maritime continent"                       ; title
  plot(3)  =  gsn_csm_x2y2(wks,xlabel,xlabel,htp(lev|2,month|:),htt(lev|2,month|:),r0,r1)   
;=======================================================================
;=======================================================================
;=======================================================================
   r2               = True                        ; plot mods desired
   r2@gsnDraw       = False                       ; do not draw
   r2@gsnFrame      = False                       ; do not advance frame
   r2@tiMainString  = ""                       ; title
   r2@tiMainFontHeightF  = 0.025
   r2@tiXAxisString = ""                  ; yaxis
   r2@tiXAxisFontHeightF = 0.012
   r2@tiYAxisFontHeightF = 0.012
   r2@tiYAxisString = "Gauges per grid-cell"                  ; yaxis
   r2@tmXBLabelFontHeightF = 0.012
   r2@tmYLLabelFontHeightF = 0.012
   r2@trYLog              = False                ; log scaling
   r2@trXLog              = False               ; log scaling
   r2@trYMinF             =  0.0                 ; manually set lower limit
   r2@trYMaxF             =  12.0
   r2@trXMinF             =  yrStrt-5                 ; manually set lower limit
   r2@trXMaxF             =  yrLast+5               ;   "          upper
   r2@xyLineColors          = (/"red","blue","grey50","black","darksalmon","black"/)
   r2@tmXTBorderOn            =  True
   r2@tmXTOn                  =  True
   r2@tmYLFormat              = "@*+^sg"        ; use "e" symbol, don't force 0's (see documentation)
   r2@vpWidthF                = 0.90
   r2@vpHeightF               = 0.35
   r2@xyLineThicknesses   = (/1.5,1.5,1.5,1.5,1.5,1.5/)       ; Define line thicknesses 
   r2@xyDashPatterns      = (/0.,0.,0.,0.,0.,0./)           ; Dash patterns
   ;r2@gsnXRefLine         =  (/1930.,2014.,2.,0.,0.,0./)           ; reflines
   ;r2@gsnXRefLineDashPattern = 2.
   ;r2@gsnXRefLineThicknessF = 0.1           ; reflines
   r2@tmYLLabelFontColor = "blue"   ; and right axes are same.
   r2@tiYAxisFontColor  = "blue"
   r2@tmXMajorGrid                = False          ; implement x grid 
   r2@tmXMajorGridThicknessF      = 1.0           ; 2.0 is default
   r2@tmXMajorGridLineDashPattern = 2             ; select short dash lines
   r2@tmXMajorGridLineColor      = "black"
   r2@tmYMajorGrid                = False          ; implement y grid
   r2@tmYMajorGridThicknessF      = 1.0           ; 2.0 is default
   r2@tmYMajorGridLineDashPattern = 2             ; select short dash lines
   r2@tmYMajorGridLineColor      = "black"
   r2@tiYAxisFontThicknessF  = 1.
   r2@tmXBMajorThicknessF    = 1.
   r2@tmXBMinorThicknessF    = 1.
   r2@tmYLMajorThicknessF    = 1.
   r2@tmYLMinorThicknessF    = 1.
   r2@tmYLLabelFontThicknessF= 1.
   r2@tmBorderThicknessF     = 1.
   ;r2@gsnXYBarChart         = True                 ; turn on bar chart
   ;r2@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
   ;===legends
   r2@pmLegendDisplayMode    = "Always"            ; turn on legend
   r2@pmLegendSide           = "Top"               ; Change location of 
   r2@pmLegendParallelPosF   = 0.20                 ; move units right
   r2@pmLegendOrthogonalPosF = -0.60                ; move units down
   r2@pmLegendWidthF         = 0.10                ; Change width and
   r2@pmLegendHeightF        = 0.08                ; height of legend.
   r2@lgLabelFontHeightF     = 0.010                 ; change font height
   r2@lgTitleOn              = False               ; turn on legend title
   r2@lgTitleString          = "SST indices"           ; create legend title
   r2@lgTitleFontHeightF     = .003                ; font of legend title
   r2@lgPerimOn              = False               ; turn off box around
   r2@xyExplicitLegendLabels = (/"Amazon basin","Congo basin","Maritime continent","","",""/)
   r2@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r2@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r2@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r2@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r2@tmXTMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r2@tmXTMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r2@tmYRMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r2@tmYRMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r2@tiYAxisFontThicknessF  = 1.
   r2@tmXBMajorThicknessF    = 1.
   r2@tmXBMinorThicknessF    = 1.
   r2@tmYLMajorThicknessF    = 1.
   r2@tmYLMinorThicknessF    = 1.
   r2@tmYLLabelFontThicknessF= 1.
   r2@tmBorderThicknessF     = 1.
;========================================================================
;========================================================================
;
  xlabel2 = ispan(yrStrt,yrLast,1)
  print(xlabel2)

  r0@tiMainString  = ""                       ; title
  plot(4)  =  gsn_csm_xy(wks,xlabel2,htg(lev|:,year|:),r2)
;=========================================================================
;=========================================================================
;=========================================================================
  txres5               = True
  txres5@txAngleF      = 0.          ; Rotate string clockwise 
  txres5@txFontHeightF = 0.021   ; Use same font height as left axis
  txres5@txFont                = "Helvetica-Bold"
 ; txid = gsn_create_text(wks, "DT anomaly (~S~o~N~C)", txres)
   txid5 = gsn_create_text(wks, "a", txres5);
   txid5Y = gsn_create_text(wks, "e", txres5);
; Move text string to center/right edge of plot.;
  amres5                  = True
  amres5@amParallelPosF   =  -0.45 ; 0.5 is the right edge of the plot, so
                                 ; 0.6 is a little further to the right.
  amres5@amOrthogonalPosF =  -0.42   ; This is the center of the plot.
  tt_p0X = gsn_add_annotation(plot(0),txid5,amres5)
  tt_p0Y = gsn_add_annotation(plot(4),txid5Y,amres5)

  txres5@txFontHeightF = 0.042   ; Use same font height as left axis
  amres5@amParallelPosF   =  -0.79 ; 0.5 is the right edge of the plot, so
  amres5@amOrthogonalPosF =  -0.53    ; This is the center of the plot.
  amres5@amJust           = "TopLeft"

 tt = (/"a","b","c","d","e","f"/)
 tt2 = (/"g","h","i","j","k","l","m","n","o"/)
create_tt = gsn_create_text(wks,tt,txres5);
create_tt2 = gsn_create_text(wks,tt2,txres5);
tt_p0 = new(6,graphic)                ; create graphic array ; only needed if paneling
tt_p2 = new(9,graphic)                ; create graphic array ; only needed if paneling
;---Attach the polyline
     do i = 1,nplots-2,1
	print(i)
      tt_p0(i) = gsn_add_annotation(plot(i),create_tt(i),amres5)
     end do
 delete(i)
;========================================================================
  latEQ = (/ 5.,  5.,  -10.,   -10., 5./)
  lonEQ = (/-80., -50., -50., -80.,-80./)
;---Resources for the polyline
  pres0                  = True           ; polyline mods desired
  pres0@gsLineThicknessF = 2.            ; line thickness   
  pres0@gsLineColor      = "red"         ; color of lines
  pres0@gsLineDashPattern = 0
  pres0@tfPolyDrawOrder   = "PostDraw"
  

 dum0 = gsn_add_polyline(wks,plot(0),lonEQ,latEQ,pres0)

 latEQ1 = (/5.,  5.,  -10.,   -10., 5./)
 lonEQ1 = (/10., 30., 30., 10.,10./)
 dum1 = gsn_add_polyline(wks,plot(0),lonEQ1,latEQ1,pres0)
 
 latEQ2 = (/5.,  5.,  -10.,   -10., 5./)
 lonEQ2 = (/100., 150., 150., 100.,100./)
 dum2 = gsn_add_polyline(wks,plot(0),lonEQ2,latEQ2,pres0)

;======================================================================== 
;========================================================================
;---Resources for the polyline
  pres0                  = True           ; polyline mods desired
  pres0@gsLineThicknessF = 0.5            ; line thickness   
  pres0@gsLineColor      = "black"         ; color of lines
  pres0@gsLineDashPattern = 2
;  pres0@tfPolyDrawOrder   = "postDraw"
;  ;r2@gsnXRefLine         =  (/1930.,2014.,2.,0.,0.,0./)           ; reflines
  y0 = (/0.,12.,12.,0.,0./)               ;95% confidence limit
  x0 = (/1930.,1930.,2014.,2014.,1930./)
 
  d4 =   gsn_add_polyline(wks,plot(4),x0,y0,pres0)

;delete(n)
;---------------------------------------------------------------------
;=====================================================================
;=====================================================================
;=====================================================================
  resP                                  = True         ; modify the panel plot
  resP@gsnDraw                          = True      ; don't draw yet
  resP@gsnFrame                         = False        ; don't advance frame yet
  resP@gsnPanelLabelBar                 = False        ; add common colorbar
  resP@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelTop                      = 0.99
  resP@gsnPanelBottom                   = 0.70
  resP@gsnPanelLeft                     = 0.01
  resP@gsnPanelRight                    = 0.99
  resP@lbTitleFontHeightF               = 0.010
  resP@lbLabelFontHeightF               = 0.010
  resP@lbLabelStride                    = 5
  resP@lbLabelFont                      = "Helvetica-Bold"     ; label font
  resP@lbTitleString                    = "Annual precipitation trends (mm/year)"
  ;resP@lbTitleString                   = "SST trend (~S~o~N~C per 35-yr)"
  resP@lbTopMarginF                     = 0.3
  resP@gsnMaximize                      = True         ; large format
  resP@gsnPaperOrientation              = "portrait"   ; force portrait
  resP@gsnLeftString                    = ""
  ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plot(0),(/1,1/),resP)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================
;=====================================================================
  resT                                  = True         ; modify the panel plot
  resT@gsnDraw                          = True      ; don't draw yet
  resT@gsnFrame                         = False        ; don't advance frame yet
  resT@gsnPanelLabelBar                 = False        ; add common colorbar
  resT@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resT@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resT@gsnPanelTop                      = 0.83
  resT@gsnPanelBottom                   = 0.33
  resT@gsnPanelLeft                     = 0.01
  resT@gsnPanelRight                    = 0.85
  resT@gsnMaximize                      = True         ; large format
  resT@gsnPaperOrientation              = "portrait"   ; force portrait
  resT@gsnLeftString                    = ""
  ;resT@txString                        = "SST trends: 1984-2008"
  ;resT@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plot(1:3),(/1,3/),resT)     ; now draw as one plot
;===============================================================
;===============================================================
  resS                                  = True         ; modify the panel plot
  resS@gsnDraw                          = True      ; don't draw yet
  resS@gsnFrame                         = False        ; don't advance frame yet
  resS@gsnPanelLabelBar                 = False        ; add common colorbar
  resS@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resS@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resS@gsnPanelTop                      = 0.45
  resS@gsnPanelBottom                   = 0.05
  resS@gsnPanelLeft                     = 0.01
  resS@gsnPanelRight                    = 0.85
  resS@gsnMaximize                      = True         ; large format
  resS@gsnPaperOrientation              = "portrait"   ; force portrait
  resS@gsnLeftString                    = ""
  ;resS@txString                        = "SST trends: 1984-2008"
  ;resS@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plot(4:4),(/1,1/),resS)     ; now draw as one plot
;===============================================================
;===============================================================
;===============================================================
;===============================================================
end
