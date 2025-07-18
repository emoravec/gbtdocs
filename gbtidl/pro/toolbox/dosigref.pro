; docformat = 'rst'

;+
; Combine signal and reference data containers.
;
; The result is :math:`((dcsig-dcref)/dcref) * dcref.tsys`, where
; :math:`dcsig` and :math:`dcref` are the data values in the signal
; and reference data containers, respectively.
; The tsys in the result, dcresult.tsys, is equal to dcref.tsys.  
; 
; The exposure time of the result is :math:`t_{res} = t_{sig} * t_{ref} * smoothref / (t_{sig}+t_{ref} * smoothref)`,
; where :math:`t_{sig}` and :math:`t_{ref}` are the exposures of
; the signal and reference data container and where smoothref=1 in
; when smoothref has not been supplied.  That is the effective integration
; time appropriate for use in the radiometer equation.  Note that in
; the two limits of smoothref (1=no smoothing and large smoothing), if
; :math:`t_{sig} = t_{ref}` then :math:`exposure = 1/2 * t_{sig}` or 
; :math:`exposure = t_{sig}`.  With no smothing, the noise increases due 
; to the subtraction of an equally noisy reference spectrum.  With 
; smoothing, the noise is as it would be for just the signal spectrum.
; Smoothing should be done with caution, though, because it can emphasize
; systematic glitches present in both signal and reference spectra that
; are not fully subtracted as a consequence of the smoothing.  
; All of the other header values are copied from dcsig.
;
; If smoothref is set, the dcref values are smoothed using the IDL
; smooth function.  This does a simple boxcar smooth where the smoothref
; parameter is the width of the boxcar. smoothref is only used if it
; is larger than 1.  In certain cases this can improve the signal to
; noise ratio, but it may degrade baseline shapes and artificially
; emphasize spectrometer glitches.  Use with care.  A value of
; smoothref=16 is often a good choice 
;
; The dcresult data container is created as necessary.  If it
; already exists, the internal pointer will be reused.  It is the
; responsibility of the calling procedure or functiosdn to free that
; pointer using data_free.  Failure to do that will result in a memory
; leak.
; 
; :Params:
;   dcresult : out, required, type=data_container
;       The result.
;   dcsig : in, required, type=data_container
;       The signal data container.
;   dcref : in, required, type=data_container
;       The reference data container.
;   smoothref : in, optional, type=integer
;       Boxcar smooth width for reference spectrum. No smoothing if
;       not supplied or if value is less than or equal to 1.
; 
;-
pro dosigref,dcresult,dcsig,dcref,smoothref
    compile_opt idl2

    ok = dcpaircheck(dcsig,dcref)
    if not ok then return

    ; copy the headers from dcresult
    data_copy,dcsig,dcresult
   
    refdata = *dcref.data_ptr
    nsmooth = 1
    if n_elements(smoothref) gt 0 then begin
        if smoothref gt 1 then begin
            refdata = smooth(refdata,smoothref,/nan,/edge_truncate)
            nsmooth = smoothref
        endif 
    endif
    *dcresult.data_ptr = ((*dcsig.data_ptr - refdata)/refdata) * dcref.tsys
    dcresult.tsys = dcref.tsys
    dcresult.exposure = dcsig.exposure*dcref.exposure*nsmooth/(dcsig.exposure+dcref.exposure*nsmooth)
end
