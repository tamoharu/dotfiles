# terminal dotfiles

Ghostty + Herdr + Neovim + Codex の個人開発環境です。

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

Codex は `~/.codex/config.toml` のみを同様にリンクします。認証情報や
セッションなど、`~/.codex` 内のほかのファイルは管理対象にしません。

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
- Codex のモデル、TUI キーマップ、承認・権限設定
- 再現に必要な Homebrew パッケージとフォント (`Brewfile`)

Neovim のプラグインは初回起動時に `lazy.nvim` が lockfile のバージョンで
導入します。LSP・formatter・linter は Mason が自動導入します。
