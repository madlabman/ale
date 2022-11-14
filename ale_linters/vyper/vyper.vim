" Author: madlabman
" Description: Report vyper compiler errors in Vyper code

call ale#Set('vyper_executable', 'vyper')
call ale#Set('vyper_options', '-o /dev/null')

function! ale_linters#vyper#vyper#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " vyper.exceptions.SyntaxException: invalid syntax (<unknown>, line 27)
    "   line 27:20
    let l:pattern = '\vvyper\.exceptions\.(\w+): (.*)$'
    let l:line_and_column_pattern = '\vline (\d+):(\d+)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            let l:match = matchlist(l:line, l:line_and_column_pattern)

            if len(l:match) > 0
                let l:index = len(l:output) - 1
                let l:output[l:index]['lnum'] = l:match[1] + 0
                let l:output[l:index]['col'] = l:match[2] + 0
            endif
        else
            call add(l:output, {
            \   'lnum': 0,
            \   'col': 0,
            \   'text': l:match[2],
            \   'type': 'E'
            \})
        endif
    endfor

    return l:output
endfunction

function! ale_linters#vyper#vyper#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'vyper_executable')

    return l:executable . ale#Pad(ale#Var(a:buffer, 'vyper_options')) . ' /dev/stdin'
endfunction

call ale#linter#Define('vyper', {
\   'name': 'vyper',
\   'executable': {b -> ale#Var(b, 'vyper_executable')},
\   'command': function('ale_linters#vyper#vyper#GetCommand'),
\   'callback': 'ale_linters#vyper#vyper#Handle',
\   'output_stream': 'stderr',
\})
