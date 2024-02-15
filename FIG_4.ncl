begin
;
;======================================
yrStrt = 1930
yrLast = 2015
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

list_vars()
;print(xxxxxxxxxxxxxxx)
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
;  Q1 = Q1*86400.		;Converts to K/day

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
 f      = addfile ("/data/datasets/20cr/v3/prate.mon.mean.nc", "r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  Q2   = f->prate(iYYYY,:,:)
  printVarSummary(Q2)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(Q2,True)
  Q2 = Q2*86400.*30.437               ;Converts to mm/month
;==============================================================
;================================================================
;==============================================================
;==============================================================
Q2Clm      = clmMonTLL(Q2)
printVarSummary(Q2Clm)                   ; (12,nlat,nlon)   
Q2         = calcMonAnomTLL(Q2, Q2Clm)    ; replace with anonamlies
Q2@long_name = "ANOMALIES: "+Q2@long_name
;==============================================================
;==============================================================
;==============================================================
;==============================================================
dimZ = dimsizes(Q2)
saodP_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,Q2@_FillValue)
printVarSummary(saodP_cases_maps)
d_q2dP  = new((/nvar,dimZ(1),dimZ(2)/),float,Q2@_FillValue)
printVarSummary(d_q2dP)
;
;
do n = 0,nvar-1
        n_saodP = dim_num_n(a_spi(:,n).ge.drought,0)        ;Number of cases
        print(n_saodP)
        valsP = ind(a_spi(:,n).ge.drought)
        print(valsP)
        saodP_cases_maps(n,valsP,:,:) = Q2(valsP,:,:)
        printMinMax(saodP_cases_maps,True)
        d_q2dP(n,:,:) = ttest(dim_avg_n_Wrap(saodP_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodP_cases_maps(n,:,:,:)^2,0), n_saodP \
              ,dim_avg_n_Wrap(Q2,0),dim_stddev_n_Wrap(Q2,0)^2, dimZ(0),True, False)
        delete(valsP)
end do
delete(n)
printVarSummary(saodP_cases_maps)
d_q2P = dim_avg_n_Wrap(saodP_cases_maps,1)
printVarSummary(d_q2P)
copy_VarCoords(d_q2P,d_q2dP)
printVarSummary(d_q2dP)
d_q2dP@long_name = "Probability: difference between means"
d_q2dP = where(abs(d_q2dP).le.p95,d_q2dP,d_q2dP@_FillValue) ; Sig. q2s
print("==============================================================")
;===================================================================
delete(dimZ)
delete(saodP_cases_maps)


dimZ = dimsizes(Q2)
saodN_cases_maps  = new((/nvar,dimZ(0),dimZ(1),dimZ(2)/),float,Q2@_FillValue)
printVarSummary(saodN_cases_maps)
d_q2dN  = new((/nvar,dimZ(1),dimZ(2)/),float,Q2@_FillValue)
printVarSummary(d_q2dN)
;
;
do n = 0,nvar-1
        n_saodN = dim_num_n(a_spi(:,n).le.-drought,0)        ;Number of cases
        print(n_saodN)
        valsN = ind(a_spi(:,n).le.-drought)
        print(valsN)
        saodN_cases_maps(n,valsN,:,:) = Q2(valsN,:,:)
        printMinMax(saodN_cases_maps,True)
        d_q2dN(n,:,:) = ttest(dim_avg_n_Wrap(saodN_cases_maps(n,:,:,:),0), dim_stddev_n_Wrap(saodN_cases_maps(n,:,:,:)^2,0), n_saodN \
              ,dim_avg_n_Wrap(Q2,0),dim_stddev_n_Wrap(Q2,0)^2, dimZ(0),True, False)
        delete(valsN)
end do
delete(n)
printVarSummary(saodN_cases_maps)
d_q2N = dim_avg_n_Wrap(saodN_cases_maps,1)
printVarSummary(d_q2N)
copy_VarCoords(d_q2N,d_q2dN)
printVarSummary(d_q2dN)
d_q2dN@long_name = "Probability: difference between means"
d_q2dN = where(abs(d_q2dN).le.p95,d_q2dN,d_q2dN@_FillValue) ; Sig. q2s
print("==============================================================")
printMinMax(d_q2dN,True)

;-------
delete(dimZ)
delete(saodN_cases_maps)
delete(Q2)

list_vars()
;print(xxxxxxxxxxxxxxx)
;==============================================================
;==============================================================
;==============================================================
;==============================================================
;==============================================================
;==============================================================
;==============================================================
  wks = gsn_open_wks("eps","FIG_4")         ; send graphics to PNG file
  plot = new(nplots,graphic)                ; create graphic array ; only needed if paneling
  plotS = new(nplots,graphic)                ; 
   
  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res@cnMinLevelValF       =  -20.            ; set min contour level
  res@cnMaxLevelValF       =  20.             ; set max contour level
  res@cnLevelSpacingF      =  2.            ; set contour spacing     
  ;res@gsnPolar             = "SH"
  ;res@mpProjection      = "LambertConformal"       ; choose projection
  res@mpFillOn             = True    ; turn off gray continents
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR
  res@mpCenterLonF         = -140.0 
  res@pmTickMarkDisplayMode = "Always"
  res@tmXBLabelFontHeightF = 0.017
  res@tmYLLabelFontHeightF = 0.017
  ;res@mpGeophysicalLineColor  = "transparent"
  ;res@mpFillColor            = -1
  ;res@mpOceanFillColor       = 1
;   res@mpFillDrawOrder      = "Draw"
;  res@mpOutlineBoundarySets = "National"
  ;res@mpDataSetName            = "Earth..4"
  ;res@mpDataBaseVersion                = "Ncarg4_1"
  ;res@mpFillOn              = True        ; Turn on map fill.
  ;;res@mpFillAreaSpecifiers  = (/"Water","Land"/)
  ;;res@mpSpecifiedFillColors = (/"transparent","transparent"/)
  ;;res@mpFillBoundarySets    = (/"Geophysical","Geophysical"/)
 ; res@mpAreaMaskingOn       = True            ; Indicate we want to 
 ; res@mpMaskAreaSpecifiers  = "Ocean"  ; mask land.
  ;res@mpPerimOn             = True            ; Turn on a perimeter.
  ;res@mpGridMaskMode        = "MaskOcean"      ; Mask grid over land.
  ;res@mpFillColors             = (/-1,0,28,-1/) ; Fill land and leave oceans
  ;res@mpOceanFillColor         = "grey"
  ;res@mpMaskAreaSpecifiers     = "Ocean"
;  res@mpAreaTypes              = 1
  ;res@gsnAddCyclic         = True
  res@cnFillOn             = True         ; turn on color fill
  res@cnFillPalette        = "ncl_default"
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False     ; turn off individual lb's
  ;res@lbOrientation        = "vertical"
  ;res@lbTitleFontHeightF   = 0.010
  ;res@lbLabelFontHeightF   = 0.010
  ;res@lbLabelFont          = "Helvetica-Bold"     ; label font
  ;res@lbTitleString        = ""
  ;res@lbTitleAngleF       = 270.
  ;res@lbTitlePosition      = "Right"
;res@lbTitleDirection    = "Across"
  ;res@lbTopMarginF         = 0.30
  ;res@lbBottomMarginF      = 0.35
  ;res@vpWidthF            = 0.40
  ;res@vpHeightF           = 0.80
  res@lbLabelStride        = 5
  ;res@pmLabelBarParallelPosF = 0.50
  ;res@pmLabelBarOrthogonalPosF = -0.11
  res@lbOrientation        = "vertical"
  res@lbTitleFontHeightF  = 0.008
  res@lbLabelFontHeightF  = 0.008
  res@lbLeftMarginF       = 0.10
  res@lbRightMarginF      = 0.55
  ;res@lbLabelOffsetF     = 0.20
  res@lbLabelFont         = "Helvetica-Bold"     ; label font
  ;res@lbLabelPosition    = "Top"
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
   
   res@gsnRightStringFontHeightF  = 0.025
   res@gsnRightString  = "GPCC"
   res@gsnCenterString  = ""
   do n=0,nvar-1,1

   print(n)
   plot(n) = gsn_csm_contour_map_ce(wks,d_rainP(n,:,:),res)  ;           ; 
   plotS(n) = gsn_csm_contour(wks,d_raindP(n,:,:),res1)       ;
   plotS(n) = gsn_contour_shade(plotS(n),p95,d_raindP@_FillValue,opt)
   overlay(plot(n),plotS(n))
   plot(n) = plot(n)
end do

delete(n)

 do n=0,nvar-1,1

   print(n)
   plot(nvar+n) = gsn_csm_contour_map_ce(wks,d_rainN(n,:,:),res)  ;           ; 
   plotS(nvar+n) = gsn_csm_contour(wks,d_raindN(n,:,:),res1)       ;
   plotS(nvar+n) = gsn_contour_shade(plotS(nvar+n),p95,d_raindN@_FillValue,opt)
   overlay(plot(nvar+n),plotS(nvar+n))
   plot(nvar+n) = plot(nvar+n)
end do

delete(n)

;===============================================================
;===============================================================
;=====================================================================
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

  resP@txFont                           = "helvetica-bold"
 ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plot(0:5),(/2,3/),resP)     ; now draw as one plot
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;========================================================
  delete(res@cnFillPalette)
   res@cnFillPalette        = "GMT_panoply"                        ;different colour bar
  res@cnMinLevelValF       =  -0.5            ; set min contour level
  res@cnMaxLevelValF       =  0.5             ; set max contour level
  res@cnLevelSpacingF      =  0.05            ; set contour spacing
  res@gsnCenterString  = ""
  res@gsnRightString  = "500hPa"
  
 do n=0,nvar-1,1

   print(n)
   plot(2*nvar+n) = gsn_csm_contour_map_ce(wks,d_q1P(n,:,:),res)  ;           ; 
   plotS(2*nvar+n) = gsn_csm_contour(wks,d_q1dP(n,:,:),res1)       ;
   plotS(2*nvar+n) = gsn_contour_shade(plotS(2*nvar+n),p95,d_q1dP@_FillValue,opt)
   overlay(plot(2*nvar+n),plotS(2*nvar+n))
   plot(2*nvar+n) = plot(2*nvar+n)
end do

delete(n)

 do n=0,nvar-1,1

   print(n)
   plot(3*nvar+n) = gsn_csm_contour_map_ce(wks,d_q1N(n,:,:),res)  ;           ; 
   plotS(3*nvar+n) = gsn_csm_contour(wks,d_q1dN(n,:,:),res1)       ;
   plotS(3*nvar+n) = gsn_contour_shade(plotS(3*nvar+n),p95,d_q1dN@_FillValue,opt)
   overlay(plot(3*nvar+n),plotS(3*nvar+n))
   plot(3*nvar+n) = plot(3*nvar+n)
end do

delete(n)
;=====================================================================
  resQ                                  = True         ; modify the panel plot
  resQ@gsnDraw                          = True      ; don't draw yet
  resQ@gsnFrame                         = False        ; don't advance frame yet
  resQ@gsnPanelLabelBar                 = True        ; add common colorbar
  resQ@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resQ@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resQ@gsnPanelTop                      = 0.50
  resQ@gsnPanelBottom                   = 0.20
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
 ; resQ@lbTitleString                    = "Precipitation (mm/month)"  
 resQ@lbTitleString                    = "Diabatic heating rate (K/day)"
  resQ@gsnPanelFigureStrings            = (/"m","n","o","p","q","r"/) ; add strings to panel 
 ;resQ@gsnPanelFigureStrings            = (/"g","h","i","j","k","l"/) ; add strings to panel
  resQ@amJust                           = "TopLeft"
  resQ@gsnPanelFigureStringsFontHeightF =  0.012
  resQ@gsnPanelFigureStringsFont        =  "Helvetica-Bold"

  resQ@txFont                           = "helvetica-bold"

  ;resP@txString                        = "SST trends: 1984-2008"
  ;resP@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
;  gsn_panel(wks,plot(6:11),(/2,3/),resQ)     ; now draw as one plot
;===============================================================
;===============================================================
;=====================================================================
;=====================================================================
;=====================================================================
;frame(wks)
;print(xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
;========================================================
  ;delete(res@cnFillPalette)
  ;res@cnFillPalette        = "amwg_blueyellowred"       ;different colour bar

  res@cnMinLevelValF       =  -20.            ; set min contour level
  res@cnMaxLevelValF       =  20.             ; set max contour level
  res@cnLevelSpacingF      =  2.            ; set contour spacing
  res@gsnCenterString  	   =  ""
  res@gsnRightString  	   =  "20CRv3"


   do n=0,nvar-1,1

   print(n)
   plot(4*nvar+n) = gsn_csm_contour_map_ce(wks,d_q2P(n,:,:),res)  ;           ; 
   plotS(4*nvar+n) = gsn_csm_contour(wks,d_q2dP(n,:,:),res1)       ;
   plotS(4*nvar+n) = gsn_contour_shade(plotS(4*nvar+n),p95,d_q2dP@_FillValue,opt)
   overlay(plot(4*nvar+n),plotS(4*nvar+n))
   plot(4*nvar+n) = plot(4*nvar+n)
end do

delete(n)

 do n=0,nvar-1,1

   print(n)
   plot(5*nvar+n) = gsn_csm_contour_map_ce(wks,d_q2N(n,:,:),res)  ;           ; 
   plotS(5*nvar+n) = gsn_csm_contour(wks,d_q2dN(n,:,:),res1)       ;
   plotS(5*nvar+n) = gsn_contour_shade(plotS(5*nvar+n),p95,d_q2dN@_FillValue,opt)
   overlay(plot(5*nvar+n),plotS(5*nvar+n))
   plot(5*nvar+n) = plot(5*nvar+n)
end do

delete(n)
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
var_names1 = (/"~                         ","                         ","~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5","~F21~SPI ~F34~#~F21~ -1.5","~F21~SPI ~F34~3~F21~ 1.5"/)
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
;===============================================================
;===============================================================
  resT                                  = True         ; modify the panel plot
  resT@gsnDraw                          = True      ; don't draw yet
  resT@gsnFrame                         = False        ; don't advance frame yet
  resT@gsnPanelLabelBar                 = True        ; add common colorbar
  resT@gsnPanelYWhiteSpacePercent       = 1.0    ; default is 1.0
  resT@gsnPanelXWhiteSpacePercent       = 1.0    ; default is 1.0
  resT@gsnPanelTop                      = 0.74
  resT@gsnPanelBottom                   = 0.44
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
 ; resT@lbTitleString                    = "Diabatic heating rate (K/day)" 
  resT@lbTitleString                    = "Precipitation (mm/month)"
  resT@gsnPanelFigureStrings            = (/"g","h","i","j","k","l"/) ; add strings to panel
;  resT@gsnPanelFigureStrings            = (/"m","n","o","p","q","r"/) ; add strings to panel
  resT@amJust                           = "TopLeft"
  resT@gsnPanelFigureStringsFontHeightF =  0.012
  resT@gsnPanelFigureStringsFont        =  "Helvetica-Bold"

  resT@txFont                           = "helvetica-bold"

  ;resT@txString                        = "SST trends: 1984-2008"
  ;resT@txString                        = "JAS SST trends: 1979-2018"
;**************************************************************
  gsn_panel(wks,plot(12:),(/2,3/),resT)     ; now draw as one plot
;===============================================================
;===============================================================
;===============================================================
;===============================================================
frame(wks)
end
