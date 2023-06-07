syntax on 
set number
set noswapfile
set hlsearch
set ignorecase
set incsearch
set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
:augroup END

inoremap <special> jk <ESC>:w<CR>
noremap <silent> <C-S>          :update<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>i
