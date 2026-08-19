# Ubuntu + US keyboard profile

Ubuntu 24.04 / GNOME 46 / Wayland とUS配列キーボード向けの、明示的に導入する
デスクトッププロファイルです。リポジトリ直下の通常の `install.sh` からは読み込まれず、
macOS用Ghostty設定や共通dotfilesには影響しません。

## キーの役割

| 物理キー | 動作 |
| --- | --- |
| Left Alt | 英語入力（Mozc `Muhenkan` / IME off） |
| Right Alt / AltGr | 日本語入力（Mozc `Henkan` / IME on） |
| Start / Windows | macOSのCommand相当（GNOME/Ghosttyでは `Super`） |
| Ctrl | macOSのControl相当。端末のCtrlキーとして維持 |
| Start+Tab | アプリケーション切り替え |
| Start+\` | Ghosttyでは次のHerdr Space、その他のアプリではアプリ内ウィンドウ切り替え |
| Start+Shift+\` | Ghosttyでは前のHerdr Space、その他のアプリでは逆方向のウィンドウ切り替え |
| Start+Enter | Codexへ送信（Ctrl+EnterのCSI-uシーケンス） |
| CapsLock+Space | GNOMEのアプリ検索を開く |
| CapsLock単押し | 検索／Overview表示中だけ閉じる。通常時は何もしない |

GhosttyではStartキーをmacOS風のCommandショートカットに使い、物理Ctrlは
`Ctrl+C`、`Ctrl+D`、`Ctrl+Z`などの端末制御用に残します。修飾キーそのものを
一括変換せず、必要なGhosttyバインドだけを明示しています。

## 対象と依存関係

次の構成で検証しています。

- Ubuntu 24.04、GNOME Shell 46、Wayland
- US ANSIキーボード
- IBus + Mozc
- Input Remapper 2.0.1
- Ghostty 1.3.1
- Herdr 0.7.5

必要なパッケージを先に導入します。

```sh
sudo apt-get update
sudo apt-get install -y ibus-mozc input-remapper jq mozc-utils-gui
sudo systemctl enable --now input-remapper-daemon.service
```

## インストール

Input Remapperが認識しているキーボード名を確認します。既にremapを実行中の場合は、
GUIに表示されるデバイス名を使用してください。

```sh
input-remapper-control --list-devices
```

このPCの場合:

```sh
./profiles/ubuntu-us/install.sh --keyboard 'Chicony USB Keyboard'
```

`INPUT_REMAPPER_DEVICE`環境変数でも指定できます。

```sh
INPUT_REMAPPER_DEVICE='Chicony USB Keyboard' \
  ./profiles/ubuntu-us/install.sh
```

インストーラーは対象ファイルをdotfilesへのシンボリックリンクにします。既存ファイルが
ある場合は削除せず、同じ場所へ `.backup.YYYYMMDDhhmmss` を付けて退避します。
Input Remapperの `config.json` とGNOMEのショートカット配列は全置換しません。
既存項目を維持しながら、競合するSuperキーだけを外し、必要な項目を追加します。
`overlay-key`とUbuntu Dockの数字キー起動は、このプロファイルのStartキーを
Commandとして使うため明示的に無効化します。

例外として、GNOMEの入力ソースはMozcだけに設定します。`Muhenkan` / `Henkan` は
Mozcがアクティブな時だけIME off/onとして解釈されるため、Right Altで常に日本語へ
切り替えるにはMozcを唯一の入力ソースにする必要があります。ほかの言語の入力ソースを
併用する構成には、このプロファイルをそのまま適用しないでください。

完了後に一度ログアウト／ログインしてください。これにより新しいGNOME Shell拡張と
Mozc設定が確実に読み込まれます。Ghosttyも全ウィンドウを閉じて起動し直してください。

## Mozcのカスタムキー

バイナリのMozc設定DBや入力履歴はGitへ保存しません。初回だけ次を実行します。

```sh
/usr/lib/mozc/mozc_tool --mode=config_dialog
```

「一般」→「キー設定」→「キー設定の選択」をCustomにし、「編集」から
[`mozc/keymap-additions.tsv`](mozc/keymap-additions.tsv) の12行を追加します。
各状態で `Muhenkan` が `IMEOff`、`Henkan` が `IMEOn` になれば完了です。

物理配列もOS全体でUSへ揃える場合は、必要に応じて次を実行します。

```sh
sudo localectl set-x11-keymap us pc105
```

## 検証

```sh
./profiles/ubuntu-us/check.sh --keyboard 'Chicony USB Keyboard'
```

GNOME Shell拡張を初めて配置した直後は、ログアウト前の検証で「未ロード」と表示される
ことがあります。

## Gitに含めない状態

次のファイルは個人状態や生成物のため、このプロファイルには含めません。

- Mozcの `*.db`、履歴、暗号鍵、IPCファイル
- IBusのbus/sessionファイル
- dconfデータベース全体
- Input Remapperの生成済み `xmodmap.json`
- Input Remapperのデバイス固有 `config.json`
