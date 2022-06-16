function txtToArr
; Select a text file and open for reading
  file = DIALOG_PICKFILE(FILTER='*.txt')
  OPENR, lun, file, /GET_LUN
  ; Read one line at a time, saving the result into array
  array = ''
  line = ''
  WHILE NOT EOF(lun) DO BEGIN & $
    READF, lun, line & $
    array = [array, line] & $
  ENDWHILE
  ; Close the file and free the file unit
  FREE_LUN, lun
  return,array
end
