# ============================================
# PowerShell Profile
# ============================================


# ============================================
# Oh My Posh
# ============================================

$originalErrorAction = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init powershell --config "$HOME\.config\ohmyposh\custom.omp.json" | Invoke-Expression
}

$ErrorActionPreference = $originalErrorAction


# ============================================
# Fastfetch
# ============================================

if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch
}


# ============================================
# Zoxide
# ============================================

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}


# ============================================
# PSReadLine - Autocomplete & History
# ============================================

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    # Windows-style editing
    Set-PSReadLineOption -EditMode Windows

    # Tab completion menu
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Search command history with Up/Down
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}


# ============================================
# Eza - Modern ls
# ============================================

if (Get-Command eza -ErrorAction SilentlyContinue) {

    # ls
    function ls {
        eza --icons --git @args
    }

    # ll - detailed listing
    function ll {
        eza -lah --icons --git @args
    }

    # la - show hidden files
    function la {
        eza -a --icons --git @args
    }

    # lt - tree view
    function lt {
        eza --tree --icons --git @args
    }
}


# ============================================
# Sudo
# ============================================

if (Get-Command gsudo -ErrorAction SilentlyContinue) {
    Set-Alias sudo gsudo
}


# ============================================
# Fetchpaper
# ============================================

function fetchpaper {
    & "$HOME\Scripts\fetchpaper.ps1" @args
}