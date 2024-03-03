begin
;
;======================================
yrStrt = 1930
yrLast = 2014
latS   = -40.
latN   =  40.
lonL   = -180.
lonR   =  180.
drought = 1.5
nvar = 3
nplots =  6
nmos =12
xlabel = ispan(0,nmos-1,1)
print(xlabel)
;
opt = True 
opt@spi_type = 3 ;to have this function calculate the standardized precipitation index (SPI) using the Pearson type III distribution. 


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
  printMinMax(GPCC,True)
;==============================================================
yyyymm = cd_calendar(GPCC&time,-1)
yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0); not used here
;==============================================================
htp = new((/dimsizes(GPCC(:,0,0)),nvar/),float,GPCC@_FillValue)                ;array to hold the PCs
htp(:,0) =  wgt_areaave_Wrap(GPCC(time|:, {lon|-80:-50}, {lat|-10:5}),1.0, 1.0, 0)
htp(:,1) =  wgt_areaave_Wrap(GPCC(time|:, {lon|10:30}, {lat|-10:5}),1.0, 1.0, 0)
htp(:,2) =  wgt_areaave_Wrap(GPCC(time|:, {lon|100:150}, {lat|-10:5}),1.0, 1.0, 0)
htp!0 = "time"
printVarSummary(htp)
printMinMax(htp,True)
delete(GPCC)
;
a_spi = htp     ;transfers dims 

 do n=0,nvar-1,1
    ; a_htp(n,:) = rmAnnCycle1D(htp(n,:))
     a_spi(:,n) = dim_spi_n(htp(:,n),6,True, 0)
  end do
delete(n)
printMinMax(a_spi,True)
printVarSummary(a_spi)
;===============================================================
nyears = dimsizes(a_spi&time)/nmos
print(nyears)
spi_s     = onedtond(ndtooned(a_spi),(/nyears,nmos,nvar/))
spi_s!0 = "time"
spi_s!1 = "month"
spi_s!2 = "lev"
printVarSummary(spi_s)
printMinMax(spi_s,True)
;================================================================
;---------------------------------------------------------------- 
n_P = spi_s(0,:,:)
printVarSummary(n_P)
n_N = spi_s(0,:,:)
printVarSummary(n_N)
;
do n = 0,nvar-1,1
	do m = 0,nmos-1,1
		n_P(m,n) = dim_num_n(spi_s(:,m,n).ge.drought,0)
		print(n_P(m,n))
		n_N(m,n) = dim_num_n(spi_s(:,m,n).le.-drought,0)
                print(n_N(m,n))
	end do
end do
printVarSummary(n_P)
;
n_P = n_P/nyears	;Convert to frequency of occurences.
printMinMax(n_P,True)
n_N = n_N/nyears
printMinMax(n_N,True)

;=================================================================
;==============================================================
;==============================================================
  wks = gsn_open_wks("eps","FIG_3")         ; send graphics to PNG file
  plot = new(nplots,graphic)                ; create graphic array ; only needed if paneling
  plotS = new(nplots,graphic)                ; 
   
   r0               = True                        ; plot mods desired
   r0@gsnDraw       = False                       ; do not draw
   r0@gsnFrame      = False                       ; do not advance frame
   r0@tiMainString  = ""                       ; title
   r0@tiMainFontHeightF  = 0.015              
   r0@tiXAxisString = ""                  ; yaxis
   r0@tiXAxisFontHeightF = 0.010
   r0@tiYAxisFontHeightF = 0.010
   r0@tiYAxisString = "Standardized precipitation anomaly"                  ; yaxis
   r0@tmXBLabelFontHeightF = 0.010
   r0@tmYLLabelFontHeightF = 0.010
   ;r0@trYLog              = False                ; log scaling
   ;r0@trXLog              = False               ; log scaling
   r0@trYMinF             =  -4.0                 ; manually set lower limit
   r0@trYMaxF             =   4.0           
   r0@trXMinF             =  yrStrt-5                 ; manually set lower limit
   r0@trXMaxF             =  yrLast+5               ;   "          upper
   ;r0@xyLineColor          =	"red"
   ;r0@xyLineColors          = (/"transparent","red","grey50","black","darksalmon","black"/)   
   r0@tmXTBorderOn            =  True
   r0@tmXTOn                  =  True
   r0@tmYLFormat	      = "@*+^sg"	; use "e" symbol, don't force 0's (see documentation)
   r0@vpWidthF                = 0.60
   r0@vpHeightF               = 0.25
   ;r0@xyLineThicknesses   = (/0.5,1.5,1.5,1.5,1.5,1.5/)       ; Define line thicknesses 
   ;r0@xyDashPatterns      = (/0.,0.,0.,0.,0.,0./)           ; Dash patterns
   ;r0@gsnXRefLine	  =  (/1930.,2014.,2.,0.,0.,0./)           ; reflines
   ;r0@gsnXRefLineDashPattern = 2.
   ;r0@gsnXRefLineThicknessF = 0.1           ; reflines
   ;r0@tmYLLabelFontColor = "blue"   ; and right axes are same.
   ;r0@tiYAxisFontColor  = "blue"
   ;r0@tmBorderLineColor = "deepskyblue"
   ;r0@tmYLMajorLineColor = "red" ; YR axis uses YL resources, can
   ;r0@tmYLMinorLineColor = "red" ; change by setting tmYUseLeft = False 
   ;r0@tmBorderLineColor =  "red"
   ;;r0@tmXBMode = "Explicit"
   ;;r0@tmXBValues = (/"0", "1","2","3","4","5","6","7","8","9","10","11"/)
   ;;r0@tmXBLabels = (/"J", "F","M","A","M","J","J","A","S","O","N","D"/)
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

   r0@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r0@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r0@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r0@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r0@tmXTMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r0@tmXTMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r0@tmYRMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r0@tmYRMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   ;r0@gsnXYBarChart         = True                 ; turn on bar chart
   ;r0@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
   
;   r0@gsnYRefLineColor      = "red"
   ;r0@gsnYRefLineColor	    = 0.
;  r0@gsnYRefLineColor      = (/"black","transparent","black"/)
   r0@gsnBelowYRefLineColor = (/ "red", "transparent", "transparent"/)
   r0@gsnAboveYRefLineColor = (/ "transparent", "transparent", "blue"/)
   r0@gsnYRefLine           = (/-drought,  0., drought/)
   r0@gsnYRefLineThicknesses    = (/0.5,0.5,0.5/)       ; Define line thicknesses 
   r0@gsnYRefLineDashPatterns    = (/2.,0.,2./)       ; Define line thicknesses
;========================================================================
;========================================================================
lab = (/"Amazon basin","Congo basin","Maritime continent"/)
print(lab)

; create individual plots
  do n=0,nvar-1,1
     r0@tiMainString  = lab(n)
	plot(n) = gsn_csm_xy (wks,yrfrac,a_spi(:,n),r0)
   end do
delete(n)
;=========================================================================
;=========================================================================
   r1               = True                        ; plot mods desired
   r1@gsnDraw       = False                       ; do not draw
   r1@gsnFrame      = False                       ; do not advance frame
   r1@tiMainString  = ""                       ; title
   r1@tiMainFontHeightF  = 0.020
   r1@tiXAxisString = ""                  ; yaxis
   r1@tiXAxisFontHeightF = 0.015
   r1@tiYAxisFontHeightF = 0.015
   r1@tiYAxisString = "Occurences (1/year)"                  ; yaxis
   r1@tmXBLabelFontHeightF = 0.015
   r1@tmYLLabelFontHeightF = 0.015
   ;r1@trYLog              = False                ; log scaling
   ;r1@trXLog              = False               ; log scaling
   r1@trYMinF             =   0.0                 ; manually set lower limit
   r1@trYMaxF             =   0.15
   r1@trXMinF             =   -1.                 ; manually set lower limit
   r1@trXMaxF             =    12.             ;   "          upper
   r1@xyLineColor          =   "blue"
   ;r1@xyLineColors          = (/"transparent","red","grey50","black","darksalmon","black"/)   
   r1@tmXTBorderOn            =  True
   r1@tmXTOn                  =  True
   r1@tmYLFormat              = "@*+^sg"        ; use "e" symbol, don't force 0's (see documentation)
   r1@vpWidthF                = 0.45
   r1@vpHeightF               = 0.40
   ;r1@xyLineThicknesses   = (/0.5,1.5,1.5,1.5,1.5,1.5/)       ; Define line thicknesses 
   ;r1@xyDashPatterns      = (/0.,0.,0.,0.,0.,0./)           ; Dash patterns
   ;r1@gsnXRefLine        =  (/1930.,2014.,2.,0.,0.,0./)           ; reflines
   ;r1@gsnXRefLineDashPattern = 2.
   ;r1@gsnXRefLineThicknessF = 0.1           ; reflines
   ;r1@tmYLLabelFontColor = "blue"   ; and right axes are same.
   ;r1@tiYAxisFontColor  = "blue"
   ;r1@tmBorderLineColor = "deepskyblue"
   ;r1@tmYLMajorLineColor = "red" ; YR axis uses YL resources, can
   ;r1@tmYLMinorLineColor = "red" ; change by setting tmYUseLeft = False 
   ;r1@tmBorderLineColor =  "red"
   ;;r1@tmXBMode = "Explicit"
   ;;r1@tmXBValues = (/"0", "1","2","3","4","5","6","7","8","9","10","11"/)
   ;;r1@tmXBLabels = (/"J", "F","M","A","M","J","J","A","S","O","N","D"/)
   ;r1@tmXBLabels = (/"-5", "-4","-3","-2","-1","0","+1","+2","+3","+4","+5","+6"/)
   ;r1@tmXBLabels = (/"Jan", "Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
   r1@tmXMajorGrid                = False          ; implement x grid 
   r1@tmXMajorGridThicknessF      = 1.0           ; 2.0 is default
   r1@tmXMajorGridLineDashPattern = 2             ; select short dash lines
   r1@tmXMajorGridLineColor      = "black"
   r1@tmYMajorGrid                = False          ; implement y grid
   r1@tmYMajorGridThicknessF      = 1.0           ; 2.0 is default
   r1@tmYMajorGridLineDashPattern = 2             ; select short dash lines
   r1@tmYMajorGridLineColor      = "black"
   r1@tiYAxisFontThicknessF  = 1.
   r1@tmXBMajorThicknessF    = 1.
   r1@tmXBMinorThicknessF    = 1.
   r1@tmYLMajorThicknessF    = 1.
   r1@tmYLMinorThicknessF    = 1.
   r1@tmYLLabelFontThicknessF= 1.
   r1@tmBorderThicknessF     = 1.

   r1@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r1@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r1@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r1@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r1@tmXTMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r1@tmXTMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r1@tmYRMajorOutwardLengthF = 0.0               ; draw tickmarks inward
   r1@tmYRMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
   r1@gsnXYBarChart         = True                 ; turn on bar chart
   r1@gsnXYBarChartBarWidth = 0.75                 ; change bar widths

;   r1@gsnYRefLineColor      = "red"
   ;r1@gsnYRefLineColor     = 0.
;  r1@gsnYRefLineColor      = (/"black","transparent","black"/)
   ;r1@gsnBelowYRefLineColor = (/ "red", "transparent", "transparent"/)
   ;r1@gsnAboveYRefLineColor = (/ "transparent", "transparent", "blue"/)
   ;r1@gsnYRefLine           = (/-1.3,  0., 1.3/)
   ;r1@gsnYRefLineThicknesses    = (/0.5,0.5,0.5/)       ; Define line thicknesses 
   ;r1@gsnYRefLineDashPatterns    = (/2.,0.,2./)       ; Define line thicknesses
;========================================================================
;lab = (/"Amazon basin","Congo basin","Maritime continent"/)
;print(lab)

; create individual plots
;  do n=0,nvar-1,1
;     r1@tiMainString  = lab(n)
;     plot(n+nvar) = gsn_csm_xy (wks,xlabel,n_P(:,n),r1)
;     ;plot(n) = gsn_csm_xy (wks,yrfrac,a_spi(n,0,:),r0)
;  end do
;delete(n)

; r1@tiMainString  = ""
;r1@xyLineColor          =   "red"
; create individual plots
;  do n=0,nvar-1,1
;     r1@tiMainString  = lab(n)
;     plot(n+nvar) = gsn_csm_xy (wks,xlabel,n_P(:,n),r1)
;     ;plot(n) = gsn_csm_xy (wks,yrfrac,a_spi(n,0,:),r0)
;  end do
;delete(n)

     nplots_per_panel = 2

     sres = True
     sres@gsnDraw               = False
     sres@gsnFrame              = False
     sres@vpWidthF              = 0.45
     sres@vpHeightF             = 0.40
     sres@trXMinF               = 0.4
     sres@trXMaxF               = 12.6
     sres@trYMinF               = 0.0
     sres@trYMaxF               = 0.15
     sres@gsnXYBarChart         = True
     sres@gsnXYBarChartBarWidth = 0.25           ; change bar widths
     sres@tmXBMode              = "Explicit"         ; explicit labels
     sres@tmXBValues            = ispan(1,12,1)
     sres@tmXBLabels            = (/"J","F","M","A","M","J","J","A","S", \
                                   "O","N","D"/)
     sres@tiYAxisFontThicknessF  = 1.
     sres@tmXBMajorThicknessF    = 1.
     sres@tmXBMinorThicknessF    = 1.
     sres@tmYLMajorThicknessF    = 1.
     sres@tmYLMinorThicknessF    = 1.
     sres@tmYLLabelFontThicknessF= 1.
     sres@tmBorderThicknessF     = 1.
     sres@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     sres@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     sres@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     sres@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     sres@tmXTMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     sres@tmXTMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     sres@tmYRMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     sres@tmYRMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     sres@tiYAxisString 	= "Occurences"                  ; yaxis
     sres@tmXBLabelFontHeightF  = 0.015
     sres@tmXTLabelFontHeightF  = 0.015
     sres@tmYLLabelFontHeightF  = 0.015
     sres@tiMainFontHeightF  = 0.025
     sres@gsnRightString        = ""
     ;sres@tiYAxisString         = "(~S~o~N~C)"
        
     plots = new((/nvar,nplots_per_panel/),graphic)

; The X values for each plot is different, ensuring that the bars don't overlap.
     do i = 0,nvar-1,1
       sres@tiMainString  = lab(i)
       sres@gsnXYBarChartColors = "blue"
       plots(i,0) = gsn_csm_xy(wks,fspan(.775,11.775,nmos),n_P(:,i),sres)

       sres@gsnXYBarChartColors = "red"
       plots(i,1) = gsn_csm_xy(wks,fspan(.775,11.775,nmos)+0.225,n_N(:,i),sres)

; Overlay the last three plots on the first one.
       do j=1,1
         overlay(plots(i,0),plots(i,j))
       end do
     end do
delete(i)
delete(j)
;=========================================================================
; Create some labelbars for a legend
     lbres                    = True          ; labelbar only resources
     lbres@vpWidthF           = 0.15           ; labelbar width
     lbres@vpHeightF          = 0.05           ; labelbar height
     lbres@lbBoxMajorExtentF  = 0.15          ; puts space between color boxes
     lbres@lbMonoFillPattern  = True          ; Solid fill pattern
     lbres@lbLabelFontHeightF = 0.010         ; font height. default is small
     lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
     lbres@lbPerimOn          = False

     colors = (/"blue",   "red", "blue",  "green"/)
     labels = (/"Wet", "Dry",    "third", "fourth"/)
     xpos   = (/0.70,    0.85,         0.55,     0.8/)

     do i=0,1
       lbres@lbFillColors = colors(i)
       gsn_labelbar_ndc(wks,1,labels(i),xpos(i),0.70,lbres)
     end do	

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
  
  txres5@txFontHeightF = 0.020   ; Use same font height as left axis
  amres5@amParallelPosF   =  -0.57 ; 0.5 is the right edge of the plot, so
  amres5@amOrthogonalPosF =  -0.55    ; This is the center of the plot.
  amres5@amJust           = "TopLeft"

 tt = (/"a","b","c","d","e","f"/)
create_tt = gsn_create_text(wks,tt,txres5);
tt_p0 = new(6,graphic)                ; create graphic array ; only needed if paneling
;---Attach the polyline
     do i = 0,nvar-1,1
	print(i)
      tt_p0(i) = gsn_add_annotation(plot(i),create_tt(i),amres5)
     end do
delete(i)
;
 
  txres5@txFontHeightF = 0.035   ; Use same font height as left axis
  amres5@amParallelPosF   =  -0.70 ; 0.5 is the right edge of the plot, so
  amres5@amOrthogonalPosF =  -0.60    ; This is the center of the plot.
  amres5@amJust           = "TopLeft"
tt2 = (/"d","e","f","j","k","l","m","n","o"/)
create_tt2 = gsn_create_text(wks,tt2,txres5);
tt_p2 = new(9,graphic)                ; create graphic array ; only needed if paneling
 
    do i = 0,nvar-1,1
        print(i)
         do j = 0,0,1
      tt_p2(i) = gsn_add_annotation(plots(i,j),create_tt2(i),amres5)
	end do
     end do
 delete(i)
 delete(j)

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
  resT@gsnPanelRight                    = 0.65
  resT@gsnMaximize                      = True         ; large format
  resT@gsnPaperOrientation              = "portrait"   ; force portrait
  resT@gsnLeftString                    = ""
  ;resT@txString                        = "SST trends: 1984-2008"
  ;resT@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plot(0:2),(/3,1/),resT)     ; now draw as one plot
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
  gsn_panel(wks,plots(:,0),(/3,1/),resP)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================
;=====================================================================

end
