-- 1. CLIPBOARD SETUP
-- Yanks go to the system clipboard (and so into Pano); deletes stay inside nvim,
-- so dd/p, ddp, diw/p work like normal Vim without flooding Pano's history.
-- Ubuntu (X11) needs xclip for this: sudo apt install xclip

-- Define the clipboard provider specifically for WSL
if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "win32yank-wsl",
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = 0,
    }
end

-- The last system clipboard content nvim has seen or written, so a pull only
-- happens when something new was copied outside nvim.
local last_clip = nil

-- Yank (y, yy, yiw, ...) into the unnamed register also copies it to the system clipboard.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("srindot_clipboard_yank", { clear = true }),
    callback = function()
        local ev = vim.v.event
        if ev.operator ~= "y" or ev.regname ~= "" then
            return
        end
        vim.fn.setreg("+", ev.regcontents, ev.regtype)
        last_clip = vim.fn.getreg("+")
    end,
})

-- Auto sync: when nvim starts or regains focus, text newly copied elsewhere
-- (browser, Pano, another nvim) becomes what p pastes.
local function pull_system_clipboard()
    local ok, clip = pcall(vim.fn.getreg, "+")
    if not ok or clip == "" or clip == last_clip then
        return
    end
    last_clip = clip
    vim.fn.setreg('"', clip, vim.fn.getregtype("+"))
end

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
    group = vim.api.nvim_create_augroup("srindot_clipboard_sync", { clear = true }),
    callback = pull_system_clipboard,
})

-- 2. KEYMAPS
-- d, c, x behave like normal Vim: they fill nvim's register (so p pastes them)
-- but never reach the system clipboard.

-- "System Cut": Leader + x (and xx) cuts to the system clipboard (and Pano)
vim.keymap.set({ "n", "v" }, "<leader>x", '"+d', { desc = "Cut to system clipboard" })
vim.keymap.set("n", "<leader>xx", '"+dd', { desc = "Cut line to system clipboard" })

-- "Greatest Paste": Paste over a selection without losing your original copy
-- Perfect for replacing "BS" code blocks over and over
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste and keep original clipboard" })
