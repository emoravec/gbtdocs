; docformat = 'rst' 

;+
; This procedure smooths a spectrum with a hanning filter.
;
; Replaces the contents of the data being smoothed with the
; smoothed data.  Blanked data values are ignored.
;
; For spectrum data containers, the frequency_resolution is set 
; using :idl:pro:`esthanres`. 
;
; :Keywords:
;   buffer : in, optional, type=integer, default=0
;       global buffer number to use (0-15).
;   decimate : in, optional, type=boolean
;       If set, decimates by 2.
;   ok : out, optional, type=boolean
;       Returns 1 if everything went ok, 0 if it did not
;       (invalid or empty buffer)
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       getrec,1
;       show
;       hanning
;       show
;
; :Uses:
;   :idl:pro:`gconvol`
;   :idl:pro:`decimate`
;
;-
pro hanning, buffer=buffer, decimate=decimate, ok=ok
    compile_opt idl2

    if n_elements(buffer) eq 0 then buffer=0

    ; don't update until done
    lastFrozen = !g.frozen
    if not !g.frozen then !g.frozen=1

    ; the hanning smoothing kernel
    kernel = [0.25, 0.5, 0.25]

    gconvol, kernel, buffer=buffer, ok=ok, /nan, /edge_truncate, /normalize

    if not ok then begin
        !g.frozen = lastFrozen
        return
    endif

    if !g.line then begin
        chanRes = !g.s[buffer].frequency_resolution / abs(!g.s[buffer].frequency_interval)
        chanRes = esthanres(chanRes)
        !g.s[buffer].frequency_resolution = chanRes * abs(!g.s[buffer].frequency_interval)
    endif

    if keyword_set(decimate) then decimate, 2

    ; restore frozen state
    !g.frozen = lastFrozen

    if not !g.frozen and buffer eq 0 then show
end
