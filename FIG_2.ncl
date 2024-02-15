begin
;
;======================================
yrStrt = 1981
yrLast = 2014
latS   = -10.
latN   =  5.
lonL   = -80.
lonR   =  150.
nvar = 3
nplots =  12
nmos =12
daysmonth = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,31./)
print(daysmonth)
xlabel = ispan(0,nmos-1,1)
print(xlabel)
;
;f      = addfile ("/data/datasets/rain/gpcp_precip.mon.mean.nc","r")
   f      = addfile ("/data/datasets/rain/gpcc_full_data_monthly_v2022_1891_2020_25.nc", "r")
;   f      = addfile ("/data/datasets/rain/full_data_monthly_v2022_1891_2020_025.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCC   = f->precip(iYYYY,{latS:latN},:)
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
gpcc = new((/dimsizes(GPCC(:,0,0)),nvar/),float,GPCC@_FillValue)                ;array to hold the time series
gpcc(:,0) =  wgt_areaave_Wrap(GPCC(time|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
gpcc(:,1) =  wgt_areaave_Wrap(GPCC(time|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
gpcc(:,2) =  wgt_areaave_Wrap(GPCC(time|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
gpcc    = dim_standardize_n_Wrap(gpcc,1,0)  ; overwrite with deviations
gpcc!0 = "time"
printVarSummary(gpcc)
printMinMax(gpcc,True)
delete(GPCC)
;
;============================================================
   f      = addfile("/data/datasets/rain/cru_ts4.06.1901.2021.pre.dat.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire filei
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  CRU   = f->pre(iYYYY,{latS:latN},:)
  printVarSummary(CRU)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(CRU,True)
;==============================================================
;==============================================================
cru = new((/dimsizes(CRU(:,0,0)),nvar/),float,CRU@_FillValue)                ;array to hold the time series
cru(:,0) =  wgt_areaave_Wrap(CRU(time|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
cru(:,1) =  wgt_areaave_Wrap(CRU(time|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
cru(:,2) =  wgt_areaave_Wrap(CRU(time|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
cru    = dim_standardize_n_Wrap(cru,1,0)  ; overwrite with deviations
cru!0 = "time"
printVarSummary(cru)
printMinMax(cru,True)
delete(CRU)
;
;=================================================================

;=================================================================
f      = addfile ("/data/datasets/rain/gpcp_precip.mon.mean.nc","r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCP   = f->precip(iYYYY,:,:)
  printVarSummary(GPCP)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(GPCP,True)
  
  GPCP = lonFlip(GPCP)
;==============================================================
;==============================================================
gpcp = new((/dimsizes(GPCP(:,0,0)),nvar/),float,GPCP@_FillValue)                ;array to hold the time series
gpcp(:,0) =  wgt_areaave_Wrap(GPCP(time|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
gpcp(:,1) =  wgt_areaave_Wrap(GPCP(time|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
gpcp(:,2) =  wgt_areaave_Wrap(GPCP(time|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
gpcp    = dim_standardize_n_Wrap(gpcp,1,0)  ; overwrite with deviations
gpcp!0 = "time"
printVarSummary(gpcp)
printMinMax(gpcp,True)
delete(GPCP)

;
;=================================================================
f      = addfile ("/data/datasets/rain/cmap_precip.mon.mean.nc","r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  CMAP   = f->precip(iYYYY,:,:)
  printVarSummary(CMAP)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(CMAP,True)
  
  CMAP = lonFlip(CMAP)
;==============================================================
;==============================================================
cmap = new((/dimsizes(CMAP(:,0,0)),nvar/),float,CMAP@_FillValue)                ;array to hold the time series
cmap(:,0) =  wgt_areaave_Wrap(CMAP(time|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
cmap(:,1) =  wgt_areaave_Wrap(CMAP(time|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
cmap(:,2) =  wgt_areaave_Wrap(CMAP(time|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
cmap!0 = "time"
cmap    = dim_standardize_n_Wrap(cmap,1,0)  ; overwrite with deviations
printVarSummary(cmap)
printMinMax(cmap,True)
delete(CMAP)

;
;=================================================================
f      = addfile ("/data/datasets/rain/re_chirps-v2.0.monthly.nc","r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  CHIR   = f->precip(iYYYY,:,:)
  printVarSummary(CHIR)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(CHIR,True)

;   CHIR = lonFlip(CHIR)
;==============================================================
;==============================================================
chir = new((/dimsizes(CHIR(:,0,0)),nvar/),float,CHIR@_FillValue)                ;array to hold the time series
chir(:,0) =  wgt_areaave_Wrap(CHIR(time|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
chir(:,1) =  wgt_areaave_Wrap(CHIR(time|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
chir(:,2) =  wgt_areaave_Wrap(CHIR(time|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
chir    = dim_standardize_n_Wrap(chir,1,0)  ; overwrite with deviations
chir!0 = "time"
printVarSummary(chir)
printMinMax(chir,True)
delete(CHIR)
;
;Correlations
rCHIR = escorc_n(gpcc,chir,0,0)
print(rCHIR)
;
rCMAP = escorc_n(gpcc,cmap,0,0)
print(rCMAP)
;
rGPCP = escorc_n(gpcc,gpcp,0,0)
print(rGPCP)
;
rCRU = escorc_n(gpcc,cru,0,0)
print(rCRU)
;
;==============================================================
;==============================================================
;==============================================================
  wks = gsn_open_wks("eps","FIG_2")         ; send graphics to PNG file
  plot = new(nplots,graphic)                ; create graphic array ; only needed if paneling
  plotS = new(nplots,graphic)                ; 
   
   r0               = True                        ; plot mods desired
   r0@gsnDraw       = False                       ; do not draw
   r0@gsnFrame      = False                       ; do not advance frame
   r0@tiMainString  = ""                       ; title
   r0@tiMainFontHeightF  = 0.045              
   r0@tiXAxisString = ""                  ; yaxis
   r0@tiXAxisFontHeightF = 0.030
   r0@tiYAxisFontHeightF = 0.030
   r0@tiYAxisString = "CHIPRS"                  ; yaxis
   r0@tiXAxisString = "GPCC"                  ; xaxis
   r0@tmXBLabelFontHeightF = 0.030
   r0@tmYLLabelFontHeightF = 0.030
   r0@trYMinF             =  -4.0                 ; manually set lower limit
   r0@trYMaxF             =   4.0           
   r0@trXMinF             =  -4.0                 ; manually set lower limit
   r0@trXMaxF             =   4.0               ;   "          upper
   r0@tmXTBorderOn            =  True
   r0@tmXTOn                  =  True
   r0@tmYLFormat	      = "@*+^sg"	; use "e" symbol, don't force 0's (see documentation)
   r0@tmXBFormat              = "@*+^sg"        ;
   r0@gsnCenterStringFontHeightF  = 0.020 
   r0@gsnCenterStringOrthogonalPosF = -0.20
   r0@gsnCenterStringFontColor 	    = "red"
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
   r0@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r0@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r0@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r0@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r0@tmXTMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r0@tmXTMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r0@tmYRMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r0@tmYRMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r0@xyMarkLineMode	      = "Markers"
   r0@xyMarkerColor	      = "blue"
   r0@xyMarker		      =  16
   ;r0@gsnXYBarChart         = True                 ; turn on bar chart
   ;r0@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
   
;   r0@gsnYRefLineColor      = "red"
   ;r0@gsnYRefLineColor	    = 0.
;  r0@gsnYRefLineColor      = (/"black","transparent","black"/)
   ;r0@gsnBelowYRefLineColor = (/ "red", "transparent", "transparent"/)
   ;r0@gsnAboveYRefLineColor = (/ "transparent", "transparent", "blue"/)
   ;r0@gsnYRefLine           = (/-1.3,  0., 1.3/)
   ;r0@gsnYRefLineThicknesses    = (/0.5,0.5,0.5/)       ; Define line thicknesses 
   ;r0@gsnYRefLineDashPatterns    = (/2.,0.,2./)       ; Define line thicknesses
;========================================================================
;========================================================================
lab = (/"Amazon basin","Congo basin","Maritime continent"/)
print(lab)

r0@gsnCenterStringFontHeightF = 0.025

; create individual plots
        r0@tiYAxisString = "CRU"                  ; yaxis
  do n=0,nvar-1,1
	r0@tiMainString  = lab(n)
        r0@gsnCenterString = "r ="+ sprintf("%5.2f", rCRU(n))
        plot(n) = gsn_csm_xy (wks,gpcc(:,n),cru(:,n),r0)
   end do
delete(n)
r0@tiMainString  = ""

; create individual plots
 r0@tiYAxisString = "CHIRPS"                  ; yaxis
  do n=0,nvar-1,1
	r0@gsnCenterString = "r ="+ sprintf("%5.2f", rCHIR(n))
        r0@tiMainString  = ""
	plot(n+nvar) = gsn_csm_xy (wks,gpcc(:,n),chir(:,n),r0)
   end do
delete(n)
;
; create individual plots
	r0@tiYAxisString = "CMAP"                  ; yaxis
  do n=0,nvar-1,1
	r0@gsnCenterString = "r ="+ sprintf("%5.2f", rCMAP(n))
        r0@tiMainString  = ""
        plot(n+2*nvar) = gsn_csm_xy (wks,gpcc(:,n),cmap(:,n),r0)
   end do
delete(n)
;
; create individual plots
        r0@tiYAxisString = "GPCP"                  ; yaxis
  do n=0,nvar-1,1
	r0@gsnCenterString = "r ="+ sprintf("%5.2f", rGPCP(n))
        r0@tiMainString  = ""
        plot(n+3*nvar) = gsn_csm_xy (wks,gpcc(:,n),gpcp(:,n),r0)
   end do
delete(n)
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
  
  txres5@txFontHeightF = 0.050   ; Use same font height as left axis
  amres5@amParallelPosF   =  -0.45 ; 0.5 is the right edge of the plot, so
  amres5@amOrthogonalPosF =  -0.45   ; This is the center of the plot.
  amres5@amJust           = "TopLeft"

 tt = (/"a","b","c","d","e","f","g","h","i","j","k","l"/)
create_tt = gsn_create_text(wks,tt,txres5);
tt_p0 = new(nplots,graphic)                ; create graphic array ; only needed if paneling
;---Attach the polyline
     do i = 0,nplots-1,1
	print(i)
      tt_p0(i) = gsn_add_annotation(plot(i),create_tt(i),amres5)
     end do
delete(i)
;
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


  ;latEQ = (/ 3.,  3.,  -3.,   -3., 3./)
  ;lonEQ = (/-40., 5., 5., -40.,-40./)

  pres0@gsLineThicknessF = 2.5            ; line thickness   
 ; pres0@gsLineColor      = "white"         ; color of lines
  pres0@gsLineDashPattern = 2
 ;dum0x = gsn_add_polyline(wks,plot(0),lonEQ,latEQ,pres0)
 ;dum1x = gsn_add_polyline(wks,plot(0),lonEQ,latEQ,pres0)
;===============================================================
;===============================================================
  x0 =  -4.0
  x1 =  4.0
  y0 =  -4.0
  y1 =  4.0
;---Resources for the polyline
  pres1                  = True           ; polyline mods desired
  pres1@gsLineThicknessF = 1.5            ; line thickness   
  pres1@gsLineColor      = "black"         ; color of lines
  pres1@gsLineDashPattern = 2
  pres1@tfPolyDrawOrder   = "postDraw"
  pres1@gsLineColor      = "black"         ; color of lines
  dumA = new(nplots,graphic)
;  
  do n = 0,nplots-1,1
   print(n)
   dumA(n) = gsn_add_polyline(wks,plot(n), (/x0,x1/),(/y0,y1/) ,pres1)
   end do
   delete(n)

;=====================================================================
;=====================================================================
;---------------------------------------------------------------------

;---------------------------------------------------------------------
;=====================================================================
;=====================================================================
;=====================================================================
  resT                                  = True         ; modify the panel plot
  resT@gsnDraw                          = True      ; don't draw yet
  resT@gsnFrame                         = False        ; don't advance frame yet
  resT@gsnPanelLabelBar                 = False        ; add common colorbar
  resT@gsnPanelYWhiteSpacePercent       = 0.0    ; default is 1.0
  resT@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resT@gsnPanelTop                      = 0.99
  resT@gsnPanelBottom                   = 0.01
  resT@gsnPanelLeft                     = 0.01
  resT@gsnPanelRight                    = 0.99
  resT@gsnMaximize                      = True         ; large format
  resT@gsnPaperOrientation              = "portrait"   ; force portrait
  resT@gsnLeftString                    = ""
  ;resT@txString                        = "SST trends: 1984-2008"
  ;resT@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plot(0:),(/4,3/),resT)     ; now draw as one plot
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;=====================================================================
  resP                                  = True         ; modify the panel plot
  resP@gsnDraw                          = True      ; don't draw yet
  resP@gsnFrame                         = False        ; don't advance frame yet
  resP@gsnPanelLabelBar                 = False        ; add common colorbar
  resP@gsnPanelYWhiteSpacePercent       = 6.0    ; default is 1.0
  resP@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelTop                      = 0.99
  resP@gsnPanelBottom                   = 0.01
  resP@gsnPanelLeft                     = 0.65
  resP@gsnPanelRight                    = 0.99
  resP@gsnMaximize                      = True         ; large format
  resP@gsnPaperOrientation              = "portrait"   ; force portrait
  resP@gsnLeftString                    = ""
  ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
;  gsn_panel(wks,plots(:,0),(/3,1/),resP)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================
;=====================================================================

end
