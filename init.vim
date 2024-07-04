" Leader
noremap <Space> <Nop>
let mapleader = " "

" Options
set clipboard+=unnamed
set scrolloff=10
set incsearch
set hlsearch
set number
set relativenumber
set ignorecase
set smartcase

" Better behaviors
noremap <C-d> <C-d>zz
noremap <C-u> <C-u>zz
noremap n nzz
noremap N Nzz
nnoremap Y y$
nnoremap J Jh
nnoremap x "_x
nnoremap s "_s
nnoremap c "_c
nnoremap C "_C
xnoremap p "_dP
xnoremap c "_c
xnoremap < <gv
xnoremap > >gv

" Better shortcuts
noremap <C-j> <C-e>
noremap <C-k> <C-y>
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>
nnoremap gl $
xnoremap gl $
onoremap gl $
nnoremap gh ^
xnoremap gh ^
onoremap gh ^
noremap + <C-a>
noremap - <C-x>
nnoremap U <C-r>
noremap Q @q
noremap [[ [{
noremap ]] ]}

" Misc
nmap <Leader>ns :nohlsearch<CR>

" Break old habits / unwanted shortcuts
map <Up> <Nop>
map <Down> <Nop>
map <Left> <Nop>
map <Right> <Nop>
imap <C-n> <Nop>
imap <C-p> <Nop>
map <C-n> <Nop>

" Edit config 
map <Leader>ev :e ~\AppData\Local\nvim\init.vim<CR>
map <Leader>sv :source ~\AppData\Local\nvim\init.vim<CR>
