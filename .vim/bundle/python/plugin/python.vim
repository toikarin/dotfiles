if !has("python")
   finish
endif

python << EOF
import vim

def set_breakpoint(after=False):
    import re
    nLine = int( vim.eval( 'line(".")'))

    strLine = vim.current.line
    strWhite = re.search( '^(\s*)', strLine).group(1)

    if not after:
       nLine -= 1

    vim.current.buffer.append(
       "%(space)simport ipdb; ipdb.set_trace() %(mark)s Breakpoint %(mark)s" %
         {'space':strWhite, 'mark': '#' * 30}, nLine)

def remove_breakpoints():
    import re

    nCurrentLine = int( vim.eval( 'line(".")'))

    nLines = []
    nLine = 1
    for strLine in vim.current.buffer:
        if strLine == "import ipdb" or strLine.lstrip()[:16] == "ipdb.set_trace()" or strLine.lstrip()[:29] == "import ipdb; ipdb.set_trace()":
            nLines.append( nLine)
        nLine += 1

    nLines.reverse()

    for nLine in nLines:
        vim.command( "normal %dG" % nLine)
        vim.command( "normal dd")
        if nLine < nCurrentLine:
            nCurrentLine -= 1

    vim.command( "normal %dG" % nCurrentLine)

def EvaluateCurrentRange():
    eval(compile('\n'.join(vim.current.range),'','exec'),globals())

EOF
