" Bootstrap Plug
let autoload_plug_path = stdpath('data') . '/site/autoload/plug.vim'
if !filereadable(autoload_plug_path)
  silent execute '!curl -fLo ' . autoload_plug_path . '  --create-dirs 
      \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
unlet autoload_plug_path

" LOAD PLUGINS
call plug#begin()
" statusline
Plug 'itchyny/lightline.vim'
" VSCode plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" snippets
Plug 'honza/vim-snippets'
" coc extensions
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-highlight', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-snippets', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-html', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-css', {'do': 'yarn install --frozen-lockfile'}
" Plug 'neoclide/coc-prettier', {'do': 'yarn install --frozen-lockfile'}
Plug 'coc-extensions/coc-svelte', {'do': 'yarn install --frozen-lockfile'}
" indent indicator line
Plug 'Yggdroot/indentLine'
" general syntax highlighintg
Plug 'sheerun/vim-polyglot'
" commenting
Plug 'tpope/vim-commentary'
" folding
Plug 'pseewald/vim-anyfold'
" sudo
Plug 'lambdalisue/suda.vim'
" directory tree
Plug 'justinmk/vim-dirvish'
" git general integration
Plug 'tpope/vim-fugitive'
" git indicators in gutter
Plug 'airblade/vim-gitgutter'
" color scheme
Plug 'lifepillar/vim-gruvbox8'
" Plug 'arcticicestudio/nord-vim'
" git hunks in lightline
Plug 'sinetoami/lightline-hunks'
" buffer cycling and list
Plug 'mihaifm/bufstop'
" fzflukelbd/vim-scrollwrapped
Plug 'junegunn/fzf.vim'
" common *nix actions
Plug 'tpope/vim-eunuch'
" indicate cursor jump
" Plug 'danilamihailov/beacon.nvim'

call plug#end()

" leader key
let mapleader=" "

" bufstop
let g:BufstopSpeedKeys = ["<F1>", "<F2>", "<F3>", "<F4>", "<F5>", "<F6>"]
let g:BufstopLeader = ""
let g:BufstopAutoSpeedToggle = 1
nnoremap <silent><nowait><leader><leader> :BufstopModeFast<cr>2
nnoremap <silent><nowait><leader>b :BufstopFast<cr>

" disbable default mode indicator
set noshowmode

" enable mouse integration
set mouse=a

" set split directions
set splitbelow
set splitright

" auto equal splits on resize
autocmd VimResized * wincmd =

" floating window transparency
set winblend=25

" resize splits
nnoremap <silent><C-A-j> :resize +2<cr>
nnoremap <silent><C-A-k> :resize -2<cr>
nnoremap <silent><C-A-l> :vertical resize +1<cr>
nnoremap <silent><C-A-h> :vertical resize -1<cr>

" quicker split switching
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-l> <C-W><C-L>
nnoremap <C-h> <C-W><C-H>

" creating splits
nnoremap <silent><leader>s :split<cr>
nnoremap <silent><leader>vs :vsplit<cr>

" close window
nnoremap <C-q> :q<CR>

" lightline setup
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             ['lightline_hunks', 'readonly', 'relativepath', 'modified' ] ],
      \ 'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'filetype' ] ]
      \ },
      \ 'component_function': {
      \  'lightline_hunks': 'lightline#hunks#composer',
      \ }
      \ }
let g:lightline.colorscheme = 'seoul256'
" let g:lightline.colorscheme = 'nord'

" jump between git hunks
nmap <Leader>gn <Plug>GitGutterNextHunk
nmap <Leader>gp <Plug>GitGutterPrevHunk

" git status shortcut
nnoremap <silent><nowait><leader>g :Gstatus<cr>

" set default encoding
set encoding=utf-8

" folding
filetype plugin indent on
autocmd Filetype * AnyFoldActivate
let g:anyfold_fold_comments=1
set foldlevel=99
hi Folded gui=NONE term=NONE cterm=NONE

" hidden bufers
set hidden

" no search highlight
set nohlsearch

" higlight line under cursor
"set cursorline

" colors
set termguicolors
set background=dark
colorscheme gruvbox8
" colorscheme orbital
" colorscheme nord
syntax on
let g:gitgutter_override_sign_column_highlight = 1

" update gitgutter regurarly
autocmd BufWritePost,WinEnter * GitGutter

" always show signcolumn
set signcolumn=yes:2

" hide empty line indicator
set fcs=eob:\ 

" line numbers
set number
set relativenumber

" command line completion
set wildmenu
set wildmode=longest:list,full

" tabs and spaces
set tabstop=4 shiftwidth=4 expandtab
autocmd FileType graphql setlocal shiftwidth=4 softtabstop=4 expandtab

" dispay special chars
"set listchars=eol:⦙,tab:»\ 
set listchars=eol:¶,tab:»\ 
set list

" terminal buffer settings
au TermOpen * setlocal nonumber norelativenumber signcolumn=no

" unfocus terminal
tnoremap <C-w> <C-\><C-n>

" Some servers have issues with backup files
set nobackup
set nowritebackup

" disable swp-ing
set noswapfile

" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=100

" No 'Press Enter to continue'
set shortmess+=c

" merge clipboard registers
" set clipboard=unnamedplus

" sudo
let g:suda_smart_edit = 1

" file exploring
let loaded_netrw = 0

" indent plugin
let g:indentLine_color_gui = '#3c3836'
let g:indentLine_char = '▏'

" fzf 
nnoremap <silent><tab> :GFiles --exclude-standard --others --cached<cr>
nnoremap <silent><s-tab> :Files<cr>
nnoremap <silent><nowait><leader>e :Rg<cr>
let g:fzf_layout = { 'window': 'call FloatingWindoww()' }

function! FloatingWindoww()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let height = &lines - 6
  let width = float2nr(&columns - (&columns * 2 / 9))
  let col = float2nr((&columns - width) / 2)

  let opts = {
        \ 'relative': 'editor',
        \ 'row': 2,
        \ 'col': col,
        \ 'width': width,
        \ 'height': height
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" coc reformatting bindings
nmap <leader>f  <Plug>(coc-format-selected)
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>F  <Plug>(coc-format)
xmap <leader>F  <Plug>(coc-format)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Filetypes
au FileType markdown set syntax=off
au FileType markdown.mdx set syntax=off

" beacon
" let g:beacon_shrink = 0
" let g:beacon_fade = 0
" let g:beacon_size = 1
" let g:beacon_timeout = 200
" let g:beacon_minimal_jump = 10
" nmap n n:Beacon<cr>
" nmap N N:Beacon<cr>
" nmap * *:Beacon<cr>
" nmap # #:Beacon<cr>
