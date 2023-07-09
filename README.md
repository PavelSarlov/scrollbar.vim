# scrollbar.vim

A not that good vim port of [nvim-scrollbar](https://github.com/petertriho/nvim-scrollbar)

---

## Demo

![](./demo.mkv)

---

## Usage

As simple as just installing the plugin with your favourite plugin manager and using the following commands
to use its features:

```
:ScrollbarEnableAll
:ScrollbarDisableAll
```

`:help scrollbar` for more info.

## Customization

If you want to auto-enable features on startup or change some highlighting, you can use the provided global variables.
Here is a short summary with their default values:

```
let g:scrollbar_enabled = 0
let g:scrollbar_signs_enabled = g:scrollbar_enabled
let g:scrollbar_cursor_enabled = g:scrollbar_enabled

let g:scrollbar_term_color = "DarkBlue"
let g:scrollbar_gui_color = "#8AADF4"
let g:scrollbar_cursor_term_color = "White"
let g:scrollbar_cursor_gui_color = "#FFFFFF"
```
