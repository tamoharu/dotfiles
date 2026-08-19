# dotfiles

macOS と Ubuntu の開発環境を、一つのリポジトリから再現するためのdotfilesです。

## 対応環境

- macOS（Apple Silicon / Intel）
- Ubuntu Linux（x86_64 / arm64、SSH先を含む）

## セットアップ

```sh
sudo apt-get update && sudo apt-get install -y git # Ubuntuのみ
mkdir -p ~/ghq/github.com/tamoharu
git clone https://github.com/tamoharu/dotfiles.git ~/ghq/github.com/tamoharu/dotfiles
cd ~/ghq/github.com/tamoharu/dotfiles
./install.sh
```

完了後はシェルを開き直します。

```sh
exec zsh
```

SSH先では、CodexとGitHub CLIをそれぞれ認証します。

```sh
codex login --device-auth
gh auth login
```

パッケージを入れず、設定リンクだけ作成する場合:

```sh
./install.sh --links-only
```

設定を変更せず、パッケージだけ導入する場合:

```sh
./install.sh --packages-only
```

既存の設定は削除せず、`*.backup.YYYYMMDDhhmmss` に移動してからリンクします。
同じリンクに対して再実行しても変更しません。

## 含まれる環境

- zsh、fzf、direnv、nvm/Node.js
- Neovim、Yazi、btop、ripgrep、fd
- Git、GitHub CLI、ghq、Lazygit、Hunk
- Codex CLI、OpenCode、Herdr
- Ghostty、Hammerspoon、Karabiner、Espanso（macOS）
- Tokyo Night系のターミナル・TUIテーマ

UbuntuではNeovim、Yaziなど、ディストリビューション標準版が古くなりやすい
ツールをリリースバイナリから固定バージョンで導入します。macOSではBrewfileを
使用します。

## 設定の扱い

設定ディレクトリは原則として `~/.config` へリンクします。例外として、Codexは
認証情報やセッションを巻き込まないよう `~/.codex/config.toml` だけをリンクします。

認証情報、履歴、ログ、実行時状態はGitの追跡対象にしません。マシン固有の値は
次のファイルへ記述します。

```sh
cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh
```

`local.zsh` はgitignoreされています。

## オプションのデスクトッププロファイル

Ubuntu GNOMEとUSキーボードでmacOS風の修飾キー・IME・Ghostty操作を使う場合は、
通常の設定と分離された [`profiles/ubuntu-us`](profiles/ubuntu-us/README.md) を
明示的に導入します。

## SSHでの利用

```sh
ssh queen
herdr
```

SSH先でもHerdrでワークスペースとペインを管理できます。画像プレビューの可否は
接続元ターミナルにも依存します。
