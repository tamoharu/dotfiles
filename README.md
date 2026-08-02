# terminal dotfiles

Ghostty + Herdr + Neovim の個人開発環境です。

## 対応環境

- macOS (Apple Silicon / Intel)
- Homebrew は未導入でもインストーラーが導入します

## セットアップ

```sh
git clone https://github.com/tamoharu/dotfiles.git ~/ghq/github.com/tamoharu/dotfiles
cd ~/ghq/github.com/tamoharu/dotfiles
./install.sh
```

既存の `~/.config/{ghostty,herdr,nvim}` は削除せず、日時付きの
`*.backup.YYYYMMDDhhmmss` に移動してからリンクします。何度実行しても、
すでに正しいリンクになっている設定は変更しません。

パッケージを入れず設定だけ切り替える場合:

```sh
./install.sh --links-only
```

設定を切り替えずパッケージだけ入れる場合:

```sh
./install.sh --packages-only
```

## 含まれるもの

- Ghostty のテーマ、フォント、Herdr 向けキーバインド
- Herdr のワークスペース、ペイン移動、Neovim 連携
- Neovim の Lua 設定と `lazy.nvim` lockfile
- 再現に必要な Homebrew パッケージとフォント (`Brewfile`)

Neovim のプラグインは初回起動時に `lazy.nvim` が lockfile のバージョンで
導入します。LSP・formatter・linter は Mason が自動導入します。

