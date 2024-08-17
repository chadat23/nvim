-- init.lua
--
-- -- At the beginning of init.lua
local filetypes = {
    longform = {
        "markdown",
        "text",
        -- Add more file extensions as needed
    }
}

-- Base configuration (common to all file types)
-- [Your existing basic configurations go here]
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

-- See `:help vim.opt`
-- See `:help option-list`
vim.opt.number = true
vim.opt.relativenumber = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8
vim.opt.autoread = true

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Some key bindings are just anoying
vim.keymap.set('n', '.', '<cmd>echo ". are so dumb"<CR>')
vim.keymap.set('n', '<C-z>', '<cmd>echo "<C-z> are so dumb"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Coding-specific configuration
local function setup_coding_config()
    -- [Your existing coding-specific configurations go here]

    -- Enable break indent
    vim.opt.breakindent = true
end

function StopSpeakFile()
    if _G.speak_job_id then
        vim.fn.jobstop(_G.speak_job_id)
        _G.speak_job_id = nil
    else
        print("No TTS process running.")
    end
end

-- Long-form writing configuration
local function setup_longform_config()
    -- Configurations for long-form writing
    vim.opt.wrap = true
    vim.opt.linebreak = true
    vim.opt.spell = true
    vim.opt.spelllang = "en_us"
    vim.opt.textwidth = 80
    vim.opt.columns = 80

    -- Get the path of the current file (i.e., init.lua)
    local init_path = debug.getinfo(1, 'S').source:sub(2)
    local init_dir = vim.fn.fnamemodify(init_path, ':p:h')

    -- Add more long-form writing specific settings here
    -- In Visual mode, read the selected text
    --vim.keymap.set('v', '<F1>', ':w !espeak -s 150 &<cr>')
    vim.keymap.set('v', '<F1>', function()
        -- Get the visually selected text
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local lines = vim.fn.getline(start_pos[2], end_pos[2])

        -- If the selection spans multiple lines, extract the selected portion
        if #lines > 0 then
            lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
            lines[1] = string.sub(lines[1], start_pos[3])
        end

        -- Write the selected text to a temporary file
        vim.fn.writefile(lines, '/tmp/nvim_selected.txt')

        -- Use espeak to read the text
        vim.fn.system('espeak -s 150 -f /tmp/nvim_selected.txt &')
    end)

    -- In Normal mode play the current line
    vim.keymap.set('n', '<F1>', function()
        vim.cmd('normal! vipy')
        local paragraph = vim.fn.getreg('"')
        --[[paragraph = paragraph
            :gsub('\\', '\\\\')  -- Escape backslashes
            :gsub('"', '\\"')    -- Escape double quotes
            :gsub("'", "\\'")    -- Escape single quotes
            :gsub("\n", "\\n")   -- Escape newlines
            :gsub("\r", "\\r")   -- Escape carriage returns
            :gsub("\t", "\\t")   -- Escape tabs
            :gsub("\v", "\\v")   -- Escape vertical tabs
            :gsub("\f", "\\f")   -- Escape form feeds
            :gsub("\b", "\\b")   -- Escape backspaces
            :gsub("\a", "\\a")   -- Escape bell/alert (if applicable)
            :gsub("\0", "\\0")   -- Escape null characters]]
        vim.fn.system({init_dir .. "/fetch.py", paragraph})
        _G.speak_job_id = vim.fn.jobstart("ffplay -nodisp -autoexit -af 'atempo=2' /tmp/sound.mp3")
    end)
    -- Play from the current line to the end of file.
    vim.keymap.set('n', '<F11>', ':.,$w !setsid -f espeak -s 150 -D<cr><cr>')
    -- In insert mode, use ctrl-enter to read the newly inserted line.
    vim.keymap.set('i', '<C-CR>', '<Esc>:.w !setsid -f espeak<CR>o')
    -- Stop playing
    vim.api.nvim_set_keymap('n', '<F12>', ':lua StopSpeakFile()<cr>', { noremap = true, silent = true })

end

-- Apply the appropriate configuration based on file type
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = "*",
    callback = function()
        local ft = vim.bo.filetype
        if vim.tbl_contains(filetypes.longform, ft) then
            setup_longform_config()
        else
            setup_coding_config()
        end
    end
})

-- Keybindings for long-form mode
vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes.longform,
    callback = function()
        vim.keymap.set('n', '<leader>o', ':Goyo<CR>', {buffer = true})
        vim.keymap.set('n', '<leader>l', ':Limelight!!<CR>', {buffer = true})
    end
})

-- [Your existing lazy.nvim setup code]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
local plugins = {
    -- [Your existing plugins]
{ "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for install instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      require('telescope').setup {
        -- :help telescope.setup()
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
        file_ignore_patterns = { "node%_modules/.*" },
      }

      -- Enable telescope extensions, if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- Also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').register {
        { "<leader>c", group = "[C]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>r", group = "[R]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>s", group = "[S]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>w", group = "[W]orkspace" },
        { "<leader>w_", hidden = true },
      }
    end,
  },
  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false }
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      statusline.setup()

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  -- Add plugins specific to long-form writing
  {
    "preservim/vim-pencil",
    ft = filetypes.longform,
    config = function()
      vim.cmd[[
        let g:pencil#wrapModeDefault = 'soft'
        augroup pencil
          autocmd!
          autocmd FileType markdown,text call pencil#init()
        augroup END
      ]]
    end
  },
  {
    "junegunn/goyo.vim",
    ft = filetypes.longform,
  },
  --{
    --"junegunn/limelight.vim",
    --ft = filetypes.longform,
  --},
}

local opts = {}

require("lazy").setup(plugins, opts)

local config = require("nvim-treesitter.configs")
config.setup({
    ensure_installed = {"rust", "lua", "vim", "vimdoc", "query", "javascript", "html" },
    highlight = { enable = true },
    indent = { enable = true },
    ignore_install = { "javascript" },
})

-- https://github.com/bluz71/vim-moonfly-colors
vim.cmd [[colorscheme moonfly]]
