begin
;
;======================================
yrStrt = 1930
yrLast = 2014
latS   = -40.
latN   =  40.
lonL   = -180.
lonR   =  180.
nvar = 3
nmodels = 24
nplots =  2*nvar
nmos =12
drought = 1.5
nplots_per_panel = 2
;xlabel = ispan(0,nmos-1,1)
;print(xlabel)
;
daysmonth = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31./)
print(daysmonth)
;
hdata_names = (/"ACCESS-CM2","ACCESS-ESM1-5","AWI-CM-1-1-MR","BCC-CSM2-MR","CanESM5","CESM2","CESM2-WACCM","CMCC-CM2-SR5","CMCC-ESM2","EC-Earth3","EC-Earth3-Veg-LR",\
        "EC-Earth3-Veg","FGOALS-f3-L","GFDL-ESM4","INM-CM5-0","IPSL-CM6A-LR","KACE-1-0-G",\
        "MIROC6","MPI-ESM1-2-HR","MPI-ESM1-2-LR","MRI-ESM2-0","NorESM2-LM","NorESM2-MM","TaiESM1"/)
print(hdata_names)
printVarSummary(hdata_names)
;
nmodels = dimsizes(hdata_names)
print(nmodels)
;
;===============================================================
opt = True
opt@spi_type = 3 ;to have this function calculate the standardized precipitation index (SPI) using the Pearson type III distribution. 
;==============================================================
;
;
;f      = addfile("/data/datasets/plots/sf/hist_count_0.nc", "r")
;d_histP   = f->d_histP
;print(d_histP)
;print(xxxxxxxxxxx)
;
;d_histN   = f->d_histN
;print(d_histN)
;delete(f)

f      = addfile("/data/datasets/plots/sf/s_hist_0.nc", "r")
hist   = f->s_hist
printVarSummary(hist)
;
;=============================================================================================================
 hist_d = new(dimsizes(hist),typeof(hist),hist@_FillValue)
 x   = hist&time
 x1  = x(::12)
 do tt = 0,nmos-1
    work = hist(tt::nmos,:,:)
    work = work*daysmonth(tt)
    hist_d(tt::nmos,:,:) = work
    print(tt)
 end do

 printVarSummary(hist_d)
 hist = hist_d

;===
delete([/tt,x,x1,hist_d,work/])
printMinMax(hist,True)
;print(xxxxxxxxx)
;---------------------------------------------------------------------------
;=============================================================================================================
;==============================================================
a_spi = hist
a_spi = hist@_FillValue
do n=0,nvar-1,1
	do m=0,nmodels-1,1
    ; a_htp(n,:) = rmAnnCycle1D(htp(n,:))
     a_spi(:,n,m) = dim_spi_n(hist(:,n,m),6,True, 0)
	end do 
end do
delete(n)
printMinMax(a_spi,True)
printVarSummary(a_spi)
;================================================================
;================================================================
;---------------------------------------------------------------- 
n_months = dimsizes(a_spi(:,0,0))
n_P = a_spi(0,:,:)
n_P = a_spi@_FillValue
printVarSummary(n_P)
n_N = a_spi(0,:,:)
n_N = a_spi@_FillValue
printVarSummary(n_N)
;
do n = 0,nvar-1,1
	do m=0,nmodels-1,1
         n_P(n,m) = dim_num_n(a_spi(:,n,m).ge.drought,0)
         print(n_P(n,m))
         n_N(n,m) = dim_num_n(a_spi(:,n,m).le.-drought,0)
         print(n_N(n,m))
	end do
end do
;
n_P = n_P/n_months      ;Convert to frequency of occurences.
printMinMax(n_P,True)
n_N = n_N/n_months
printMinMax(n_N,True)
;
print(n_P)
print(n_N)

;=============================================================
;==============================================================
;==============================================================
printVarSummary(a_spi)
;dimZ = dimsizes(a_spi)
;saodP_cases_maps  = new((/dimZ(0),dimZ(1)/),float,a_spi@_FillValue)
saodP_cases_maps  = a_spi
saodP_cases_maps = a_spi@_FillValue
printVarSummary(saodP_cases_maps)
saodN_cases_maps = saodP_cases_maps
;
do n=0,nvar-1,1
	do m=0,nmodels-1,1
        n_saodP = dim_num_n(a_spi(:,n,m).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n,m).ge.drought)
        print(valsP)
        saodP_cases_maps(valsP,n,m) = a_spi(valsP,n,m)
        printMinMax(saodP_cases_maps,True)
        delete(valsP)
	end do
end do
delete(n)
;
m_rainP = dim_sum_n_Wrap(saodP_cases_maps,0)
printVarSummary(m_rainP)
d_rainP = dim_stddev_n_Wrap(saodP_cases_maps,0)
printVarSummary(d_rainP)
delete(saodP_cases_maps)
delete(n_saodP)
;==============================================================
;==============================================================
;==============================================================
do n=0,nvar-1,1
	do m=0,nmodels-1,1
        n_saodN = dim_num_n(a_spi(:,n,m).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n,m).le.-drought)
        print(valsN)
        saodN_cases_maps(valsN,n,m) = a_spi(valsN,n,m)
        printMinMax(saodN_cases_maps,True)
        delete(valsN)
	end do
end do
delete(n)
;
m_rainN = dim_sum_n_Wrap(saodN_cases_maps,0)
printVarSummary(m_rainN)
print(m_rainN)
d_rainN = dim_stddev_n_Wrap(saodN_cases_maps,0)
printVarSummary(d_rainN)
print(d_rainN)
delete(saodN_cases_maps)
delete(n_saodN)
;==============================================================
;==============================================================
;==============================================================
xlab = fspan(.775,23.775,nmodels)
print(xlab)
;==============================================================
;==============================================================
;==============================================================
  wks = gsn_open_wks("eps","FIG_7")         ; send graphics to PNG file
  plot = new(nplots,graphic)                ; create graphic array ; only needed if paneling
  plotS = new(nplots,graphic)                ; 
   
     sres = True
     sres@gsnDraw               = False
     sres@gsnFrame              = False
;     sres@vpWidthF              = 0.45
;     sres@vpHeightF             = 0.45
     sres@trXMinF               = -0.5
     sres@trXMaxF               = 25.
     sres@trYMinF               = 0.0
     sres@trYMaxF               = 0.12
     sres@gsnXYBarChart         = True
     sres@gsnXYBarChartBarWidth = 0.25           ; change bar widths
     sres@tmXBMode              = "Explicit"         ; explicit labels
     sres@tmXBValues            = xlab-(0.35/2.)
     sres@tmXBLabels            = hdata_names
     ;sres@tmXBLabelDeltaF       = -12.5 
     sres@tmXBLabelAngleF	= 90.
     ;sres@tmXBLabelFontColor	= "white"
     sres@tmXBLabelFontHeightF	= 0.0005
     sres@tmYLFormat              = "0@*+^sg"        ; use "e" symbol, don't force 0's (see documentation)
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
     sres@tiYAxisString 	= "Wet/dry ocurences (1/month)"                  ; yaxis
     sres@tiYAxisFontHeightF    =  0.025       
     sres@tmXBLabelFontHeightF  = 0.015
     sres@tmXTLabelFontHeightF  = 0.015
     sres@tmYLLabelFontHeightF  = 0.020
     sres@tiMainFontHeightF  = 0.030
     sres@gsnRightString        = ""
     ;sres@tiYAxisString         = "(~S~o~N~C)"
     sres@gsnXYBarChartColors   =  "blue"
     ;sres@tmXBLabelDeltaF    = -3.5
     ;rgba      = span_color_rgba("matlab_jet",nmodels)
     ;sres@gsnXYBarChartColors   = rgba
     ;sres@tmXBLabelFontColor	= (/rgba/)
     ;print(rgba)  

     plots = new((/2*nvar,nplots_per_panel/),graphic)

     lab = (/"Amazon basin","Congo basin","Maritime continent"/)
     print(lab)
         
 
 ;        plots = new((/2*nvar,nplots_per_panel/),graphic)

; The X values for each plot is different, ensuring that the bars don't overlap.
     do i = 0,nvar-1,1
       sres@tiMainString  = lab(i)
       sres@gsnXYBarChartColors = "blue"
       plots(i,0) = gsn_csm_xy(wks,xlab,n_P(i,:),sres)

       sres@gsnXYBarChartColors = "red"
       plots(i,1) = gsn_csm_xy(wks,xlab+0.35,n_N(i,:),sres)
       ;plots(i,1) = gsn_csm_xy(wks,fspan(.775+0.35,11.775+0.35,nmos),abs(m_rainN(:,i)),sres) 
; Overlay the last three plots on the first one.
       do j=1,1
         overlay(plots(i,0),plots(i,j))
       end do
     end do
delete(i)
delete(j)

nm_Pmodels = dim_avg_n_Wrap(n_P,1)
print(nm_Pmodels)
nd_Pmodels = dim_stddev_n_Wrap(n_P,1)
print(nd_Pmodels)
;
nm_Nmodels = dim_avg_n_Wrap(n_N,1)
nm_Nmodels = abs(nm_Nmodels)
print(nm_Nmodels)
nd_Nmodels = dim_stddev_n_Wrap(n_N,1)
print(nd_Nmodels)
;
;nm_PN  = new((/2,nvar/),float,n_P@_FillValue)
;nm(0,:) =
;================================================================================
     sres@trYMinF               = 0.0
     sres@trYMaxF               = 240.0


; The X values for each plot is different, ensuring that the bars don't overlap.
 sres@tiYAxisString         = "Absolute magnitude (s.d.)"                  ; yaxis
     do i = 0,nvar-1,1
       sres@tiMainString  = lab(i)
       sres@gsnXYBarChartColors = "blue"
       plots(nvar+i,0) = gsn_csm_xy(wks,xlab,m_rainP(i,:),sres)

       sres@gsnXYBarChartColors = "red"
       plots(nvar+i,1) = gsn_csm_xy(wks,xlab+0.35,abs(m_rainN(i,:)),sres)

; Overlay the last three plots on the first one.
       do j=1,1
         overlay(plots(nvar+i,0),plots(nvar+i,j))
       end do
     end do
delete(i)
delete(j)

;
m_rainPmodels = dim_avg_n_Wrap(m_rainP,1)
print(m_rainPmodels)
dm_rainPmodels = dim_stddev_n_Wrap(m_rainP,1)
print(dm_rainPmodels)
;
m_rainNmodels = dim_avg_n_Wrap(m_rainN,1)
m_rainNmodels = abs(m_rainNmodels)
print(m_rainNmodels)
dm_rainNmodels = dim_stddev_n_Wrap(m_rainN,1)
print(dm_rainNmodels)
;
;
;
nm_PP  = new((/2,nvar/),float,n_P@_FillValue)
nm_PP(0,:) = nm_Pmodels
nm_PP(1,:) = m_rainPmodels
printVarSummary(nm_PP)
print(nm_PP)
;
nd_PP  = new((/2,nvar/),float,n_P@_FillValue)
nd_PP(0,:) = nd_Pmodels
nd_PP(1,:) = dm_rainPmodels
printVarSummary(nd_PP)
print(nd_PP)
;
;
;
;
nm_NN  = new((/2,nvar/),float,n_N@_FillValue)
nm_NN(0,:) = abs(nm_Nmodels)
nm_NN(1,:) = m_rainNmodels
printVarSummary(nm_NN)
print(nm_NN)
;
nd_NN  = new((/2,nvar/),float,n_P@_FillValue)
nd_NN(0,:) = nd_Nmodels
nd_NN(1,:) = dm_rainNmodels
printVarSummary(nd_NN)
print(nd_NN)
;
;=========================================================================
;=========================================================================
     xlab0 = fspan(.775,23.775,nvar)
     print(xlab0)

     plotX = new((/nvar,nplots_per_panel/),graphic)

     lab = (/"Amazon basin","Congo basin","Maritime continent"/)
;=========================================================================
;=========================================================================
     sres0 = True
     sres0@gsnDraw               = False
     sres0@gsnFrame              = False
     sres0@trXMinF               = -1.5
     sres0@trXMaxF               = 26.
     sres0@trYMinF               = 0.0
     sres0@trYMaxF               = 0.12
     sres0@gsnXYBarChart         = True
     sres0@gsnXYBarChartBarWidth = 0.75           ; change bar widths
     sres0@tmXBMode              = "Explicit"         ; explicit labels
     sres0@vpWidthF              = 0.60
     sres0@vpHeightF             = 0.30
     sres0@tmXBValues            = xlab0
     sres0@tmXBLabels            = lab
     ;sres0@tmXBLabelAngleF       = 90.
     sres0@tmXBLabelFontHeightF  = 0.0005
     sres0@tmYLFormat              = "0@*+^sg"        ; use "e" symbol, don't force 0's (see documentation)
     sres0@tiYAxisFontThicknessF  = 1.
     sres0@tmXBMajorThicknessF    = 1.
     sres0@tmXBMinorThicknessF    = 1.
     sres0@tmYLMajorThicknessF    = 1.
     sres0@tmYLMinorThicknessF    = 1.
     sres0@tmYLLabelFontThicknessF= 1.
     sres0@tmBorderThicknessF     = 1.
     sres0@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     sres0@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     sres0@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     sres0@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     sres0@tmXTMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     sres0@tmXTMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     sres0@tmYRMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     sres0@tmYRMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     sres0@tiYAxisString         = "Wet/dry ocurences (1/month)"                  ; yaxis
     sres0@tiYAxisFontHeightF    =  0.015
     sres0@tmXBLabelFontHeightF  = 0.015
     sres0@tmXTLabelFontHeightF  = 0.015
     sres0@tmYLLabelFontHeightF  = 0.015
     sres0@tiMainFontHeightF  = 0.030
     sres0@gsnRightString        = ""
     sres0@gsnXYBarChartColors   =  "blue"

     xlab0 = fspan(.775,23.775,nvar)
     print(xlab0)

     plotX = new((/nvar,nplots_per_panel/),graphic)

     lab = (/"Amazon basin","Congo basin","Maritime continent"/)

     ; The X values for each plot is different, ensuring that the bars don't overlap.
    
       sres0@tiMainString  = ""
       sres0@gsnXYBarChartColors = "blue"
       plotA0 = gsn_csm_xy(wks,xlab0,nm_Pmodels,sres0)
       sres0@gsnXYBarChartColors = "red"
       plotB0 = gsn_csm_xy(wks,xlab0+0.75,nm_Nmodels,sres0)
       overlay(plotA0,plotB0)
       plotX(0,0) = plotA0
       ;

       sres0@tiYAxisString         = "Absolute magnitude (s.d.)"  
       sres0@trYMinF               = 0.0
       sres0@trYMaxF               = 240.0
       sres0@tiMainString  = ""
       sres0@gsnXYBarChartColors = "blue"
       plotA1 = gsn_csm_xy(wks,xlab0,m_rainPmodels,sres0)
       sres0@gsnXYBarChartColors = "red"
       plotB1 = gsn_csm_xy(wks,xlab0+0.75,m_rainNmodels,sres0)
       overlay(plotA1,plotB1)
       plotX(1,0) = plotA1

;=========================================================================
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
     xpos   = (/0.07,    0.18,         0.55,     0.8/)

     do i=0,1
       lbres@lbFillColors = colors(i)
       gsn_labelbar_ndc(wks,1,labels(i),xpos(i),0.95,lbres)
     end do	
     delete(i)
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
  
  txres5@txFontHeightF = 0.040   ; Use same font height as left axis
  amres5@amParallelPosF   =  -0.70 ; 0.5 is the right edge of the plot, so
  amres5@amOrthogonalPosF =  -0.60    ; This is the center of the plot.
  amres5@amJust           = "TopLeft"

 tt = (/"a","b","c","d","e","f"/)
create_tt = gsn_create_text(wks,tt,txres5);
tt_p0 = new(6,graphic)                ; create graphic array ; only needed if paneling
;---Attach the polyline
     do i = 0,2*nvar-1,1
	print(i)
	do j=0,0,1
      tt_p0(i) = gsn_add_annotation(plots(i,j),create_tt(i),amres5)
	end do
     end do
delete(i)
;
 
  txres5@txFontHeightF = 0.030   ; Use same font height as left axis
  amres5@amParallelPosF   =  -0.70 ; 0.5 is the right edge of the plot, so
  amres5@amOrthogonalPosF =  -0.50    ; This is the center of the plot.
  amres5@amJust           = "TopLeft"
tt2 = (/"g","h","i","j","k","l","m","n","o"/)
create_tt2 = gsn_create_text(wks,tt2,txres5);
tt_p2 = new(9,graphic)                ; create graphic array ; only needed if paneling
 
    do i = 0,nvar-2,1
        print(i)
         do j = 0,0,1
      tt_p2(i) = gsn_add_annotation(plotX(i,j),create_tt2(i),amres5)
	end do
     end do
 delete(i)
 delete(j)
;===============================================================
;===============================================================
;===============================================================
  x0 =  -2.
  x1 =  25.
  y0 =  -3.
  y1 =  3.
;---Resources for the polyline
  pres1                  = True           ; polyline mods desired
  pres1@gsLineThicknessF = 2.0           ; line thickness   
  pres1@gsLineDashPattern = 2
  pres1@tfPolyDrawOrder   = "postDraw"
  pres1@gsLineColor      = "blue"         ; color of lines
  dP = new(nplots,graphic)
  dN = new(nplots,graphic)
  nN = (/0.07254902,0.06666667,0.07647059/)
  print(nN)
  nP = (/0.05686275,0.06372549,0.05/)
  print(nP)

  ;mrN = (/-2.090252,-1.999892,-2.224591/)
  mrN = (/-154.6786,-135.9926,-173.5181/)
  mrN = abs(mrN)

  ;mrP = (/1.900121,1.996882,1.812041/)
  mrP = (/110.207,129.7973,92.41411/)


;  
  do n = 0,nvar-1,1
   print(n)
   dP(n) = gsn_add_polyline(wks,plots(n,0),(/x0,x1/),(/nP(n),nP(n)/),pres1)
   dP(nvar+n) = gsn_add_polyline(wks,plots(nvar+n,0),(/x0,x1/),(/mrP(n),mrP(n)/),pres1)
end do
   delete(n)

pres1@gsLineColor      = "red"         ; color of lines
 do n = 0,nvar-1,1
   print(n)
   dN(n) = gsn_add_polyline(wks,plots(n,0),(/x0,x1/),(/nN(n),nN(n)/),pres1)
   dN(nvar+n) = gsn_add_polyline(wks,plots(nvar+n,0),(/x0,x1/),(/mrN(n),mrN(n)/),pres1)
  end do
   delete(n)


;=====================================================================
;=====================================================================
;=====================================================================
;=====================================================================
  polyres                   = True                       ; marker resources
  polyres@gsMarkerIndex     = 16                          ; index for circle
  polyres@gsMarkerColor     = "black"
  polyres@gsMarkerSizeF     = .0010                        ; size
  polyres@gsLineThicknessF = 2.0            ; line thickness   
  polyres@tfPolyDrawOrder   = "postDraw"
  polyres@gsLineColor      = polyres@gsMarkerColor         ; color of lines
  polyres@gsLineDashPattern = 0
  polyres@gsMarkerOpacityF  = 1.0
  ;marker_colors = (/"black","pink3","red3","seagreen4","yellow3"/)
;======================Amazon
;   x = fspan(0.775,2.775,nvar)
   x = xlab0
   print(x)
   bb = 0.12    ;scaling factor for bars
   M_OBS  = abs(nm_PP)
   rM_OBS = abs(nd_PP)
  error_bar_n = new((/2,nvar/),graphic)
  up_bar_n = new((/2,nvar/),graphic)
  lo_bar_n = new((/2,nvar/),graphic)
  centers_n   = new((/2,nvar/),graphic)
;  printVarSummary(centers_n)
do j=0,1,1
do t=0,nvar-1,1
;       do j=0,nvar-1,1
   ;polyres@gsMarkerColor =  marker_colors(t)
   ;polyres@gsLineColor =  marker_colors(t)
   print(t)
   print(j)
   centers_n(j,t)   = gsn_add_polymarker(wks,plots(j,0),x(t),M_OBS(j,t),polyres)
   error_bar_n(j,t) = gsn_add_polyline(wks,plotX(j,0),(/x(t),x(t)/),(/(M_OBS(j,t)+rM_OBS(j,t)),(M_OBS(j,t)-rM_OBS(j,t))/),polyres)
   up_bar_n(j,t) = gsn_add_polyline(wks,plotX(j,0),(/x(t)-bb,x(t)+bb/),(/(M_OBS(j,t)+rM_OBS(j,t)),(M_OBS(j,t)+rM_OBS(j,t))/),polyres)
   lo_bar_n(j,t) = gsn_add_polyline(wks,plotX(j,0),(/x(t)-bb,x(t)+bb/),(/(M_OBS(j,t)-rM_OBS(j,t)),(M_OBS(j,t)-rM_OBS(j,t))/),polyres)
end do
end do
delete(t)
delete(j)
;delete(x)
delete(M_OBS)
delete(rM_OBS)
;======================
;=========================================================================
;=========================================================================
;======================
   delete(polyres@gsMarkerColor)

   delete(x1)
;   x1 = fspan(0.775,23.775,nmodels)+0.35
   x1 = xlab0+0.75 
   print(x1)
   bb = 0.12    ;scaling factor for bars
   M_OBS1  = abs(nm_NN)
   rM_OBS1 = abs(nd_NN)
  error_bar_n1 = new((/2,nvar/),graphic)
  up_bar_n1 = new((/2,nvar/),graphic)
  lo_bar_n1 = new((/2,nvar/),graphic)
  centers_n1   = new((/2,nvar/),graphic)
  printVarSummary(centers_n1)
do j=0,1,1
do t=0,nvar-1,1
;       do j=0,nvar-1,1
   ;polyres@gsMarkerColor =  marker_colors(t)
   ;polyres@gsLineColor =  marker_colors(t)
   print(t)
   print(j)
   centers_n1(j,t)   = gsn_add_polymarker(wks,plotX(j,0),x1(t),M_OBS1(j,t),polyres)
   error_bar_n1(j,t) = gsn_add_polyline(wks,plotX(j,0),(/x1(t),x1(t)/),(/(M_OBS1(j,t)+rM_OBS1(j,t)),(M_OBS1(j,t)-rM_OBS1(j,t))/),polyres)
   up_bar_n1(j,t) = gsn_add_polyline(wks,plotX(j,0),(/x1(t)-bb,x1(t)+bb/),(/(M_OBS1(j,t)+rM_OBS1(j,t)),(M_OBS1(j,t)+rM_OBS1(j,t))/),polyres)
   lo_bar_n1(j,t) = gsn_add_polyline(wks,plotX(j,0),(/x1(t)-bb,x1(t)+bb/),(/(M_OBS1(j,t)-rM_OBS1(j,t)),(M_OBS1(j,t)-rM_OBS1(j,t))/),polyres)
end do
end do
delete(t)
delete(j)
;delete(x1)
delete(M_OBS1)
delete(rM_OBS1)
;===============================================================
;===============================================================
;===============================================================
  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
  gsres@gsMarkerThicknessF = 1.0

dum0a = new(dimsizes(mrP),graphic)
dum1a = new(dimsizes(mrP),graphic)
;
do i = 0,nvar-1,1
;      gsres@gsMarkerColor      = colors(i,:)
dum0a(i) = gsn_add_polymarker(wks,plotX(0,0),x(i),nP(i),gsres)
dum1a(i) = gsn_add_polymarker(wks,plotX(0,0),x1(i),nN(i),gsres)
end do
delete(i)
;
dum0 = new(dimsizes(mrP),graphic)
dum1 = new(dimsizes(mrP),graphic)
;
do i = 0,nvar-1,1
;      gsres@gsMarkerColor      = colors(i,:)
dum0(i) = gsn_add_polymarker(wks,plotX(1,0),x(i),mrP(i),gsres)
dum1(i) = gsn_add_polymarker(wks,plotX(1,0),x1(i),mrN(i),gsres)
end do
delete(i)
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;=====================================================================
  resP                                  = True         ; modify the panel plot
  resP@gsnDraw                          = True      ; don't draw yet
  resP@gsnFrame                         = False        ; don't advance frame yet
  resP@gsnPanelLabelBar                 = False        ; add common colorbar
  resP@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resP@gsnPanelTop                      = 0.99
  resP@gsnPanelBottom                   = 0.20
  resP@gsnPanelLeft                     = 0.01
  resP@gsnPanelRight                    = 0.99
  resP@gsnMaximize                      = True         ; large format
  resP@gsnPaperOrientation              = "portrait"   ; force portrait
  resP@gsnLeftString                    = ""
  ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plots(:,0),(/2,3/),resP)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================
;=====================================================================
;=====================================================================
  resT                                  = True         ; modify the panel plot
  resT@gsnDraw                          = True      ; don't draw yet
  resT@gsnFrame                         = False        ; don't advance frame yet
  resT@gsnPanelLabelBar                 = False        ; add common colorbar
  resT@gsnPanelYWhiteSpacePercent       = 0.0    ; default is 1.0
  resT@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resT@gsnPanelTop                      = 0.24
  resT@gsnPanelBottom                   = 0.0
  resT@gsnPanelLeft                     = 0.01
  resT@gsnPanelRight                    = 0.99
  resT@gsnMaximize                      = True         ; large format
  resT@gsnPaperOrientation              = "portrait"   ; force portrait
  resT@gsnLeftString                    = ""
  ;resT@txString                        = "SST trends: 1984-2008"
  ;resT@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plotX(:,0),(/1,2/),resT)     ; now draw as one plot
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================

end
