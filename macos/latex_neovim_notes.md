Reference vim-lsp textlab configuration (lualatex):

```
 let g:lsp_settings['texlab'] = {
     \     'workspace_config': { 'texlab': {
     \       'build': {
     \           'executable': 'latexmk',
     \           'args': [
     \               '-pdf',
     \               '-pdflatex=lualatex',
     \               '-synctex=1',
     \           ],
     \           'onSave': v:true
     \       },
     \       'forwardSearch': {
     \           'executable': '/Applications/Skim.app/Contents/SharedSupport/displayline',
     \           'args': ['%l', '%p', '%f']
     \       },
     \   }}
     \ }
```

---

1. **MacTex.** https://www.tug.org/mactex/

2. **PDF viewer.** Skim is great, use skim:

   - https://skim-app.sourceforge.io/

3. **neovim-remote** `pip install neovim-remote`

4. **Configuring forward search.**

   - See above

5. **Configuring reverse search.**

   - Open Skim, top bar: Skim > Preferences > Sync
     - Preset: Custom
     - Command: /Users/brentyi/miniconda3/bin/nvr
     - Arguments: --remote-silent +"%line" "%file"

6. **Launching.**

   - Need to use neovim-remote: `nvr main.tex`

7. **Bindings.**

   - Build: `:LspDocumentBuild`
      - Our binding: `<Leader>lb` ("Latex Build")
      - (this will also happen automatically on save)
   - Forward search: `:LspDocumentForwardSearch` `<Leader>lfs`
      - Our binding: `<Leader>lfs` ("Latex Forward Search")
   - Inverse search (Skim): `Command-Shift-Click`
