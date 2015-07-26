if !exists(':SpeedDatingFormat')
    finish
endif

" Remove roman numerals.
silent! SpeedDatingFormat! %v
silent! SpeedDatingFormat! %^v

" Add german date formats.
silent! SpeedDatingFormat %d.%m.%Y
silent! SpeedDatingFormat %d.%m.%Y%[ T_-]%H:%M
silent! SpeedDatingFormat %d. %B %Y
silent! SpeedDatingFormat %H:%M
