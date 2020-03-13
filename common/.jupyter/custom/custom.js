// Configure CodeMirror Keymap
require(
    [
      'nbextensions/vim_binding/vim_binding', // depends your installation
    ],
    function() {
      // <Esc> mappings
      CodeMirror.Vim.map("[[", "<Esc>", "insert");
      CodeMirror.Vim.map(";;", "<Esc>", "insert");

      // Hacky relative line numbering callback
      function showRelativeLines(cm) {
        const lineNum = cm.getCursor().line + 1;
        if (cm.state.curLineNum === lineNum) {
          return;
        }
        cm.state.curLineNum = lineNum;
        cm.setOption('lineNumberFormatter',
                     l => l === lineNum ? lineNum : Math.abs(lineNum - l));
      }

      // Casually make some changes to some global object prototypes :) :)
      NodeList.prototype.forEach = Array.prototype.forEach;

      // Some more hacky stuff :) :) :) :) :)
      setInterval(() => {
        document.querySelectorAll('.CodeMirror').forEach((obj) => {
          editor = obj.CodeMirror;
          editor.off('cursorActivity', showRelativeLines)
          editor.on('cursorActivity', showRelativeLines)
        });
      }, 1000);
    });
